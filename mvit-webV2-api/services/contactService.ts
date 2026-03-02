import { contact } from "../db/schema.js";
import { db } from "../db/db.js";
import { contactObject } from "../models/contact.js";

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

export const contactService = { createContactRequest };