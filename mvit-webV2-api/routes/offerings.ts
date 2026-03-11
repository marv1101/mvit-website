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

router.get('/:id', async (req: Request, res: Response): Promise<void> => {
    try {

        const offeringId = req.params.id;

        const offering = await offeringService.getOfferingById(offeringId);

        if (!offering) {
            res.status(404).json({ error: 'Offering not found' });
            return;
        }

        res.json(offering);

    }catch (error) {
        console.log("Error fetching offering by ID:", error);
        res.status(500).json({ error: 'Failed to fetch offering' });
    }
})

export default router;