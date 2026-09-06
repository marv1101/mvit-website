// `process` existiert im Browser nicht nativ. Der Shim in `index.html`
// definiert es vor dem Modul-Start (für Vendor-Chunks). Diese Guards hier
// sichern zusätzlich ab, falls das Bundle ohne `index.html` läuft
// (z.B. `dist/`-Build). Die `process.env.BUN_PUBLIC_*`-Zugriffe bleiben
// bewusst statisch, damit Bun sie zur Serve-/Build-Zeit inlinen kann.
const g = globalThis as { process?: { env?: Record<string, string | undefined> } };
g.process = g.process ?? { env: {} };
g.process.env = g.process.env ?? {};

export const CONFIG = {
    API_BASE_URL: process.env.BUN_PUBLIC_API_BASE_URL ?? "https://mphion.de/api",
    DRUPAL_BASE_URL: process.env.BUN_PUBLIC_DRUPAL_BASE_URL ?? "https://mphion.de/drupal",
};