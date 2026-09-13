import { referenceService } from '../services/referenceService.js';
import { db } from '../db/db.js';
import { reference } from '../db/schema.js';

// Mock the database
vi.mock('../db/db.js', () => ({
  db: {
    select: vi.fn(),
  },
}));

vi.mock('../db/schema.js', () => ({
  reference: {},
}));

describe('Reference Service', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('getAllReferences', () => {
    it('should return references ordered by created_at descending', async () => {
      const mockReferences = [
        { id: 1, company: 'Company 1', company_url: 'https://example.com', logo_url: null, summary: 'Summary 1', story: 'Story 1', created_at: new Date('2024-01-01T00:00:00Z') },
      ];

      // Simulate db chain: select -> from -> orderBy -> offset -> limit
      const mockLimit = vi.fn().mockResolvedValue(mockReferences);
      const mockOffset = vi.fn(() => ({ limit: mockLimit }));
      const mockOrderBy = vi.fn(() => ({ offset: mockOffset }));
      const mockFrom = vi.fn(() => ({ orderBy: mockOrderBy }));
      const mockSelect = vi.fn(() => ({ from: mockFrom }));

      vi.mocked(db.select).mockImplementation(mockSelect);

      const result = await referenceService.getAllReferences(0, 10);

      expect(result).toEqual([
        { id: '1', company: 'Company 1', company_url: 'https://example.com', logo_url: null, summary: 'Summary 1', story: 'Story 1', created_at: '2024-01-01T00:00:00.000Z' },
      ]);
    });
  });

  describe('getReferenceById', () => {
    it('should return reference by id', async () => {
      const mockReference = { id: 1, company: 'Company 1', company_url: 'https://example.com', logo_url: null, summary: 'Summary 1', story: 'Story 1', created_at: new Date('2024-01-01T00:00:00Z') };

      const mockLimit = vi.fn().mockResolvedValue([mockReference]);
      const mockWhere = vi.fn(() => ({ limit: mockLimit }));
      const mockFrom = vi.fn(() => ({ where: mockWhere }));
      const mockSelect = vi.fn(() => ({ from: mockFrom }));

      vi.mocked(db.select).mockImplementation(mockSelect);

      const result = await referenceService.getReferenceById(1);

      expect(result).toEqual({
        id: '1',
        company: 'Company 1',
        company_url: 'https://example.com',
        logo_url: null,
        summary: 'Summary 1',
        story: 'Story 1',
        created_at: '2024-01-01T00:00:00.000Z',
      });
    });

    it('should throw error if reference not found', async () => {
      const mockLimit = vi.fn().mockResolvedValue([]);
      const mockWhere = vi.fn(() => ({ limit: mockLimit }));
      const mockFrom = vi.fn(() => ({ where: mockWhere }));
      const mockSelect = vi.fn(() => ({ from: mockFrom }));

      vi.mocked(db.select).mockImplementation(mockSelect);

      await expect(referenceService.getReferenceById(999)).rejects.toThrow('Reference not found');
    });
  });
});
