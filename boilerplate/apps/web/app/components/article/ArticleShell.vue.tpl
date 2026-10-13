<script setup lang="ts">
// The shared article design — one shell, every language. Content
// pages write raw markup into the default slot; only the shell
// owns typography, spacing and the language alternates.
const props = defineProps<{
  title: string
  description: string
  date?: string
  lang: string
  translations?: Record<string, string>
}>()

const published = computed(() => (props.date ? new Date(props.date) : undefined))
const route = useRoute()
const alternates = computed(() =>
  Object.entries(props.translations ?? {}).map(([lang, slug]) => ({
    lang,
    to: `/${slug}`
  }))
)

useHead(() => ({
  link: [
    ...alternates.value.map(alternate => ({
      rel: 'alternate',
      hreflang: alternate.lang,
      href: `https://{{DOMAIN}}${alternate.to}`
    })),
    { rel: 'canonical', href: `https://{{DOMAIN}}${route.path}` }
  ]
}))
</script>

<template>
  <article class="mx-auto max-w-3xl px-4 py-20 sm:px-6 lg:px-8">
    <header class="border-b border-default pb-10 text-center">
      <p v-if="published" class="soul-mono">
        {{ published.toLocaleDateString(lang, { year: 'numeric', month: 'long', day: 'numeric' }) }}
      </p>

      <h1 class="mt-4 text-4xl font-bold tracking-tight text-highlighted">
        {{ title }}
      </h1>

      <p class="mx-auto mt-4 max-w-xl text-lg text-muted">
        {{ description }}
      </p>

      <nav v-if="alternates.length" class="mt-6 flex justify-center gap-4" aria-label="translations">
        <NuxtLink
          v-for="alternate in alternates"
          :key="alternate.lang"
          :to="alternate.to"
          class="text-xs font-semibold uppercase tracking-widest"
          :class="alternate.lang === lang ? 'text-primary' : 'text-muted hover:text-highlighted'"
        >
          {{ alternate.lang }}
        </NuxtLink>
      </nav>
    </header>

    <!-- Raw content lands here — same design for every language -->
    <div class="article-body mt-10">
      <slot />
    </div>

    <footer class="mt-16 border-t border-default pt-8 text-center">
      <NuxtLink to="/#contact" class="text-sm font-semibold text-primary hover:underline">
        {{ lang === '{{DEFAULT_LOCALE}}' ? 'Talk to us' : 'Échangeons' }}
      </NuxtLink>
    </footer>
  </article>
</template>

<style scoped>
.article-body {
  :deep(h2) {
    margin-top: 2.5rem;
    margin-bottom: 1rem;
    font-size: 1.5rem;
    font-weight: 700;
    color: var(--ui-text-highlighted);
  }

  :deep(p) {
    margin-bottom: 1.25rem;
    line-height: 1.75;
    color: var(--ui-text-muted);
  }

  :deep(a) {
    color: var(--color-primary-500);
    text-decoration: underline;
    text-underline-offset: 3px;
  }

  :deep(ul),
  :deep(ol) {
    margin: 0 0 1.25rem 1.25rem;
    line-height: 1.75;
    color: var(--ui-text-muted);
  }

  :deep(ul) {
    list-style: disc;
  }

  :deep(ol) {
    list-style: decimal;
  }

  :deep(strong) {
    color: var(--ui-text-highlighted);
  }

  :deep(blockquote) {
    margin: 1.5rem 0;
    border-inline-start: 3px solid var(--color-primary-500);
    padding-inline-start: 1rem;
    font-style: italic;
    color: var(--ui-text-highlighted);
  }
}
</style>
