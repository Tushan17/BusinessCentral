import path from 'path'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      '@': path.resolve(import.meta.dirname, './src'),
    },
  },
  base: './',
  build: {
    outDir: '../dist',
    emptyOutDir: true,
    rollupOptions: {
      output: {
        // iife wraps everything in a self-executing function – safe for BC
        // control addin Scripts/StartupScript which are plain <script> tags.
        format: 'iife',
        name: 'BCReactAddin',
        // Fixed file names so AL ControlAddin definition can reference them
        entryFileNames: 'index.js',
        chunkFileNames: 'index.js',
        assetFileNames: (assetInfo) =>
          assetInfo.names && assetInfo.names[0] === 'index.css'
            ? 'index.css'
            : '[name][extname]',
      },
    },
  },
})
