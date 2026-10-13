<script setup lang="ts">
const { t } = useI18n()

const plans = computed(() => [
  {
    name: t('pricing.starter.name'),
    price: t('pricing.starter.price'),
    period: t('pricing.starter.period'),
    description: t('pricing.starter.description'),
    features: t('pricing.lists.starter') as unknown as string[],
    cta: t('pricing.starter.cta'),
    highlight: false
  },
  {
    name: t('pricing.professional.name'),
    price: t('pricing.professional.price'),
    period: t('pricing.professional.period'),
    description: t('pricing.professional.description'),
    features: t('pricing.lists.professional') as unknown as string[],
    cta: t('pricing.professional.cta'),
    badge: t('pricing.professional.badge'),
    highlight: true
  },
  {
    name: t('pricing.enterprise.name'),
    price: t('pricing.enterprise.price'),
    period: t('pricing.enterprise.period'),
    description: t('pricing.enterprise.description'),
    features: t('pricing.lists.enterprise') as unknown as string[],
    cta: t('pricing.enterprise.cta'),
    highlight: false
  }
])
</script>

<template>
  <section id="pricing" class="mx-auto max-w-7xl scroll-mt-24 px-4 py-24 sm:px-6 lg:px-8">
    <SectionHeading
      :eyebrow="t('sections.pricing.eyebrow')"
      :title="t('sections.pricing.title')"
      :description="t('sections.pricing.description')"
    />

    <div class="mx-auto mt-16 grid max-w-5xl gap-6 lg:grid-cols-3">
      <div
        v-for="plan in plans"
        :key="plan.name"
        class="soul-card relative p-8"
        :class="plan.highlight ? 'ring-2 ring-primary-500/60' : ''"
      >
        <span
          v-if="plan.badge"
          class="absolute -top-3 start-6 rounded-full bg-primary-500 px-3 py-1 text-xs font-semibold text-inverted"
        >
          {{ plan.badge }}
        </span>

        <h3 class="text-lg font-semibold text-highlighted">
          {{ plan.name }}
        </h3>

        <p class="mt-1 text-sm text-muted">
          {{ plan.description }}
        </p>

        <p class="mt-6">
          <span class="text-4xl font-extrabold text-highlighted">{{ plan.price }}</span>
          <span class="text-sm text-dimmed">{{ plan.period }}</span>
        </p>

        <ul class="mt-6 space-y-3">
          <li
            v-for="feature in plan.features"
            :key="feature"
            class="flex items-center gap-2.5 text-sm text-muted"
          >
            <UIcon name="i-lucide-check" class="size-4 text-primary-500" />
            {{ feature }}
          </li>
        </ul>

        <UButton
          to="#contact"
          block
          size="lg"
          class="mt-8"
          :color="plan.highlight ? 'primary' : 'neutral'"
          :variant="plan.highlight ? 'solid' : 'subtle'"
        >
          {{ plan.cta }}
        </UButton>
      </div>
    </div>
  </section>
</template>
