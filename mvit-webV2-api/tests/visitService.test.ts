import { visitService } from '../services/visitService.js';

describe('Visit Service', () => {
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
});
