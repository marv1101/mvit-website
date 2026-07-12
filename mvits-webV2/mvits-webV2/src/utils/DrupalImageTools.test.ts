import { describe, it, expect } from 'bun:test';
import { replaceDrupalImgTagsWithSrc, getFirstImageUrlFromHtml } from './DrupalImageTools';
import { CONFIG } from './ConfigLoader';

const DRUPAL_FILES_URL = `${CONFIG.DRUPAL_BASE_URL}/sites/default/files/`;

describe('replaceDrupalImgTagsWithSrc', () => {
  it('prefixes relative Drupal image paths with the configured base URL', () => {
    const html = '<img src="/sites/default/files/2025-07/image.jpg" alt="foo">';
    expect(replaceDrupalImgTagsWithSrc(html)).toBe(
      `<img src="${DRUPAL_FILES_URL}2025-07/image.jpg" alt="foo">`
    );
  });

  it('handles single-quoted src attributes', () => {
    const html = "<img src='/sites/default/files/2025-07/image.jpg' alt='foo'>";
    expect(replaceDrupalImgTagsWithSrc(html)).toBe(
      `<img src='${DRUPAL_FILES_URL}2025-07/image.jpg' alt='foo'>`
    );
  });

  it('replaces multiple occurrences', () => {
    const html =
      '<img src="/sites/default/files/a.jpg"><img src="/sites/default/files/b.jpg">';
    expect(replaceDrupalImgTagsWithSrc(html)).toBe(
      `<img src="${DRUPAL_FILES_URL}a.jpg"><img src="${DRUPAL_FILES_URL}b.jpg">`
    );
  });

  it('leaves already-absolute URLs untouched', () => {
    const html = `<img src="${DRUPAL_FILES_URL}image.jpg">`;
    expect(replaceDrupalImgTagsWithSrc(html)).toBe(html);
  });
});

describe('getFirstImageUrlFromHtml', () => {
  it('extracts and prefixes a double-quoted relative image src', () => {
    const html = '<img src="/sites/default/files/2025-07/image.jpg" alt="foo">';
    expect(getFirstImageUrlFromHtml(html)).toBe(`${DRUPAL_FILES_URL}2025-07/image.jpg`);
  });

  it('extracts and prefixes a single-quoted relative image src', () => {
    const html = "<img src='/sites/default/files/2025-07/image.jpg' alt='foo'>";
    expect(getFirstImageUrlFromHtml(html)).toBe(`${DRUPAL_FILES_URL}2025-07/image.jpg`);
  });

  it('returns already-absolute URLs unchanged', () => {
    const html = '<img src="https://example.com/image.jpg">';
    expect(getFirstImageUrlFromHtml(html)).toBe('https://example.com/image.jpg');
  });

  it('handles protocol-relative URLs by prepending the Drupal base URL', () => {
    const html = '<img src="sites/default/files/image.jpg">';
    expect(getFirstImageUrlFromHtml(html)).toBe(`${CONFIG.DRUPAL_BASE_URL}/sites/default/files/image.jpg`);
  });

  it('returns undefined when no image is present', () => {
    expect(getFirstImageUrlFromHtml('<p>no image here</p>')).toBeUndefined();
  });

  it('returns undefined for an empty src attribute', () => {
    expect(getFirstImageUrlFromHtml('<img src="">')).toBeUndefined();
  });
});
