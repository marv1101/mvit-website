import { CONFIG } from "../utils/ConfigLoader";
import { getToken } from "../services/authService";

export type visitStats = {
    total: number;
    today: number;
    thisWeek: number;
    thisMonth: number;
};

export type dailyVisit = {
    date: string;
    count: number;
};

export type pageCount = {
    path: string;
    count: number;
};

export type referrerCount = {
    referrer: string;
    count: number;
};

export type deviceCount = {
    deviceType: string;
    count: number;
};

async function fetchWithAuth(path: string): Promise<Response> {
    const token = getToken();
    const headers: Record<string, string> = { "Content-Type": "application/json" };
    if (token) {
        headers["Authorization"] = `Bearer ${token}`;
    }
    return fetch(`${CONFIG.API_BASE_URL}${path}`, { headers });
}

export async function getVisitStats(): Promise<visitStats> {
    const res = await fetchWithAuth("/visits/stats");
    if (!res.ok) throw new Error("Failed to fetch stats");
    return res.json();
}

export async function getDailyVisits(days: number = 30): Promise<dailyVisit[]> {
    const res = await fetchWithAuth(`/visits/daily?days=${days}`);
    if (!res.ok) throw new Error("Failed to fetch daily visits");
    return res.json();
}

export async function getTopPages(limit: number = 10): Promise<pageCount[]> {
    const res = await fetchWithAuth(`/visits/pages?limit=${limit}`);
    if (!res.ok) throw new Error("Failed to fetch top pages");
    return res.json();
}

export async function getTopReferrers(limit: number = 10): Promise<referrerCount[]> {
    const res = await fetchWithAuth(`/visits/referrers?limit=${limit}`);
    if (!res.ok) throw new Error("Failed to fetch referrers");
    return res.json();
}

export async function getDeviceBreakdown(): Promise<deviceCount[]> {
    const res = await fetchWithAuth("/visits/devices");
    if (!res.ok) throw new Error("Failed to fetch device breakdown");
    return res.json();
}
