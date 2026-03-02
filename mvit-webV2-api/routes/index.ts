import express, { Request, Response } from 'express';

// create a typed router instance
const router = express.Router();

/* GET default page. */
router.get('/', (req: Request, res: Response): void => {
  res.send('server is up and running');
});

// export as ES module for TypeScript compatibility
export default router;

