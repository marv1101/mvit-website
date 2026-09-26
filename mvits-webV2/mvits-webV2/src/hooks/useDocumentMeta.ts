import { useEffect } from "react";
import { useLocation } from "react-router-dom";
import { CONFIG } from "../utils/ConfigLoader";

const SITE_URL = CONFIG.SITE_URL;
const SITE_NAME = CONFIG.SITE_NAME;

interface DocumentMetaOptions {
  title: string;
  description: string;
  /** Pfad relativ zur Site, z.B. "/blog/42". Standard = aktueller Router-Pfad. */
  path?: string;
  /** canonical der mitgelieferten Route kann bewusst weggelassen werden */
  noindex?: boolean;
  type?: "website" | "article";
  imageUrl?: string;
  publishedTime?: string;
}

function upsertMeta(selector: string, create: () => HTMLMetaElement, values: { attr: string; value: string }[]) {
  let el = document.head.querySelector<HTMLMetaElement>(selector);
  if (!el) {
    el = create();
    document.head.appendChild(el);
  }
  for (const { attr, value } of values) {
    el.setAttribute(attr, value);
  }
}

function upsertJsonLd(id: string, data: object | null) {
  const existing = document.getElementById(id);
  if (existing) existing.remove();
  if (!data) return;
  const script = document.createElement("script");
  script.type = "application/ld+json";
  script.id = id;
  script.textContent = JSON.stringify(data);
  document.head.appendChild(script);
}

export function useDocumentMeta({
  title,
  description,
  path,
  noindex,
  type = "website",
  imageUrl,
  publishedTime,
}: DocumentMetaOptions) {
  const location = useLocation();
  const routePath = path ?? location.pathname;

  useEffect(() => {
    const canonicalUrl = `${SITE_URL}${routePath}`;
    document.title = title;

    upsertMeta(
      'meta[name="description"]',
      () => {
        const m = document.createElement("meta");
        m.name = "description";
        return m;
      },
      [{ attr: "content", value: description }],
    );

    upsertMeta(
      'meta[name="robots"]',
      () => {
        const m = document.createElement("meta");
        m.name = "robots";
        return m;
      },
      noindex ? [{ attr: "content", value: "noindex, nofollow" }] : [],
    );

    upsertMeta(
      'meta[name="author"]',
      () => {
        const m = document.createElement("meta");
        m.name = "author";
        return m;
      },
      [{ attr: "content", value: "Marian Voigtländer" }],
    );

    let canonical = document.head.querySelector<HTMLLinkElement>('link[rel="canonical"]');
    if (!canonical) {
      canonical = document.createElement("link");
      canonical.rel = "canonical";
      document.head.appendChild(canonical);
    }
    canonical.href = canonicalUrl;

    const ogValues = [
      { attr: "content", property: "og:title", value: title },
      { attr: "content", property: "og:description", value: description },
      { attr: "content", property: "og:url", value: canonicalUrl },
      { attr: "content", property: "og:type", value: type === "article" ? "article" : "website" },
      { attr: "content", property: "og:site_name", value: SITE_NAME },
      { attr: "content", property: "og:locale", value: "de_DE" },
    ];
    if (imageUrl) {
      ogValues.push({ attr: "content", property: "og:image", value: imageUrl });
    }
    if (publishedTime) {
      ogValues.push({ attr: "content", property: "article:published_time", value: publishedTime });
    }
    if (type === "article") {
      ogValues.push({ attr: "content", property: "article:author", value: "Marian Voigtländer" });
    }

    for (const v of ogValues) {
      upsertMeta(
        `meta[property="${v.property}"]`,
        () => {
          const m = document.createElement("meta");
          m.setAttribute("property", v.property);
          return m;
        },
        [{ attr: "content", value: v.value }],
      );
    }

    upsertMeta(
      'meta[name="twitter:card"]',
      () => {
        const m = document.createElement("meta");
        m.name = "twitter:card";
        return m;
      },
      [{ attr: "content", value: imageUrl ? "summary_large_image" : "summary" }],
    );

    const twitterValues = [
      { attr: "content", property: "twitter:title", value: title },
      { attr: "content", property: "twitter:description", value: description },
      { attr: "content", property: "twitter:url", value: canonicalUrl },
    ];
    if (imageUrl) {
      twitterValues.push({ attr: "content", property: "twitter:image", value: imageUrl });
    }
    for (const v of twitterValues) {
      upsertMeta(
        `meta[property="${v.property}"]`,
        () => {
          const m = document.createElement("meta");
          m.setAttribute("property", v.property);
          return m;
        },
        [{ attr: "content", value: v.value }],
      );
    }

    window.scrollTo({ top: 0 });
  }, [title, description, routePath, noindex, type, imageUrl, publishedTime]);
}

export function useJsonLd(id: string, data: object | null) {
  useEffect(() => {
    upsertJsonLd(id, data);
    return () => upsertJsonLd(id, null);
  }, [id, data ? JSON.stringify(data) : null]);
}

export { SITE_URL, SITE_NAME };
