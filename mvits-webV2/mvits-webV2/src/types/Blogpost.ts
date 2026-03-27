export type Blogpost = {
    nid: number;
    vid: number | null;
    langcode: string;
    content: string;
    summary: string | null;
    title: string;
    created: number;
    changed: number;
}