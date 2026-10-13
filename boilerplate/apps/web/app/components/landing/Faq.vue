<script setup lang="ts">
const { t } = useI18n()

const faqs = computed(() => [
  { label: t('faq.setup.q'), content: t('faq.setup.a') },
  { label: t('faq.selfhost.q'), content: t('faq.selfhost.a') },
  { label: t('faq.permissions.q'), content: t('faq.permissions.a') },
  { label: t('faq.api.q'), content: t('faq.api.a') },
  { label: t('faq.export.q'), content: t('faq.export.a') }
])

useHead(() => ({
  script: [
    {
      type: 'application/ld+json',
      innerHTML: JSON.stringify({
        '@context': 'https://schema.org',
        '@type': 'FAQPage',
        mainEntity: faqs.value.map((faq) => ({
          '@type': 'Question',
          name: faq.label,
          acceptedAnswer: { '@type': 'Answer', text: faq.content }
        }))
      })
    }
  ]
}))
</script>

<template>
  <section id="faq" class="mx-auto max-w-3xl scroll-mt-24 px-4 py-24 sm:px-6 lg:px-8">
    <SectionHeading
      :eyebrow="t('sections.faq.eyebrow')"
      :title="t('sections.faq.title')"
    />

    <UAccordion
      class="mt-12"
      :items="faqs"
      :ui="{ item: 'soul-card mb-3 px-6' }"
    />
  </section>
</template>
