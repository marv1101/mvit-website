import { createContext, useContext } from "react";
import { useLocation } from "react-router-dom";
import type { SsrData } from "../types/SsrData";
import { SSR_DATA_KEY } from "../types/SsrData";

/**
 * Serverseitig vom SSR-Renderer bereitgestellte Routen-Daten; clientseitig
 * wird auf `window.__SSR_DATA__` (SSR-Injection) zurückgegriffen.
 */
const SSRDataContext = createContext<SsrData | null>(null);

export const SSRDataProvider = SSRDataContext.Provider;

function windowData(): SsrData | null {
  if (typeof window === "undefined") return null;
  return (window as unknown as Record<typeof SSR_DATA_KEY, SsrData | undefined>)[SSR_DATA_KEY] ?? null;
}

/** Rohdaten aus Server-Context oder SSR-Injection. */
export function useSSRData(): SsrData | null {
  const ctx = useContext(SSRDataContext);
  if (ctx) return ctx;
  return windowData();
}

/**
 * SSR-Daten, wenn ihr `path` zur aktuellen Route passt. Verhindert, dass
 * beim SPA-Navigieren Daten einer fremden Route (stale `window.__SSR_DATA__`)
 * angezeigt werden – bei Mismatch `null`, Komponenten laden selbst nach.
 */
export function useRouteSSRData(): SsrData | null {
  const { pathname } = useLocation();
  const data = useSSRData();
  return data && data.path === pathname ? data : null;
}
