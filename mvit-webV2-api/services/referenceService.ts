import { referenceObject } from '../models/reference.js';
import { reference } from '../db/schema.js';
import { db } from '../db/db.js';
import { eq, desc } from 'drizzle-orm';

type ReferenceResponse = {
    id: string,
    company: string,
    company_url: string | null,
    logo_url: string | null,
    summary: string,
    story: string,
    created_at: string
};

async function getAllReferences(offset = 0, limit = 10): Promise<ReferenceResponse[]> {
    const references: referenceObject[] = await db.select().from(reference).orderBy(desc(reference.created_at)).offset(offset).limit(limit);

    const referenceResponses: ReferenceResponse[] = references.map((ref) => ({
        id: ref.id.toString(),
        company: ref.company,
        company_url: ref.company_url,
        logo_url: ref.logo_url,
        summary: ref.summary,
        story: ref.story,
        created_at: ref.created_at ? new Date(ref.created_at).toISOString() : new Date(0).toISOString(),
    }));

    return referenceResponses;
}

async function getReferenceById(id: number): Promise<ReferenceResponse> {

    const foundReference: referenceObject = await db.select().from(reference).where(eq(reference.id, id)).limit(1).then(results => results[0]);

    if (!foundReference) {
        throw new Error('Reference not found');
    }

    const responseObject: ReferenceResponse = {
        id: foundReference.id.toString(),
        company: foundReference.company,
        company_url: foundReference.company_url,
        logo_url: foundReference.logo_url,
        summary: foundReference.summary,
        story: foundReference.story,
        created_at: foundReference.created_at ? new Date(foundReference.created_at).toISOString() : new Date(0).toISOString(),
    }

    return responseObject;

}

async function createReference(data: referenceObject): Promise<ReferenceResponse> {
    const [inserted] = await db.insert(reference).values({
        company: data.company,
        company_url: data.company_url,
        logo_url: data.logo_url,
        summary: data.summary,
        story: data.story,
    }).returning();

    return {
        id: inserted.id.toString(),
        company: inserted.company,
        company_url: inserted.company_url,
        logo_url: inserted.logo_url,
        summary: inserted.summary,
        story: inserted.story,
        created_at: inserted.created_at ? new Date(inserted.created_at).toISOString() : new Date(0).toISOString(),
    };
}

async function updateReference(id: number, data: referenceObject): Promise<ReferenceResponse> {
    const [updated] = await db.update(reference).set({
        company: data.company,
        company_url: data.company_url,
        logo_url: data.logo_url,
        summary: data.summary,
        story: data.story,
    }).where(eq(reference.id, id)).returning();

    if (!updated) {
        throw new Error('Reference not found');
    }

    return {
        id: updated.id.toString(),
        company: updated.company,
        company_url: updated.company_url,
        logo_url: updated.logo_url,
        summary: updated.summary,
        story: updated.story,
        created_at: updated.created_at ? new Date(updated.created_at).toISOString() : new Date(0).toISOString(),
    };
}

async function deleteReference(id: number): Promise<boolean> {
    const result = await db.delete(reference).where(eq(reference.id, id)).returning();
    return result.length > 0;
}

const referenceService = { getAllReferences, getReferenceById, createReference, updateReference, deleteReference };

export { referenceService };
