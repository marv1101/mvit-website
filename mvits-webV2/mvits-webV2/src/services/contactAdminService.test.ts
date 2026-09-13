import { describe, it, expect, beforeEach, afterEach, mock } from 'bun:test';
import { fetchAllContactRequests, updateContactStatus } from './contactAdminService';
import { CONFIG } from '../utils/ConfigLoader';

type FetchCall = { url: string; init: RequestInit | undefined };

const originalFetch = globalThis.fetch;
let calls: FetchCall[] = [];

const now = new Date().toISOString();

const sampleContact = {
  id: 1,
  name: 'Max Mustermann',
  email: 'max@example.com',
  subject: 'Anfrage',
  message: 'Hallo',
  createdAt: now,
  status: 'open',
};

function stubFetch(responder: (call: FetchCall) => Response) {
  globalThis.fetch = mock(async (url: any, init: any): Promise<Response> => {
    const call = { url, init };
    calls.push(call);
    return responder(call);
  }) as unknown as typeof globalThis.fetch;
}

describe('contactAdminService', () => {
  beforeEach(() => {
    calls = [];
    stubFetch(() => new Response(JSON.stringify([]), { status: 200 }));
  });

  afterEach(() => {
    globalThis.fetch = originalFetch;
  });

  describe('fetchAllContactRequests', () => {
    it('calls GET /api/contacts with credentials: include', async () => {
      await fetchAllContactRequests();

      expect(calls).toHaveLength(1);
      expect(calls[0].url).toBe(`${CONFIG.API_BASE_URL}/contacts`);
      expect(calls[0].init?.credentials).toBe('include');
    });

    it('returns contacts from the response', async () => {
      stubFetch(() => new Response(JSON.stringify([sampleContact]), { status: 200 }));

      const result = await fetchAllContactRequests();

      expect(result).toContainEqual({ ...sampleContact, createdAt: now });
    });

    it('throws on failed request', async () => {
      stubFetch(() => new Response('unauthorized', { status: 401 }));

      expect(fetchAllContactRequests()).rejects.toThrow('Failed to fetch contact requests');
    });
  });

  describe('updateContactStatus', () => {
    it('sends PATCH to /api/contacts/:id with status payload', async () => {
      const updated = { ...sampleContact, status: 'handled' };
      stubFetch(() => new Response(JSON.stringify(updated), { status: 200 }));

      await updateContactStatus(1, 'handled');

      expect(calls).toHaveLength(1);
      expect(calls[0].url).toBe(`${CONFIG.API_BASE_URL}/contacts/1`);
      expect(calls[0].init?.method).toBe('PATCH');
      expect(JSON.parse(String(calls[0].init?.body))).toEqual({ status: 'handled' });
      expect(calls[0].init?.credentials).toBe('include');
    });

    it('returns the updated contact', async () => {
      const updated = { ...sampleContact, status: 'handled' };
      stubFetch(() => new Response(JSON.stringify(updated), { status: 200 }));

      const result = await updateContactStatus(1, 'handled');

      expect(result).toEqual({ ...sampleContact, status: 'handled', createdAt: now });
    });

    it('throws on failed request', async () => {
      stubFetch(() => new Response('unauthorized', { status: 401 }));

      expect(updateContactStatus(1, 'handled')).rejects.toThrow('Failed to update contact status');
    });
  });
});
