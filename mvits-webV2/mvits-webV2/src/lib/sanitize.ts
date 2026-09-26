import DOMPurify from "dompurify";

/**
 * HTML-Sanitize, der im Browser (dompurify) und unter SSR läuft.
 *
 * Der SSR-Renderer installiert beim Start eine Server-Implementierung
 * (isomorphic-dompurify) als `globalThis.__mvitSsrPurify`; die
 * Browser-Instanz des dompurify-Pakets funktioniert ohne DOM nicht.
 */
const g = globalThis as typeof globalThis & { __mvitSsrPurify?: (html: string) => string };

export function sanitizeHtml(html: string): string {
  if (g.__mvitSsrPurify) {
    return g.__mvitSsrPurify(html);
  }
  if (typeof window === "undefined") {
    // SSR ohne Server-Sanitizer: kein HTML ausgeben, um XSS zu vermeiden.
    return "";
  }
  return DOMPurify.sanitize(html);
}
