import { createElement } from "react";
import { renderToReadableStream } from "react-dom/server";
import { StaticRouter } from "react-router-dom";
import App, { Main } from "../App";
import { SSRDataProvider } from "../lib/ssrData";
import type { SsrData } from "../types/SsrData";

// Server-Sanitizer bereitstellen (isomorphic-dompurify mit jsdom),
// damit die Seiten description_page/story/content über sanitizeHtml rendern.
const g = globalThis as typeof globalThis & { __mvitSsrPurify?: (html: string) => string };
let purifyPrepare: Promise<void> | null = null;

export function ensureSsrPurify(): Promise<void> {
  if (g.__mvitSsrPurify) return Promise.resolve();
  purifyPrepare = (async () => {
    try {
      const { default: purify } = await import("isomorphic-dompurify");
      g.__mvitSsrPurify = (html: string) => purify.sanitize(html);
    } catch (err) {
      console.error("isomorphic-dompurify nicht verfügbar – SSR rendert Cleanup-HTML leer", err);
    }
  })();
  return purifyPrepare;
}

/**
 * Rendert die App einer Route serverseitig zu HTML-String.
 * Wirft bei Render-Problemen – der Aufrufer fällt dann auf das CSR-Shell zurück.
 */
export async function renderAppHtml(pathname: string, data: SsrData): Promise<string> {
  await ensureSsrPurify();

  const stream = await renderToReadableStream(
    createElement(
      SSRDataProvider,
      { value: data },
      createElement(
        StaticRouter,
        { location: pathname },
        // App enthält selbst BrowserRouter (clientseitig); unter SSR rendern wir
        // das Routen-Layout Main direkt im StaticRouter.
        createElement(Main),
      ),
    ),
    {
      onError(error) {
        console.error(`SSR-Fehler für ${pathname}:`, error);
      },
    },
  );

  return new Response(stream).text();
}
