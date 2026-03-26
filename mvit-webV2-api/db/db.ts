import { drizzle } from 'drizzle-orm/node-postgres';
import pg from 'pg';

// Create a connection pool to the PostgreSQL database for the main application database
const pool = new pg.Pool({
	connectionString: process.env.DATABASE_URL,
});

const db = drizzle(pool);

// Create a separate connection pool for the Drupal database
const drupalPool = new pg.Pool({
	connectionString: process.env.DRUPAL_DB_URL,
});

const drupalDb = drizzle(drupalPool);

export { db, pool, drupalDb, drupalPool };