import { node, nodeBody, nodeFieldData, nodeFieldImage, fileManaged } from '../db/schema_drupal.js';
import { drupalDb } from '../db/db.js';
import { blogpostObject } from '../models/blogpost.js';
import { eq, sql } from 'drizzle-orm';

const DRUPAL_FILES_BASE = 'https://mphion.de/drupal/sites/default/files/';

function drupalUriToUrl(uri: string | null): string | null {
    if (!uri) return null;
    const path = uri.replace(/^public:\/\//, '');
    return `${DRUPAL_FILES_BASE}${path}`;
}

async function getAllBlogposts(offset = 0, limit = 10): Promise<blogpostObject[]> {
    const rawResults = await drupalDb.select({
        nid: node.nid,
        vid: node.vid,
        langcode: nodeFieldData.langcode,
        content: nodeBody.bodyValue,
        summary: nodeBody.bodySummary,
        title: nodeFieldData.title,
        fileUri: sql<string | null>`${fileManaged.uri}`,
        created: nodeFieldData.created,
        changed: nodeFieldData.changed,
    }).from(node)
        .innerJoin(nodeBody, eq(node.nid, nodeBody.entityId) && eq(node.vid, nodeBody.revisionId))
        .innerJoin(nodeFieldData, eq(node.nid, nodeFieldData.nid) && eq(node.vid, nodeFieldData.vid))
        .leftJoin(nodeFieldImage, eq(node.nid, nodeFieldImage.entityId) && eq(node.vid, nodeFieldImage.revisionId))
        .leftJoin(fileManaged, eq(nodeFieldImage.fieldImageTargetId, fileManaged.fid))
        .where(eq(node.type, 'article'))
        .offset(offset).limit(limit);

    return rawResults.map((row) => ({
        nid: row.nid,
        vid: row.vid,
        langcode: row.langcode,
        content: row.content,
        summary: row.summary,
        title: row.title,
        title_image_url: drupalUriToUrl(row.fileUri),
        created: row.created,
        changed: row.changed,
    }));
}

async function getBlogpostById(id: number): Promise<blogpostObject | null> {
    const rawResult = await drupalDb.select({
        nid: node.nid,
        vid: node.vid,
        langcode: nodeFieldData.langcode,
        content: nodeBody.bodyValue,
        summary: nodeBody.bodySummary,
        title: nodeFieldData.title,
        fileUri: sql<string | null>`${fileManaged.uri}`,
        created: nodeFieldData.created,
        changed: nodeFieldData.changed,
    }).from(node)
        .innerJoin(nodeBody, eq(node.nid, nodeBody.entityId) && eq(node.vid, nodeBody.revisionId))
        .innerJoin(nodeFieldData, eq(node.nid, nodeFieldData.nid) && eq(node.vid, nodeFieldData.vid))
        .leftJoin(nodeFieldImage, eq(node.nid, nodeFieldImage.entityId) && eq(node.vid, nodeFieldImage.revisionId))
        .leftJoin(fileManaged, eq(nodeFieldImage.fieldImageTargetId, fileManaged.fid))
        .where(eq(node.type, 'article') && eq(node.nid, id))
        .limit(1).then(results => results[0]) || null;

    if (!rawResult) return null;

    const { fileUri, ...rest } = rawResult;
    return {
        ...rest,
        title_image_url: drupalUriToUrl(fileUri),
    };
}

export const blogService = { getAllBlogposts, getBlogpostById };