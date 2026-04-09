import { contactService } from '../services/contactService.js';
import { db } from '../db/db.js';
import { contact } from '../db/schema.js';

// Mock the database
vi.mock('../db/db.js', () => ({
  db: {
    insert: vi.fn().mockReturnThis(),
    values: vi.fn().mockResolvedValue(undefined),
  },
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
});