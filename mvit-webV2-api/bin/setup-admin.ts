import { registerRequest } from "../models/adminUser.js";
import { authService } from "../services/authService.js";

async function setup() {
    const username = process.env.ADMIN_DEFAULT_USERNAME;
    const password = process.env.ADMIN_DEFAULT_PASSWORD;

    if (!username || !password) {
        console.log("Set ADMIN_DEFAULT_USERNAME and ADMIN_DEFAULT_PASSWORD to create initial admin user");
        process.exit(0);
    }

    console.log(`Creating initial admin user: ${username}`);
    const data: registerRequest = { username, password };
    const result = await authService.createAdminUser(data);

    if (result) {
        console.log("Admin user created successfully");
    } else {
        console.log("Failed to create admin user (may already exist)");
    }

    process.exit(0);
}

setup();
