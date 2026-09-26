import { describe, expect, test } from "bun:test";
import { buildSitemap, buildSitemapXml, type SitemapEntry } from "./sitemap";
import { clearApiCache } from "./api";

/** Installiert einen temporären fetch-Mock und liefert Restore zurück. */
function mockApi(respond: (path: string) => unknown, status = 200): () => void {
  const original = globalThis.fetch;
  globalThis.fetch = (async (input: string | URL | Request) => {
    const url =
      typeof input === "string" ? input : input instanceof Request ? input.url : String(input);
    const path = new URL(url).pathname + new URL(url).search;
    return new Response(JSON.stringify(respond(path)), {
      status,
      headers: { "content-type": "application/json" },
    });
  }) as typeof fetch;
  return () => {
    globalThis.fetch = original;
  };
}

describe("buildSitemapXml", () => {
  test("baut strukturierte XML mit Base-URL", () => {
    const entries: SitemapEntry[] = [
      { loc: "/" },
      { loc: "/impressum" },
      { loc: "/product/3", lastmod: "2025-08-01T10:00:00.000Z" },
    ];
    const xml = buildSitemapXml(entries, "https://mphion.de");

    expect(xml).toContain('<?xml version="1.0" encoding="UTF-8"?>');
    expect(xml).toContain('xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"');
    expect(xml).toContain("<loc>https://mphion.de/</loc>");
    expect(xml).toContain("<loc>https://mphion.de/impressum</loc>");
    expect(xml).toContain("<loc>https://mphion.de/product/3</loc>");
    expect(xml).toContain("<lastmod>2025-08-01T10:00:00.000Z</lastmod>");
    expect(xml.endsWith("</urlset>\n")).toBeTrue();
  });

  test("escapet Sonderzeichen in Pfaden", () => {
    const xml = buildSitemapXml([{ loc: "/x?a=1&b=2" }], "https://mphion.de");
    expect(xml).toContain("/x?a=1&amp;b=2");
  });

  test("hängt Base-URL nicht doppelt an", () => {
    const xml = buildSitemapXml([{ loc: "/a" }], "https://mphion.de/");
    expect(xml).toContain("<loc>https://mphion.de/a</loc>");
  });
});

describe("buildSitemap (API-Integration)", () => {
  test("ergänzt offerings, references und blogposts mit lastmod", async () => {
    clearApiCache();
    const restore = mockApi((path) => {
      if (path.startsWith("/api/offerings")) return [{ id: 7 }];
      if (path.startsWith("/api/references"))
        return [{ id: "2", company: "c", summary: "", story: "", created_at: "2025-08-02T12:00:00.000Z" }];
      if (path.startsWith("/api/blogposts")) return [{ nid: 42, changed: 1_700_000_000 }];
      return [];
    });

    try {
      const xml = await buildSitemap("https://mphion.de");
      expect(xml).toContain("<loc>https://mphion.de/product/7</loc>");
      expect(xml).toContain("<loc>https://mphion.de/reference/2</loc>");
      expect(xml).toContain("<lastmod>2025-08-02T12:00:00.000Z</lastmod>");
      expect(xml).toContain("<loc>https://mphion.de/blog/42</loc>");
      // changed = 1.7e9 Sekunden → ISO
      expect(xml).toContain(`<lastmod>${new Date(1_700_000_000 * 1000).toISOString()}</lastmod>`);
    } finally {
      restore();
      clearApiCache();
    }
  });

  test("fällt bei API-Fehlern auf statische Routen zurück", async () => {
    clearApiCache();
    const restore = mockApi(() => [], 500);

    try {
      const xml = await buildSitemap("https://mphion.de");
      expect(xml).toContain("<loc>https://mphion.de/</loc>");
      expect(xml).toContain("<loc>https://mphion.de/impressum</loc>");
      expect(xml).toContain("<loc>https://mphion.de/datenschutz</loc>");
      expect(xml).not.toContain("/product/");
    } finally {
      restore();
      clearApiCache();
    }
  });
});
