import { useState } from "react";
import { useAuth } from "../hooks/useAuth";

type ChangePasswordProps = {
    onComplete: () => void;
};

export function ChangePassword({ onComplete }: ChangePasswordProps) {
    const [currentPassword, setCurrentPassword] = useState("");
    const [newPassword, setNewPassword] = useState("");
    const [confirmPassword, setConfirmPassword] = useState("");
    const [error, setError] = useState("");
    const [loading, setLoading] = useState(false);
    const { changePassword } = useAuth();

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setError("");

        if (newPassword !== confirmPassword) {
            setError("Die Passwörter stimmen nicht überein");
            return;
        }

        if (newPassword.length < 8) {
            setError("Das Passwort muss mindestens 8 Zeichen lang sein");
            return;
        }

        setLoading(true);
        try {
            await changePassword(currentPassword, newPassword);
            onComplete();
        } catch (err) {
            setError(err instanceof Error ? err.message : "Fehler beim Ändern des Passworts");
        }
        setLoading(false);
    };

    return (
        <div className="min-h-screen flex items-center justify-center bg-background">
            <div className="w-full max-w-md p-8 rounded-lg border bg-card">
                <h1 className="text-2xl font-bold text-center mb-2">Passwort ändern</h1>
                <p className="text-muted-foreground text-center mb-6 text-sm">
                    Sie müssen Ihr Passwort ändern, bevor Sie fortfahren können.
                </p>
                <form onSubmit={handleSubmit} className="space-y-4">
                    <div>
                        <label htmlFor="currentPassword" className="block text-sm font-medium mb-1">
                            Aktuelles Passwort
                        </label>
                        <input
                            id="currentPassword"
                            type="password"
                            value={currentPassword}
                            onChange={(e) => setCurrentPassword(e.target.value)}
                            className="w-full px-3 py-2 border rounded-md bg-background"
                            required
                        />
                    </div>
                    <div>
                        <label htmlFor="newPassword" className="block text-sm font-medium mb-1">
                            Neues Passwort
                        </label>
                        <input
                            id="newPassword"
                            type="password"
                            value={newPassword}
                            onChange={(e) => setNewPassword(e.target.value)}
                            className="w-full px-3 py-2 border rounded-md bg-background"
                            required
                            minLength={8}
                        />
                    </div>
                    <div>
                        <label htmlFor="confirmPassword" className="block text-sm font-medium mb-1">
                            Neues Passwort bestätigen
                        </label>
                        <input
                            id="confirmPassword"
                            type="password"
                            value={confirmPassword}
                            onChange={(e) => setConfirmPassword(e.target.value)}
                            className="w-full px-3 py-2 border rounded-md bg-background"
                            required
                            minLength={8}
                        />
                    </div>
                    {error && <p className="text-destructive text-sm">{error}</p>}
                    <button
                        type="submit"
                        disabled={loading}
                        className="w-full py-2 px-4 bg-primary text-primary-foreground rounded-md hover:bg-primary/90 disabled:opacity-50"
                    >
                        {loading ? "Wird geändert..." : "Passwort ändern"}
                    </button>
                </form>
            </div>
        </div>
    );
}
