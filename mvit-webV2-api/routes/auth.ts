import express, { Request, Response } from "express";
import { authService } from "../services/authService.js";
import { loginRequest, registerRequest } from "../models/adminUser.js";
import { validateLoginRequest, validateRegisterRequest } from "../validators/authValidator.js";
import { authMiddleware, AuthRequest } from "../middleware/authMiddleware.js";

const router = express.Router();

router.post("/login", async (req: Request, res: Response): Promise<void> => {
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

        res.json(result);
    } catch (error) {
        console.log("Error during login:", error);
        res.status(500).json({ error: "Login failed" });
    }
});

router.post("/register", async (req: Request, res: Response): Promise<void> => {
    try {
        const data: registerRequest = req.body;

        const validated = validateRegisterRequest(data);
        if (!validated) {
            res.status(400).json({ error: "Invalid registration data" });
            return;
        }

        const result = await authService.createAdminUser(validated);
        if (!result) {
            res.status(409).json({ error: "Username already exists" });
            return;
        }

        res.status(201).json(result);
    } catch (error) {
        console.log("Error during registration:", error);
        res.status(500).json({ error: "Registration failed" });
    }
});

router.post("/change-password", authMiddleware, async (req: AuthRequest, res: Response): Promise<void> => {
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

        const success = await authService.changePassword(req.userId!, newPassword);
        if (!success) {
            res.status(500).json({ error: "Failed to change password" });
            return;
        }

        res.json({ message: "Password changed successfully" });
    } catch (error) {
        console.log("Error changing password:", error);
        res.status(500).json({ error: "Failed to change password" });
    }
});

export default router;
