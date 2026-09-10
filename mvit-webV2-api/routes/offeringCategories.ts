import express, { Request, Response } from 'express';
import { offeringCategoryService } from '../services/offeringCategoryService.js';
import { validateCategoryRequest } from '../validators/offeringCategoryValidator.js';
import { authMiddleware } from '../middleware/authMiddleware.js';

const router = express.Router();

/* GET all offering categories. */
router.get('/', async (_req: Request, res: Response): Promise<void> => {
    try {
        const categories = await offeringCategoryService.getAllCategories();
        res.json(categories);
    } catch (error) {
        console.log("Error fetching categories:", error);
        res.status(500).json({ error: 'Failed to fetch categories' });
    }
});

/* POST create new category (auth required). */
router.post('/', authMiddleware, async (req: Request, res: Response): Promise<void> => {
    try {
        const validatedData = validateCategoryRequest(req.body);
        if (!validatedData) {
            res.status(400).json({ error: 'Invalid category data. Required: name (string)' });
            return;
        }

        const newCategory = await offeringCategoryService.createCategory(validatedData);
        res.status(201).json(newCategory);

    } catch (error) {
        console.log("Error creating category:", error);
        res.status(500).json({ error: 'Failed to create category' });
    }
});

/* PUT update category (auth required). */
router.put('/:id', authMiddleware, async (req: Request, res: Response): Promise<void> => {
    try {
        const categoryId = parseInt(req.params.id as string, 10);
        if (isNaN(categoryId)) {
            res.status(400).json({ error: 'Invalid category ID' });
            return;
        }

        const validatedData = validateCategoryRequest(req.body);
        if (!validatedData) {
            res.status(400).json({ error: 'Invalid category data. Required: name (string)' });
            return;
        }

        const updatedCategory = await offeringCategoryService.updateCategory(categoryId, validatedData);
        res.json(updatedCategory);

    } catch (error) {
        console.log("Error updating category:", error);
        if (error instanceof Error && error.message === 'Category not found') {
            res.status(404).json({ error: 'Category not found' });
        } else {
            res.status(500).json({ error: 'Failed to update category' });
        }
    }
});

/* DELETE category (auth required). */
router.delete('/:id', authMiddleware, async (req: Request, res: Response): Promise<void> => {
    try {
        const categoryId = parseInt(req.params.id as string, 10);
        if (isNaN(categoryId)) {
            res.status(400).json({ error: 'Invalid category ID' });
            return;
        }

        const deleted = await offeringCategoryService.deleteCategory(categoryId);
        if (!deleted) {
            res.status(404).json({ error: 'Category not found' });
            return;
        }

        res.json({ message: 'Category deleted successfully' });

    } catch (error) {
        console.log("Error deleting category:", error);
        res.status(500).json({ error: 'Failed to delete category' });
    }
});

export default router;
