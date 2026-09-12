import { CONFIG } from "../utils/ConfigLoader";

export type ContactStatus = "open" | "handled";

export type ContactRequest = {
    id: number;
    name: string;
    email: string;
    subject: string;
    message: string;
    createdAt: string;
    status: ContactStatus;
};

async function fetchWithAuth(path: string, init?: RequestInit): Promise<Response> {
    return fetch(`${CONFIG.API_BASE_URL}${path}`, {
        credentials: "include",
        headers: { "Content-Type": "application/json" },
        ...init,
    });
}

function normalizeContact(c: any): ContactRequest {
    return {
        id: c.id,
        name: c.name,
        email: c.email,
        subject: c.subject,
        message: c.message,
        createdAt: c.createdAt,
        status: c.status === "handled" ? "handled" : "open",
    };
}

export async function fetchAllContactRequests(): Promise<ContactRequest[]> {
    const res = await fetchWithAuth("/contacts");
    if (!res.ok) throw new Error("Failed to fetch contact requests");
    const data = await res.json();
    return data.map(normalizeContact);
}

export async function updateContactStatus(id: number, status: ContactStatus): Promise<ContactRequest> {
    const res = await fetchWithAuth(`/contacts/${id}`, {
        method: "PATCH",
        body: JSON.stringify({ status }),
    });
    if (!res.ok) throw new Error("Failed to update contact status");
    return normalizeContact(await res.json());
}
