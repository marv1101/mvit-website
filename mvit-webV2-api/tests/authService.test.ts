import { authService } from '../services/authService.js';
import { db } from '../db/db.js';
import jwt from 'jsonwebtoken';

vi.mock('../db/db.js', () => ({
    db: {
        select: vi.fn().mockReturnThis(),
        from: vi.fn().mockReturnThis(),
        where: vi.fn().mockReturnThis(),
        insert: vi.fn().mockReturnThis(),
        values: vi.fn().mockReturnThis(),
        returning: vi.fn().mockReturnThis(),
        update: vi.fn().mockReturnThis(),
        set: vi.fn().mockReturnThis(),
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

vi.mock('bcrypt', () => ({
    default: {
        hash: vi.fn().mockResolvedValue('hashed-password'),
        compare: vi.fn().mockResolvedValue(true),
    },
    hash: vi.fn().mockResolvedValue('hashed-password'),
    compare: vi.fn().mockResolvedValue(true),
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
            expect(result?.username).toBe('testadmin');
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

        it('should return requirePasswordChange flag', async () => {
            vi.mocked(db.select).mockReturnValue({
                from: vi.fn().mockReturnValue({
                    where: vi.fn().mockResolvedValue([{
                        id: 1,
                        username: 'testadmin',
                        password_hash: 'hashed',
                        force_password_change: true,
                        password_changed_at: null,
                    }]),
                }),
            } as any);

            vi.mocked(db.update).mockReturnValue({
                set: vi.fn().mockReturnValue({
                    where: vi.fn().mockResolvedValue(undefined),
                }),
            } as any);

            const result = await authService.login({ username: 'testadmin', password: 'password123' });

            expect(result).not.toBeNull();
            expect(result?.requirePasswordChange).toBe(true);
        });
    });

    describe('changePassword', () => {
        it('should change password and return a fresh token', async () => {
            vi.mocked(db.update).mockReturnValue({
                set: vi.fn().mockReturnValue({
                    where: vi.fn().mockResolvedValue(undefined),
                }),
            } as any);

            vi.mocked(db.select).mockReturnValue({
                from: vi.fn().mockReturnValue({
                    where: vi.fn().mockResolvedValue([{ id: 1, username: 'testadmin' }]),
                }),
            } as any);

            const result = await authService.changePassword(1, 'newpassword123');

            expect(result).toBe('mock-token');
        });
    });

    describe('generateSecurePassword', () => {
        it('should generate a password of correct length', () => {
            const password = authService.generateSecurePassword(20);
            expect(password.length).toBe(20);
        });

        it('should generate unique passwords', () => {
            const p1 = authService.generateSecurePassword(20);
            const p2 = authService.generateSecurePassword(20);
            expect(p1).not.toBe(p2);
        });
    });

    describe('verifyToken', () => {
        it('should verify valid token and return session info', async () => {
            vi.mocked(db.select).mockReturnValue({
                from: vi.fn().mockReturnValue({
                    where: vi.fn().mockResolvedValue([{
                        id: 1,
                        username: 'testuser',
                        force_password_change: false,
                        password_changed_at: null,
                    }]),
                }),
            } as any);

            const result = await authService.verifyToken('valid-token');

            expect(result).not.toBeNull();
            expect(result?.username).toBe('testuser');
            expect(result?.forcePasswordChange).toBe(false);
        });

        it('should reject tokens issued before the last password change', async () => {
            vi.mocked(jwt.verify).mockReturnValue({ userId: 1, username: 'testuser', iat: 1234567 } as any);
            const changedAt = new Date((1234567 * 1000) + 10_000);
            vi.mocked(db.select).mockReturnValue({
                from: vi.fn().mockReturnValue({
                    where: vi.fn().mockResolvedValue([{
                        id: 1,
                        username: 'testuser',
                        force_password_change: false,
                        password_changed_at: changedAt,
                    }]),
                }),
            } as any);

            const result = await authService.verifyToken('stale-token');

            expect(result).toBeNull();
        });
    });
});
