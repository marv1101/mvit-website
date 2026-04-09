import { blogService } from '../services/blogService.js';
import { drupalDb } from '../db/db.js';

// Mock the database
vi.mock('../db/db.js', () => ({
  drupalDb: {
    select: vi.fn().mockReturnThis(),
    from: vi.fn().mockReturnThis(),
    innerJoin: vi.fn().mockReturnThis(),
    where: vi.fn().mockReturnThis(),
    offset: vi.fn().mockReturnThis(),
    limit: vi.fn().mockReturnThis(),
    eq: vi.fn(),
  },
}));

describe('Blog Service', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('getAllBlogposts', () => {
    it('should return blogposts', async () => {
      const mockBlogposts = [
        { nid: 1, vid: 1, langcode: 'en', content: 'Content 1', summary: 'Summary 1', title: 'Title 1', created: 123456, changed: 123456 },
      ];

      vi.mocked(drupalDb.select).mockReturnValue(mockBlogposts);
      vi.mocked(drupalDb.from).mockReturnValue({
        innerJoin: vi.fn().mockReturnThis(),
        where: vi.fn().mockReturnThis(),
        offset: vi.fn().mockReturnThis(),
        limit: vi.fn().mockResolvedValue(mockBlogposts),
      });

      const result = await blogService.getAllBlogposts(0, 10);
      expect(result).toEqual(mockBlogposts);
    });
  });

  describe('getBlogpostById', () => {
    it('should return blogpost by id', async () => {
      const mockBlogpost = { nid: 1, vid: 1, langcode: 'en', content: 'Content 1', summary: 'Summary 1', title: 'Title 1', created: 123456, changed: 123456 };

      vi.mocked(drupalDb.select).mockReturnValue([mockBlogpost]);
      vi.mocked(drupalDb.from).mockReturnValue({
        innerJoin: vi.fn().mockReturnThis(),
        where: vi.fn().mockReturnThis(),
        limit: vi.fn().mockResolvedValue([mockBlogpost]),
      });

      const result = await blogService.getBlogpostById(1);
      expect(result).toEqual(mockBlogpost);
    });

    it('should return null if not found', async () => {
      vi.mocked(drupalDb.select).mockReturnValue([]);
      vi.mocked(drupalDb.from).mockReturnValue({
        innerJoin: vi.fn().mockReturnThis(),
        where: vi.fn().mockReturnThis(),
        limit: vi.fn().mockResolvedValue([]),
      });

      const result = await blogService.getBlogpostById(999);
      expect(result).toBeNull();
    });
  });
});