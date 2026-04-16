import {integer, pgTable, varchar, text, json} from "drizzle-orm/pg-core";

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