import 'dotenv/config';
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
    out: './drizzle/drupal',
    schema: './db/drizzle/drupal/schema.ts',
    dialect: 'postgresql',
    dbCredentials: {
        url: process.env.DRUPAL_DB_URL!,
    },
});