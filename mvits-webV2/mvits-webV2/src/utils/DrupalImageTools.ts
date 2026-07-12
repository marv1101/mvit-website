import { CONFIG } from "./ConfigLoader";

export function replaceDrupalImgTagsWithSrc(html: string): string {
    // Replace relative image URLs in src attributes with absolute URLs pointing to the Drupal site.
    return html.replace(
        /src=(["'])\/sites\/default\/files\//gi,
        `src=$1${CONFIG.DRUPAL_BASE_URL}/sites/default/files/`
    );
}

export function getFirstImageUrlFromHtml(html: string): string | undefined {
    const imgTagRegex = /<img\s+[^>]*?src=(["'])(.*?)\1/i;
    const match = html.match(imgTagRegex);

    if (match && match[2]) {
        const src = match[2].trim();
        if (!src) return undefined;
        // Already absolute URL - return as-is.
        if (/^https?:\/\//i.test(src)) return src;
        // Relative URL starting with "/" - prepend Drupal base URL.
        if (src.startsWith('/')) return CONFIG.DRUPAL_BASE_URL + src;
        // Relative URL without leading "/" - prepend Drupal base URL with separator.
        return CONFIG.DRUPAL_BASE_URL + '/' + src;
    }
    return undefined;
}