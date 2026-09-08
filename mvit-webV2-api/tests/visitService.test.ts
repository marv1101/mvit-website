import { visitService } from '../services/visitService.js';

describe('Visit Service', () => {
    describe('getClientIp', () => {
        it('should extract IP from x-forwarded-for', () => {
            const req = {
                ip: '127.0.0.1',
                headers: { 'x-forwarded-for': '203.0.113.42, 70.41.3.18' },
            };
            const result = visitService.getClientIp(req);
            expect(result).toBe('203.0.113.42');
        });

        it('should fallback to req.ip', () => {
            const req = {
                ip: '127.0.0.1',
                headers: {},
            };
            const result = visitService.getClientIp(req);
            expect(result).toBe('127.0.0.1');
        });

        it('should return unknown if no IP', () => {
            const req = {
                headers: {},
            };
            const result = visitService.getClientIp(req as any);
            expect(result).toBe('unknown');
        });
    });
});
