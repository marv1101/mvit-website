import { useState, useEffect, useCallback } from "react";
import { login as apiLogin, logout as apiLogout, getMe, changePassword as apiChangePassword } from "../services/authService";

type AuthUser = {
    id: number;
    username: string;
};

export function useAuth() {
    const [user, setUser] = useState<AuthUser | null>(null);
    const [loading, setLoading] = useState(true);
    const [requirePasswordChange, setRequirePasswordChange] = useState(false);

    useEffect(() => {
        let cancelled = false;
        const load = async () => {
            const me = await getMe();
            if (cancelled) return;
            if (me) {
                setUser(me.user);
                setRequirePasswordChange(me.requirePasswordChange);
            } else {
                setUser(null);
            }
            setLoading(false);
        };
        load();
        return () => {
            cancelled = true;
        };
    }, []);

    const login = useCallback(async (username: string, password: string): Promise<{ success: boolean; requirePasswordChange: boolean }> => {
        try {
            const response = await apiLogin(username, password);
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

    const logout = useCallback(async () => {
        await apiLogout();
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
