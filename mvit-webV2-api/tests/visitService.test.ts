import { visitService } from '../services/visitService.js';

vi.mock('../db/db.js', () => ({
    db: {
        transaction: vi.fn(),
        select: vi.fn(),
        from: vi.fn(),
        where: vi.fn(),
        groupBy: vi.fn(),
        orderBy: vi.fn(),
        limit: vi.fn(),
        execute: vi.fn(),
    },
}));

vi.mock('../db/schema.js', () => ({
    pageVisit: {
        visited_at: 'page_visit.visited_at',
        path: 'page_visit.path',
        referrer: 'page_visit.referrer',
        device_type: 'page_visit.device_type',
    },
    pageVisitDaily: {
        day: 'visit_daily.day',
        path: 'visit_daily.path',
        referrer: 'visit_daily.referrer',
        device_type: 'visit_daily.device_type',
        count: 'visit_daily.count',
    },
}));

import { db } from '../db/db.js';

const mockedDb = vi.mocked(db);

describe('Visit Service', () => {
    beforeEach(() => {
        visitService.__resetForTests();
        vi.clearAllMocks();
    });

    describe('getClientIp', () => {
        it('should use req.ip as resolved by express (trust proxy aware)', () => {
            const req = {
                ip: '203.0.113.42',
            };
            const result = visitService.getClientIp(req);
            expect(result).toBe('203.0.113.42');
        });

        it('should ignore spoofable x-forwarded-for header', () => {
            const req = {
                ip: '198.51.100.7',
                headers: { 'x-forwarded-for': '203.0.113.42, 70.41.3.18' },
            } as any;
            const result = visitService.getClientIp(req);
            expect(result).toBe('198.51.100.7');
        });

        it('should return unknown if no IP', () => {
            const req = {};
            const result = visitService.getClientIp(req as any);
            expect(result).toBe('unknown');
        });
    });

    describe('recordVisit (buffering)', () => {
        it('should buffer visits without immediate DB write', async () => {
            const result = await visitService.recordVisit({ path: '/' }, 'Mozilla/5.0', '1.2.3.4');

            expect(result).toBe(true);
            expect(mockedDb.transaction).not.toHaveBeenCalled();
        });

        it('should count buffered visits in stats', async () => {
            mockedDb.transaction.mockResolvedValue(undefined as never);

            await visitService.recordVisit({ path: '/' }, 'Mozilla/5.0', '1.2.3.4');

            await expect(visitService.flushVisits()).resolves.toBe(true);

            expect(mockedDb.transaction).toHaveBeenCalledTimes(1);
        });
    });

    describe('flushVisits', () => {
        it('should succeed with empty buffer without touching db', async () => {
            const result = await visitService.flushVisits();

            expect(result).toBe(true);
            expect(mockedDb.transaction).not.toHaveBeenCalled();
        });

        it('should write buffered visits in a transaction', async () => {
            const tx = vi.fn().mockResolvedValue(undefined);
            const insertFn = vi.fn().mockReturnValue({
                values: vi.fn().mockReturnValue({
                    onConflictDoUpdate: vi.fn().mockResolvedValue(undefined),
                }),
            });
            mockedDb.transaction.mockImplementation(async (cb: any) => {
                await cb({
                    insert: insertFn,
                });
                return undefined;
            });

            await visitService.recordVisit({ path: '/about' }, 'Mozilla/5.0 (iPhone)', '1.2.3.4');
            const result = await visitService.flushVisits();

            expect(result).toBe(true);
            expect(mockedDb.transaction).toHaveBeenCalledTimes(1);
            expect(insertFn).toHaveBeenCalledTimes(2);
        });

        it('should keep buffer on flush failure (retry in memory)', async () => {
            mockedDb.transaction.mockRejectedValue(new Error('DB down'));

            await visitService.recordVisit({ path: '/' }, 'Mozilla/5.0', '1.2.3.4');
            const firstResult = await visitService.flushVisits();
            expect(firstResult).toBe(false);

            mockedDb.transaction.mockResolvedValue(undefined as never);
            const secondResult = await visitService.flushVisits();
            expect(secondResult).toBe(true);
            expect(mockedDb.transaction).toHaveBeenCalledTimes(2);
        });
    });

    describe('stats caching', () => {
        const makeSelectChain = () => {
            const rows = [{ count: 0 }];
            const p: any = Promise.resolve(rows);
            p.from = vi.fn(() => p);
            p.where = vi.fn(() => p);
            p.groupBy = vi.fn(() => p);
            p.orderBy = vi.fn(() => p);
            p.limit = vi.fn(() => p);
            return p;
        };

        it('should serve repeated getStats calls from cache without new db queries', async () => {
            mockedDb.select.mockImplementation(() => makeSelectChain());
            mockedDb.transaction.mockResolvedValue(undefined as never);

            await visitService.recordVisit({ path: '/' }, 'Mozilla/5.0', '1.2.3.4');
            await visitService.flushVisits();

            const stats1 = await visitService.getStats();
            const stats2 = await visitService.getStats();

            expect(stats1).toEqual(stats2);
            expect(mockedDb.select).toHaveBeenCalledTimes(4);
        });

        it('should invalidate cache when a new visit is buffered', async () => {
            mockedDb.select.mockImplementation(() => makeSelectChain());

            await visitService.getStats();
            await visitService.recordVisit({ path: '/' }, 'Mozilla/5.0', '1.2.3.4');
            await visitService.getStats();

            expect(mockedDb.select).toHaveBeenCalledTimes(8);
        });
    });
});
