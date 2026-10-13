<script setup lang="ts">
const { t } = useI18n()

const navItems = computed<NavigationMenuItem[]>(() => [
  { label: t('nav.features'), icon: 'i-lucide-sparkles', to: '/#features' },
  { label: t('nav.how'), icon: 'i-lucide-compass', to: '/#how' },
  { label: t('nav.pricing'), icon: 'i-lucide-tag', to: '/#pricing' },
  { label: t('nav.faq'), icon: 'i-lucide-circle-help', to: '/#faq' }
])

useHead({
  viewport: 'width=device-width, initial-scale=1',
  link: [
    { rel: 'icon', href: '/favicon.ico', sizes: 'any' },
    { rel: 'icon', href: '/icon.svg', type: 'image/svg+xml' },
    { rel: 'apple-touch-icon', href: '/apple-touch-icon-180x180.png' },
    { rel: 'manifest', href: '/manifest.webmanifest' }
  ],
  htmlAttrs: { lang: '{{DEFAULT_LOCALE}}' }
})

useSeoMeta({
  title: t('seo.title'),
  description: t('seo.description'),
  ogTitle: '{{APP_TITLE}}',
  ogDescription: t('seo.description'),
  ogUrl: 'https://{{DOMAIN}}',
  twitterCard: 'summary'
})
</script>

<template>
  <UApp>
    <UHeader>
      <template #title>
        <Logo />
      </template>

      <template #right>
        <ULink
          v-for="locale in $i18n.availableLocales"
          :key="locale"
          :to="switchLocalePath(locale)"
          class="text-xs uppercase text-muted hover:text-highlighted"
        >
          {{ locale }}
        </ULink>
        <UColorModeButton />
        <UButton
          to="/#contact"
          :label="t('nav.contact')"
          color="primary"
          trailing-icon="i-lucide-arrow-right"
        />
      </template>

      <template #body>
        <UNavigationMenu orientation="vertical" :items="navItems" class="-mx-2.5" />
      </template>
    </UHeader>

    <UMain>
      <NuxtPage />
    </UMain>

    <Footer />
  </UApp>
</template>
