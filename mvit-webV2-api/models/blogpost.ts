export type blogpostObject = {
    nid: number;
    vid: number | null;
    langcode: string;
    content: string;
    summary: string | null;
    title: string;
    title_image_url: string | null;
    created: number;
    changed: number;
}