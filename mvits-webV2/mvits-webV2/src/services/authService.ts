import { CONFIG } from "../utils/ConfigLoader";
import { get, post } from "../lib/api";

export type authResponse = {
    user: {
        id: number;
        username: string;
    };
    requirePasswordChange: boolean;
};

const BASE_URL = CONFIG.API_BASE_URL;

export function login(username: string, password: string): Promise<authResponse> {
    return post<authResponse>("/auth/login", { username, password });
}

export async function getMe(): Promise<authResponse | null> {
    try {
        return await get<authResponse>("/auth/me");
    } catch {
        return null;
    }
}

export async function logout(): Promise<void> {
    try {
        await post("/auth/logout");
    } catch {
        return;
    }
}

export async function changePassword(currentPassword: string, newPassword: string): Promise<void> {
    const res = await fetch(`${BASE_URL}/auth/change-password`, {
        method: "POST",
        credentials: "include",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify({ currentPassword, newPassword }),
    });
    if (!res.ok) {
        const data = await res.json().catch(() => ({ error: "Failed to change password" }));
        throw new Error(data.error || "Failed to change password");
    }
}
