<script setup lang="ts">
const { t } = useI18n()

// Tokens like {{APP_TITLE}} are resolved at scaffold time.
const year = new Date().getFullYear()

const blueprint = [
  { ref: 'A-01', label: 'intake', status: 'ok' },
  { ref: 'A-02', label: 'dispatch', status: 'ok' },
  { ref: 'B-07', label: 'review', status: 'hold' },
  { ref: 'C-15', label: 'settle', status: 'ok' },
]
</script>

<template>
  <section class="relative overflow-hidden border-b border-default">
    <div aria-hidden="true" class="pointer-events-none absolute inset-0 -z-10">
      <div class="soul-hero-bg absolute inset-0" />
      <div
        class="absolute inset-x-0 top-0 h-px bg-linear-to-r from-transparent via-primary-500 to-transparent motion-safe:animate-[scan_5s_linear_infinite]"
      />
    </div>

    <div class="mx-auto max-w-7xl px-4 pt-24 pb-16 sm:px-6 sm:pt-32 lg:px-8">
      <div class="grid items-center gap-16 lg:grid-cols-2">
        <!-- copy -->
        <div class="text-center lg:text-start">
          <p class="soul-mono motion-safe:animate-[hero-rise_0.7s_ease-out]">
            {{ t('hero.tag') }} · rev {{ year }}
          </p>

          <h1
            class="mt-4 font-mono text-4xl font-semibold tracking-tight text-highlighted sm:text-5xl motion-safe:animate-[hero-rise_0.7s_ease-out_0.1s_both]"
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
            <UButton to="#contact" size="xl" class="rounded-none">
              {{ t('hero.cta') }}
              <UIcon name="i-lucide-corner-down-right" />
            </UButton>
            <UButton to="#features" size="xl" color="neutral" variant="outline" class="rounded-none">
              {{ t('hero.secondary') }}
            </UButton>
          </div>

          <dl class="mt-10 grid grid-cols-3 gap-px border border-default bg-default">
            <div v-for="(s, i) in [{ k: 'workflows', v: '40+' }, { k: 'uptime', v: '99.98%' }, { k: 'latency', v: '<80ms' }]" :key="i" class="bg-default px-4 py-3 text-center">
              <dt class="soul-mono">{{ s.k }}</dt>
              <dd class="mt-1 font-mono text-xl font-semibold text-highlighted">{{ s.v }}</dd>
            </div>
          </dl>
        </div>

        <!-- schematic panel -->
        <div class="relative mx-auto w-full max-w-xl motion-safe:animate-[hero-rise_0.9s_ease-out_0.25s_both]">
          <div class="soul-card bg-default">
            <div class="flex items-center justify-between border-b border-default px-4 py-2.5">
              <span class="soul-mono">fig. 01 — process flow</span>
              <span class="size-2 rounded-full bg-primary-500 motion-safe:animate-[tick-blink_2s_ease-in-out_infinite]" />
            </div>

            <div class="space-y-px bg-default">
              <div
                v-for="row in blueprint"
                :key="row.ref"
                class="flex items-center gap-4 bg-default px-4 py-3.5"
              >
                <span class="w-12 font-mono text-xs text-primary-600">{{ row.ref }}</span>
                <div class="h-px flex-1 bg-border-accented relative">
                  <span
                    class="absolute inset-y-0 left-0 h-px"
                    :class="row.status === 'ok' ? 'bg-primary-500' : 'bg-amber-500'"
                    :style="{ width: row.status === 'ok' ? '100%' : '45%' }"
                  />
                </div>
                <span class="font-mono text-sm text-highlighted">{{ row.label }}</span>
                <span
                  class="soul-mono"
                  :class="row.status === 'ok' ? 'text-primary-600' : 'text-amber-600'"
                >
                  {{ row.status }}
                </span>
              </div>
            </div>

            <div class="grid grid-cols-2 gap-px border-t border-default bg-default">
              <div class="bg-default p-4">
                <p class="soul-mono">dimension</p>
                <p class="mt-1 font-mono text-sm text-muted">RBAC · enum-driven, zero DB</p>
              </div>
              <div class="bg-default p-4">
                <p class="soul-mono">tolerance</p>
                <p class="mt-1 font-mono text-sm text-muted">± 0 regressions / release</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>
