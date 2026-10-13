<script setup lang="ts">
// Copy lives in i18n/locales/*.json — never in components.
const { t } = useI18n()

const features = computed(() => [
  { icon: 'i-lucide-users', title: t('features.teams.title'), body: t('features.teams.body') },
  { icon: 'i-lucide-zap', title: t('features.fast.title'), body: t('features.fast.body') },
  { icon: 'i-lucide-shield-check', title: t('features.audit.title'), body: t('features.audit.body') },
  { icon: 'i-lucide-image', title: t('features.media.title'), body: t('features.media.body') },
  { icon: 'i-lucide-radio', title: t('features.realtime.title'), body: t('features.realtime.body') },
  { icon: 'i-lucide-bot', title: t('features.ai.title'), body: t('features.ai.body') }
])
</script>

<template>
  <section id="features" class="mx-auto max-w-7xl scroll-mt-24 px-4 py-24 sm:px-6 lg:px-8">
    <SectionHeading
      :eyebrow="t('sections.features.eyebrow')"
      :title="t('sections.features.title')"
      :description="t('sections.features.description')"
    />

    <div class="mt-16 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
      <Reveal v-for="(feature, i) in features" :key="feature.title" :delay="i * 80">
        <div class="soul-card group h-full p-6">
          <span class="soul-chip">
            <UIcon :name="feature.icon" class="size-5" />
          </span>

          <h3 class="mt-5 text-lg font-semibold text-highlighted">
            {{ feature.title }}
          </h3>

          <p class="mt-2 text-sm leading-relaxed text-muted">
            {{ feature.body }}
          </p>
        </div>
      </Reveal>
    </div>
  </section>
</template>
