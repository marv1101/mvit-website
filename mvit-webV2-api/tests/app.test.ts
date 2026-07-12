import request from 'supertest';
import app from '../app.js';
import { offeringService } from '../services/offeringService.js';
import { blogService } from '../services/blogService.js';
import { contactService } from '../services/contactService.js';

// Mock the database and services
vi.mock('../db/db.js', () => ({
  db: {
    select: vi.fn(),
    from: vi.fn(),
    where: vi.fn(),
    offset: vi.fn(),
    limit: vi.fn(),
    eq: vi.fn(),
  },
}));

vi.mock('../services/offeringService.js', () => ({
  offeringService: {
    getAllOfferings: vi.fn(),
    getOfferingById: vi.fn(),
  },
}));

vi.mock('../services/blogService.js', () => ({
  blogService: {
    getAllBlogposts: vi.fn(),
    getBlogpostById: vi.fn(),
  },
}));

vi.mock('../services/contactService.js', () => ({
  contactService: {
    createContactRequest: vi.fn(),
    getAllContacts: vi.fn(),
  },
}));

describe('API Integration Tests', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('GET /api/', () => {
    it('should return server status', async () => {
      const response = await request(app).get('/api/');
      expect(response.status).toBe(200);
      expect(response.text).toBe('server is up and running');
    });
  });

  describe('GET /api/offerings', () => {
    it('should return offerings with default pagination', async () => {
      const mockOfferings = [
        { id: 1, title: 'Test Offering', description: 'Desc', description_page: null, icon: 'icon', features: {}, category: 'Test Cat', price: 100 },
      ];
      vi.mocked(offeringService).getAllOfferings.mockResolvedValue(mockOfferings);

      const response = await request(app).get('/api/offerings');
      expect(response.status).toBe(200);
      expect(response.body).toEqual(mockOfferings);
      expect(vi.mocked(offeringService).getAllOfferings).toHaveBeenCalledWith(0, 10);
    });

    it('should return offerings with custom pagination', async () => {
      const mockOfferings = [];
      vi.mocked(offeringService).getAllOfferings.mockResolvedValue(mockOfferings);

      const response = await request(app).get('/api/offerings?offset=5&limit=20');
      expect(response.status).toBe(200);
      expect(vi.mocked(offeringService).getAllOfferings).toHaveBeenCalledWith(5, 20);
    });

    it('should handle errors', async () => {
      vi.mocked(offeringService).getAllOfferings.mockRejectedValue(new Error('DB Error'));

      const response = await request(app).get('/api/offerings');
      expect(response.status).toBe(500);
      expect(response.body).toEqual({ error: 'Failed to fetch offerings' });
    });
  });

  describe('GET /api/offerings/:id', () => {
    it('should return offering by id', async () => {
      const mockOffering = { id: 1, title: 'Test Offering', description: 'Desc', description_page: null, icon: 'icon', features: {}, category: 'Test Cat', price: 100 };
      vi.mocked(offeringService).getOfferingById.mockResolvedValue(mockOffering);

      const response = await request(app).get('/api/offerings/1');
      expect(response.status).toBe(200);
      expect(response.body).toEqual(mockOffering);
      expect(vi.mocked(offeringService).getOfferingById).toHaveBeenCalledWith(1);
    });

    it('should return 404 if offering not found', async () => {
      vi.mocked(offeringService).getOfferingById.mockResolvedValue(null);

      const response = await request(app).get('/api/offerings/999');
      expect(response.status).toBe(404);
      expect(response.body).toEqual({ error: 'Offering not found' });
    });

    it('should handle errors', async () => {
      vi.mocked(offeringService).getOfferingById.mockRejectedValue(new Error('DB Error'));

      const response = await request(app).get('/api/offerings/1');
      expect(response.status).toBe(500);
      expect(response.body).toEqual({ error: 'Failed to fetch offering' });
    });
  });

  // Add similar tests for other routes: blogposts, contacts, users
  // For brevity, I'll add placeholders

  describe('GET /api/blogposts', () => {
    it('should return blogposts with default pagination', async () => {
      const mockBlogposts = [{ nid: 1, title: 'Test Blog', content: 'Content' }];
      vi.mocked(blogService).getAllBlogposts.mockResolvedValue(mockBlogposts);

      const response = await request(app).get('/api/blogposts');
      expect(response.status).toBe(200);
      expect(response.body).toEqual(mockBlogposts);
      expect(vi.mocked(blogService).getAllBlogposts).toHaveBeenCalledWith(0, 10);
    });

    it('should handle errors', async () => {
      vi.mocked(blogService).getAllBlogposts.mockRejectedValue(new Error('DB Error'));

      const response = await request(app).get('/api/blogposts');
      expect(response.status).toBe(500);
      expect(response.body).toEqual({ error: 'Failed to fetch blogposts' });
    });
  });

  describe('GET /api/blogposts/:id', () => {
    it('should return blogpost by id', async () => {
      const mockBlogpost = { nid: 1, title: 'Test Blog', content: 'Content' };
      vi.mocked(blogService).getBlogpostById.mockResolvedValue(mockBlogpost);

      const response = await request(app).get('/api/blogposts/1');
      expect(response.status).toBe(200);
      expect(response.body).toEqual(mockBlogpost);
      expect(vi.mocked(blogService).getBlogpostById).toHaveBeenCalledWith(1);
    });

    it('should parse multi-digit ids correctly', async () => {
      const mockBlogpost = { nid: 123, title: 'Test Blog', content: 'Content' };
      vi.mocked(blogService).getBlogpostById.mockResolvedValue(mockBlogpost);

      const response = await request(app).get('/api/blogposts/123');
      expect(response.status).toBe(200);
      expect(response.body).toEqual(mockBlogpost);
      expect(vi.mocked(blogService).getBlogpostById).toHaveBeenCalledWith(123);
    });

    it('should return 404 if blogpost not found', async () => {
      vi.mocked(blogService).getBlogpostById.mockResolvedValue(null);

      const response = await request(app).get('/api/blogposts/999');
      expect(response.status).toBe(404);
      expect(response.body).toEqual({ error: 'Blogpost not found' });
    });
  });

  describe('POST /api/contacts', () => {
    it('should create contact successfully', async () => {
      const contactData = { name: 'Test', email: 'test@example.com', subject: 'Subject', message: 'Message' };
      vi.mocked(contactService).createContactRequest.mockResolvedValue(true);

      const response = await request(app).post('/api/contacts').send(contactData);
      expect(response.status).toBe(200);
      expect(response.body).toEqual({ message: 'Contact request submitted successfully' });
    });

    it('should return 400 for missing fields', async () => {
      const response = await request(app).post('/api/contacts').send({ name: 'Test' });
      expect(response.status).toBe(400);
      expect(response.body).toEqual({ error: 'All fields are required: name, email, subject, message' });
    });

    it('should return 400 for invalid email', async () => {
      const contactData = { name: 'Test', email: 'invalid', subject: 'Subject', message: 'Message' };
      const response = await request(app).post('/api/contacts').send(contactData);
      expect(response.status).toBe(400);
      expect(response.body).toEqual({ error: 'Invalid contact data format' });
    });

    it('should handle service failure', async () => {
      const contactData = { name: 'Test', email: 'test@example.com', subject: 'Subject', message: 'Message' };
      vi.mocked(contactService).createContactRequest.mockResolvedValue(false);

      const response = await request(app).post('/api/contacts').send(contactData);
      expect(response.status).toBe(500);
      expect(response.body).toEqual({ error: 'Failed to submit contact request', details: 'Failed to save contact request to database.' });
    });
  });

  describe('404 Handler', () => {
    it('should return 404 for unknown routes', async () => {
      const response = await request(app).get('/api/unknown');
      expect(response.status).toBe(404);
    });
  });
});