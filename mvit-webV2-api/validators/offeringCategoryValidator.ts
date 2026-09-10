export function validateCategoryRequest(data: {
    name?: unknown;
    description?: unknown;
}): { name: string; description: string | null } | null {
    if (typeof data.name !== "string" || data.name.trim().length === 0) {
        return null;
    }

    if (data.name.length > 255) return null;

    return {
        name: data.name.trim(),
        description: typeof data.description === "string" ? data.description.trim() : null,
    };
}
