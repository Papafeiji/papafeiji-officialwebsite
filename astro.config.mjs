import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  output: 'static',
  outDir: 'out',
  site: 'https://papafeiji.cn',
  integrations: [react()],
  vite: {
    plugins: [tailwindcss()],
  },
});