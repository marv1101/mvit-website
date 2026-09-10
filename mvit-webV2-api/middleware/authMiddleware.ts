import { Request, Response, NextFunction } from "express";
import { authService } from "../services/authService.js";

export interface AuthRequest extends Request {
    userId?: number;
    username?: string;
    requirePasswordChange?: boolean;
}

const COOKIE_NAME = "admin_token";

function extractToken(req: Request): string | null {
    const authHeader = req.headers.authorization;
    if (authHeader?.startsWith("Bearer ")) {
        return authHeader.slice("Bearer ".length);
    }
    return req.cookies?.[COOKIE_NAME] ?? null;
}

type AuthMiddlewareOptions = {
    allowPasswordChangePending?: boolean;
};

function createAuthMiddleware(options: AuthMiddlewareOptions = {}) {
    return async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
        const token = extractToken(req);

        if (!token) {
            res.status(401).json({ error: "Authentication required" });
            return;
        }

        const session = await authService.verifyToken(token);

        if (!session) {
            res.status(401).json({ error: "Invalid or expired token" });
            return;
        }

        if (session.forcePasswordChange && !options.allowPasswordChangePending) {
            res.status(403).json({ error: "Password change required before accessing this resource" });
            return;
        }

        req.userId = session.id;
        req.username = session.username;
        req.requirePasswordChange = session.forcePasswordChange;
        next();
    };
}

export const authMiddleware = createAuthMiddleware();
export const passwordChangeAuthMiddleware = createAuthMiddleware({ allowPasswordChangePending: true });

export { COOKIE_NAME };
