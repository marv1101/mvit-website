import { describe, it, expect } from 'vitest';
import { validateReferenceRequest } from '../validators/referenceValidator.js';

const validBase = {
    company: 'Beispiel GmbH',
    summary: 'Kurze Zusammenfassung',
    story: '<p>User-Story</p>',
};

describe('referenceValidator', () => {
    it('accepts a valid request', () => {
        const result = validateReferenceRequest(validBase);
        expect(result).not.toBeNull();
        expect(result?.company).toBe('Beispiel GmbH');
    });

    it('rejects missing required fields', () => {
        expect(validateReferenceRequest({ ...validBase, company: '' })).toBeNull();
        expect(validateReferenceRequest({ ...validBase, summary: '' })).toBeNull();
        expect(validateReferenceRequest({ ...validBase, story: '' })).toBeNull();
        expect(validateReferenceRequest({})).toBeNull();
    });

    it('rejects oversized fields', () => {
        expect(validateReferenceRequest({ ...validBase, company: 'a'.repeat(256) })).toBeNull();
        expect(validateReferenceRequest({ ...validBase, summary: 'a'.repeat(1025) })).toBeNull();
        expect(validateReferenceRequest({ ...validBase, story: 'a'.repeat(100_001) })).toBeNull();
    });

    it('rejects company_url without http/https', () => {
        expect(validateReferenceRequest({ ...validBase, company_url: 'javascript:alert(1)' })).toBeNull();
        expect(validateReferenceRequest({ ...validBase, company_url: 'ftp://example.com' })).toBeNull();
        expect(validateReferenceRequest({ ...validBase, company_url: 'https://example.com' })).not.toBeNull();
    });

    it('rejects oversized company_url', () => {
        expect(validateReferenceRequest({ ...validBase, company_url: 'https://' + 'a'.repeat(2048) + '.com' })).toBeNull();
    });

    it('rejects logo_url without http/https', () => {
        expect(validateReferenceRequest({ ...validBase, logo_url: 'data:text/html,<script>alert(1)</script>' })).toBeNull();
        expect(validateReferenceRequest({ ...validBase, logo_url: 'javascript:alert(1)' })).toBeNull();
        expect(validateReferenceRequest({ ...validBase, logo_url: 'https://example.com/logo.png' })).not.toBeNull();
    });

    it('rejects oversized logo_url', () => {
        expect(validateReferenceRequest({ ...validBase, logo_url: 'https://' + 'a'.repeat(2048) + '.com/logo.png' })).toBeNull();
    });

    it('sanitizes story HTML', () => {
        const result = validateReferenceRequest({ ...validBase, story: '<p>ok</p><script>alert(1)</script><img src=x onerror=alert(1)>' });
        expect(result).not.toBeNull();
        expect(result?.story).not.toContain('<script');
        expect(result?.story).not.toContain('onerror');
        expect(result?.story).toContain('<p>ok</p>');
    });

    it('accepts null and undefined optional fields', () => {
        expect(validateReferenceRequest({ ...validBase, company_url: null, logo_url: null })).not.toBeNull();
        expect(validateReferenceRequest({ ...validBase, company_url: undefined, logo_url: undefined })).not.toBeNull();
    });
});
