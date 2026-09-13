import DOMPurify from "isomorphic-dompurify";
import { referenceObject } from "../models/reference.js";

export function validateReferenceRequest(data: {
    company?: unknown;
    company_url?: unknown;
    logo_url?: unknown;
    summary?: unknown;
    story?: unknown;
}): referenceObject | null {
    if (
        typeof data.company !== "string" || data.company.trim().length === 0 ||
        typeof data.summary !== "string" || data.summary.trim().length === 0 ||
        typeof data.story !== "string" || data.story.trim().length === 0
    ) {
        return null;
    }

    if (data.company.length > 255) return null;
    if (data.summary.length > 1024) return null;
    if (data.story.length > 100_000) return null;
    if (data.company_url !== undefined && data.company_url !== null) {
        if (typeof data.company_url !== "string") return null;
        if (data.company_url.length > 2048) return null;
        if (!data.company_url.startsWith("http://") && !data.company_url.startsWith("https://")) return null;
    }
    if (data.logo_url !== undefined && data.logo_url !== null) {
        if (typeof data.logo_url !== "string") return null;
        if (data.logo_url.length > 2048) return null;
        if (!data.logo_url.startsWith("http://") && !data.logo_url.startsWith("https://")) return null;
    }

    return {
        id: 0,
        company: data.company.trim(),
        company_url: typeof data.company_url === "string" ? data.company_url.trim() : null,
        logo_url: typeof data.logo_url === "string" ? data.logo_url : null,
        summary: data.summary.trim(),
        story: DOMPurify.sanitize(data.story),
    };
}
