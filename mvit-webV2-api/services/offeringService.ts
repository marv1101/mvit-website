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

async function getAllOfferings(limit = 10): Promise<OfferingResponse[]> {
    const offerings: offeringObject[] = await db.select().from(offering).limit(limit);

    // fetch categories for all offerings in parallel
    const offeringResponses: OfferingResponse[] = await Promise.all(
        offerings.map(async (off) => {
            const categories = await db
                .select()
                .from(offering_category)
                .where(eq(offering_category.id, off.category));
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

const offeringService = { getAllOfferings };

export { offeringService };
