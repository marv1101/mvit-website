import api from "../lib/api";
import type { ContactPayload, ContactResponse } from "../types/contact";

export async function sendContactRequest(payload: ContactPayload): Promise<ContactResponse> {
  return await api.post<ContactResponse>("/contacts/", payload);
}

export default { sendContactRequest };
