import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import {
    LineChart,
    Line,
    XAxis,
    YAxis,
    CartesianGrid,
    Tooltip,
    ResponsiveContainer,
    PieChart,
    Pie,
    Cell,
} from "recharts";
import { useAuth } from "../hooks/useAuth";
import {
    getVisitStats,
    getDailyVisits,
    getTopPages,
    getTopReferrers,
    getDeviceBreakdown,
    type visitStats,
    type dailyVisit,
    type pageCount,
    type referrerCount,
    type deviceCount,
} from "../services/visitService";

const COLORS = ["#3b82f6", "#10b981", "#f59e0b", "#ef4444", "#8b5cf6"];

export function AdminDashboard() {
    const [stats, setStats] = useState<visitStats | null>(null);
    const [dailyVisits, setDailyVisits] = useState<dailyVisit[]>([]);
    const [topPages, setTopPages] = useState<pageCount[]>([]);
    const [referrers, setReferrers] = useState<referrerCount[]>([]);
    const [devices, setDevices] = useState<deviceCount[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const { user, logout } = useAuth();
    const navigate = useNavigate();

    useEffect(() => {
        const fetchData = async () => {
            try {
                const [statsData, daily, pages, refs, devs] = await Promise.all([
                    getVisitStats(),
                    getDailyVisits(30),
                    getTopPages(10),
                    getTopReferrers(10),
                    getDeviceBreakdown(),
                ]);
                setStats(statsData);
                setDailyVisits(daily);
                setTopPages(pages);
                setReferrers(refs);
                setDevices(devs);
            } catch {
                setError("Fehler beim Laden der Daten");
            } finally {
                setLoading(false);
            }
        };
        fetchData();
    }, []);

    const handleLogout = () => {
        logout();
        navigate("/admin/login");
    };

    if (loading) {
        return (
            <div className="min-h-screen flex items-center justify-center">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
            </div>
        );
    }

    if (error) {
        return (
            <div className="min-h-screen flex items-center justify-center">
                <div className="text-center">
                    <p className="text-destructive text-lg mb-4">{error}</p>
                    <button
                        onClick={() => window.location.reload()}
                        className="px-4 py-2 bg-primary text-primary-foreground rounded-md"
                    >
                        Erneut versuchen
                    </button>
                </div>
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-background p-6">
            <div className="max-w-7xl mx-auto">
                <div className="flex justify-between items-center mb-8">
                    <div>
                        <h1 className="text-3xl font-bold">Admin Dashboard</h1>
                        <p className="text-muted-foreground">Willkommen, {user?.username}</p>
                    </div>
                    <button
                        onClick={handleLogout}
                        className="px-4 py-2 border border-destructive text-destructive rounded-md hover:bg-destructive/10"
                    >
                        Abmelden
                    </button>
                </div>

                {stats && (
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
                        <StatCard label="Heute" value={stats.today} />
                        <StatCard label="Diese Woche" value={stats.thisWeek} />
                        <StatCard label="Dieser Monat" value={stats.thisMonth} />
                        <StatCard label="Gesamt" value={stats.total} />
                    </div>
                )}

                <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
                    <div className="p-6 rounded-lg border bg-card">
                        <h2 className="text-lg font-semibold mb-4">Besucherverlauf (30 Tage)</h2>
                        <div className="h-64">
                            <ResponsiveContainer width="100%" height="100%">
                                <LineChart data={dailyVisits}>
                                    <CartesianGrid strokeDasharray="3 3" />
                                    <XAxis
                                        dataKey="date"
                                        tick={{ fontSize: 12 }}
                                        tickFormatter={(v) => v.slice(5)}
                                    />
                                    <YAxis tick={{ fontSize: 12 }} />
                                    <Tooltip />
                                    <Line
                                        type="monotone"
                                        dataKey="count"
                                        stroke="#3b82f6"
                                        strokeWidth={2}
                                        dot={false}
                                    />
                                </LineChart>
                            </ResponsiveContainer>
                        </div>
                    </div>

                    <div className="p-6 rounded-lg border bg-card">
                        <h2 className="text-lg font-semibold mb-4">Geräteverteilung</h2>
                        <div className="h-64">
                            <ResponsiveContainer width="100%" height="100%">
                                <PieChart>
                                    <Pie
                                        data={devices}
                                        dataKey="count"
                                        nameKey="deviceType"
                                        cx="50%"
                                        cy="50%"
                                        outerRadius={80}
                                        label={({ deviceType, percent }) =>
                                            `${deviceType} (${(percent * 100).toFixed(0)}%)`
                                        }
                                    >
                                        {devices.map((_, index) => (
                                            <Cell key={index} fill={COLORS[index % COLORS.length]} />
                                        ))}
                                    </Pie>
                                    <Tooltip />
                                </PieChart>
                            </ResponsiveContainer>
                        </div>
                    </div>
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    <div className="p-6 rounded-lg border bg-card">
                        <h2 className="text-lg font-semibold mb-4">Top Seiten</h2>
                        <div className="overflow-x-auto">
                            <table className="w-full text-sm">
                                <thead>
                                    <tr className="border-b">
                                        <th className="text-left py-2">Seite</th>
                                        <th className="text-right py-2">Aufrufe</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {topPages.map((page) => (
                                        <tr key={page.path} className="border-b last:border-0">
                                            <td className="py-2 font-mono text-xs">{page.path}</td>
                                            <td className="py-2 text-right">{page.count}</td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <div className="p-6 rounded-lg border bg-card">
                        <h2 className="text-lg font-semibold mb-4">Top Referrer</h2>
                        <div className="overflow-x-auto">
                            <table className="w-full text-sm">
                                <thead>
                                    <tr className="border-b">
                                        <th className="text-left py-2">Referrer</th>
                                        <th className="text-right py-2">Aufrufe</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {referrers.map((ref) => (
                                        <tr key={ref.referrer} className="border-b last:border-0">
                                            <td className="py-2 font-mono text-xs break-all">
                                                {ref.referrer === "direct" ? "(direkt)" : ref.referrer}
                                            </td>
                                            <td className="py-2 text-right">{ref.count}</td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}

function StatCard({ label, value }: { label: string; value: number }) {
    return (
        <div className="p-6 rounded-lg border bg-card">
            <p className="text-sm text-muted-foreground">{label}</p>
            <p className="text-3xl font-bold mt-1">{value.toLocaleString("de-DE")}</p>
        </div>
    );
}
