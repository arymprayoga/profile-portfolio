import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
    plugins: [
        laravel({
            input: ['resources/css/site.css', 'resources/js/site.js'],
            refresh: true,
        }),
        tailwindcss(),
    ],
    build: {
        // Optimize for low memory environments
        rollupOptions: {
            output: {
                manualChunks: undefined,
            }
        },
        // Reduce memory usage during build
        minify: 'esbuild', // Faster and less memory-intensive than terser
        target: 'es2015',
        cssCodeSplit: true,
        // Limit concurrent processing
        chunkSizeWarningLimit: 1000,
    },
    // Disable source maps to save memory
    css: {
        devSourcemap: false,
    },
});
