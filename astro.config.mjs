import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';
import tailwindcss from '@tailwindcss/vite';

import { readingTimeRemarkPlugin, responsiveTablesRehypePlugin, lazyImagesRehypePlugin } from './src/utils/frontmatter.mjs';

export default defineConfig({
  output: 'static',
  outDir: 'out',
  site: 'https://papafeiji.cn',
  integrations: [
    sitemap({
      filter: (page) => !/\/(model|privacy-police|terms-of-use)\/$/.test(page),
    }),
  ],
  compressHTML: true,
  vite: {
    plugins: [tailwindcss()],
  },
  markdown: {
    remarkPlugins: [readingTimeRemarkPlugin],
    rehypePlugins: [responsiveTablesRehypePlugin, lazyImagesRehypePlugin],
  },
});
