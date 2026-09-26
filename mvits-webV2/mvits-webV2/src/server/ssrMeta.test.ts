import { describe, expect, test } from "bun:test";
import type { SsrData } from "../types/SsrData";
import { buildMetaTags, deriveMeta, stripSeoTags } from "./ssrMeta";

const SHELL = `<!doctype html>
<html lang="de">
  <head>
    <meta charset="UTF-8" />
    <meta name="robots" content="index, follow" />
    <link rel="icon" type="image/svg+xml" href="/x.svg" />
    <title>mvit Solutions</title>
    <meta name="description" content="Fallback" />
    <link rel="canonical" href="https://mphion.de/" />
    <meta property="og:title" content="Fallback" />
    <meta name="theme-color" content="#ffffff" media="(prefers-color-scheme: light)" />
    <script type="application/ld+json">{"@type":"Organization"}</script>
  </head>
  <body>
    <div id="root"></div>
  </body>
</html>
`;

describe("stripSeoTags", () => {
  test("entfernt Titel, SEO-Metas, Canonical und JSON-LD", () => {
    const stripped = stripSeoTags(SHELL);
    expect(stripped).not.toContain("<title>");
    expect(stripped).not.toContain('name="description"');
    expect(stripped).not.toContain('rel="canonical"');
    expect(stripped).not.toContain('property="og:title"');
    expect(stripped).not.toContain("application/ld+json");
    // Unberührte Tags bleiben erhalten:
    expect(stripped).toContain("<meta charset");
    expect(stripped).toContain('name="robots" content="index, follow"');
    expect(stripped).toContain('<link rel="icon"');
    expect(stripped).toContain("theme-color");
    expect(stripped).toContain('<div id="root"></div>');
  });
});

describe("buildMetaTags", () => {
  test("erzeugt vollständigen Meta-Block mit Canonical und OG", () => {
    const meta = buildMetaTags({
      title: "PlanBar | mvit Solutions",
      description: "Dienstplanung für Apotheken.",
      path: "/product/1",
    });
    expect(meta).toContain("<title>PlanBar | mvit Solutions</title>");
    expect(meta).toContain('name="description" content="Dienstplanung für Apotheken."');
    expect(meta).toContain('<link rel="canonical" href="https://mphion.de/product/1" />');
    expect(meta).toContain('property="og:title" content="PlanBar | mvit Solutions"');
    expect(meta).toContain('property="og:type" content="website"');
    expect(meta).toContain('name="twitter:card" content="summary"');
    expect(meta).not.toContain("og:image");
  });

  test("mit Bild & article: zusätzliche Tags", () => {
    const meta = buildMetaTags({
      title: "Titel",
      description: "Desc",
      path: "/blog/42",
      type: "article",
      imageUrl: "https://mphion.de/img.png",
      publishedTime: "2025-08-01T10:00:00.000Z",
    });
    expect(meta).toContain('name="twitter:card" content="summary_large_image"');
    expect(meta).toContain('property="og:image" content="https://mphion.de/img.png"');
    expect(meta).toContain('name="twitter:image" content="https://mphion.de/img.png"');
    expect(meta).toContain('property="article:published_time" content="2025-08-01T10:00:00.000Z"');
    expect(meta).toContain('property="article:author"');
  });

  test("escapet HTML-Sonderzeichen in Titeln", () => {
    const meta = buildMetaTags({
      title: 'Wurst & "<Käse>"',
      description: "d",
      path: "/x",
    });
    expect(meta).toContain("<title>Wurst &amp; &quot;&lt;Käse&gt;&quot;</title>");
  });

  test("JSON-LD Block mit geschützten '</script>' Sequenzen", () => {
    const meta = buildMetaTags({
      title: "t",
      description: "d",
      path: "/",
      jsonLd: { "@type": "Organization", name: "a<b" },
    });
    expect(meta).toContain('type="application/ld+json"');
    expect(meta).not.toContain("<b");
  });
});

describe("deriveMeta", () => {
  test("Startseite: Homepage-Metadaten + Organization JSON-LD", () => {
    const data: SsrData = { path: "/" };
    const meta = deriveMeta("/", data);
    expect(meta.title).toContain("mvit Solutions");
    expect(meta.path).toBe("/");
    expect((meta.jsonLd as Record<string, unknown>)["@type"]).toBe("Organization");
  });

  test("Produktseite nutzt Produktdaten", () => {
    const data: SsrData = { path: "/product/1", product: { id: "1", name: "PlanBar", description: "Dienstplanung." } as never };
    const meta = deriveMeta("/product/1", data);
    expect(meta.title).toBe("PlanBar | mvit Solutions");
    expect(meta.description).toBe("Dienstplanung.");
    expect(meta.path).toBe("/product/1");
  });

  test("Blogpost: article-Metadaten mit ISO-Zeitstempel", () => {
    const data: SsrData = {
      path: "/blog/5",
      blogpost: {
        nid: 5,
        vid: null,
        langcode: "de",
        content: "<p>Content</p>",
        summary: null,
        title: "Mein Beitrag",
        title_image_url: undefined,
        created: 1_700_000_000,
        changed: 1_700_000_000,
      },
    };
    const meta = deriveMeta("/blog/5", data);
    expect(meta.title).toBe("Mein Beitrag | mvit Solutions");
    expect(meta.type).toBe("article");
    expect(meta.publishedTime).toBe(new Date(1_700_000_000 * 1000).toISOString());
    expect((meta.jsonLd as Record<string, unknown>)["@type"]).toBe("BlogPosting");
  });

  test("Datenschutzseite", () => {
    const meta = deriveMeta("/datenschutz", { path: "/datenschutz" });
    expect(meta.title).toBe("Datenschutz | mvit Solutions");
  });
});
