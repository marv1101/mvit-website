import express, { Request, Response } from 'express';
import { offeringService } from '../services/offeringService.js';

const router = express.Router();

/* GET offerings. */
router.get('/', async (req: Request, res: Response): Promise<void> => {
    try {

        const offerings = await offeringService.getAllOfferings();

        res.json(offerings);
    } catch (error) {
        console.log("Error fetching offerings:", error);
        res.status(500).json({ error: 'Failed to fetch offerings' });
    }
});

export default router;