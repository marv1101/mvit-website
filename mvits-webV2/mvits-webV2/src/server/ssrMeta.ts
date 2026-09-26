import type { Blogpost } from "../types/Blogpost";
import type { Product } from "../types/Product";
import type { Reference } from "../types/Reference";
import type { SsrData } from "../types/SsrData";
import { CONFIG } from "../utils/ConfigLoader";

const SITE_NAME = CONFIG.SITE_NAME;

/** SEO-Attribute, die die SSR-Injection ersetzt (wie useDocumentMeta). */
const BLOCKED_META_NAMES = new Set([
  "description",
  "author",
  "og:title",
  "og:description",
  "og:url",
  "og:type",
  "og:site_name",
  "og:locale",
  "og:image",
  "article:published_time",
  "article:author",
  "twitter:card",
  "twitter:title",
  "twitter:description",
  "twitter:url",
  "twitter:image",
]);

function escapeAttr(value: string): string {
  return value.replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll('"', "&quot;");
}

/** Entfernt Titel/SEO-Metatags/Canonical/JSON-LD aus dem App-Shell (werden ersetzt). */
export function stripSeoTags(html: string): string {
  return html
    .replace(/<title[^>]*>[\s\S]*?<\/title>/i, "")
    .replace(/<script[^>]*type=["']application\/ld\+json["'][^>]*>[\s\S]*?<\/script>/gi, "")
    .replace(/<meta\s+[^>]*>/gi, (tag) => {
      const name = /(?:\bname|\bproperty)=["']([^"']+)["']/.exec(tag)?.[1]?.toLowerCase() ?? "";
      return BLOCKED_META_NAMES.has(name) ? "" : tag;
    })
    .replace(/<link\s+[^>]*>/gi, (tag) => (/rel=["']canonical["']/.test(tag) ? "" : tag));
}

export interface MetaInfo {
  title: string;
  description: string;
  /** Pfad relativ zur Site (z.B. "/product/3"). */
  path: string;
  type?: "website" | "article";
  imageUrl?: string;
  publishedTime?: string;
  jsonLd?: object;
}

/** Erzeugt den kompletten <head>-Injektionsblock (wie useDocumentMeta erzeugt). */
export function buildMetaTags(meta: MetaInfo): string {
  const canonical = `${CONFIG.SITE_URL}${meta.path}`;
  const type = meta.type === "article" ? "article" : "website";
  const lines = [
    `<title>${escapeAttr(meta.title)}</title>`,
    `<meta name="description" content="${escapeAttr(meta.description)}" />`,
    `<link rel="canonical" href="${escapeAttr(canonical)}" />`,
    `<meta property="og:title" content="${escapeAttr(meta.title)}" />`,
    `<meta property="og:description" content="${escapeAttr(meta.description)}" />`,
    `<meta property="og:url" content="${escapeAttr(canonical)}" />`,
    `<meta property="og:type" content="${type}" />`,
    `<meta property="og:site_name" content="${escapeAttr(SITE_NAME)}" />`,
    `<meta property="og:locale" content="de_DE" />`,
    `<meta name="twitter:card" content="${meta.imageUrl ? "summary_large_image" : "summary"}" />`,
    `<meta name="twitter:title" content="${escapeAttr(meta.title)}" />`,
    `<meta name="twitter:description" content="${escapeAttr(meta.description)}" />`,
    `<meta name="twitter:url" content="${escapeAttr(canonical)}" />`,
  ];
  if (meta.imageUrl) {
    lines.push(`<meta property="og:image" content="${escapeAttr(meta.imageUrl)}" />`);
    lines.push(`<meta name="twitter:image" content="${escapeAttr(meta.imageUrl)}" />`);
  }
  if (meta.publishedTime) {
    lines.push(`<meta property="article:published_time" content="${escapeAttr(meta.publishedTime)}" />`);
    lines.push(`<meta property="article:author" content="Marian Voigtländer" />`);
  }
  if (meta.jsonLd) {
    // "<" escapen, damit "</script>" im JSON den Block nicht vorzeitig beendet
    lines.push(
      `<script type="application/ld+json">${JSON.stringify(meta.jsonLd).replaceAll("<", "\\u003c")}</script>`,
    );
  }
  return lines.join("\n    ");
}

function blogDescription(post: Pick<Blogpost, "content">): string {
  return post.content
    ? post.content.replace(/<[^>]+>/g, " ").replace(/\s+/g, " ").trim().slice(0, 155)
    : "Blogbeitrag der mvit Solutions.";
}

/** Leitet die Meta-Daten aus der Route + SSR-Daten her (wie die Client-Hooks). */
export function deriveMeta(pathname: string, data: SsrData): MetaInfo {
  const FALLBACK_DESCRIPTION =
    "Lösung von mvit Solutions: individuelle IT-Dienstleistungen und Software zu fairen Konditionen.";

  if (pathname === "/" || data.home) {
    return {
      title: "mvit Solutions – IT-Dienstleistungen & individuelle Software",
      description:
        "mvit Solutions entwickelt individuelle Softwarelösungen von der KI-gestützten Dienstplanung über Cloud-Migration bis zur IT-Beratung zu fairen Preis-Leistungs-Konditionen.",
      path: "/",
      jsonLd: {
        "@context": "https://schema.org",
        "@type": "Organization",
        name: SITE_NAME,
        url: CONFIG.SITE_URL,
        logo: `${CONFIG.SITE_URL}/res/icons/icon-512x512.png`,
      },
    };
  }
  if (pathname === "/impressum") {
    return {
      title: `Impressum | ${SITE_NAME}`,
      description:
        "Impressum von mvit Solutions mit Angaben zu Anbieter, Kontakt und rechtlichen Rahmenbedingungen.",
      path: pathname,
    };
  }
  if (pathname === "/datenschutz") {
    return {
      title: `Datenschutz | ${SITE_NAME}`,
      description:
        "Informationen zum Datenschutz und zur Verarbeitung personenbezogener Daten bei mvit Solutions.",
      path: pathname,
    };
  }
  if (data.product) {
    const product: Product = data.product;
    return {
      title: product.name ? `${product.name} | ${SITE_NAME}` : `Produkt | ${SITE_NAME}`,
      description: product.description || FALLBACK_DESCRIPTION,
      path: pathname,
    };
  }
  if (data.blogpost) {
    const post: Blogpost = data.blogpost;
    return {
      title: `${post.title} | ${SITE_NAME}`,
      description: blogDescription(post),
      path: pathname,
      type: "article",
      imageUrl: post.title_image_url,
      publishedTime: new Date(post.created * 1000).toISOString(),
      jsonLd: {
        "@context": "https://schema.org",
        "@type": "BlogPosting",
        headline: post.title,
        image: post.title_image_url ? [post.title_image_url] : undefined,
        datePublished: new Date(post.created * 1000).toISOString(),
        dateModified:
          post.changed !== post.created ? new Date(post.changed * 1000).toISOString() : undefined,
        author: { "@type": "Organization", name: SITE_NAME, url: CONFIG.SITE_URL },
        publisher: { "@type": "Organization", name: SITE_NAME, url: CONFIG.SITE_URL },
        mainEntityOfPage: `${CONFIG.SITE_URL}/blog/${post.nid}`,
      },
    };
  }
  if (data.reference) {
    const reference: Reference = data.reference;
    return {
      title: `${reference.company} | ${SITE_NAME}`,
      description: reference.summary || "Referenz von mvit Solutions.",
      path: pathname,
    };
  }

  // Route ohne vollständige Daten (API-Fallback): neutral standardisieren
  return {
    title: SITE_NAME,
    description: FALLBACK_DESCRIPTION,
    path: pathname,
  };
}
