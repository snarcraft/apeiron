{
  "name": "@{{APP_NAME}}/web",
  "private": true,
  "type": "module",
  "packageManager": "pnpm@12.3.4",
  "scripts": {
    "build": "nuxt build",
    "dev": "nuxt dev",
    "generate": "nuxt generate",
    "lint": "eslint .",
    "postinstall": "nuxt prepare",
    "preview": "nuxt preview",
    "typecheck": "nuxt typecheck"
  },
  "dependencies": {
    "@iconify-json/lucide": "^1.2.138",
    "@iconify-json/simple-icons": "^1.2.98",
    "@nuxt/a11y": "1.0.0-alpha.1",
    "@nuxt/scripts": "1.3.9",
    "@nuxt/ui": "^4.11.3",
    "@nuxtjs/i18n": "10.6.0",
    "nuxt": "^4.5.2",
    "tailwindcss": "^4.3.3"
  },
  "devDependencies": {
    "@nuxt/eslint": "^1.17.0",
    "eslint": "^10.12.0",
    "typescript": "^6.0.3",
    "vue-tsc": "^3.3.12"
  }
}
