import request from 'supertest';
import app from '../app.js';
import { contactService } from '../services/contactService.js';
import { authService } from '../services/authService.js';

// Mock the database and services
vi.mock('../db/db.js', () => ({
  db: {
    select: vi.fn(),
    from: vi.fn(),
    where: vi.fn(),
    orderBy: vi.fn(),
    insert: vi.fn(),
    values: vi.fn(),
    update: vi.fn(),
    set: vi.fn(),
    returning: vi.fn(),
  },
  pool: {},
  drupalDb: {},
  drupalPool: {},
}));

vi.mock('../services/contactService.js', () => ({
  contactService: {
    createContactRequest: vi.fn(),
    getAllContactRequests: vi.fn(),
    setContactRequestStatus: vi.fn(),
  },
}));

vi.mock('../services/authService.js', () => ({
  authService: {
    verifyToken: vi.fn(),
  },
}));

const mockSession = { id: 1, username: 'admin', forcePasswordChange: false };

const authHeader = { Authorization: 'Bearer valid-token' };

const mockContact = {
  id: 2,
  name: 'Jane Doe',
  email: 'jane@example.com',
  subject: 'Anfrage',
  message: 'Nachricht',
  createdAt: '2026-09-12T10:00:00.000Z',
  status: 'open',
};

describe('Contacts Admin API', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    vi.mocked(authService.verifyToken).mockResolvedValue(mockSession as any);
  });

  describe('GET /api/contacts', () => {
    it('should return 401 without token', async () => {
      const response = await request(app).get('/api/contacts');
      expect(response.status).toBe(401);
      expect(vi.mocked(contactService).getAllContactRequests).not.toHaveBeenCalled();
    });

    it('should return 401 with invalid token', async () => {
      vi.mocked(authService.verifyToken).mockResolvedValue(null as any);

      const response = await request(app).get('/api/contacts').set(authHeader);
      expect(response.status).toBe(401);
      expect(vi.mocked(contactService).getAllContactRequests).not.toHaveBeenCalled();
    });

    it('should return contacts sorted by createdAt desc', async () => {
      const mockContacts = [
        { ...mockContact, id: 2, createdAt: '2026-09-12T10:00:00.000Z' },
        { ...mockContact, id: 1, createdAt: '2026-09-11T10:00:00.000Z' },
      ];
      vi.mocked(contactService).getAllContactRequests.mockResolvedValue(mockContacts as any);

      const response = await request(app).get('/api/contacts').set(authHeader);
      expect(response.status).toBe(200);
      expect(response.body).toEqual(mockContacts);
      expect(vi.mocked(contactService).getAllContactRequests).toHaveBeenCalledWith();
    });

    it('should return contact objects with the exact response shape', async () => {
      vi.mocked(contactService).getAllContactRequests.mockResolvedValue([mockContact] as any);

      const response = await request(app).get('/api/contacts').set(authHeader);
      expect(response.status).toBe(200);
      expect(response.body).toHaveLength(1);
      expect(Object.keys(response.body[0]).sort()).toEqual(
        ['createdAt', 'email', 'id', 'message', 'name', 'status', 'subject'].sort()
      );
      expect(typeof response.body[0].id).toBe('number');
      expect(typeof response.body[0].createdAt).toBe('string');
      expect(['open', 'handled']).toContain(response.body[0].status);
    });

    it('should handle errors', async () => {
      vi.mocked(contactService).getAllContactRequests.mockRejectedValue(new Error('DB Error'));

      const response = await request(app).get('/api/contacts').set(authHeader);
      expect(response.status).toBe(500);
      expect(response.body).toEqual({ error: 'Failed to fetch contacts' });
    });
  });

  describe('PATCH /api/contacts/:id', () => {
    it('should return 401 without token', async () => {
      const response = await request(app).patch('/api/contacts/1').send({ status: 'handled' });
      expect(response.status).toBe(401);
      expect(vi.mocked(contactService).setContactRequestStatus).not.toHaveBeenCalled();
    });

    it('should return updated contact on success', async () => {
      const updated = { ...mockContact, id: 1, status: 'handled' };
      vi.mocked(contactService).setContactRequestStatus.mockResolvedValue(updated as any);

      const response = await request(app)
        .patch('/api/contacts/1')
        .set(authHeader)
        .send({ status: 'handled' });

      expect(response.status).toBe(200);
      expect(response.body).toEqual(updated);
      expect(vi.mocked(contactService).setContactRequestStatus).toHaveBeenCalledWith(1, 'handled');
    });

    it('should return 400 for invalid status', async () => {
      const response = await request(app)
        .patch('/api/contacts/1')
        .set(authHeader)
        .send({ status: 'archived' });

      expect(response.status).toBe(400);
      expect(vi.mocked(contactService).setContactRequestStatus).not.toHaveBeenCalled();
    });

    it('should return 400 for missing status', async () => {
      const response = await request(app)
        .patch('/api/contacts/1')
        .set(authHeader)
        .send({});

      expect(response.status).toBe(400);
      expect(vi.mocked(contactService).setContactRequestStatus).not.toHaveBeenCalled();
    });

    it('should return 400 for invalid id', async () => {
      const response = await request(app)
        .patch('/api/contacts/abc')
        .set(authHeader)
        .send({ status: 'handled' });

      expect(response.status).toBe(400);
      expect(vi.mocked(contactService).setContactRequestStatus).not.toHaveBeenCalled();
    });

    it('should return 404 for unknown id', async () => {
      vi.mocked(contactService).setContactRequestStatus.mockRejectedValue(
        new Error('Contact request not found')
      );

      const response = await request(app)
        .patch('/api/contacts/999')
        .set(authHeader)
        .send({ status: 'handled' });

      expect(response.status).toBe(404);
      expect(response.body).toEqual({ error: 'Contact request not found' });
    });

    it('should handle errors', async () => {
      vi.mocked(contactService).setContactRequestStatus.mockRejectedValue(new Error('DB Error'));

      const response = await request(app)
        .patch('/api/contacts/1')
        .set(authHeader)
        .send({ status: 'open' });

      expect(response.status).toBe(500);
      expect(response.body).toEqual({ error: 'Failed to update contact request' });
    });
  });
});
