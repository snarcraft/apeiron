<script setup lang="ts">
const { t } = useI18n()

// Tokens like {{APP_TITLE}} are resolved at scaffold time — they
// land as plain text before Vue ever compiles this file.
const stats = { operations: 12000, teams: 340, uptime: 99.98 }
</script>

<template>
  <section class="relative overflow-hidden">
    <!-- aurora orbs -->
    <div aria-hidden="true" class="pointer-events-none absolute inset-0 -z-10">
      <div
        class="absolute left-[12%] top-[-10%] size-[36rem] rounded-full bg-primary-500/25 blur-[130px] motion-safe:animate-[glow-pulse_9s_ease-in-out_infinite]"
      />
      <div
        class="absolute right-[8%] top-[15%] size-[28rem] rounded-full bg-secondary-500/20 blur-[130px] motion-safe:animate-[glow-pulse_11s_ease-in-out_2s_infinite]"
      />
      <div class="absolute inset-0 bg-dots opacity-60" />
    </div>

    <div class="mx-auto max-w-7xl px-4 pt-24 pb-16 sm:px-6 sm:pt-32 lg:px-8">
      <div class="grid items-center gap-16 lg:grid-cols-2">
        <!-- copy -->
        <div class="text-center lg:text-start">
          <p class="soul-mono motion-safe:animate-[hero-rise_0.7s_ease-out]">
            {{ t('hero.tag') }}
          </p>

          <h1
            class="mt-4 text-4xl font-extrabold tracking-tight text-highlighted sm:text-5xl xl:text-6xl motion-safe:animate-[hero-rise_0.7s_ease-out_0.1s_both]"
          >
            {{ t('hero.title') }}
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
              trailing-icon="i-lucide-arrow-right"
              class="rounded-xl"
            >
              {{ t('hero.cta') }}
            </UButton>
            <UButton
              to="#features"
              size="xl"
              color="neutral"
              variant="subtle"
              trailing-icon="i-lucide-compass"
              class="rounded-xl"
            >
              {{ t('hero.secondary') }}
            </UButton>
          </div>

          <p class="mt-8 text-sm text-dimmed">
            <span class="font-semibold text-default">{{ stats.operations.toLocaleString() }}+</span>
            {{ stats.operations.toLocaleString() }}+ {{ t('hero.proof') }} · {{ stats.uptime }}% uptime
          </p>
        </div>

        <!-- product mock, pure CSS -->
        <div
          class="relative mx-auto w-full max-w-xl motion-safe:animate-[hero-rise_0.9s_ease-out_0.25s_both]"
        >
          <div class="soul-card p-3 shadow-2xl shadow-primary-950/10">
            <!-- window chrome -->
            <div class="flex items-center gap-1.5 border-b border-default px-3 pb-3">
              <span class="size-3 rounded-full bg-red-400/80" />
              <span class="size-3 rounded-full bg-amber-400/80" />
              <span class="size-3 rounded-full bg-emerald-400/80" />
              <span class="ms-3 soul-mono">app.{{DOMAIN}}</span>
            </div>

            <div class="grid grid-cols-[auto_1fr] gap-0">
              <!-- sidebar -->
              <div class="border-e border-default p-4">
                <div class="size-8 rounded-lg bg-gradient-to-br from-primary-500 to-secondary-500" />
                <div class="mt-6 space-y-3">
                  <div class="h-2.5 w-24 rounded bg-primary-500/30" />
                  <div class="h-2.5 w-16 rounded bg-default/70" />
                  <div class="h-2.5 w-20 rounded bg-default/70" />
                  <div class="h-2.5 w-14 rounded bg-default/70" />
                </div>
              </div>

              <!-- body -->
              <div class="space-y-4 p-5">
                <div class="flex items-center justify-between">
                  <div class="h-3.5 w-32 rounded bg-default/80" />
                  <div class="h-7 w-20 rounded-lg bg-primary-500/25" />
                </div>

                <div class="grid grid-cols-3 gap-3">
                  <div v-for="i in 3" :key="i" class="rounded-xl border border-default p-3">
                    <div class="h-2 w-10 rounded bg-muted/50" />
                    <div
                      class="mt-2 h-5 w-14 rounded font-mono text-lg font-bold"
                      :class="i === 1 ? 'text-primary-500' : 'text-highlighted'"
                    >
                      {{ i * 24 + 8 }}
                    </div>
                    <div
                      class="mt-2 h-1 rounded"
                      :class="i === 1 ? 'bg-primary-500/60' : 'bg-secondary-500/40'"
                    />
                  </div>
                </div>

                <div class="flex items-end gap-1.5 pt-2" aria-hidden="true">
                  <div
                    v-for="(h, i) in [38, 62, 45, 80, 55, 92, 70, 48, 85, 60]"
                    :key="i"
                    class="w-full rounded-t motion-safe:animate-[bar-rise_1s_ease-out_both]"
                    :class="i % 3 === 0 ? 'bg-primary-500/70' : 'bg-secondary-500/50'"
                    :style="{ height: h + 'px', animationDelay: i * 80 + 'ms' }"
                  />
                </div>
              </div>
            </div>
          </div>

          <!-- floating badge -->
          <div
            class="absolute -bottom-6 -start-6 soul-card flex items-center gap-3 px-4 py-3 motion-safe:animate-[float_6s_ease-in-out_infinite]"
          >
            <span class="grid size-9 place-items-center rounded-full bg-emerald-500/15 text-emerald-500">
              <UIcon name="i-lucide-check" class="size-5" />
            </span>
            <div>
              <p class="text-sm font-semibold text-highlighted">All synced</p>
              <p class="text-xs text-muted">realtime · just now</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>
