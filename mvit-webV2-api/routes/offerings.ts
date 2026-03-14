import express, { Request, Response } from 'express';
import { offeringService } from '../services/offeringService.js';

const router = express.Router();

/* GET offerings. 
    Respond with a json array of offerings.
    Each offering includes its category name instead of the category ID.
*/
router.get('/', async (req: Request, res: Response): Promise<void> => {
    try {

        //user pagination parameters if provided, otherwise default values are used
        const offset = parseInt(req.query.offset as string) || 0;
        const limit = parseInt(req.query.limit as string) || 10;

        const offerings = await offeringService.getAllOfferings(offset, limit);

        res.json(offerings);
    } catch (error) {
        console.log("Error fetching offerings:", error);
        res.status(500).json({ error: 'Failed to fetch offerings' });
    }
});

/* GET offering by id. 
    Respond with a json array of offerings.
    Each offering includes its category name instead of the category ID.
*/
router.get('/:id', async (req: Request, res: Response): Promise<void> => {
    try {

        // parse the offering ID from the URL parameter
        const offeringId: number = parseInt(req.params.id[0], 10);

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