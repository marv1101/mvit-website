import { post } from "../lib/api";

export type authResponse = {
    token: string;
    user: {
        id: number;
        username: string;
    };
    requirePasswordChange: boolean;
};

const TOKEN_KEY = "admin_token";
const USER_KEY = "admin_user";

export function login(username: string, password: string): Promise<authResponse> {
    return post<authResponse>("/auth/login", { username, password });
}

export async function changePassword(currentPassword: string, newPassword: string): Promise<void> {
    const token = getToken();
    const res = await fetch("/api/auth/change-password", {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${token}`,
        },
        body: JSON.stringify({ currentPassword, newPassword }),
    });
    if (!res.ok) {
        const data = await res.json().catch(() => ({ error: "Failed to change password" }));
        throw new Error(data.error || "Failed to change password");
    }
}

export function logout(): void {
    sessionStorage.removeItem(TOKEN_KEY);
    sessionStorage.removeItem(USER_KEY);
}

export function getToken(): string | null {
    return sessionStorage.getItem(TOKEN_KEY);
}

export function getUser(): { id: number; username: string } | null {
    const data = sessionStorage.getItem(USER_KEY);
    if (!data) return null;
    try {
        return JSON.parse(data);
    } catch {
        return null;
    }
}

export function setAuth(token: string, user: { id: number; username: string }): void {
    sessionStorage.setItem(TOKEN_KEY, token);
    sessionStorage.setItem(USER_KEY, JSON.stringify(user));
}

export function isAuthenticated(): boolean {
    return getToken() !== null;
}

export async function authFetch(path: string, init?: RequestInit): Promise<Response> {
    const token = getToken();
    const headers = new Headers(init?.headers as HeadersInit);
    if (token) {
        headers.set("Authorization", `Bearer ${token}`);
    }
    if (!headers.has("Content-Type") && init?.body) {
        headers.set("Content-Type", "application/json");
    }
    return fetch(path, { ...init, headers });
}
