import { CONFIG } from "./ConfigLoader";

export function replaceDrupalImgTagsWithSrc(html: string): string {
    
    //replace relative image URLs with absolute URLs pointing to the Drupal site
    let modifiedHtml = html.replaceAll("/sites/default/files/", CONFIG.DRUPAL_BASE_URL + "sites/default/files/");

    return modifiedHtml;
}

export function getFirstImageUrlFromHtml(html: string): string | undefined {
    const imgTagRegex = /<img\s+[^>]*?src=(["'])(.*?)\1/i;
    const match = html.match(imgTagRegex);

    if (match && match[0]) {
        const URL = CONFIG.DRUPAL_BASE_URL + match[0].substring(match[0].indexOf('"')+1, match[0].lastIndexOf('"'));
        return URL;
    }
    return undefined;
}