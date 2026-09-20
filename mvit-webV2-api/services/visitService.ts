import crypto from "crypto";
import { sql } from "drizzle-orm";
import { db } from "../db/db.js";
import { pageVisit, pageVisitDaily } from "../db/schema.js";
import type {
    createVisitRequest,
    visitStats,
    dailyVisits,
    pageCount,
    referrerCount,
    deviceCount,
} from "../models/visit.js";

const FLUSH_INTERVAL_MS = 5000;
const MAX_BUFFER_SIZE = 5000;
const STATS_CACHE_TTL_MS = 60000;

type bufferedVisit = {
    visited_at: Date;
    path: string;
    ip_hash: string;
    user_agent: string | null;
    referrer: string | null;
    device_type: string;
};

type dailyAggregate = {
    day: string;
    path: string;
    referrer: string;
    device_type: string;
    count: number;
};

type cacheEntry<T> = {
    value: T;
    expiresAt: number;
};

const buffer: bufferedVisit[] = [];
const statsCache = new Map<string, cacheEntry<unknown>>();
let flushTimer: ReturnType<typeof setInterval> | null = null;

function getPepper(): string {
    return process.env.PEPPER || "default-pepper-change-in-production";
}

function hashIp(ip: string): string {
    return crypto.createHash("sha256").update(ip + getPepper()).digest("hex");
}

function parseDeviceType(userAgent: string | null): string {
    if (!userAgent) return "unknown";

    const ua = userAgent.toLowerCase();
    if (/mobile|android|iphone|ipad|ipod/.test(ua)) {
        if (/ipad|tablet/.test(ua)) return "tablet";
        return "mobile";
    }
    if (/tablet|ipad/.test(ua)) return "tablet";
    return "desktop";
}

function getClientIp(req: { ip?: string }): string {
    return req.ip || "unknown";
}

function toDayString(date: Date): string {
    const y = date.getFullYear();
    const m = String(date.getMonth() + 1).padStart(2, "0");
    const d = String(date.getDate()).padStart(2, "0");
    return `${y}-${m}-${d}`;
}

function startFlushTimer(): void {
    if (flushTimer) return;
    flushTimer = setInterval(() => {
        void flushVisits();
    }, FLUSH_INTERVAL_MS);
    flushTimer.unref?.();
}

function invalidateStatsCache(): void {
    statsCache.clear();
}

function addToBuffer(visit: bufferedVisit): void {
    if (buffer.length >= MAX_BUFFER_SIZE) {
        buffer.shift();
        console.log("[VisitBuffer] Buffer full, dropped oldest visit");
    }
    buffer.push(visit);
    invalidateStatsCache();
}

function aggregateBatch(batch: bufferedVisit[]): dailyAggregate[] {
    const aggregated = new Map<string, dailyAggregate>();
    for (const visit of batch) {
        const day = toDayString(visit.visited_at);
        const referrer = visit.referrer || "";
        const key = `${day}|${visit.path}|${referrer}|${visit.device_type}`;
        const entry = aggregated.get(key);
        if (entry) {
            entry.count += 1;
        } else {
            aggregated.set(key, {
                day,
                path: visit.path,
                referrer,
                device_type: visit.device_type,
                count: 1,
            });
        }
    }
    return Array.from(aggregated.values());
}

async function flushVisits(): Promise<boolean> {
    if (buffer.length === 0) return true;

    const batch = buffer.splice(0, buffer.length);

    try {
        await db.transaction(async (tx) => {
            await tx.insert(pageVisit).values(batch.map(v => ({
                visited_at: v.visited_at,
                path: v.path,
                ip_hash: v.ip_hash,
                user_agent: v.user_agent,
                referrer: v.referrer,
                device_type: v.device_type,
            })));

            const aggregates = aggregateBatch(batch);
            if (aggregates.length > 0) {
                await tx.insert(pageVisitDaily).values(aggregates).onConflictDoUpdate({
                    target: [pageVisitDaily.day, pageVisitDaily.path, pageVisitDaily.referrer, pageVisitDaily.device_type],
                    set: { count: sql`${pageVisitDaily.count} + excluded.count` },
                });
            }
        });

        invalidateStatsCache();
        return true;
    } catch (error) {
        console.log("[VisitBuffer] Flush failed, retrying later:", error);
        buffer.unshift(...batch);
        return false;
    }
}

function flushOnShutdown(): Promise<void> {
    return flushVisits().then(() => undefined);
}

function getCached<T>(key: string, compute: () => Promise<T>): Promise<T> {
    const cached = statsCache.get(key) as cacheEntry<T> | undefined;
    if (cached && cached.expiresAt > Date.now()) {
        return Promise.resolve(cached.value);
    }
    return compute().then(value => {
        statsCache.set(key, { value, expiresAt: Date.now() + STATS_CACHE_TTL_MS });
        return value;
    });
}

function sumBufferSince(cutoff: Date): number {
    let sum = 0;
    for (const visit of buffer) {
        if (visit.visited_at >= cutoff) sum += 1;
    }
    return sum;
}

async function recordVisit(data: createVisitRequest, userAgent: string | null, ip: string): Promise<boolean> {
    try {
        const ipHash = hashIp(ip);
        const deviceType = parseDeviceType(userAgent);

        addToBuffer({
            visited_at: new Date(),
            path: data.path,
            ip_hash: ipHash,
            user_agent: userAgent,
            referrer: data.referrer || null,
            device_type: deviceType,
        });
        startFlushTimer();

        return true;
    } catch (error) {
        console.log("Error recording visit:", error);
        return false;
    }
}

