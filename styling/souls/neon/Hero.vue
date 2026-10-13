<script setup lang="ts">
const { t } = useI18n()

// Tokens like {{APP_TITLE}} are resolved at scaffold time.
const terminal = [
  { prompt: '$', cmd: '{{APP_SLUG}} deploy --env prod', out: '✓ 3 services rolled · 0 downtime' },
  { prompt: '$', cmd: '{{APP_SLUG}} audit --who manager', out: '✓ 42 actions · 0 denials' },
  { prompt: '$', cmd: '{{APP_SLUG}} agents run nightly', out: '✓ drift corrected at 03:00' },
]
</script>

<template>
  <section class="relative overflow-hidden">
    <div aria-hidden="true" class="pointer-events-none absolute inset-0 -z-10">
      <div class="soul-hero-bg absolute inset-0" />
      <div class="absolute inset-0 bg-dots opacity-40" />
      <div
        class="absolute left-1/2 top-[-20%] h-64 w-[42rem] -translate-x-1/2 rounded-full bg-secondary-500/15 blur-[100px] motion-safe:animate-[pulse-glow_8s_ease-in-out_infinite]"
      />
    </div>

    <div class="mx-auto max-w-7xl px-4 pt-24 pb-16 sm:px-6 sm:pt-32 lg:px-8">
      <div class="grid items-center gap-16 lg:grid-cols-2">
        <!-- copy -->
        <div class="text-center lg:text-start">
          <p class="soul-mono motion-safe:animate-[hero-rise_0.7s_ease-out]">
            {{ t('hero.tag') }}
          </p>

          <h1
            class="mt-4 text-4xl font-bold tracking-tight text-highlighted sm:text-6xl motion-safe:animate-[hero-rise_0.7s_ease-out_0.1s_both]"
          >
            {{ t('hero.title') }}<br />
            <span class="soul-grad-text">{{ t('hero.highlight') }}</span>
          </h1>

          <p
            class="mx-auto mt-6 max-w-xl text-lg text-muted lg:mx-0 motion-safe:animate-[hero-rise_0.7s_ease-out_0.2s_both]"
          >
            {{ t('hero.subtitle') }}
          </p>

          <div
            class="mt-10 flex flex-col items-center justify-center gap-4 sm:flex-row lg:justify-start motion-safe:animate-[hero-rise_0.7s_ease-out_0.3s_both]"
          >
            <UButton
              to="#contact"
              size="xl"
              class="rounded-xl shadow-lg shadow-primary-500/30 motion-safe:animate-[pulse-glow_4s_ease-in-out_infinite]"
            >
              {{ t('hero.cta') }}
            </UButton>
            <UButton to="#features" size="xl" color="neutral" variant="subtle" class="rounded-xl">
              {{ t('hero.secondary') }}
            </UButton>
          </div>

          <div class="mt-10 flex items-center justify-center gap-6 lg:justify-start">
            <span
              v-for="label in [t('hero.badges.security'), t('hero.badges.realtime'), t('hero.badges.selfhosted')]"
              :key="label"
              class="soul-mono"
            >
              {{ label }}
            </span>
          </div>
        </div>

        <!-- terminal panel -->
        <div class="relative mx-auto w-full max-w-xl motion-safe:animate-[hero-rise_0.9s_ease-out_0.25s_both]">
          <div class="soul-card overflow-hidden">
            <div class="flex items-center justify-between border-b border-primary-500/20 px-4 py-3">
              <span class="soul-mono">zsh — {{APP_SLUG}}</span>
              <div class="flex gap-1.5">
                <span class="size-2 rounded-full bg-primary-500/60" />
                <span class="size-2 rounded-full bg-secondary-500/60" />
              </div>
            </div>

            <div class="space-y-5 p-6 font-mono text-sm">
              <div v-for="(line, i) in terminal" :key="i" class="motion-safe:animate-[hero-rise_0.6s_ease-out_both]" :style="{ animationDelay: 400 + i * 250 + 'ms' }">
                <p>
                  <span class="text-secondary-400">{{ line.prompt }}</span>
                  <span class="text-highlighted"> {{ line.cmd }}</span>
                </p>
                <p class="mt-1 text-muted motion-safe:animate-[marquee-flicker_7s_linear_infinite]">
                  {{ line.out }}
                </p>
              </div>

              <p>
                <span class="text-secondary-400">$</span>
                <span class="ms-2 inline-block h-4 w-2 translate-y-0.5 bg-primary-400 motion-safe:animate-[tick-blink_1s_steps(1)_infinite]" />
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>
