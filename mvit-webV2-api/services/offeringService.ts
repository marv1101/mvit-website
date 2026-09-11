import { offeringObject } from '../models/offering.js';
import { offering, offering_category } from '../db/schema.js';
import { db } from '../db/db.js';
import { eq } from 'drizzle-orm';

type OfferingResponse = {
    id: string,
    name: string,
    description: string,
    description_page: string | null,
    icon: string,
    features: string[],
    category: string,
    category_id: number,
    price: string
};

async function getCategoryById(categoryId: number): Promise<any> {
    return db
                .select()
                .from(offering_category)
                .where(eq(offering_category.id, categoryId));
}

async function getAllOfferings(offset = 0, limit = 10): Promise<OfferingResponse[]> {
    const offerings: offeringObject[] = await db.select().from(offering).offset(offset).limit(limit);

    const offeringResponses: OfferingResponse[] = await Promise.all(
        offerings.map(async (off) => {
            const categories = await getCategoryById(off.category);
            return {
                id: off.id.toString(),
                name: off.title,
                description: off.description,
                description_page: off.description_page,
                icon: off.icon,
                features: (off.features as string[]) || [],
                category: categories.length > 0 ? categories[0].name : 'Unbekannt',
                category_id: off.category,
                price: off.price.toString(),
            } as OfferingResponse;
        })
    );

    return offeringResponses;
}

async function getOfferingById(id: number): Promise<OfferingResponse> {

    const foundOffering: offeringObject = await db.select().from(offering).where(eq(offering.id, id)).limit(1).then(results => results[0]);

    if (!foundOffering) {
        throw new Error('Offering not found');
    }

    const categories = await getCategoryById(foundOffering.category);

    const responseObject: OfferingResponse = {
        id: foundOffering.id.toString(),
        name: foundOffering.title,
        description: foundOffering.description,
        description_page: foundOffering.description_page,
        icon: foundOffering.icon,
        features: (foundOffering.features as string[]) || [],
        category: categories.length > 0 ? categories[0].name : 'Unbekannt',
        category_id: foundOffering.category,
        price: foundOffering.price.toString(),
    }

    return responseObject;

}

async function createOffering(data: offeringObject): Promise<OfferingResponse> {
    const [inserted] = await db.insert(offering).values({
        title: data.title,
        description: data.description,
        description_page: data.description_page,
        icon: data.icon,
        category: data.category,
        features: data.features,
        price: data.price,
    }).returning();

    const categories = await getCategoryById(inserted.category);

    return {
        id: inserted.id.toString(),
        name: inserted.title,
        description: inserted.description,
        description_page: inserted.description_page,
        icon: inserted.icon,
        features: (inserted.features as string[]) || [],
        category: categories.length > 0 ? categories[0].name : 'Unbekannt',
        category_id: inserted.category,
        price: inserted.price.toString(),
    };
}

async function updateOffering(id: number, data: offeringObject): Promise<OfferingResponse> {
    const [updated] = await db.update(offering).set({
        title: data.title,
        description: data.description,
        description_page: data.description_page,
        icon: data.icon,
        category: data.category,
        features: data.features,
        price: data.price,
    }).where(eq(offering.id, id)).returning();

    if (!updated) {
        throw new Error('Offering not found');
    }

    const categories = await getCategoryById(updated.category);

    return {
        id: updated.id.toString(),
        name: updated.title,
        description: updated.description,
        description_page: updated.description_page,
        icon: updated.icon,
        features: (updated.features as string[]) || [],
        category: categories.length > 0 ? categories[0].name : 'Unbekannt',
        category_id: updated.category,
        price: updated.price.toString(),
    };
}

async function deleteOffering(id: number): Promise<boolean> {
    const result = await db.delete(offering).where(eq(offering.id, id)).returning();
    return result.length > 0;
}

const offeringService = { getAllOfferings, getOfferingById, createOffering, updateOffering, deleteOffering };

export { offeringService };
