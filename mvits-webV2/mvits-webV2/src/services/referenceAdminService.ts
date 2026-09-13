import { CONFIG } from "../utils/ConfigLoader";

export type ReferenceFormData = {
    id?: number;
    company: string;
    company_url: string;
    logo_url: string;
    summary: string;
    story: string;
};

async function fetchWithAuth(path: string, init?: RequestInit): Promise<Response> {
    return fetch(`${CONFIG.API_BASE_URL}${path}`, {
        credentials: "include",
        headers: { "Content-Type": "application/json" },
        ...init,
    });
}

export async function getAllReferences(): Promise<ReferenceFormData[]> {
    const res = await fetchWithAuth("/references?limit=100");
    if (!res.ok) throw new Error("Failed to fetch references");
    const data = await res.json();
    return data.map((r: any) => ({
        id: parseInt(r.id),
        company: r.company,
        company_url: r.company_url || "",
        logo_url: r.logo_url || "",
        summary: r.summary,
        story: r.story,
    }));
}

export async function getReferenceById(id: number): Promise<ReferenceFormData> {
    const res = await fetchWithAuth(`/references/${id}`);
    if (!res.ok) throw new Error("Failed to fetch reference");
    const r = await res.json();
    return {
        id: parseInt(r.id),
        company: r.company,
        company_url: r.company_url || "",
        logo_url: r.logo_url || "",
        summary: r.summary,
        story: r.story,
    };
}

export async function createReference(data: Omit<ReferenceFormData, "id">): Promise<ReferenceFormData> {
    const res = await fetchWithAuth("/references", {
        method: "POST",
        body: JSON.stringify(data),
    });
    if (!res.ok) throw new Error("Failed to create reference");
    return res.json();
}

export async function updateReference(id: number, data: Omit<ReferenceFormData, "id">): Promise<ReferenceFormData> {
    const res = await fetchWithAuth(`/references/${id}`, {
        method: "PUT",
        body: JSON.stringify(data),
    });
    if (!res.ok) throw new Error("Failed to update reference");
    return res.json();
}

export async function deleteReference(id: number): Promise<void> {
    const res = await fetchWithAuth(`/references/${id}`, {
        method: "DELETE",
    });
    if (!res.ok) throw new Error("Failed to delete reference");
}
