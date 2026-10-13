<script setup lang="ts">
const { t } = useI18n()

const steps = computed(() => [
  { title: t('steps.one.title'), body: t('steps.one.body') },
  { title: t('steps.two.title'), body: t('steps.two.body') },
  { title: t('steps.three.title'), body: t('steps.three.body') }
])

const chips = computed(() => [
  t('steps.chips.rbac'),
  t('steps.chips.zero'),
  t('steps.chips.realtime'),
  t('steps.chips.media'),
  t('steps.chips.dark')
])
</script>

<template>
  <section id="how" class="mx-auto max-w-7xl scroll-mt-24 px-4 py-24 sm:px-6 lg:px-8">
    <div class="grid gap-16 lg:grid-cols-2 lg:items-center">
      <div>
        <SectionHeading
          align="start"
          :eyebrow="t('sections.how.eyebrow')"
          :title="t('sections.how.title')"
        />

        <ol class="mt-10 space-y-8">
          <li v-for="(step, i) in steps" :key="step.title" class="relative flex gap-6">
            <span class="soul-ghost shrink-0">{{ i + 1 }}</span>

            <div class="pt-6">
              <h3 class="text-lg font-semibold text-highlighted">
                {{ step.title }}
              </h3>
              <p class="mt-2 text-sm leading-relaxed text-muted">
                {{ step.body }}
              </p>
            </div>
          </li>
        </ol>
      </div>

      <div class="flex flex-wrap gap-3 lg:justify-end lg:pt-24">
        <span
          v-for="chip in chips"
          :key="chip"
          class="rounded-full border border-default bg-elevated/50 px-4 py-2 text-sm text-muted"
        >
          {{ chip }}
        </span>
      </div>
    </div>
  </section>
</template>
