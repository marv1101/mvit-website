import { authService } from '../services/authService.js';
import { db } from '../db/db.js';
import { adminUser } from '../db/schema.js';

vi.mock('../db/db.js', () => ({
    db: {
        select: vi.fn().mockReturnThis(),
        from: vi.fn().mockReturnThis(),
        where: vi.fn().mockReturnThis(),
        insert: vi.fn().mockReturnThis(),
        values: vi.fn().mockReturnThis(),
        returning: vi.fn().mockReturnThis(),
    },
}));

vi.mock('jsonwebtoken', () => ({
    default: {
        sign: vi.fn().mockReturnValue('mock-token'),
        verify: vi.fn().mockReturnValue({ userId: 1, username: 'testuser' }),
    },
    sign: vi.fn().mockReturnValue('mock-token'),
    verify: vi.fn().mockReturnValue({ userId: 1, username: 'testuser' }),
}));

describe('Auth Service', () => {
    const originalEnv = process.env;

    beforeEach(() => {
        vi.clearAllMocks();
        process.env.JWT_SECRET = 'test-secret-key-for-testing';
    });

    afterAll(() => {
        process.env = originalEnv;
    });

    describe('createAdminUser', () => {
        it('should create admin user successfully', async () => {
            vi.mocked(db.select).mockReturnValue({
                from: vi.fn().mockReturnValue({
                    where: vi.fn().mockResolvedValue([]),
                }),
            } as any);

            vi.mocked(db.insert).mockReturnValue({
                values: vi.fn().mockReturnValue({
                    returning: vi.fn().mockResolvedValue([{ id: 1, username: 'testadmin' }]),
                }),
            } as any);

            const result = await authService.createAdminUser({ username: 'testadmin', password: 'password123' });

            expect(result).not.toBeNull();
            expect(result?.user.username).toBe('testadmin');
            expect(result?.token).toBe('mock-token');
        });

        it('should return null if username already exists', async () => {
            vi.mocked(db.select).mockReturnValue({
                from: vi.fn().mockReturnValue({
                    where: vi.fn().mockResolvedValue([{ id: 1, username: 'testadmin' }]),
                }),
            } as any);

            const result = await authService.createAdminUser({ username: 'testadmin', password: 'password123' });

            expect(result).toBeNull();
        });
    });

    describe('login', () => {
        it('should fail for non-existent user', async () => {
            vi.mocked(db.select).mockReturnValue({
                from: vi.fn().mockReturnValue({
                    where: vi.fn().mockResolvedValue([]),
                }),
            } as any);

            const result = await authService.login({ username: 'nonexistent', password: 'password123' });

            expect(result).toBeNull();
        });
    });

    describe('verifyToken', () => {
        it('should verify valid token', () => {
            const result = authService.verifyToken('valid-token');

            expect(result).not.toBeNull();
            expect(result?.username).toBe('testuser');
        });
    });
});
