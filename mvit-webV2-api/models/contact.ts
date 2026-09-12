export type contactObject = {
    id: number,
    name: string,
    email: string,
    subject: string,
    message: string
}

export type contactStatus = 'open' | 'handled';

export type contactRequestObject = contactObject & {
    createdAt: string,
    status: contactStatus
}
