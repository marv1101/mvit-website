import { contactService } from '../services/contactService.js';
import { db } from '../db/db.js';
import { contact } from '../db/schema.js';
import { desc } from 'drizzle-orm';

// Mock the database
vi.mock('../db/db.js', () => ({
  db: {
    select: vi.fn(),
    from: vi.fn(),
    where: vi.fn(),
    orderBy: vi.fn(),
    insert: vi.fn().mockReturnThis(),
    values: vi.fn().mockResolvedValue(undefined),
    update: vi.fn(),
    set: vi.fn(),
    returning: vi.fn(),
  },
}));

vi.mock('drizzle-orm', () => ({
  eq: vi.fn(),
  desc: vi.fn(),
}));

describe('Contact Service', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('createContactRequest', () => {
    it('should create contact successfully', async () => {
      const contactData = { name: 'Test', email: 'test@example.com', subject: 'Subject', message: 'Message' };

      const result = await contactService.createContactRequest(contactData);
      expect(result).toBe(true);
      expect(vi.mocked(db).insert).toHaveBeenCalledWith(contact);
    });

    it('should return false on error', async () => {
      const contactData = { name: 'Test', email: 'test@example.com', subject: 'Subject', message: 'Message' };

      vi.mocked(db.insert).mockImplementation(() => {
        throw new Error('DB Error');
      });

      const result = await contactService.createContactRequest(contactData);
      expect(result).toBe(false);
    });
  });

  describe('getAllContactRequests', () => {
    it('should return all contact requests ordered by createdAt desc', async () => {
      const mockContacts = [
        { id: 2, name: 'Jane', email: 'jane@example.com', subject: 'S2', message: 'M2', created_at: new Date('2026-09-12T10:00:00Z'), status: 'open' },
        { id: 1, name: 'John', email: 'john@example.com', subject: 'S1', message: 'M1', created_at: new Date('2026-09-11T10:00:00Z'), status: 'handled' },
      ];

      const mockOrderBy = vi.fn().mockResolvedValue(mockContacts);
      const mockFrom = vi.fn(() => ({ orderBy: mockOrderBy }));
      vi.mocked(db.select).mockReturnValue({ from: mockFrom } as any);

      const result = await contactService.getAllContactRequests();

      expect(result).toEqual([
        { id: 2, name: 'Jane', email: 'jane@example.com', subject: 'S2', message: 'M2', createdAt: '2026-09-12T10:00:00.000Z', status: 'open' },
        { id: 1, name: 'John', email: 'john@example.com', subject: 'S1', message: 'M1', createdAt: '2026-09-11T10:00:00.000Z', status: 'handled' },
      ]);
      expect(db.select).toHaveBeenCalled();
      expect(mockOrderBy).toHaveBeenCalledWith(desc(contact.created_at));
    });
  });

  describe('setContactRequestStatus', () => {
    it('should update status and return updated contact', async () => {
      const updated = { id: 1, name: 'John', email: 'john@example.com', subject: 'S1', message: 'M1', created_at: new Date('2026-09-11T10:00:00Z'), status: 'handled' };

      const mockReturning = vi.fn().mockResolvedValue([updated]);
      const mockWhere = vi.fn(() => ({ returning: mockReturning }));
      const mockSet = vi.fn(() => ({ where: mockWhere }));
      vi.mocked(db.update).mockReturnValue({ set: mockSet } as any);

      const result = await contactService.setContactRequestStatus(1, 'handled');

      expect(result).toEqual({ id: 1, name: 'John', email: 'john@example.com', subject: 'S1', message: 'M1', createdAt: '2026-09-11T10:00:00.000Z', status: 'handled' });
      expect(db.update).toHaveBeenCalledWith(contact);
      expect(mockSet).toHaveBeenCalledWith({ status: 'handled' });
    });

    it('should throw if contact not found', async () => {
      const mockReturning = vi.fn().mockResolvedValue([]);
      const mockWhere = vi.fn(() => ({ returning: mockReturning }));
      const mockSet = vi.fn(() => ({ where: mockWhere }));
      vi.mocked(db.update).mockReturnValue({ set: mockSet } as any);

      await expect(contactService.setContactRequestStatus(999, 'open')).rejects.toThrow(
        'Contact request not found'
      );
    });
  });
});
