import express, { Request, Response } from 'express';
import rateLimit from 'express-rate-limit';
import { contactService } from '../services/contactService.js';
import { contactObject } from "../models/contact.js";
import { validateContactRequest } from '../validators/contactValidator.js';

const router = express.Router();

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

export default router;