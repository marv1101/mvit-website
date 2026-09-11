import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { eq } from "drizzle-orm";
import crypto from "crypto";
import { db } from "../db/db.js";
import { adminUser } from "../db/schema.js";
import { loginRequest, registerRequest } from "../models/adminUser.js";

const SALT_ROUNDS = 12;
const TOKEN_EXPIRY_SECONDS = 24 * 60 * 60;
const JWT_ALGORITHM = "HS256";

function nowTruncatedToSeconds(): Date {
    return new Date(Math.floor(Date.now() / 1000) * 1000);
}

function getJwtSecret(): string {
    const secret = process.env.JWT_SECRET;
    if (!secret) {
        throw new Error("JWT_SECRET environment variable is not set");
    }
    return secret;
}

function generateSecurePassword(length: number = 20): string {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*";
    const bytes = crypto.randomBytes(length);
    let result = "";
    for (let i = 0; i < length; i++) {
        result += chars[bytes[i] % chars.length];
    }
    return result;
}

async function hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, SALT_ROUNDS);
}

async function verifyPassword(password: string, hash: string): Promise<boolean> {
    return bcrypt.compare(password, hash);
}

function generateToken(userId: number, username: string): string {
    return jwt.sign({ userId, username }, getJwtSecret(), {
        expiresIn: TOKEN_EXPIRY_SECONDS,
        algorithm: JWT_ALGORITHM,
    });
}

async function createAdminUser(data: registerRequest, forcePasswordChange: boolean = false): Promise<{ id: number; username: string } | null> {
    try {
        const existing = await db.select().from(adminUser).where(eq(adminUser.username, data.username));
        if (existing.length > 0) {
            return null;
        }

        const passwordHash = await hashPassword(data.password);
        const result = await db.insert(adminUser).values({
            username: data.username,
            password_hash: passwordHash,
            force_password_change: forcePasswordChange,
            password_changed_at: nowTruncatedToSeconds(),
        }).returning({ id: adminUser.id, username: adminUser.username });

        return result[0] ?? null;
    } catch (error) {
        console.log("Error creating admin user:", error);
        return null;
    }
}

async function login(data: loginRequest): Promise<{ token: string; user: { id: number; username: string }; requirePasswordChange: boolean } | null> {
    try {
        const result = await db.select().from(adminUser).where(eq(adminUser.username, data.username));
        if (result.length === 0) {
            return null;
        }

        const user = result[0];
        const isValid = await verifyPassword(data.password, user.password_hash);
        if (!isValid) {
            return null;
        }

        const token = generateToken(user.id, user.username);

        return {
            token,
            user: { id: user.id, username: user.username },
            requirePasswordChange: user.force_password_change,
        };
    } catch (error) {
        console.log("Error during login:", error);
        return null;
    }
}

async function changePassword(userId: number, newPassword: string): Promise<string | null> {
    try {
        const passwordHash = await hashPassword(newPassword);
        await db.update(adminUser)
            .set({
                password_hash: passwordHash,
                force_password_change: false,
                password_changed_at: nowTruncatedToSeconds(),
            })
            .where(eq(adminUser.id, userId));

        const [user] = await db.select({ id: adminUser.id, username: adminUser.username })
            .from(adminUser)
            .where(eq(adminUser.id, userId));
        if (!user) {
            return null;
        }

        return generateToken(user.id, user.username);
    } catch (error) {
        console.log("Error changing password:", error);
        return null;
    }
}

async function verifyToken(token: string): Promise<{ id: number; username: string; forcePasswordChange: boolean } | null> {
    try {
        const decoded = jwt.verify(token, getJwtSecret(), { algorithms: [JWT_ALGORITHM] }) as {
            userId: number;
            username: string;
            iat?: number;
        };

        const [user] = await db.select().from(adminUser).where(eq(adminUser.id, decoded.userId));
        if (!user) {
            return null;
        }

        if (user.password_changed_at && decoded.iat !== undefined) {
            const issuedAtMs = decoded.iat * 1000;
            if (issuedAtMs < user.password_changed_at.getTime()) {
                return null;
            }
        }

        return {
            id: user.id,
            username: user.username,
            forcePasswordChange: user.force_password_change,
        };
    } catch {
        return null;
    }
}

export const authService = {
    createAdminUser,
    login,
    changePassword,
    generateSecurePassword,
    verifyToken,
};
