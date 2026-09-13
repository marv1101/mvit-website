import express, { Request, Response } from 'express';
import rateLimit from 'express-rate-limit';
import { contactService } from '../services/contactService.js';
import { contactObject, contactStatus } from "../models/contact.js";
import { validateContactRequest } from '../validators/contactValidator.js';
import { authMiddleware } from '../middleware/authMiddleware.js';

const router = express.Router();

const VALID_CONTACT_STATUSES: contactStatus[] = ['open', 'handled'];

const contactLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    limit: 5,
    standardHeaders: "draft-7",
    legacyHeaders: false,
    message: { error: "Too many contact submissions. Try again later." },
});

/* POST contact form submission. */
router.post('/', contactLimiter, async (req: Request, res: Response): Promise<void> => {
    try {
        
        const contactData: contactObject = JSON.parse(JSON.stringify(req.body)) as contactObject;

        //input validation
        if (!contactData.name || !contactData.email || !contactData.subject || !contactData.message) {
            res.status(400).json({ error: 'All fields are required: name, email, subject, message' });
            return;
        }

        const validatedContactData = validateContactRequest(contactData);
        if (!validatedContactData) {
            res.status(400).json({ error: 'Invalid contact data format' });
            return;
        }

        const success = await contactService.createContactRequest(validatedContactData);

        if (success) {
            res.json({ message: 'Contact request submitted successfully' });
        } else {
            res.status(500).json({ error: 'Failed to submit contact request',
                details: 'Failed to save contact request to database.' });
        }

    } catch (error) {
        console.log("Error processing contact form submission:", error);
        res.status(500).json({ error: 'Failed to process contact form submission' });
    }
});

/* GET contact requests (auth required). */
router.get('/', authMiddleware, async (req: Request, res: Response): Promise<void> => {
    try {
        const contacts = await contactService.getAllContactRequests();
        res.json(contacts);
    } catch (error) {
        console.log("Error fetching contact requests:", error);
        res.status(500).json({ error: 'Failed to fetch contacts' });
    }
});

/* PATCH contact request status (auth required). */
router.patch('/:id', authMiddleware, async (req: Request, res: Response): Promise<void> => {
    try {
        const contactId = parseInt(req.params.id as string, 10);
        if (isNaN(contactId)) {
            res.status(400).json({ error: 'Invalid contact ID' });
            return;
        }

        const { status } = req.body as { status?: string };
        if (!status || !VALID_CONTACT_STATUSES.includes(status as contactStatus)) {
            res.status(400).json({ error: 'Invalid status. Allowed values: open, handled' });
            return;
        }

        const updated = await contactService.setContactRequestStatus(contactId, status as contactStatus);
        res.json(updated);

    } catch (error) {
        console.log("Error updating contact request:", error);
        if (error instanceof Error && error.message === 'Contact request not found') {
            res.status(404).json({ error: 'Contact request not found' });
        } else {
            res.status(500).json({ error: 'Failed to update contact request' });
        }
    }
});

export default router;