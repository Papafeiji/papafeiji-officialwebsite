import { getCollection } from 'astro:content';
import type { CollectionEntry } from 'astro:content';

export interface Post {
  id: string;
  slug: string;
  permalink: string;
  publishDate: Date;
  updateDate?: Date;
  title: string;
  excerpt?: string;
  image?: string;
  category?: string;
  tags?: string[];
  author?: string;
  draft?: boolean;
  Content: any;
  readingTime?: number;
}

const getNormalizedPost = async (post: CollectionEntry<'post'>): Promise<Post> => {
  const { id, data } = post;
  const { Content, remarkPluginFrontmatter } = await post.render();

  const {
    publishDate: rawPublishDate = new Date(),
    updateDate: rawUpdateDate,
    title,
    excerpt,
    image,
    tags = [],
    category,
    author,
    draft = false,
  } = data;

  const publishDate = new Date(rawPublishDate);
  const updateDate = rawUpdateDate ? new Date(rawUpdateDate) : undefined;

  const slug = id.replace(/\.md$/, '');
  return {
    id,
    slug,
    permalink: `/tutorial/${slug}`,
    publishDate,
    updateDate,
    title,
    excerpt,
    image,
    category,
    tags,
    author,
    draft,
    Content,
    readingTime: remarkPluginFrontmatter?.readingTime,
  };
};

const load = async (): Promise<Post[]> => {
  const posts = await getCollection('post');
  const normalizedPosts = posts.map((post) => getNormalizedPost(post));
  const results = (await Promise.all(normalizedPosts))
    .sort((a, b) => b.publishDate.valueOf() - a.publishDate.valueOf())
    .filter((post) => !post.draft);
  return results;
};

let _posts: Post[];

export const fetchPosts = async (): Promise<Post[]> => {
  if (!_posts) {
    _posts = await load();
  }
  return _posts;
};

export const getStaticPathsTutorialPost = async () => {
  return (await fetchPosts()).map((post) => ({
    params: { slug: post.slug },
    props: { post },
  }));
};
