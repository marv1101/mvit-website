import { offeringService } from '../services/offeringService.js';
import { db } from '../db/db.js';
import { offering, offering_category } from '../db/schema.js';

// Mock the database
vi.mock('../db/db.js', () => ({
  db: {
    select: vi.fn(() => ({
      from: vi.fn(() => ({
        offset: vi.fn(() => ({
          limit: vi.fn(),
        })),
      })),
    })),
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
        { id: 1, title: 'Offering 1', description: 'Desc 1', description_page: null, icon: 'icon1', features: {}, price: 100 },
      ];

      const mockCategories = [{ name: 'Category 1' }];

      // Mock the chain
      const mockLimit = vi.fn().mockResolvedValue(mockOfferings);
      const mockOffset = vi.fn(() => ({ limit: mockLimit }));
      const mockFrom = vi.fn(() => ({ offset: mockOffset }));
      const mockSelect = vi.fn(() => ({ from: mockFrom }));

      vi.mocked(db.select).mockImplementation(mockSelect);

      // Mock getCategoriesForOfferingByOfferingId
      const getCategoriesMock = vi.fn().mockResolvedValue(mockCategories);
      (global as any).getCategoriesForOfferingByOfferingId = getCategoriesMock;

      const result = await offeringService.getAllOfferings(0, 10);

      expect(result).toEqual([
        { id: 1, title: 'Offering 1', description: 'Desc 1', description_page: null, icon: 'icon1', features: {}, category: 'Category 1', price: 100 },
      ]);
    });
  });

  describe('getOfferingById', () => {
    it('should return offering by id', async () => {
      const mockOffering = { id: 1, title: 'Offering 1', description: 'Desc 1', description_page: null, icon: 'icon1', features: {}, price: 100 };
      const mockCategories = [{ name: 'Category 1' }];

      const mockLimit = vi.fn().mockResolvedValue([mockOffering]);
      const mockWhere = vi.fn(() => ({ limit: mockLimit }));
      const mockFrom = vi.fn(() => ({ where: mockWhere }));
      const mockSelect = vi.fn(() => ({ from: mockFrom }));

      vi.mocked(db.select).mockImplementation(mockSelect);

      const getCategoriesMock = vi.fn().mockResolvedValue(mockCategories);
      (global as any).getCategoriesForOfferingByOfferingId = getCategoriesMock;

      const result = await offeringService.getOfferingById(1);
      expect(result).toEqual({
        id: 1,
        title: 'Offering 1',
        description: 'Desc 1',
        description_page: null,
        icon: 'icon1',
        features: {},
        category: 'Category 1',
        price: 100,
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