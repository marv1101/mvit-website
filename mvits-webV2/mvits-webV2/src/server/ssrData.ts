import type { Blogpost } from "../types/Blogpost";
import type { Product } from "../types/Product";
import type { Reference } from "../types/Reference";
import type { SsrData, SsrHomeData } from "../types/SsrData";
import { fetchApiJson } from "./api";
import { getFirstImageUrlFromHtml, replaceDrupalImgTagsWithSrc } from "../utils/DrupalImageTools";

const LIST_TTL = 60_000;
const ITEM_TTL = 60_000;

/** Bereitet Blogposts wie HomePage nach dem Fetch auf (Bild-Handling aus Drupal-HTML). */
function prepareBlogposts(posts: Blogpost[]): Blogpost[] {
  return posts.map((post) => ({
    ...post,
    content: post.content ? replaceDrupalImgTagsWithSrc(post.content) : "",
    title_image_url:
      post.title_image_url ?? (post.content ? getFirstImageUrlFromHtml(post.content) : undefined),
  }));
}

async function resolveHome(): Promise<SsrHomeData | undefined> {
  const [offerings, blogposts, references] = await Promise.all([
    fetchApiJson<Product[]>("/offerings/", LIST_TTL),
    fetchApiJson<Blogpost[]>("/blogposts/", LIST_TTL),
    fetchApiJson<Reference[]>("/references/", LIST_TTL),
  ]);
  if (!offerings && !blogposts && !references) return undefined;
  return {
    offerings: offerings ?? [],
    blogposts: prepareBlogposts(blogposts ?? []),
    references: references ?? [],
  };
}

async function resolveProduct(id: string): Promise<Product | undefined> {
  return (await fetchApiJson<Product>(`/offerings/${id}`, ITEM_TTL)) ?? undefined;
}

async function resolveBlogpost(id: string): Promise<Blogpost | undefined> {
  const post = await fetchApiJson<Blogpost>(`/blogposts/${id}`, ITEM_TTL);
  return post ? { ...post, content: post.content ? replaceDrupalImgTagsWithSrc(post.content) : "" } : undefined;
}

async function resolveReference(id: string): Promise<Reference | undefined> {
  return (await fetchApiJson<Reference>(`/references/${id}`, ITEM_TTL)) ?? undefined;
}

/** Lädt zu einer public Route die SSR-Vordaten. */
export async function resolveSsrData(pathname: string): Promise<SsrData> {
  const data: SsrData = { path: pathname };

  if (pathname === "/") {
    const home = await resolveHome();
    if (home) data.home = home;
    return data;
  }

  if (pathname === "/impressum" || pathname === "/datenschutz") {
    return data;
  }

  const match = /^(?:\/product\/|\/blog\/|\/reference\/)([^/]+)$/.exec(pathname);
  if (match?.[1]) {
    const id = match[1];
    if (pathname.startsWith("/product/")) {
      const product = await resolveProduct(id);
      if (product) data.product = product;
    } else if (pathname.startsWith("/blog/")) {
      const blogpost = await resolveBlogpost(id);
      if (blogpost) data.blogpost = blogpost;
    } else if (pathname.startsWith("/reference/")) {
      const reference = await resolveReference(id);
      if (reference) data.reference = reference;
    }
  }

  return data;
}
