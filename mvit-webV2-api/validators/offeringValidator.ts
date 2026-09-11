import { offeringObject } from "../models/offering.js";

export function validateOfferingRequest(data: {
    title?: unknown;
    description?: unknown;
    description_page?: unknown;
    icon?: unknown;
    category?: unknown;
    features?: unknown;
    price?: unknown;
}): offeringObject | null {
    if (
        typeof data.title !== "string" || data.title.trim().length === 0 ||
        typeof data.description !== "string" || data.description.trim().length === 0 ||
        typeof data.icon !== "string" || data.icon.trim().length === 0 ||
        typeof data.category !== "number" ||
        typeof data.price !== "number"
    ) {
        return null;
    }

    if (data.title.length > 255) return null;
    if (data.description.length > 1024) return null;
    if (data.description_page !== undefined && data.description_page !== null && typeof data.description_page !== "string") return null;
    if (data.features !== undefined && !Array.isArray(data.features)) return null;

    return {
        id: 0,
        title: data.title.trim(),
        description: data.description.trim(),
        description_page: typeof data.description_page === "string" ? data.description_page : null,
        icon: data.icon.trim(),
        features: Array.isArray(data.features) ? data.features.filter((f): f is string => typeof f === "string") : null,
        category: data.category,
        price: data.price,
    };
}
