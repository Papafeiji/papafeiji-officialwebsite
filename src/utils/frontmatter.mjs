import getReadingTime from 'reading-time';
import { toString } from 'mdast-util-to-string';

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
      if (child.type === 'element' && child.tagName === 'img') {
        child.properties.loading = 'lazy';
        child.properties.decoding = 'async';
      }
    }
  };
}

export function lazyImagesRehypePlugin() {
  return function (tree) {
    function visit(node) {
      if (node.type === 'element' && node.tagName === 'img') {
        node.properties = node.properties || {};
        node.properties.loading = 'lazy';
        node.properties.decoding = 'async';
      }
      if (node.children) {
        for (const child of node.children) {
          visit(child);
        }
      }
    }
    visit(tree);
  };
}
