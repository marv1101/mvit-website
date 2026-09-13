import express, { Request, Response } from 'express';
import { referenceService } from '../services/referenceService.js';
import { validateReferenceRequest } from '../validators/referenceValidator.js';
import { authMiddleware } from '../middleware/authMiddleware.js';

const router = express.Router();

/* GET references. */
router.get('/', async (req: Request, res: Response): Promise<void> => {
    try {
        const offset = parseInt(req.query.offset as string) || 0;
        const limit = parseInt(req.query.limit as string) || 10;

        const references = await referenceService.getAllReferences(offset, limit);

        res.json(references);
    } catch (error) {
        console.log("Error fetching references:", error);
        res.status(500).json({ error: 'Failed to fetch references' });
    }
});

/* GET reference by id. */
router.get('/:id', async (req: Request, res: Response): Promise<void> => {
    try {
        const referenceId: number = parseInt(req.params.id as string, 10);

        if (isNaN(referenceId)) {
            res.status(400).json({ error: 'Invalid reference ID' });
            return;
        }

        const reference = await referenceService.getReferenceById(referenceId);

        if (!reference) {
            res.status(404).json({ error: 'Reference not found' });
            return;
        }

        res.json(reference);

    } catch (error) {
        console.log("Error fetching reference by ID:", error);
        res.status(500).json({ error: 'Failed to fetch reference' });
    }
});

/* POST create new reference (auth required). */
router.post('/', authMiddleware, async (req: Request, res: Response): Promise<void> => {
    try {
        const validatedData = validateReferenceRequest(req.body);
        if (!validatedData) {
            res.status(400).json({ error: 'Invalid reference data. Required: company, summary, story' });
            return;
        }

        const newReference = await referenceService.createReference(validatedData);
        res.status(201).json(newReference);

    } catch (error) {
        console.log("Error creating reference:", error);
        res.status(500).json({ error: 'Failed to create reference' });
    }
});

/* PUT update reference (auth required). */
router.put('/:id', authMiddleware, async (req: Request, res: Response): Promise<void> => {
    try {
        const referenceId = parseInt(req.params.id as string, 10);
        if (isNaN(referenceId)) {
            res.status(400).json({ error: 'Invalid reference ID' });
            return;
        }

        const validatedData = validateReferenceRequest(req.body);
        if (!validatedData) {
            res.status(400).json({ error: 'Invalid reference data. Required: company, summary, story' });
            return;
        }

        const updatedReference = await referenceService.updateReference(referenceId, validatedData);
        res.json(updatedReference);

    } catch (error) {
        console.log("Error updating reference:", error);
        if (error instanceof Error && error.message === 'Reference not found') {
            res.status(404).json({ error: 'Reference not found' });
        } else {
            res.status(500).json({ error: 'Failed to update reference' });
        }
    }
});

/* DELETE reference (auth required). */
router.delete('/:id', authMiddleware, async (req: Request, res: Response): Promise<void> => {
    try {
        const referenceId = parseInt(req.params.id as string, 10);
        if (isNaN(referenceId)) {
            res.status(400).json({ error: 'Invalid reference ID' });
            return;
        }

        const deleted = await referenceService.deleteReference(referenceId);
        if (!deleted) {
            res.status(404).json({ error: 'Reference not found' });
            return;
        }

        res.json({ message: 'Reference deleted successfully' });

    } catch (error) {
        console.log("Error deleting reference:", error);
        res.status(500).json({ error: 'Failed to delete reference' });
    }
});

export default router;
