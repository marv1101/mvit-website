import crypto from "crypto";
import { sql } from "drizzle-orm";
import { db } from "../db/db.js";
import { pageVisit } from "../db/schema.js";
import type {
    createVisitRequest,
    visitStats,
    dailyVisits,
    pageCount,
    referrerCount,
    deviceCount,
} from "../models/visit.js";

function getPepper(): string {
    return process.env.PEPPER || "default-pepper-change-in-production";
}

function hashIp(ip: string): string {
    return crypto.createHash("sha256").update(ip + getPepper()).digest("hex");
}

function parseDeviceType(userAgent: string | null): string | null {
    if (!userAgent) return "unknown";

    const ua = userAgent.toLowerCase();
    if (/mobile|android|iphone|ipad|ipod/.test(ua)) {
        if (/ipad|tablet/.test(ua)) return "tablet";
        return "mobile";
    }
    if (/tablet|ipad/.test(ua)) return "tablet";
    return "desktop";
}

function getClientIp(req: { ip?: string; headers: Record<string, unknown> }): string {
    const forwarded = req.headers["x-forwarded-for"];
    if (typeof forwarded === "string") {
        return forwarded.split(",")[0].trim();
    }
    if (Array.isArray(forwarded)) {
        return forwarded[0];
    }
    return req.ip || "unknown";
}

async function recordVisit(data: createVisitRequest, userAgent: string | null, ip: string): Promise<boolean> {
    try {
        const ipHash = hashIp(ip);
        const deviceType = parseDeviceType(userAgent);

        await db.insert(pageVisit).values({
            path: data.path,
            ip_hash: ipHash,
            user_agent: userAgent,
            referrer: data.referrer || null,
            device_type: deviceType,
        });

        return true;
    } catch (error) {
        console.log("Error recording visit:", error);
        return false;
    }
}

async function getStats(): Promise<visitStats> {
    const now = new Date();
    const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const startOfWeek = new Date(startOfDay);
    startOfWeek.setDate(startOfWeek.getDate() - startOfWeek.getDay());
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    const [totalResult] = await db.select({ count: sql<number>`count(*)` }).from(pageVisit);
    const [todayResult] = await db.select({ count: sql<number>`count(*)` }).from(pageVisit)
        .where(sql`${pageVisit.visited_at} >= ${startOfDay}`);
    const [weekResult] = await db.select({ count: sql<number>`count(*)` }).from(pageVisit)
        .where(sql`${pageVisit.visited_at} >= ${startOfWeek}`);
    const [monthResult] = await db.select({ count: sql<number>`count(*)` }).from(pageVisit)
        .where(sql`${pageVisit.visited_at} >= ${startOfMonth}`);

    return {
        total: Number(totalResult.count),
        today: Number(todayResult.count),
        thisWeek: Number(weekResult.count),
        thisMonth: Number(monthResult.count),
    };
}

async function getDailyVisits(days: number): Promise<dailyVisits[]> {
    const result = await db.select({
        date: sql<string>`to_char(${pageVisit.visited_at}, 'YYYY-MM-DD')`,
        count: sql<number>`count(*)`,
    }).from(pageVisit)
        .where(sql`${pageVisit.visited_at} >= now() - interval '${days} days'`)
        .groupBy(sql`to_char(${pageVisit.visited_at}, 'YYYY-MM-DD')`)
        .orderBy(sql`to_char(${pageVisit.visited_at}, 'YYYY-MM-DD')`);

    return result.map(r => ({ date: r.date, count: Number(r.count) }));
}

async function getTopPages(limit: number): Promise<pageCount[]> {
    const result = await db.select({
        path: pageVisit.path,
        count: sql<number>`count(*)`,
    }).from(pageVisit)
        .groupBy(pageVisit.path)
        .orderBy(sql`count(*) desc`)
        .limit(limit);

    return result.map(r => ({ path: r.path, count: Number(r.count) }));
}

async function getTopReferrers(limit: number): Promise<referrerCount[]> {
    const result = await db.select({
        referrer: pageVisit.referrer,
        count: sql<number>`count(*)`,
    }).from(pageVisit)
        .where(sql`${pageVisit.referrer} is not null`)
        .groupBy(pageVisit.referrer)
        .orderBy(sql`count(*) desc`)
        .limit(limit);

    return result.map(r => ({ referrer: r.referrer || "direct", count: Number(r.count) }));
}

async function getDeviceBreakdown(): Promise<deviceCount[]> {
    const result = await db.select({
        deviceType: pageVisit.device_type,
        count: sql<number>`count(*)`,
    }).from(pageVisit)
        .groupBy(pageVisit.device_type)
        .orderBy(sql`count(*) desc`);

    return result.map(r => ({ deviceType: r.deviceType || "unknown", count: Number(r.count) }));
}

async function cleanupOldVisits(retentionDays: number): Promise<number> {
    const result = await db.execute(
        sql`DELETE FROM ${pageVisit} WHERE ${pageVisit.visited_at} < now() - interval '${retentionDays} days'`
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
};
