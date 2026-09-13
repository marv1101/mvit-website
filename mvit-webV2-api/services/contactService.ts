import { contact } from "../db/schema.js";
import { db } from "../db/db.js";
import { contactObject, contactRequestObject, contactStatus } from "../models/contact.js";
import { desc, eq } from "drizzle-orm";

async function createContactRequest(contactRequest: contactObject): Promise<boolean> {

    try{

        await db.insert(contact).values({
            name: contactRequest.name,
            email: contactRequest.email,
            subject: contactRequest.subject,
            message: contactRequest.message
        });

        return true;
    }catch(error){
        console.log("Error creating contact request:", error);
    }

    return false;
}

async function getAllContactRequests(): Promise<contactRequestObject[]> {
    const rows = await db.select().from(contact).orderBy(desc(contact.created_at));

    return rows.map((row) => ({
        id: row.id,
        name: row.name,
        email: row.email,
        subject: row.subject,
        message: row.message,
        createdAt: row.created_at.toISOString(),
        status: row.status as contactStatus,
    }));
}

async function setContactRequestStatus(id: number, status: contactStatus): Promise<contactRequestObject> {
    const [updated] = await db.update(contact)
        .set({ status })
        .where(eq(contact.id, id))
        .returning();

    if (!updated) {
        throw new Error('Contact request not found');
    }

    return {
        id: updated.id,
        name: updated.name,
        email: updated.email,
        subject: updated.subject,
        message: updated.message,
        createdAt: updated.created_at.toISOString(),
        status: updated.status as contactStatus,
    };
}

export const contactService = { createContactRequest, getAllContactRequests, setContactRequestStatus };
