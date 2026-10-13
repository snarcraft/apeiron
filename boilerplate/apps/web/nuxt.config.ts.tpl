export default defineNuxtConfig({
  modules: ['@nuxt/eslint', '@nuxt/ui', '@nuxt/a11y', '@nuxt/scripts', '@nuxtjs/i18n'],

  devtools: { enabled: true },

  css: ['~/assets/css/main.css'],

  router: { options: { scrollBehaviorType: 'smooth' } },

  routeRules: { '/': { prerender: true } },

  compatibilityDate: '{{COMPATIBILITY_DATE}}',

  colorMode: { preference: '{{COLOR_MODE_PREFERENCE}}', fallback: 'dark' },

  nitro: {
    devProxy: {
      '/api/contacts': {
        target: 'http://localhost:8000/api/contacts',
        changeOrigin: true
      }
    },
    prerender: {
      crawlLinks: true,
      routes: ['/', '/sitemap.xml', '/robots.txt', '/llms.txt']
    }
  },

  eslint: { config: { stylistic: { commaDangle: 'never', braceStyle: '1tbs' } } },

  i18n: {
    strategy: 'no_prefix',
    locales: [{{WEB_LOCALES}}],
    langDir: 'locales',
    defaultLocale: '{{DEFAULT_LOCALE}}',
    detectBrowserLanguage: { useCookie: true, cookieKey: 'i18n_locale' }
  },

  icon: {
    mode: 'svg',
    serverBundle: { remote: true, collections: ['lucide', 'simple-icons'] },
    clientBundle: { scan: true }
  }
})
