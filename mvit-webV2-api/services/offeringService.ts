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

    // fetch categories for all offerings in parallel
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
                price: off.price.toString(),
            } as OfferingResponse;
        })
    );

    return offeringResponses;
}

async function getOfferingById(id: number): Promise<OfferingResponse> {

    //get single offering by ID
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
        price: foundOffering.price.toString(),
    }

    return responseObject;

}

const offeringService = { getAllOfferings, getOfferingById };

export { offeringService };
