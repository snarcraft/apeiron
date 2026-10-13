<script setup lang="ts">
const user = useSanctumUser<User>()

const initials = computed(() =>
  (user.value?.name ?? '?')
    .split(' ')
    .map(part => part[0])
    .slice(0, 2)
    .join('')
    .toUpperCase()
)
</script>

<template>
  <div class="min-h-dvh">
    <div aria-hidden="true" class="pointer-events-none fixed inset-0 -z-10 bg-dots">
      <div
        class="absolute -top-32 left-1/4 size-96 rounded-full bg-primary-500/20 blur-[120px] motion-safe:animate-[glow-pulse_10s_ease-in-out_infinite]"
      />
      <div
        class="absolute -bottom-32 right-1/4 size-96 rounded-full bg-secondary-500/15 blur-[120px] motion-safe:animate-[glow-pulse_12s_ease-in-out_3s_infinite]"
      />
    </div>

    <main class="flex min-h-dvh items-center justify-center p-4">
      <slot />
    </main>

    <p class="soul-mono fixed bottom-4 end-4 select-none opacity-60">
      {{ initials }}
    </p>
  </div>
</template>
