import { useState, useEffect, useCallback } from "react";
import { login as apiLogin, logout as apiLogout, getToken, getUser, setAuth, isAuthenticated } from "../services/authService";

type AuthUser = {
    id: number;
    username: string;
};

export function useAuth() {
    const [user, setUser] = useState<AuthUser | null>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        if (isAuthenticated()) {
            setUser(getUser());
        }
        setLoading(false);
    }, []);

    const login = useCallback(async (username: string, password: string): Promise<boolean> => {
        try {
            const response = await apiLogin(username, password);
            setAuth(response.token, response.user);
            setUser(response.user);
            return true;
        } catch {
            return false;
        }
    }, []);

    const logout = useCallback(() => {
        apiLogout();
        setUser(null);
    }, []);

    return {
        user,
        isAuthenticated: !!user,
        loading,
        login,
        logout,
    };
}
