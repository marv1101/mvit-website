import { offeringObject } from '../models/offering.js';
import { offering } from '../db/schema.js';
import { db } from '../db/db.js';

async function getAllOfferings(limit = 10): Promise<offeringObject[]> {
    const offerings: offeringObject[] = await db.select().from(offering).limit(limit);
    return offerings;
}

const offeringService = { getAllOfferings };

export { offeringService };
