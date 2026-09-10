import fs from "fs";
import { eq } from "drizzle-orm";
import { registerRequest } from "../models/adminUser.js";
import { authService } from "../services/authService.js";
import { db } from "../db/db.js";
import { adminUser } from "../db/schema.js";

const CREDENTIALS_FILE = process.env.ADMIN_INITIAL_PASSWORD_FILE || "/tmp/admin-initial-credentials.txt";
const MIN_PASSWORD_LENGTH = 8;

async function setup() {
    const username = process.env.ADMIN_DEFAULT_USERNAME || "admin";
    const password = process.env.ADMIN_INITIAL_PASSWORD || authService.generateSecurePassword(20);

    if (password.length < MIN_PASSWORD_LENGTH) {
        console.error("ADMIN_INITIAL_PASSWORD is set but too short (minimum 8 characters). Aborting.");
        process.exit(1);
    }

    const existing = await db.select().from(adminUser).where(eq(adminUser.username, username));
    if (existing.length > 0) {
        console.log(`Admin user '${username}' already exists. Skipping setup.`);
        process.exit(0);
    }

    const data: registerRequest = { username, password };
    const result = await authService.createAdminUser(data, true);

    if (!result) {
        console.error("Failed to create admin user");
        process.exit(1);
    }

    try {
        fs.writeFileSync(
            CREDENTIALS_FILE,
            `username: ${username}\npassword: ${password}\n`,
            { mode: 0o600 },
        );
        console.log(`Admin user '${username}' created.`);
        console.log(`Initial credentials written to ${CREDENTIALS_FILE} (not to stdout).`);
        console.log(`Retrieve them inside the container, e.g.: docker compose exec mvit-api cat ${CREDENTIALS_FILE}`);
        console.log("IMPORTANT: Delete the file after retrieving the password and change the password on first login.");
    } catch (error) {
        console.log(`Could not write credentials file (${CREDENTIALS_FILE}). Printing to stdout as fallback.`);
        console.log(`Admin user created: ${username} / ${password}`);
        console.log("IMPORTANT: Please change this password after first login!");
    }

    process.exit(0);
}

setup();
