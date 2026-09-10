import { CONFIG } from "../utils/ConfigLoader";

export type OfferingFormData = {
    id?: number;
    title: string;
    description: string;
    description_page: string;
    icon: string;
    category: number;
    features: string[];
    price: number;
};

export type OfferingCategory = {
    id: number;
    name: string;
    description: string | null;
};

async function fetchWithAuth(path: string, init?: RequestInit): Promise<Response> {
    return fetch(`${CONFIG.API_BASE_URL}${path}`, {
        credentials: "include",
        headers: { "Content-Type": "application/json" },
        ...init,
    });
}

export async function getAllOfferings(): Promise<OfferingFormData[]> {
    const res = await fetchWithAuth("/offerings?limit=100");
    if (!res.ok) throw new Error("Failed to fetch offerings");
    const data = await res.json();
    return data.map((o: any) => ({
        id: parseInt(o.id),
        title: o.name,
        description: o.description,
        description_page: o.description_page || "",
        icon: o.icon,
        category: o.category_id ? parseInt(o.category_id) : 0,
        features: o.features || [],
        price: parseInt(o.price),
    }));
}

export async function getOfferingById(id: number): Promise<OfferingFormData> {
    const res = await fetchWithAuth(`/offerings/${id}`);
    if (!res.ok) throw new Error("Failed to fetch offering");
    const o = await res.json();
    return {
        id: parseInt(o.id),
        title: o.name,
        description: o.description,
        description_page: o.description_page || "",
        icon: o.icon,
        category: o.category_id ? parseInt(o.category_id) : 0,
        features: o.features || [],
        price: parseInt(o.price),
    };
}

export async function createOffering(data: Omit<OfferingFormData, "id">): Promise<OfferingFormData> {
    const res = await fetchWithAuth("/offerings", {
        method: "POST",
        body: JSON.stringify(data),
    });
    if (!res.ok) throw new Error("Failed to create offering");
    return res.json();
}

export async function updateOffering(id: number, data: Omit<OfferingFormData, "id">): Promise<OfferingFormData> {
    const res = await fetchWithAuth(`/offerings/${id}`, {
        method: "PUT",
        body: JSON.stringify(data),
    });
    if (!res.ok) throw new Error("Failed to update offering");
    return res.json();
}

export async function deleteOffering(id: number): Promise<void> {
    const res = await fetchWithAuth(`/offerings/${id}`, {
        method: "DELETE",
    });
    if (!res.ok) throw new Error("Failed to delete offering");
}

export async function getAllCategories(): Promise<OfferingCategory[]> {
    const res = await fetchWithAuth("/offering-categories");
    if (!res.ok) throw new Error("Failed to fetch categories");
    return res.json();
}

export async function createCategory(data: { name: string; description: string }): Promise<OfferingCategory> {
    const res = await fetchWithAuth("/offering-categories", {
        method: "POST",
        body: JSON.stringify(data),
    });
    if (!res.ok) throw new Error("Failed to create category");
    return res.json();
}

export async function updateCategory(id: number, data: { name: string; description: string }): Promise<OfferingCategory> {
    const res = await fetchWithAuth(`/offering-categories/${id}`, {
        method: "PUT",
        body: JSON.stringify(data),
    });
    if (!res.ok) throw new Error("Failed to update category");
    return res.json();
}

export async function deleteCategory(id: number): Promise<void> {
    const res = await fetchWithAuth(`/offering-categories/${id}`, {
        method: "DELETE",
    });
    if (!res.ok) throw new Error("Failed to delete category");
}
