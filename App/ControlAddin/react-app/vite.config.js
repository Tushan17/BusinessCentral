import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  base: './',
  build: {
    outDir: '../dist',
    emptyOutDir: true,
    rollupOptions: {
      output: {
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
