import {integer, pgTable, varchar, text, json, timestamp, boolean} from "drizzle-orm/pg-core";

export const offering = pgTable('offering', {
    id: integer().primaryKey().generatedAlwaysAsIdentity(),
    title: varchar({ length: 255 }).notNull(),
    description: varchar({ length: 1024 }).notNull(),
    description_page: text(),
    icon: text().notNull(),
    category: integer().notNull().references(() => offering_category.id),
    features: json(),
    price: integer().notNull(),
});

export const offering_category = pgTable('offering_category', {
    id: integer().primaryKey().generatedAlwaysAsIdentity(),
    name: varchar({ length: 255 }).notNull(),
    description: varchar({ length: 1024 }),
});

export const contact = pgTable('contact', {
    id: integer().primaryKey().generatedAlwaysAsIdentity(),
    name: varchar({ length: 255 }).notNull(),
    email: varchar({ length: 255 }).notNull(),
    subject: varchar({ length: 255 }).notNull(),
    message: text().notNull(),
});

export const adminUser = pgTable('admin_user', {
    id: integer().primaryKey().generatedAlwaysAsIdentity(),
    username: varchar({ length: 100 }).notNull().unique(),
    password_hash: varchar({ length: 255 }).notNull(),
    force_password_change: boolean().default(false).notNull(),
    password_changed_at: timestamp(),
    created_at: timestamp().defaultNow().notNull(),
});

export const pageVisit = pgTable('page_visit', {
    id: integer().primaryKey().generatedAlwaysAsIdentity(),
    visited_at: timestamp().defaultNow().notNull(),
    path: varchar({ length: 2048 }).notNull(),
    ip_hash: varchar({ length: 64 }).notNull(),
    user_agent: text(),
    referrer: varchar({ length: 2048 }),
    device_type: varchar({ length: 50 }),
});