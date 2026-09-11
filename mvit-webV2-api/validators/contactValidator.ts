import { contactObject } from "../models/contact.js";

const mailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$";

const MAX_NAME_LENGTH = 100;
const MAX_EMAIL_LENGTH = 254;
const MAX_SUBJECT_LENGTH = 200;
const MAX_MESSAGE_LENGTH = 5000;

export function validateContactRequest(contactData: contactObject): contactObject | null {
    if (!contactData.name || !contactData.email || !contactData.subject || !contactData.message) {
        return null;
    }

    if (contactData.name.length > MAX_NAME_LENGTH) {
        return null;
    }

    if (contactData.email.length > MAX_EMAIL_LENGTH) {
        return null;
    }

    if (contactData.subject.length > MAX_SUBJECT_LENGTH) {
        return null;
    }

    if (contactData.message.length > MAX_MESSAGE_LENGTH) {
        return null;
    }

    if(!contactData.email.match(new RegExp(mailRegex))){
        return null;
    }

    return contactData;
}