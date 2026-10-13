<script setup lang="ts">
// Renderless scroll-reveal wrapper: children fade+rise once they
// enter the viewport. Honors prefers-reduced-motion by showing
// immediately.
withDefaults(
  defineProps<{
    delay?: number
    as?: string
  }>(),
  { delay: 0, as: 'div' }
)

const root = ref<HTMLElement | null>(null)
const visible = ref(false)

onMounted(() => {
  if (!root.value || prefersReducedMotion()) {
    visible.value = true
    return
  }

  const observer = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        if (entry.isIntersecting) {
          visible.value = true
          observer.disconnect()
        }
      }
    },
    { threshold: 0.15 }
  )

  observer.observe(root.value)
})

function prefersReducedMotion(): boolean {
  return window.matchMedia('(prefers-reduced-motion: reduce)').matches
}
</script>

<template>
  <component
    :is="as"
    ref="root"
    class="transition-all duration-700 ease-out motion-reduce:transition-none"
    :class="visible ? 'translate-y-0 opacity-100' : 'translate-y-4 opacity-0'"
    :style="visible ? { transitionDelay: `${delay}ms` } : undefined"
  >
    <slot />
  </component>
</template>
