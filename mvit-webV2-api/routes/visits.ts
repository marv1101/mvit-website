import express, { Request, Response } from "express";
import { visitService } from "../services/visitService.js";
import { authMiddleware } from "../middleware/authMiddleware.js";
import { createVisitRequest } from "../models/visit.js";

const router = express.Router();

router.post("/", async (req: Request, res: Response): Promise<void> => {
    try {
        const data: createVisitRequest = req.body;

        if (!data.path) {
            res.status(400).json({ error: "Path is required" });
            return;
        }

        const userAgent = req.headers["user-agent"] || null;
        const ip = visitService.getClientIp(req);

        await visitService.recordVisit(data, userAgent, ip);

        res.status(201).json({ message: "Visit recorded" });
    } catch (error) {
        console.log("Error recording visit:", error);
        res.status(500).json({ error: "Failed to record visit" });
    }
});

router.get("/stats", authMiddleware, async (_req: Request, res: Response): Promise<void> => {
    try {
        const stats = await visitService.getStats();
        res.json(stats);
    } catch (error) {
        console.log("Error fetching stats:", error);
        res.status(500).json({ error: "Failed to fetch stats" });
    }
});

router.get("/daily", authMiddleware, async (req: Request, res: Response): Promise<void> => {
    try {
        const days = Math.min(Math.max(parseInt(req.query.days as string) || 30, 1), 365);
        const daily = await visitService.getDailyVisits(days);
        res.json(daily);
    } catch (error) {
        console.log("Error fetching daily visits:", error);
        res.status(500).json({ error: "Failed to fetch daily visits" });
    }
});

router.get("/pages", authMiddleware, async (req: Request, res: Response): Promise<void> => {
    try {
        const limit = Math.min(Math.max(parseInt(req.query.limit as string) || 10, 1), 100);
        const pages = await visitService.getTopPages(limit);
        res.json(pages);
    } catch (error) {
        console.log("Error fetching top pages:", error);
        res.status(500).json({ error: "Failed to fetch top pages" });
    }
});

router.get("/referrers", authMiddleware, async (req: Request, res: Response): Promise<void> => {
    try {
        const limit = Math.min(Math.max(parseInt(req.query.limit as string) || 10, 1), 100);
        const referrers = await visitService.getTopReferrers(limit);
        res.json(referrers);
    } catch (error) {
        console.log("Error fetching referrers:", error);
        res.status(500).json({ error: "Failed to fetch referrers" });
    }
});

router.get("/devices", authMiddleware, async (_req: Request, res: Response): Promise<void> => {
    try {
        const devices = await visitService.getDeviceBreakdown();
        res.json(devices);
    } catch (error) {
        console.log("Error fetching device breakdown:", error);
        res.status(500).json({ error: "Failed to fetch device breakdown" });
    }
});

export default router;
