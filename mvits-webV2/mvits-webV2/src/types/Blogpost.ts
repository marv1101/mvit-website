export type Blogpost = {
    nid: number;
    vid: number | null;
    langcode: string;
    content: string;
    summary: string | null;
    title: string;
    title_image_url: string | undefined;
    created: number;
    changed: number;
}