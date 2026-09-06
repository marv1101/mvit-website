import { offeringService } from '../services/offeringService.js';
import { db } from '../db/db.js';
import { offering, offering_category } from '../db/schema.js';

// Mock the database
vi.mock('../db/db.js', () => ({
  db: {
    select: vi.fn(),
  },
}));

vi.mock('../db/schema.js', () => ({
  offering: {},
  offering_category: {},
}));

describe('Offering Service', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('getAllOfferings', () => {
    it('should return offerings with categories', async () => {
      const mockOfferings = [
        { id: 1, title: 'Offering 1', description: 'Desc 1', description_page: null, icon: 'icon1', features: ['Feature 1', 'Feature 2'], category: 1, price: 100 },
      ];

      const mockCategories = [{ name: 'Category 1' }];

      // Simulate db chain: select -> from -> offset -> limit (outer getAllOfferings)
      // plus:                             -> where   (inner getCategoryById)
      const mockLimit = vi.fn().mockResolvedValue(mockOfferings);
      const mockOffset = vi.fn(() => ({ limit: mockLimit }));
      const mockWhere = vi.fn().mockResolvedValue(mockCategories);
      const mockFrom = vi.fn(() => ({ offset: mockOffset, where: mockWhere }));
      const mockSelect = vi.fn(() => ({ from: mockFrom }));

      vi.mocked(db.select).mockImplementation(mockSelect);

      const result = await offeringService.getAllOfferings(0, 10);

      expect(result).toEqual([
        { id: '1', name: 'Offering 1', description: 'Desc 1', description_page: null, icon: 'icon1', features: ['Feature 1', 'Feature 2'], category: 'Category 1', price: '100' },
      ]);
    });
  });

  describe('getOfferingById', () => {
    it('should return offering by id', async () => {
      const mockOffering = { id: 1, title: 'Offering 1', description: 'Desc 1', description_page: null, icon: 'icon1', features: ['Feature 1', 'Feature 2'], category: 1, price: 100 };
      const mockCategories = [{ name: 'Category 1' }];

      const mockLimit = vi.fn().mockResolvedValue([mockOffering]);
      const mockWhereCategory = vi.fn().mockResolvedValue(mockCategories);
      const mockWhereId = vi.fn(() => ({ limit: mockLimit }));
      const mockFrom = vi.fn(() => ({ where: mockWhereId, offset: vi.fn() }));
      const mockSelect = vi.fn(() => ({ from: mockFrom }));

      vi.mocked(db.select).mockImplementation(mockSelect);
      // Also mock the select() call for getCategoryById
      // The second call to db.select() also goes through the same mockSelect chain,
      // but getCategoryById does .where() directly after .from() → mockWhereCategory
      // We bind a separate mock for the "where" path used by getCategoryById
      const mockFrom2 = vi.fn(() => ({ where: mockWhereCategory }));
      const mockSelect2 = vi.fn(() => ({ from: mockFrom2 }));
      // After the first select() call (getOfferingById), second select() call should use categories mock
      vi.mocked(db.select)
        .mockImplementationOnce(mockSelect)  // call 1: getOfferingById
        .mockImplementationOnce(mockSelect2); // call 2: getCategoryById

      const result = await offeringService.getOfferingById(1);
      expect(result).toEqual({
        id: '1',
        name: 'Offering 1',
        description: 'Desc 1',
        description_page: null,
        icon: 'icon1',
        features: ['Feature 1', 'Feature 2'],
        category: 'Category 1',
        price: '100',
      });
    });

    it('should throw error if offering not found', async () => {
      const mockLimit = vi.fn().mockResolvedValue([]);
      const mockWhere = vi.fn(() => ({ limit: mockLimit }));
      const mockFrom = vi.fn(() => ({ where: mockWhere }));
      const mockSelect = vi.fn(() => ({ from: mockFrom }));

      vi.mocked(db.select).mockImplementation(mockSelect);

      await expect(offeringService.getOfferingById(999)).rejects.toThrow('Offering not found');
    });
  });
});