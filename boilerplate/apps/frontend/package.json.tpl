{
  "name": "@{{APP_NAME}}/frontend",
  "private": true,
  "type": "module",
  "packageManager": "pnpm@12.3.4",
  "scripts": {
    "build": "nuxt build",
    "dev": "nuxt dev",
    "lint": "eslint .",
    "postinstall": "nuxt prepare",
    "preview": "nuxt preview",
    "typecheck": "nuxt typecheck"
  },
  "dependencies": {
    "@internationalized/date": "^3.12.4",
    "@nuxt/scripts": "1.3.9",
    "@nuxt/ui": "^4.11.3",
    "@nuxtjs/i18n": "10.6.0",
    "@vueuse/core": "^15.0.0",
    "dayjs": "^1.11.23",
    "maska": "^3.2.2",
    "nuxt": "^4.5.2",
    "nuxt-auth-sanctum": "3.1.2",
    "tailwindcss": "^4.3.3",
    "ufo": "^1.6.4",
    "undio": "^0.2.0"
  },
  "devDependencies": {
    "@iconify-json/heroicons": "^1.2.3",
    "@iconify-json/lucide": "^1.2.138",
    "@iconify-json/material-symbols": "^1.2.93",
    "@iconify-json/ph": "^1.2.2",
    "@iconify-json/simple-icons": "^1.2.98",
    "@nuxt/eslint": "^1.17.0",
    "eslint": "^10.12.0",
    "typescript": "^6.0.3",
    "vue-tsc": "^3.3.12"
  }
}
