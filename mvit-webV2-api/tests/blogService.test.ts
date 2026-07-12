import { blogService } from '../services/blogService.js';
import { drupalDb } from '../db/db.js';
import { and, desc, eq } from 'drizzle-orm';
import { node, nodeFieldData, nodeFieldImage } from '../db/schema_drupal.js';

const { mockQueryBuilder } = vi.hoisted(() => {
  const qb = {
    innerJoin: vi.fn().mockReturnThis(),
    leftJoin: vi.fn().mockReturnThis(),
    where: vi.fn().mockReturnThis(),
    orderBy: vi.fn().mockReturnThis(),
    offset: vi.fn().mockReturnThis(),
    limit: vi.fn(),
  };
  return { mockQueryBuilder: qb };
});

// Mock the database
vi.mock('../db/db.js', () => ({
  drupalDb: {
    select: vi.fn(() => ({ from: vi.fn(() => mockQueryBuilder) })),
  },
}));

function makeRawRow(overrides: Record<string, unknown> = {}) {
  return {
    nid: 1,
    vid: 1,
    langcode: 'en',
    content: 'Content 1',
    summary: 'Summary 1',
    title: 'Title 1',
    fileUri: null,
    created: 123456,
    changed: 123456,
    ...overrides,
  };
}

function makeExpectedRow(overrides: Record<string, unknown> = {}) {
  return {
    nid: 1,
    vid: 1,
    langcode: 'en',
    content: 'Content 1',
    summary: 'Summary 1',
    title: 'Title 1',
    title_image_url: null,
    created: 123456,
    changed: 123456,
    ...overrides,
  };
}

describe('Blog Service', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('getAllBlogposts', () => {
    it('should return blogposts', async () => {
      const rawRows = [makeRawRow()];
      const expected = [makeExpectedRow()];
      mockQueryBuilder.limit.mockResolvedValue(rawRows);

      const result = await blogService.getAllBlogposts(0, 10);
      expect(result).toEqual(expected);
    });

    it('should convert fileUri to title_image_url', async () => {
      const rawRows = [
        makeRawRow({ fileUri: 'public://2025-07/image.jpg' }),
      ];
      const expected = [
        makeExpectedRow({
          title_image_url: 'https://mphion.de/drupal/sites/default/files/2025-07/image.jpg',
        }),
      ];
      mockQueryBuilder.limit.mockResolvedValue(rawRows);

      const result = await blogService.getAllBlogposts(0, 10);
      expect(result).toEqual(expected);
    });
  });

  describe('getBlogpostById', () => {
    it('should return blogpost by id', async () => {
      const rawRows = [makeRawRow()];
      mockQueryBuilder.limit.mockResolvedValue(rawRows);

      const result = await blogService.getBlogpostById(1);
      expect(result).toEqual(makeExpectedRow());
    });

    it('should return null if not found', async () => {
      mockQueryBuilder.limit.mockResolvedValue([]);

      const result = await blogService.getBlogpostById(999);
      expect(result).toBeNull();
    });
  });

  describe('query structure', () => {
    it('should filter published articles and order by created desc', async () => {
      mockQueryBuilder.limit.mockResolvedValue([]);

      await blogService.getAllBlogposts(0, 10);

      expect(mockQueryBuilder.where).toHaveBeenCalledWith(
        and(eq(node.type, 'article'), eq(nodeFieldData.status, 1))
      );
      expect(mockQueryBuilder.orderBy).toHaveBeenCalledWith(
        desc(nodeFieldData.created)
      );
    });

    it('should only join the first image (delta = 0)', async () => {
      mockQueryBuilder.limit.mockResolvedValue([]);

      await blogService.getAllBlogposts(0, 10);

      const imageJoinCall = mockQueryBuilder.leftJoin.mock.calls.find(
        (call) => call[0] === nodeFieldImage
      );
      expect(imageJoinCall).toBeDefined();
      expect(imageJoinCall[1]).toEqual(
        and(
          eq(node.nid, nodeFieldImage.entityId),
          eq(node.vid, nodeFieldImage.revisionId),
          eq(nodeFieldImage.delta, 0)
        )
      );
    });
  });
});