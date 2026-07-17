import getReadingTime from 'reading-time';
import { toString } from 'mdast-util-to-string';
import sharp from 'sharp';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const publicDir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../../public');
const dimensionCache = new Map();

export function readingTimeRemarkPlugin() {
  return function (tree, file) {
    const textOnPage = toString(tree);
    const readingTime = Math.ceil(getReadingTime(textOnPage).minutes);
    file.data.astro.frontmatter.readingTime = readingTime;
  };
}

export function responsiveTablesRehypePlugin() {
  return function (tree) {
    if (!tree.children) return;
    for (let i = 0; i < tree.children.length; i++) {
      const child = tree.children[i];
      if (child.type === 'element' && child.tagName === 'table') {
        tree.children[i] = {
          type: 'element',
          tagName: 'div',
          properties: { style: 'overflow:auto' },
          children: [child],
        };
      }
    }
  };
}

export function lazyImagesRehypePlugin() {
  return async function (tree) {
    const images = [];
    function visit(node) {
      if (node.type === 'element' && node.tagName === 'img') {
        images.push(node);
      }
      if (node.children) {
        for (const child of node.children) {
          visit(child);
        }
      }
    }
    visit(tree);

    await Promise.all(
      images.map(async (node) => {
        node.properties = node.properties || {};
        node.properties.loading = 'lazy';
        node.properties.decoding = 'async';

        const src = node.properties.src;
        if (typeof src !== 'string' || !src.startsWith('/') || src.startsWith('//')) return;
        if (node.properties.width && node.properties.height) return;

        try {
          let dims = dimensionCache.get(src);
          if (!dims) {
            const meta = await sharp(path.join(publicDir, src)).metadata();
            dims = { width: meta.width, height: meta.height };
            dimensionCache.set(src, dims);
          }
          if (dims.width && dims.height) {
            node.properties.width = dims.width;
            node.properties.height = dims.height;
          }
        } catch {
          // image not found locally; skip dimensions
        }
      })
    );
  };
}
