import { serve } from "bun";
import index from "./index.html";
import { buildSitemap } from "./server/sitemap";
import { buildSsrDocument, getShellHtml } from "./server/ssrPage";

const port = process.env.PORT ? parseInt(process.env.PORT) : 3000;
const siteUrl = process.env.BUN_PUBLIC_SITE_URL ?? "https://mphion.de";

const HTML_HEADERS = { "Content-Type": "text/html; charset=utf-8" };

const robotsTxt = [
  "User-agent: *",
  "Allow: /",
  "",
  "# Nicht öffentlich sichtbare Bereiche",
  "Disallow: /admin",
  "Disallow: /api",
  "",
  `Sitemap: ${siteUrl}/sitemap.xml`,
  "",
].join("\n");

// Statische Response-Routen mit lazy Bun.file-Body werden in Bun 1.4 nicht als
// Route registriert (fielen auf den SPA-Fallback durch), daher die Icons
// einmalig vollständig in den Speicher laden.
const iconResp = async (file: string) =>
  new Response(new Uint8Array(await Bun.file(`./src/res/icons/${file}`).bytes()), {
    headers: { "Content-Type": "image/png" },
  });

// SSR für public/crawlable Routen (impressum/datenschutz ohne Daten-Abruf).
const ssrRoute = async (req: Request): Promise<Response> => {
  const pathname = new URL(req.url).pathname;
  try {
    const html = await buildSsrDocument(pathname);
    return new Response(html ?? (await getShellHtml()), { headers: HTML_HEADERS });
  } catch {
    try {
      // CSR-Fallback: unbearbeitetes App-Shell ausliefern
      return new Response(await getShellHtml(), { headers: HTML_HEADERS });
    } catch {
      return new Response("Dienst vorübergehend nicht verfügbar", {
        status: 503,
        headers: { "Content-Type": "text/plain; charset=utf-8" },
      });
    }
  }
};

const server = serve({
  port,
  routes: {
    // SEO-Dateien (dynamisch generiert)
    "/robots.txt": () =>
      new Response(robotsTxt, {
        headers: { "Content-Type": "text/plain; charset=utf-8" },
      }),
    "/sitemap.xml": () =>
      buildSitemap(siteUrl).then((xml) =>
        new Response(xml, {
          headers: { "Content-Type": "application/xml; charset=utf-8" },
        }),
      ),

    // SSR für crawlable Seiten
    "/": ssrRoute,
    "/product/:id": ssrRoute,
    "/blog/:id": ssrRoute,
    "/reference/:id": ssrRoute,
    "/impressum": ssrRoute,
    "/datenschutz": ssrRoute,

    // PWA-Icons (aus site.webmanifest referenziert → /icons/...)
    "/icons/icon-192x192.png": await iconResp("icon-192x192.png"),
    "/icons/icon-256x256.png": await iconResp("icon-256x256.png"),
    "/icons/icon-512x512.png": await iconResp("icon-512x512.png"),
    "/icons/icon-maskable-512x512.png": await iconResp("icon-maskable-512x512.png"),

    // Serve index.html for all unmatched routes.
    "/*": index,

    "/api/hello": {
      async GET(req) {
        return Response.json({
          message: "Hello, world!",
          method: "GET",
        });
      },
      async PUT(req) {
        return Response.json({
          message: "Hello, world!",
          method: "PUT",
        });
      },
    },

    "/api/hello/:name": async req => {
      const name = req.params.name;
      return Response.json({
        message: `Hello, ${name}!`,
      });
    },
  },

  development: process.env.NODE_ENV !== "production" && {
    // Enable browser hot reloading in development
    hmr: true,

    // Echo console logs from the browser to the server
    console: true,
  },
});

console.log(`🚀 Server running at ${server.url}`);
