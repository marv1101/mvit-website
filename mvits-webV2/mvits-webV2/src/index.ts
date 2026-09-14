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
