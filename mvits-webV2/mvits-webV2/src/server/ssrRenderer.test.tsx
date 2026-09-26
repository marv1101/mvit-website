import { expect, test } from "bun:test";
import { renderAppHtml } from "./ssrRenderer";
import { sanitizeHtml } from "../lib/sanitize";
import type { SsrData } from "../types/SsrData";

test("rendert die Startseite serverseitig (ohne DOM/Window)", async () => {
  const html = await renderAppHtml("/", { path: "/" });
  // Hero-Überschrift und Abschnitts-Struktur sind im serverseitig gerenderten Markup:
  expect(html).toContain("MVIT");
  expect(html).toContain("Unsere Leistungen");
  expect(html).toContain("<h1");
});

test("rendert Produktseite mit SSR-Daten inkl. geskrienem Cleanup-HTML", async () => {
  const data: SsrData = {
    path: "/product/1",
    product: {
      id: "1",
      name: "PlanBar",
      description: "Intelligente Dienstplanung.",
      description_page: '<p>Schichtplan <strong>mit KI</strong><noscript><img src=x onerror=alert(1)></noscript></p>',
      features: [],
      price: "",
      category: "Software",
      icon: "CalendarDays",
    },
  };
  const html = await renderAppHtml("/product/1", data);
  expect(html).toContain("PlanBar");
  expect(html).toContain("Schichtplan");
  // onerror-Angriff durch sanitizeHtml entfernt:
  expect(html).not.toContain("onerror");
});

test("sanitizeHtml: Purifier nutzen; ohne Purifier leeres HTML", () => {
  const g = globalThis as typeof globalThis & { __mvitSsrPurify?: (html: string) => string };
  const original = g.__mvitSsrPurify;

  g.__mvitSsrPurify = undefined;
  expect(sanitizeHtml("<p>ok</p>")).toBe("");

  g.__mvitSsrPurify = (html) => html.replace(/<script>[\s\S]*?<\/script>/g, "");
  expect(sanitizeHtml("<script>bad()</script><p>ok</p>")).toBe("<p>ok</p>");

  g.__mvitSsrPurify = original;
});
