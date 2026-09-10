import { offering_category } from '../db/schema.js';
import { db } from '../db/db.js';
import { eq } from 'drizzle-orm';
import type { offeringCategory } from '../models/offeringCategory.js';

async function getAllCategories(): Promise<offeringCategory[]> {
    return db.select().from(offering_category);
}

async function getCategoryById(id: number): Promise<offeringCategory | undefined> {
    const [category] = await db.select().from(offering_category).where(eq(offering_category.id, id)).limit(1);
    return category;
}

async function createCategory(data: { name: string; description: string | null }): Promise<offeringCategory> {
    const [inserted] = await db.insert(offering_category).values({
        name: data.name,
        description: data.description,
    }).returning();
    return inserted;
}

async function updateCategory(id: number, data: { name: string; description: string | null }): Promise<offeringCategory> {
    const [updated] = await db.update(offering_category).set({
        name: data.name,
        description: data.description,
    }).where(eq(offering_category.id, id)).returning();

    if (!updated) {
        throw new Error('Category not found');
    }

    return updated;
}

async function deleteCategory(id: number): Promise<boolean> {
    const result = await db.delete(offering_category).where(eq(offering_category.id, id)).returning();
    return result.length > 0;
}

const offeringCategoryService = { getAllCategories, getCategoryById, createCategory, updateCategory, deleteCategory };

export { offeringCategoryService };
