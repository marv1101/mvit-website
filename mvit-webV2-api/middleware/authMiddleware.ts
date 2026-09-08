import { Request, Response, NextFunction } from "express";
import { authService } from "../services/authService.js";

export interface AuthRequest extends Request {
    userId?: number;
    username?: string;
}

export function authMiddleware(req: AuthRequest, res: Response, next: NextFunction): void {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        res.status(401).json({ error: "Authentication required" });
        return;
    }

    const token = authHeader.split(" ")[1];
    const decoded = authService.verifyToken(token);

    if (!decoded) {
        res.status(401).json({ error: "Invalid or expired token" });
        return;
    }

    req.userId = decoded.userId;
    req.username = decoded.username;
    next();
}
