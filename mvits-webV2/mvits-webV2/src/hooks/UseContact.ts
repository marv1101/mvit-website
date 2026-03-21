import { useState } from "react";
import { sendContactRequest } from "../services/ContactService";
import type { ContactPayload, ContactResponse } from "../types/contact";

export function UseContact() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function submit(payload: ContactPayload): Promise<ContactResponse | null> {
    setLoading(true);
    setError(null);
    
    try {
      const res = await sendContactRequest(payload);
      return res;
    } catch (err: any) {
      setError(err?.message || "Unknown error");
      return null;
    } finally {
      setLoading(false);
    }
  }

  return { submit, loading, error } as const;
}

export default UseContact;
