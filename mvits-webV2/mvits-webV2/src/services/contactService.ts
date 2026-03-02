import api from "../lib/api";
import type { ContactPayload, ContactResponse } from "../types/contact";

export function sendContactRequest(payload: ContactPayload): Promise<ContactResponse> {
  return api.post<ContactResponse>("/contacts/", payload);
}

export default { sendContactRequest };
