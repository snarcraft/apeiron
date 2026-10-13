<script setup lang="ts">
const { t } = useI18n()

const { t } = useI18n()

useSeoMeta({
  title: t('seo.title'),
  description: t('seo.description')
})
</script>

<template>
  <div>
    <LandingHero />

    <LandingFeatures />

    <LandingSteps />

    <LandingPricing />

    <LandingFaq />

    <section id="contact" class="mx-auto max-w-3xl scroll-mt-24 px-4 py-24 sm:px-6 lg:px-8">
      <div class="soul-card p-8 sm:p-12">
        <SectionHeading
          :eyebrow="t('sections.contact.eyebrow')"
          :title="t('sections.contact.title')"
          :description="t('sections.contact.description')"
        />

        <ContactForm />
      </div>
    </section>

  </div>
</template>
