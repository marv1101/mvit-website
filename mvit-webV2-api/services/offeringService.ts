import { offeringObject } from '../models/offering.js';
import { offering, offering_category } from '../db/schema.js';
import { db } from '../db/db.js';
import { eq } from 'drizzle-orm';

type OfferingResponse = {
    id: number,
    title: string,
    description: string,
    icon: string,
    features: unknown,
    category: string,
    price: number
};

async function getCategoriesForOfferingByOfferingId(offeringId: number): Promise<any> {
    return db
                .select()
                .from(offering_category)
                .where(eq(offering_category.id, offeringId));
}

async function getAllOfferings(limit = 10): Promise<OfferingResponse[]> {
    const offerings: offeringObject[] = await db.select().from(offering).limit(limit);

    // fetch categories for all offerings in parallel
    const offeringResponses: OfferingResponse[] = await Promise.all(
        offerings.map(async (off) => {
            const categories = await getCategoriesForOfferingByOfferingId(off.id);
            return {
                id: off.id,
                title: off.title,
                description: off.description,
                icon: off.icon,
                features: off.features,
                category: categories.length > 0 ? categories[0].name : 'Unbekannt',
                price: off.price,
            } as OfferingResponse;
        })
    );

    return offeringResponses;
}

async function getOfferingById(id: number): Promise<OfferingResponse> {

    const foundOffering: offeringObject = await db.select().from(offering).where(eq(offering.id, id)).limit(1).then(results => results[0]);
    const categories = await getCategoriesForOfferingByOfferingId(id);

    if (!foundOffering) {
        throw new Error('Offering not found');

    }

    const responseObject: OfferingResponse = {
        id: foundOffering.id,
        title: foundOffering.title,
        description: foundOffering.description,
        icon: foundOffering.icon,
        features: foundOffering.features,
        category: categories.length > 0 ? categories[0].name : 'Unbekannt',
        price: foundOffering.price,
    }

    return responseObject;

}

const offeringService = { getAllOfferings, getOfferingById };

export { offeringService };
