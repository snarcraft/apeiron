{
  "name": "{{APP_SLUG}}",
  "private": true,
  "type": "module",
  "packageManager": "pnpm@12.3.4",
  "scripts": {
    "lang:extract": "./scripts/lang.mjs",
    "generate:assets": "pwa-assets-generator && cp assets/* apps/web/public && cp assets/* apps/frontend/public && mkdir -p apps/backend/public && cp assets/icon.svg assets/favicon.ico assets/manifest.webmanifest apps/backend/public && if [ -d apps/mobile ]; then cp assets/pwa-512x512.png apps/mobile/assets/icon.png; fi",
    "watch:assets": "node scripts/watch-assets.mjs",
    "format": "prettier --write ."
  },
  "devEngines": {
    "packageManager": {
      "name": "pnpm",
      "version": "^12.3.4",
      "onFail": "download"
    }
  },
  "devDependencies": {
    "@types/lodash-es": "^4.17.12",
    "@types/node": "^22.20.5",
    "@vite-pwa/assets-generator": "^2.0.0",
    "concurrently": "^10.0.5",
    "prettier": "^3.9.9",
    "prettier-plugin-organize-imports": "^4.3.0",
    "prettier-plugin-tailwindcss": "^0.8.1",
    "typescript": "^7.0.2",
    "vue-i18n-extract": "^2.0.7"
  },
  "dependencies": {
    "lodash-es": "^4.18.1"
  }
}
