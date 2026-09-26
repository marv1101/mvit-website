import type { Blogpost } from "../types/Blogpost";
import type { Product } from "../types/Product";
import type { Reference } from "../types/Reference";
import { fetchApiJson } from "./api";

export interface SitemapEntry {
  loc: string;
  lastmod?: string;
}

function escapeXml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&apos;");
}

/** Baut die Sitemap-XML aus Einträgen (pur, für Tests). */
export function buildSitemapXml(entries: SitemapEntry[], siteUrl: string): string {
  const base = siteUrl.endsWith("/") ? siteUrl.slice(0, -1) : siteUrl;
  const urls = entries.map(
    (entry) =>
      `  <url><loc>${base}${escapeXml(entry.loc)}</loc>${
        entry.lastmod ? `<lastmod>${entry.lastmod}</lastmod>` : ""
      }</url>`,
  );
  return [
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">',
    ...urls,
    "</urlset>",
  ].join("\n") + "\n";
}

/**
 * Baut die dynamische Sitemap: static Routen + alle offerings/references/
 * blogposts aus der API. Fällt bei API-Fehlern auf die Statischen zurück.
 */
export async function buildSitemap(siteUrl: string, ttlMs = 15 * 60_000): Promise<string> {
  const [offerings, references, blogposts] = await Promise.all([
    fetchApiJson<Product[]>("/offerings/?limit=100", ttlMs),
    fetchApiJson<Reference[]>("/references/?limit=100", ttlMs),
    fetchApiJson<Blogpost[]>("/blogposts/?limit=100", ttlMs),
  ]);

  const entries: SitemapEntry[] = [
    { loc: "/" },
    { loc: "/impressum" },
    { loc: "/datenschutz" },
  ];
  for (const offering of offerings ?? []) {
    entries.push({ loc: `/product/${offering.id}` });
  }
  for (const reference of references ?? []) {
    entries.push({
      loc: `/reference/${reference.id}`,
      lastmod: reference.created_at ? new Date(reference.created_at).toISOString() : undefined,
    });
  }
  for (const post of blogposts ?? []) {
    entries.push({ loc: `/blog/${post.nid}`, lastmod: new Date(post.changed * 1000).toISOString() });
  }

  return buildSitemapXml(entries, siteUrl);
}
