import { CONFIG } from "../utils/ConfigLoader";

// Server-seitige API-Basis für SSR und Sitemap: innerhalb des Container-Netzwerks
// (NODE_ENV=production) wird der API-Container direkt erreicht, sonst die
// öffentliche BUN_PUBLIC_API_BASE_URL.
const INTERNAL_API_BASE_URL =
  process.env.INTERNAL_API_BASE_URL ??
  (process.env.NODE_ENV === "production" ? "http://mvit-api:3000/api" : undefined);

function apiBase(): string {
  return INTERNAL_API_BASE_URL ?? CONFIG.API_BASE_URL;
}

interface CacheEntry {
  value: unknown;
  expires: number;
}

const cache = new Map<string, CacheEntry>();

/** Holt JSON von der API (mit TTL-Cache). Bei Fehlern `null` statt throw. */
export async function fetchApiJson<T>(path: string, ttlMs = 60_000): Promise<T | null> {
  const hit = cache.get(path);
  if (hit && hit.expires > Date.now()) return hit.value as T;

  try {
    const res = await fetch(`${apiBase()}${path}`, {
      headers: { accept: "application/json" },
      signal: AbortSignal.timeout(5_000),
    });
    if (!res.ok) throw new Error(`HTTP ${res.status} ${res.statusText}`);
    const value = (await res.json()) as T;
    cache.set(path, { value, expires: Date.now() + ttlMs });
    return value;
  } catch (err) {
    console.error(`API-Abruf fehlgeschlagen: ${apiBase()}${path}`, err);
    return null;
  }
}

/** Cache leeren (nur für Tests). */
export function clearApiCache(): void {
  cache.clear();
}
