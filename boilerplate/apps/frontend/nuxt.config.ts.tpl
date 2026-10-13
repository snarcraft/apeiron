export default defineNuxtConfig({
  modules: ['@nuxt/eslint', '@nuxt/ui', '@nuxt/scripts', '@nuxtjs/i18n', 'nuxt-auth-sanctum'],

  devtools: { enabled: true },

  css: ['~/assets/css/main.css'],

  compatibilityDate: '{{COMPATIBILITY_DATE}}',

  colorMode: { preference: '{{COLOR_MODE_PREFERENCE}}', fallback: 'dark' },

  devServer: { host: '0.0.0.0' },

  runtimeConfig: {
    public: {
      name: '{{APP_NAME}}',
      url: '{{FRONTEND_URL}}',

      reverb: {
        host: process.env.REVERB_HOST ?? 'localhost',
        port: process.env.REVERB_PORT ?? '8080',
        key: process.env.REVERB_APP_KEY ?? 'local',
        protocol: process.env.REVERB_SCHEME ?? 'http',
        cluster: ''
      },

      locales: ['{{DEFAULT_LOCALE}}']
    }
  },

  routeRules: {
    '/media/**': { proxy: `${process.env.APP_URL ?? 'http://127.0.0.1:8000'}/media/**` },
    '/horizon/**': { proxy: `${process.env.APP_URL ?? 'http://127.0.0.1:8000'}/horizon/**` }
  },

  sanctum: {
    baseUrl: '/backend',
    serverProxy: {
      enabled: true,
      route: '/backend',
      target: process.env.APP_URL ?? 'http://127.0.0.1:8000'
    },
    endpoints: {
      login: '/auth/login',
      logout: '/auth/logout'
    },
    redirect: {
      onLogin: '/',
      onLogout: '/login',
      onGuestOnly: '/',
      onAuthOnly: '/login'
    },
    redirectIfAuthenticated: true,
    redirectIfUnauthenticated: true,
    globalMiddleware: {
      enabled: true
    }
  },

  i18n: {
    strategy: 'no_prefix',
    locales: ['{{DEFAULT_LOCALE}}'],
    detectBrowserLanguage: false
  },

  // *.slug.localhost resolves to loopback — tenant subdomains hit
  // this dev server directly, exactly like the normatek setup.
  vite: {
    server: {
      allowedHosts: ['.{{APP_NAME}}.localhost', '.{{DOMAIN}}']
    }
  },

  eslint: { config: { stylistic: { commaDangle: 'never', braceStyle: '1tbs' } } },

  icon: {
    mode: 'svg',
    serverBundle: { remote: true, collections: ['lucide', 'heroicons', 'ph'] },
    clientBundle: { scan: true }
  }
})
