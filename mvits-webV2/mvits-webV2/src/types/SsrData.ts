import type { Product } from "./Product";
import type { Blogpost } from "./Blogpost";
import type { Reference } from "./Reference";

/** Daten der Startseite (vom SSR-Renderer vorab geladen). */
export interface SsrHomeData {
  offerings: Product[];
  blogposts: Blogpost[];
  references: Reference[];
}

/**
 * Vom SSR-Renderer erzeugter Daten-Kontext. Wird serverseitig über den
 * `SSRDataProvider` injiziert und clientseitig als `window.__SSR_DATA__`
 * im HTML hinterlegt, damit Komponenten ohne Doppel-Fetch initial rendern.
 */
export interface SsrData {
  /** Route der Erzeugung (z.B. "/product/3") – Client prüft gegen aktuellen Pfad. */
  path: string;
  home?: SsrHomeData;
  product?: Product;
  blogpost?: Blogpost;
  reference?: Reference;
}

export const SSR_DATA_KEY = "__SSR_DATA__" as const;
