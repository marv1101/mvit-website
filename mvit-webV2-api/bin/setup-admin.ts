import { eq } from "drizzle-orm";
import { registerRequest } from "../models/adminUser.js";
import { authService } from "../services/authService.js";
import { db } from "../db/db.js";
import { adminUser } from "../db/schema.js";

function printBanner(username: string, password: string): void {
    console.log("");
    console.log("╔══════════════════════════════════════════════════════════════╗");
    console.log("║                  ADMIN USER CREATED                          ║");
    console.log("╠══════════════════════════════════════════════════════════════╣");
    console.log(`║  Username: ${username.padEnd(46)} ║`);
    console.log(`║  Password: ${password.padEnd(46)} ║`);
    console.log("╠══════════════════════════════════════════════════════════════╣");
    console.log("║  IMPORTANT: Please change this password after first login!  ║");
    console.log("║  Navigate to /admin/login and use the credentials above.    ║");
    console.log("╚══════════════════════════════════════════════════════════════╝");
    console.log("");
}

async function setup() {
    const username = process.env.ADMIN_DEFAULT_USERNAME || "admin";

    const existing = await db.select().from(adminUser).where(eq(adminUser.username, username));
    if (existing.length > 0) {
        console.log(`Admin user '${username}' already exists. Skipping setup.`);
        process.exit(0);
    }

    const password = authService.generateSecurePassword(20);
    const data: registerRequest = { username, password };
    const result = await authService.createAdminUser(data, true);

    if (result) {
        printBanner(username, password);
    } else {
        console.error("Failed to create admin user");
        process.exit(1);
    }

    process.exit(0);
}

setup();
