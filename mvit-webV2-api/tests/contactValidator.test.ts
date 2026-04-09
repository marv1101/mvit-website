import { validateContactRequest } from '../validators/contactValidator.js';

describe('Contact Validator', () => {
  describe('validateContactRequest', () => {
    it('should return contact data if valid', () => {
      const validData = {
        id: 1,
        name: 'Test Name',
        email: 'test@example.com',
        subject: 'Test Subject',
        message: 'Test Message',
      };

      const result = validateContactRequest(validData);
      expect(result).toEqual(validData);
    });

    it('should return null if name is missing', () => {
      const invalidData = {
        id: 1,
        name: '',
        email: 'test@example.com',
        subject: 'Test Subject',
        message: 'Test Message',
      };

      const result = validateContactRequest(invalidData);
      expect(result).toBeNull();
    });

    it('should return null if email is invalid', () => {
      const invalidData = {
        id: 1,
        name: 'Test Name',
        email: 'invalid-email',
        subject: 'Test Subject',
        message: 'Test Message',
      };

      const result = validateContactRequest(invalidData);
      expect(result).toBeNull();
    });

    it('should return null if subject is missing', () => {
      const invalidData = {
        id: 1,
        name: 'Test Name',
        email: 'test@example.com',
        subject: '',
        message: 'Test Message',
      };

      const result = validateContactRequest(invalidData);
      expect(result).toBeNull();
    });

    it('should return null if message is missing', () => {
      const invalidData = {
        id: 1,
        name: 'Test Name',
        email: 'test@example.com',
        subject: 'Test Subject',
        message: '',
      };

      const result = validateContactRequest(invalidData);
      expect(result).toBeNull();
    });
  });
});