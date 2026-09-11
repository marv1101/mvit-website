import express, { Request, Response } from 'express';
import { offeringService } from '../services/offeringService.js';
import { validateOfferingRequest } from '../validators/offeringValidator.js';
import { authMiddleware } from '../middleware/authMiddleware.js';

const router = express.Router();

/* GET offerings. */
router.get('/', async (req: Request, res: Response): Promise<void> => {
    try {
        const offset = parseInt(req.query.offset as string) || 0;
        const limit = parseInt(req.query.limit as string) || 10;

        const offerings = await offeringService.getAllOfferings(offset, limit);

        res.json(offerings);
    } catch (error) {
        console.log("Error fetching offerings:", error);
        res.status(500).json({ error: 'Failed to fetch offerings' });
    }
});

/* GET offering by id. */
router.get('/:id', async (req: Request, res: Response): Promise<void> => {
    try {
        const offeringId: number = parseInt(req.params.id as string, 10);

        if (isNaN(offeringId)) {
            res.status(400).json({ error: 'Invalid offering ID' });
            return;
        }

        const offering = await offeringService.getOfferingById(offeringId);

        if (!offering) {
            res.status(404).json({ error: 'Offering not found' });
            return;
        }

        res.json(offering);

    } catch (error) {
        console.log("Error fetching offering by ID:", error);
        res.status(500).json({ error: 'Failed to fetch offering' });
    }
});

/* POST create new offering (auth required). */
router.post('/', authMiddleware, async (req: Request, res: Response): Promise<void> => {
    try {
        const validatedData = validateOfferingRequest(req.body);
        if (!validatedData) {
            res.status(400).json({ error: 'Invalid offering data. Required: title, description, icon, category (number), price (number)' });
            return;
        }

        const newOffering = await offeringService.createOffering(validatedData);
        res.status(201).json(newOffering);

    } catch (error) {
        console.log("Error creating offering:", error);
        res.status(500).json({ error: 'Failed to create offering' });
    }
});

/* PUT update offering (auth required). */
router.put('/:id', authMiddleware, async (req: Request, res: Response): Promise<void> => {
    try {
        const offeringId = parseInt(req.params.id as string, 10);
        if (isNaN(offeringId)) {
            res.status(400).json({ error: 'Invalid offering ID' });
            return;
        }

        const validatedData = validateOfferingRequest(req.body);
        if (!validatedData) {
            res.status(400).json({ error: 'Invalid offering data. Required: title, description, icon, category (number), price (number)' });
            return;
        }

        const updatedOffering = await offeringService.updateOffering(offeringId, validatedData);
        res.json(updatedOffering);

    } catch (error) {
        console.log("Error updating offering:", error);
        if (error instanceof Error && error.message === 'Offering not found') {
            res.status(404).json({ error: 'Offering not found' });
        } else {
            res.status(500).json({ error: 'Failed to update offering' });
        }
    }
});

/* DELETE offering (auth required). */
router.delete('/:id', authMiddleware, async (req: Request, res: Response): Promise<void> => {
    try {
        const offeringId = parseInt(req.params.id as string, 10);
        if (isNaN(offeringId)) {
            res.status(400).json({ error: 'Invalid offering ID' });
            return;
        }

        const deleted = await offeringService.deleteOffering(offeringId);
        if (!deleted) {
            res.status(404).json({ error: 'Offering not found' });
            return;
        }

        res.json({ message: 'Offering deleted successfully' });

    } catch (error) {
        console.log("Error deleting offering:", error);
        res.status(500).json({ error: 'Failed to delete offering' });
    }
});

export default router;
