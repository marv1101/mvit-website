import { node, nodeBody, nodeFieldData } from '../db/schema_drupal.js';
import { drupalDb } from '../db/db.js';
import { blogpostObject } from '../models/blogpost.js';
import { eq } from 'drizzle-orm';

async function getAllBlogposts(offset = 0, limit = 10): Promise<blogpostObject[]> {
    //select all Blogposts (Articles) from Drupal database, including their body content and summary, and return them as an array of blogpostObjects 
    const blogPosts: blogpostObject[] = await drupalDb.select(
    {
        nid: node.nid,
        vid: node.vid,
        langcode: nodeFieldData.langcode,
        content: nodeBody.bodyValue,
        summary: nodeBody.bodySummary,
        title: nodeFieldData.title,
        created: nodeFieldData.created,
        changed: nodeFieldData.changed
    }).from(node)
                                            .innerJoin(nodeBody, eq(node.nid, nodeBody.entityId) && eq(node.vid, nodeBody.revisionId))
                                            .innerJoin(nodeFieldData, eq(node.nid, nodeFieldData.nid) && eq(node.vid, nodeFieldData.vid))
                                            .where(eq(node.type, 'article'))
                                            .offset(offset).limit(limit);
    return blogPosts;
}

async function getBlogpostById(id: number): Promise<blogpostObject | null> {
    //select single blogpost by ID
    const blogPost: blogpostObject | null = await drupalDb.select(
    {
        nid: node.nid,
        vid: node.vid,
        langcode: nodeFieldData.langcode,
        content: nodeBody.bodyValue,
        summary: nodeBody.bodySummary,
        title: nodeFieldData.title,
        created: nodeFieldData.created,
        changed: nodeFieldData.changed
    }).from(node)
                                            .innerJoin(nodeBody, eq(node.nid, nodeBody.entityId) && eq(node.vid, nodeBody.revisionId))
                                            .innerJoin(nodeFieldData, eq(node.nid, nodeFieldData.nid) && eq(node.vid, nodeFieldData.vid))
                                            .where(eq(node.type, 'article') && eq(node.nid, id))
                                            .limit(1).then(results => results[0]) || null;
    return blogPost;
}

export const blogService = { getAllBlogposts, getBlogpostById };