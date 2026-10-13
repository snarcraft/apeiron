<script setup lang="ts">
withDefaults(
  defineProps<{
    eyebrow?: string
    title: string
    description?: string
    align?: 'center' | 'start'
  }>(),
  { align: 'center' }
)
</script>

<template>
  <div :class="align === 'center' ? 'mx-auto max-w-2xl text-center' : 'max-w-2xl text-start'">
    <p v-if="eyebrow" class="soul-mono">
      {{ eyebrow }}
    </p>

    <h2 class="mt-3 text-3xl font-bold tracking-tight text-highlighted sm:text-4xl">
      {{ title }}
    </h2>

    <p v-if="description" class="mt-4 text-lg text-muted">
      {{ description }}
    </p>
  </div>
</template>
