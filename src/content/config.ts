import { z, defineCollection } from 'astro:content';

const postCollection = defineCollection({
  schema: z.object({
    publishDate: z.date().optional(),
    updateDate: z.date().optional(),
    draft: z.boolean().optional(),
    title: z.string(),
    excerpt: z.string().optional(),
    image: z.string().optional(),
    category: z.string().optional(),
    tags: z.array(z.string()).optional(),
    author: z.string().optional(),
    metadata: z
      .object({
        canonical: z.string().url().optional(),
      })
      .optional(),
  }),
});

export const collections = {
  post: postCollection,
};
