import express, { Request, Response } from 'express';
import { blogService } from '../services/blogService.js';

const router = express.Router();

router.get('/', async (req: Request, res: Response): Promise<void> => {
    try {
        //user pagination parameters if provided, otherwise default values are used
        const offset = parseInt(req.query.offset as string, 10) || 0;
        const limit = parseInt(req.query.limit as string, 10) || 10;

        const blogposts = await blogService.getAllBlogposts(offset, limit);

        res.json(blogposts);
    } catch (error) {
        console.log("Error fetching blogposts:", error);
        res.status(500).json({ error: 'Failed to fetch blogposts' });
    }
});

router.get('/:id', async (req: Request, res: Response): Promise<void> => {
    try {

        // parse the blogpost ID from the URL parameter
        const blogpostId: number = parseInt(req.params.id, 10);

        const blogpost = await blogService.getBlogpostById(blogpostId);

        if (!blogpost) {
            res.status(404).json({ error: 'Blogpost not found' });
            return;
        }

        res.json(blogpost);

    }catch (error) {
        console.log("Error fetching blogpost by ID:", error);
        res.status(500).json({ error: 'Failed to fetch blogpost' });
    }
})

export default router;