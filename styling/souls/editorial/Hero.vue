<script setup lang="ts">
const { t } = useI18n()

// Tokens like {{APP_TITLE}} are resolved at scaffold time.
const chapters = computed(() => [
  { no: 'I', title: t('steps.one.title'), body: t('steps.one.body') },
  { no: 'II', title: t('steps.two.title'), body: t('steps.two.body') },
  { no: 'III', title: t('steps.three.title'), body: t('steps.three.body') }
])
</script>

<template>
  <section class="relative overflow-hidden">
    <div aria-hidden="true" class="pointer-events-none absolute inset-0 -z-10 soul-hero-bg" />

    <div class="mx-auto max-w-5xl px-4 pt-24 pb-20 sm:px-6 lg:px-8">
      <!-- masthead -->
      <div class="border-b-2 border-highlighted pb-10 text-center motion-safe:animate-[hero-rise_0.7s_ease-out]">
        <p class="soul-mono">est. {{YEAR}} · the {{APP_TITLE}} papers</p>
        <h1 class="soul-display mt-6 text-5xl leading-[1.05] text-highlighted sm:text-6xl">
          {{ t('hero.title') }}<br />
          <span class="soul-grad-text">{{ t('hero.highlight') }}</span>
        </h1>
        <p class="mx-auto mt-8 max-w-2xl text-lg leading-relaxed text-muted">
          {{ t('hero.subtitle') }}
        </p>
        <div class="mt-10 flex items-center justify-center gap-4">
          <UButton to="#contact" size="xl" class="rounded-full px-8">
            {{ t('hero.cta') }}
          </UButton>
        </div>
      </div>

      <!-- chapters -->
      <div class="mt-14 grid gap-10 sm:grid-cols-3">
        <Reveal
          v-for="(chapter, i) in chapters"
          :key="chapter.no"
          :delay="i * 120"
          as="article"
          class="text-center sm:text-start"
        >
          <p class="soul-ghost">{{ chapter.no }}</p>
          <span class="soul-rule mt-4" />
          <h2 class="mt-4 text-lg font-semibold text-highlighted">{{ chapter.title }}</h2>
          <p class="mt-2 text-sm leading-relaxed text-muted">{{ chapter.body }}</p>
        </Reveal>
      </div>

      <!-- pull quote -->
      <Reveal :delay="200">
        <figure class="mx-auto mt-16 max-w-3xl text-center">
          <blockquote class="soul-display text-2xl leading-snug text-highlighted sm:text-3xl">
            {{ t('hero.quote') }}
          </blockquote>
          <figcaption class="soul-mono mt-4">— an early reader, {{DOMAIN}}</figcaption>
        </figure>
      </Reveal>
    </div>
  </section>
</template>
