export type ContactPayload = {
  name: string;
  email: string;
  subject: string;
  message: string;
};

export type ContactResponse = {
  ok: boolean;
  id?: string;
  error?: string;
};
