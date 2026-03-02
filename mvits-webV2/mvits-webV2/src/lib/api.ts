const BASE_URL = "http://localhost:11011/api";

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  const headers = new Headers(init?.headers as HeadersInit);
  if (!headers.has("Content-Type")) headers.set("Content-Type", "application/json");

  const res = await fetch(`${BASE_URL}${path}`, {
    credentials: "omit",
    ...init,
  });

  if (!res.ok) {
    const text = await res.text();
    throw new Error(`${res.status} ${res.statusText}: ${text}`);
  }

  const contentType = res.headers.get("content-type") ?? "";
  if (contentType.includes("application/json")) return res.json() as Promise<T>;
  return (await res.text()) as unknown as T;
}

export function get<T>(path: string) {
  return request<T>(path, { method: "GET" });
}

export function post<T>(path: string, payload?: unknown) {
  return request<T>(path, { method: "POST", body: JSON.stringify(payload) });
}

export default { get, post };
