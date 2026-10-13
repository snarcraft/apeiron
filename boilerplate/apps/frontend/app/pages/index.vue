<script setup lang="ts">
const { t } = useI18n()
const { user } = useAuth()

// Dashboard skeleton — stat cards surface whatever the scaffold's
// feature set enables; wire each to its real endpoint as you build.
const stats = computed(() => [
  { label: t('pages.dashboard.members'), value: '—', icon: 'i-lucide-users', to: '/teams' },
  { label: t('pages.dashboard.media'), value: '—', icon: 'i-lucide-image', to: '/media' },
  { label: t('pages.dashboard.invoices'), value: '—', icon: 'i-lucide-receipt', to: '/invoices' },
  { label: t('pages.dashboard.activity'), value: t('pages.dashboard.live'), icon: 'i-lucide-activity', to: '/' }
])
</script>

<template>
  <UDashboardPanel id="home">
    <template #header>
      <UDashboardNavbar :title="t('pages.dashboard.title')">
        <template #right>
          <UColorModeButton />
        </template>
      </UDashboardNavbar>
    </template>

    <template #body>
      <div>
        <h2 class="text-2xl font-bold text-highlighted">
          {{ t('pages.dashboard.hello', { name: user?.name?.split(' ')[0] ?? t('pages.dashboard.there') }) }}
        </h2>
        <p class="mt-1 text-muted">
          {{ t('pages.dashboard.signedInAs') }}
          <UBadge variant="subtle" color="primary">{{ user?.role }}</UBadge>
          {{ t('pages.dashboard.inGroup') }}
          <UBadge variant="subtle">{{ user?.group }}</UBadge>
        </p>
      </div>

      <div class="mt-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <NuxtLink v-for="stat in stats" :key="stat.label" :to="stat.to" class="soul-card group p-5">
          <div class="flex items-center justify-between">
            <span class="soul-chip">
              <UIcon :name="stat.icon" class="size-5" />
            </span>
            <UIcon name="i-lucide-arrow-up-right" class="size-4 text-dimmed transition-transform group-hover:translate-x-0.5 group-hover:-translate-y-0.5" />
          </div>
          <p class="mt-4 text-2xl font-bold text-highlighted">{{ stat.value }}</p>
          <p class="text-sm text-muted">{{ stat.label }}</p>
        </NuxtLink>
      </div>

      <div class="soul-card mt-8 p-8 text-center">
        <p class="soul-ghost select-none">01</p>
        <h3 class="mt-4 text-lg font-semibold text-highlighted">{{ t('pages.dashboard.startTitle') }}</h3>
        <p class="mx-auto mt-2 max-w-md text-sm text-muted">
          {{ t('pages.dashboard.startBody') }}
        </p>
      </div>
    </template>
  </UDashboardPanel>
</template>
