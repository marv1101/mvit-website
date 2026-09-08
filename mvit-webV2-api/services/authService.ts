import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { eq } from "drizzle-orm";
import { db } from "../db/db.js";
import { adminUser } from "../db/schema.js";
import { loginRequest, registerRequest, authResponse } from "../models/adminUser.js";

const SALT_ROUNDS = 12;
const TOKEN_EXPIRY = "24h";

function getJwtSecret(): string {
    const secret = process.env.JWT_SECRET;
    if (!secret) {
        throw new Error("JWT_SECRET environment variable is not set");
    }
    return secret;
}

async function hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, SALT_ROUNDS);
}

async function verifyPassword(password: string, hash: string): Promise<boolean> {
    return bcrypt.compare(password, hash);
}

function generateToken(userId: number, username: string): string {
    return jwt.sign({ userId, username }, getJwtSecret(), { expiresIn: TOKEN_EXPIRY });
}

async function createAdminUser(data: registerRequest): Promise<authResponse | null> {
    try {
        const existing = await db.select().from(adminUser).where(eq(adminUser.username, data.username));
        if (existing.length > 0) {
            return null;
        }

        const passwordHash = await hashPassword(data.password);
        const result = await db.insert(adminUser).values({
            username: data.username,
            password_hash: passwordHash,
        }).returning({ id: adminUser.id, username: adminUser.username });

        const user = result[0];
        const token = generateToken(user.id, user.username);

        return {
            token,
            user: { id: user.id, username: user.username },
        };
    } catch (error) {
        console.log("Error creating admin user:", error);
        return null;
    }
}

async function login(data: loginRequest): Promise<authResponse | null> {
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
        };
    } catch (error) {
        console.log("Error during login:", error);
        return null;
    }
}

export const authService = {
    createAdminUser,
    login,
    verifyToken: (token: string): { userId: number; username: string } | null => {
        try {
            const decoded = jwt.verify(token, getJwtSecret()) as { userId: number; username: string };
            return decoded;
        } catch {
            return null;
        }
    },
};
