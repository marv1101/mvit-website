import { serve } from "bun";
import index from "./index.html";

const port = process.env.PORT ? parseInt(process.env.PORT) : 3000;
const siteUrl = process.env.BUN_PUBLIC_SITE_URL ?? "https://mphion.de";

const robotsTxt = [
  "User-agent: *",
  "Allow: /",
  "Disallow: /admin",
  "",
  `Sitemap: ${siteUrl}/sitemap.xml`,
  "",
].join("\n");

const sitemapXml = [
  '<?xml version="1.0" encoding="UTF-8"?>',
  '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">',
  ...["/", "/impressum", "/datenschutz"].map(
    (path) => `  <url><loc>${siteUrl}${path}</loc></url>`,
  ),
  "</urlset>",
].join("\n") + "\n";

// Statische Response-Routen mit lazy Bun.file-Body werden in Bun 1.4 nicht als
// Route registriert (fielen auf den SPA-Fallback durch), daher die Icons
// einmalig vollständig in den Speicher laden.
const iconResp = async (file: string) =>
  new Response(new Uint8Array(await Bun.file(`./src/res/icons/${file}`).bytes()), {
    headers: { "Content-Type": "image/png" },
  });

const server = serve({
  port,
  routes: {
    // SEO-Dateien
    "/robots.txt": new Response(robotsTxt, {
      headers: { "Content-Type": "text/plain; charset=utf-8" },
    }),
    "/sitemap.xml": new Response(sitemapXml, {
      headers: { "Content-Type": "application/xml; charset=utf-8" },
    }),

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