async function getStats(): Promise<visitStats> {
    return getCached("stats", async () => {
        const now = new Date();
        const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        const startOfWeek = new Date(startOfDay);
        startOfWeek.setDate(startOfWeek.getDate() - startOfWeek.getDay());
        const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

        const [totalResult] = await db.select({ count: sql<number>`coalesce(sum(${pageVisitDaily.count}), 0)` }).from(pageVisitDaily);
        const [todayResult] = await db.select({ count: sql<number>`coalesce(sum(${pageVisitDaily.count}), 0)` }).from(pageVisitDaily)
            .where(sql`${pageVisitDaily.day} >= ${toDayString(startOfDay)}`);
        const [weekResult] = await db.select({ count: sql<number>`coalesce(sum(${pageVisitDaily.count}), 0)` }).from(pageVisitDaily)
            .where(sql`${pageVisitDaily.day} >= ${toDayString(startOfWeek)}`);
        const [monthResult] = await db.select({ count: sql<number>`coalesce(sum(${pageVisitDaily.count}), 0)` }).from(pageVisitDaily)
            .where(sql`${pageVisitDaily.day} >= ${toDayString(startOfMonth)}`);

        return {
            total: Number(totalResult.count) + buffer.length,
            today: Number(todayResult.count) + sumBufferSince(startOfDay),
            thisWeek: Number(weekResult.count) + sumBufferSince(startOfWeek),
            thisMonth: Number(monthResult.count) + sumBufferSince(startOfMonth),
        };
    });
}

async function getDailyVisits(days: number): Promise<dailyVisits[]> {
    return getCached(`daily:${days}`, async () => {
        const cutoffDate = new Date();
        cutoffDate.setDate(cutoffDate.getDate() - days);

        const result = await db.select({
            date: sql<string>`to_char(${pageVisitDaily.day}, 'YYYY-MM-DD')`,
            count: sql<number>`sum(${pageVisitDaily.count})`,
        }).from(pageVisitDaily)
            .where(sql`${pageVisitDaily.day} >= ${toDayString(cutoffDate)}`)
            .groupBy(sql`to_char(${pageVisitDaily.day}, 'YYYY-MM-DD')`)
            .orderBy(sql`to_char(${pageVisitDaily.day}, 'YYYY-MM-DD')`);

        const merged = new Map<string, number>();
        for (const r of result) {
            merged.set(r.date, Number(r.count));
        }
        for (const visit of buffer) {
            if (visit.visited_at >= cutoffDate) {
                const day = toDayString(visit.visited_at);
                merged.set(day, (merged.get(day) || 0) + 1);
            }
        }

        return Array.from(merged.entries())
            .sort(([a], [b]) => a.localeCompare(b))
            .map(([date, count]) => ({ date, count }));
    });
}

async function getTopPages(limit: number): Promise<pageCount[]> {
    return getCached(`pages:${limit}`, async () => {
        const result = await db.select({
            path: pageVisitDaily.path,
            count: sql<number>`sum(${pageVisitDaily.count})`,
        }).from(pageVisitDaily)
            .groupBy(pageVisitDaily.path)
            .orderBy(sql`sum(${pageVisitDaily.count}) desc`)
            .limit(limit);

        return result.map(r => ({ path: r.path, count: Number(r.count) }));
    });
}

async function getTopReferrers(limit: number): Promise<referrerCount[]> {
    return getCached(`referrers:${limit}`, async () => {
        const result = await db.select({
            referrer: pageVisitDaily.referrer,
            count: sql<number>`sum(${pageVisitDaily.count})`,
        }).from(pageVisitDaily)
            .groupBy(pageVisitDaily.referrer)
            .orderBy(sql`sum(${pageVisitDaily.count}) desc`)
            .limit(limit);

        return result.map(r => ({ referrer: r.referrer === "" ? "direct" : r.referrer, count: Number(r.count) }));
    });
}

async function getDeviceBreakdown(): Promise<deviceCount[]> {
    return getCached("devices", async () => {
        const result = await db.select({
            deviceType: pageVisitDaily.device_type,
            count: sql<number>`sum(${pageVisitDaily.count})`,
        }).from(pageVisitDaily)
            .groupBy(pageVisitDaily.device_type)
            .orderBy(sql`sum(${pageVisitDaily.count}) desc`);

        return result.map(r => ({ deviceType: r.deviceType || "unknown", count: Number(r.count) }));
    });
}

async function cleanupOldVisits(retentionDays: number): Promise<number> {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - retentionDays);

    const result = await db.execute(
        sql`DELETE FROM ${pageVisit} WHERE ${pageVisit.visited_at} < ${cutoffDate}`
    );
    return result.rowCount || 0;
}

export const visitService = {
    recordVisit,
    getStats,
    getDailyVisits,
    getTopPages,
    getTopReferrers,
    getDeviceBreakdown,
    cleanupOldVisits,
    getClientIp,
    flushVisits,
    flushOnShutdown,
    __resetForTests: () => {
        buffer.length = 0;
        statsCache.clear();
        if (flushTimer) {
            clearInterval(flushTimer);
            flushTimer = null;
        }
    },
};
