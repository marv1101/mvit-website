import createError from 'http-errors';
import express, { Request, Response, NextFunction } from 'express';
import path from 'path';
import cookieParser from 'cookie-parser';
import logger from 'morgan';
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import cors from 'cors';
import cron from 'node-cron';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

import indexRouter from './routes/index.js';
import usersRouter from './routes/users.js';
import offeringsRouter from './routes/offerings.js';
import contactsRouter from './routes/contacts.js';
import blogpostsRouter from './routes/blogposts.js';
import authRouter from './routes/auth.js';
import visitsRouter from './routes/visits.js';
import { visitService } from './services/visitService.js';

const app = express();

app.use(logger('dev'));
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/api/', indexRouter);
app.use('/api/health', (_req: Request, res: Response) => {
  res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });
});
app.use('/api/users', usersRouter);
app.use('/api/offerings', offeringsRouter);
app.use('/api/contacts', contactsRouter);
app.use('/api/blogposts', blogpostsRouter);
app.use('/api/auth', authRouter);
app.use('/api/visits', visitsRouter);

// catch 404 and forward to error handler
app.use((req: Request, res: Response, next: NextFunction) => {
  next(createError(404));
});

// error handler
app.use((err: any, req: Request, res: Response, next: NextFunction) => {
  res.status(err.status || 500).json({ error: err.message || 'Internal Server Error' });
});

const RETENTION_DAYS = parseInt(process.env.VISIT_RETENTION_DAYS || "90", 10);
cron.schedule('0 3 * * *', async () => {
  try {
    const deleted = await visitService.cleanupOldVisits(RETENTION_DAYS);
    console.log(`[Cleanup] Removed ${deleted} old visit records`);
  } catch (error) {
    console.log('[Cleanup] Error during visit cleanup:', error);
  }
});

export default app;
