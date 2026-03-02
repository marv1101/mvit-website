import { contactObject } from "../models/contact.js";

const mailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$";

export function validateContactRequest(contactData: contactObject): contactObject | null {
    if (!contactData.name || !contactData.email || !contactData.subject || !contactData.message) {
        return null;
    }

    if(!contactData.email.match(new RegExp(mailRegex))){
        return null;
    }

    return contactData;
}