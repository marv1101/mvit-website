import { useState, useEffect, useCallback } from "react";
import { login as apiLogin, logout as apiLogout, getToken, getUser, setAuth, isAuthenticated, changePassword as apiChangePassword } from "../services/authService";

type AuthUser = {
    id: number;
    username: string;
};

export function useAuth() {
    const [user, setUser] = useState<AuthUser | null>(null);
    const [loading, setLoading] = useState(true);
    const [requirePasswordChange, setRequirePasswordChange] = useState(false);

    useEffect(() => {
        if (isAuthenticated()) {
            setUser(getUser());
        }
        setLoading(false);
    }, []);

    const login = useCallback(async (username: string, password: string): Promise<{ success: boolean; requirePasswordChange: boolean }> => {
        try {
            const response = await apiLogin(username, password);
            setAuth(response.token, response.user);
            setUser(response.user);
            setRequirePasswordChange(response.requirePasswordChange);
            return { success: true, requirePasswordChange: response.requirePasswordChange };
        } catch {
            return { success: false, requirePasswordChange: false };
        }
    }, []);

    const changePassword = useCallback(async (currentPassword: string, newPassword: string): Promise<void> => {
        await apiChangePassword(currentPassword, newPassword);
        setRequirePasswordChange(false);
    }, []);

    const logout = useCallback(() => {
        apiLogout();
        setUser(null);
        setRequirePasswordChange(false);
    }, []);

    return {
        user,
        isAuthenticated: !!user,
        loading,
        requirePasswordChange,
        login,
        logout,
        changePassword,
    };
}
