import { SSR_DATA_KEY } from "../types/SsrData";
import { buildMetaTags, deriveMeta, stripSeoTags } from "./ssrMeta";
import { renderAppHtml } from "./ssrRenderer";
import { resolveSsrData } from "./ssrData";

const port = process.env.PORT ? parseInt(process.env.PORT) : 3000;

/**
 * App-Shell HTML (das Bun-HTML-Bundle) einmalig von der eigenen Route
 * `/index.html` laden – sie wird vom Catch-All (`/*`: HTML-Bundle) als
 * fertiges, URL-rewritetes Dokument serviert.
 */
let shellPromise: Promise<string> | null = null;

export function getShellHtml(): Promise<string> {
  if (!shellPromise) {
    shellPromise = fetch(`http://127.0.0.1:${port}/index.html`)
      .then((res) => {
        if (!res.ok) throw new Error(`Shell-Fetch fehlgeschlagen: HTTP ${res.status}`);
        return res.text();
      })
      .catch((err) => {
        shellPromise = null;
        throw err;
      });
  }
  return shellPromise;
}

/**
 * Baut ein SSR-Dokument für eine public Route: App-Shell + serverseitig
 * gerenderter Inhalt + injizierte SSR-Daten + SEO-Metatags.
 * Liefert `null`, wenn das Dokument nicht erzeugt werden kann (CSR-Fallback).
 */
export async function buildSsrDocument(pathname: string): Promise<string | null> {
  try {
    const shell = await getShellHtml();
    const data = await resolveSsrData(pathname);
    const ssrHtml = await renderAppHtml(pathname, data);

    const dataScript = `<script>window.${SSR_DATA_KEY}=${JSON.stringify(data).replaceAll("<", "\\u003c")};</script>`;
    const rootMarker = '<div id="root"></div>';
    const rootReplaced = shell.replace(
      rootMarker,
      `<div id="root">${ssrHtml}</div>\n    ${dataScript}`,
    );
    if (rootReplaced === shell) {
      console.error(`SSR: Root-Marker in Shell nicht gefunden (${pathname})`);
      return null;
    }

    const metaTags = buildMetaTags(deriveMeta(pathname, data));
    return stripSeoTags(rootReplaced).replace("</head>", `${metaTags}\n  </head>`);
  } catch (err) {
    console.error(`SSR-Dokument fehlgeschlagen: ${pathname}`, err);
    return null;
  }
}
