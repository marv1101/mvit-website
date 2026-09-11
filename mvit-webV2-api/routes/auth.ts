import express, { Request, Response } from "express";
import rateLimit from "express-rate-limit";
import { authService } from "../services/authService.js";
import { loginRequest } from "../models/adminUser.js";
import { validateLoginRequest } from "../validators/authValidator.js";
import {
    authMiddleware,
    passwordChangeAuthMiddleware,
    COOKIE_NAME,
    AuthRequest,
} from "../middleware/authMiddleware.js";

const router = express.Router();

const COOKIE_MAX_AGE_MS = 24 * 60 * 60 * 1000;

const cookieOptions = {
    httpOnly: true,
    sameSite: "lax" as const,
    secure: process.env.NODE_ENV === "production",
    maxAge: COOKIE_MAX_AGE_MS,
    path: "/",
};

const loginLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    limit: 5,
    standardHeaders: "draft-7",
    legacyHeaders: false,
    message: { error: "Too many login attempts. Try again later." },
});

router.post("/login", loginLimiter, async (req: Request, res: Response): Promise<void> => {
    try {
        const data: loginRequest = req.body;

        const validated = validateLoginRequest(data);
        if (!validated) {
            res.status(400).json({ error: "Invalid login data" });
            return;
        }

        const result = await authService.login(validated);
        if (!result) {
            res.status(401).json({ error: "Invalid username or password" });
            return;
        }

        res.cookie(COOKIE_NAME, result.token, cookieOptions);
        res.json({
            user: result.user,
            requirePasswordChange: result.requirePasswordChange,
        });
    } catch (error) {
        console.log("Error during login:", error);
        res.status(500).json({ error: "Login failed" });
    }
});

router.get("/me", passwordChangeAuthMiddleware, async (req: AuthRequest, res: Response): Promise<void> => {
    try {
        res.json({
            user: { id: req.userId, username: req.username },
            requirePasswordChange: req.requirePasswordChange ?? false,
        });
    } catch (error) {
        console.log("Error fetching session:", error);
        res.status(500).json({ error: "Failed to fetch session" });
    }
});

router.post("/change-password", passwordChangeAuthMiddleware, async (req: AuthRequest, res: Response): Promise<void> => {
    try {
        const { currentPassword, newPassword } = req.body;

        if (!currentPassword || !newPassword) {
            res.status(400).json({ error: "Current password and new password are required" });
            return;
        }

        if (newPassword.length < 8) {
            res.status(400).json({ error: "New password must be at least 8 characters" });
            return;
        }

        const loginResult = await authService.login({ username: req.username!, password: currentPassword });
        if (!loginResult) {
            res.status(401).json({ error: "Current password is incorrect" });
            return;
        }

        const token = await authService.changePassword(req.userId!, newPassword);
        if (!token) {
            res.status(500).json({ error: "Failed to change password" });
            return;
        }

        res.cookie(COOKIE_NAME, token, cookieOptions);
        res.json({ message: "Password changed successfully" });
    } catch (error) {
        console.log("Error changing password:", error);
        res.status(500).json({ error: "Failed to change password" });
    }
});

router.post("/logout", (_req: Request, res: Response): void => {
    res.clearCookie(COOKIE_NAME, {
        httpOnly: true,
        sameSite: "lax" as const,
        secure: process.env.NODE_ENV === "production",
        path: "/",
    });
    res.json({ message: "Logged out" });
});

export default router;
