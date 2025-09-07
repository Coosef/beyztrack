import vue from "@vitejs/plugin-vue";
import { defineConfig } from "vite";
import visualizer from "rollup-plugin-visualizer";
import viteCompression from "vite-plugin-compression";
import VueDevTools from "vite-plugin-vue-devtools";

const postCssScss = require("postcss-scss");
const postcssRTLCSS = require("postcss-rtlcss");

const viteCompressionFilter = /\.(js|mjs|json|css|html|svg)$/i;

// https://vitejs.dev/config/
export default defineConfig({
    server: {
        port: 3000,
        host: '0.0.0.0',
        allowedHosts: [
            'localhost',
            '127.0.0.1',
            'beyztrack.yeb.one',
            '.yeb.one',
            '.trycloudflare.com',
            '.ngrok.io',
            '.ngrok-free.app'
        ],
        hmr: {
            port: 3000,
            host: 'localhost'
        },
        proxy: {
            '/api': {
                target: 'http://localhost:3001',
                changeOrigin: true,
                secure: false,
                timeout: 30000
            },
            '/socket.io': {
                target: 'http://localhost:3001',
                changeOrigin: true,
                secure: false,
                ws: true,
                timeout: 30000
            }
        }
    },
    define: {
        "FRONTEND_VERSION": JSON.stringify(process.env.npm_package_version),
        "process.env": {},
    },
    plugins: [
        vue(),
        visualizer({
            filename: "tmp/dist-stats.html"
        }),
        viteCompression({
            algorithm: "gzip",
            filter: viteCompressionFilter,
        }),
        viteCompression({
            algorithm: "brotliCompress",
            filter: viteCompressionFilter,
        }),
        VueDevTools(),
    ],
    css: {
        postcss: {
            "parser": postCssScss,
            "map": false,
            "plugins": [ postcssRTLCSS ]
        }
    },
    build: {
        commonjsOptions: {
            include: [ /.js$/ ],
        },
        rollupOptions: {
            output: {
                manualChunks(id, { getModuleInfo, getModuleIds }) {

                }
            }
        },
    }
});
