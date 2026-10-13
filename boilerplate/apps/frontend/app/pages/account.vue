<script setup lang="ts">
const { t } = useI18n()
const { user } = useAuth()
const appConfig = useAppConfig()

const profileRows = computed(() => [
  { label: t('pages.account.name'), value: user.value?.name },
  { label: t('pages.account.email'), value: user.value?.email },
  { label: t('pages.account.group'), value: user.value?.group, badge: true },
  { label: t('pages.account.role'), value: user.value?.role, badge: true, primary: true },
  { label: t('pages.account.workspace'), value: appConfig.settings?.title }
])

const policyRows = computed(() =>
  Object.entries(user.value?.policies ?? {})
    .filter(([, allowed]) => allowed)
    .map(([ability]) => ability)
)
</script>

<template>
  <UDashboardPanel id="account">
    <template #header>
      <UDashboardNavbar :title="t('pages.account.title')">
        <template #right>
          <UColorModeButton />
        </template>
      </UDashboardNavbar>
    </template>

    <template #body>
      <div class="grid gap-8 lg:grid-cols-2">
        <section class="soul-card p-6">
          <h3 class="text-lg font-semibold text-highlighted">{{ t('pages.account.profile') }}</h3>

          <dl class="mt-4 space-y-3 text-sm">
            <div v-for="row in profileRows" :key="row.label" class="flex justify-between">
              <dt class="text-muted">{{ row.label }}</dt>
              <dd>
                <UBadge v-if="row.badge" variant="subtle" :color="row.primary ? 'primary' : 'neutral'">
                  {{ row.value }}
                </UBadge>
                <span v-else class="text-highlighted">{{ row.value }}</span>
              </dd>
            </div>
          </dl>
        </section>

        <section class="soul-card p-6">
          <h3 class="text-lg font-semibold text-highlighted">{{ t('pages.account.permissions') }}</h3>
          <p class="mt-1 text-sm text-muted">
            {{ t('pages.account.permissionsBody') }}
          </p>

          <div class="mt-4 flex flex-wrap gap-2">
            <UBadge
              v-for="ability in policyRows"
              :key="ability"
              variant="subtle"
              color="primary"
              class="font-mono text-xs"
            >
              {{ ability }}
            </UBadge>
            <p v-if="!policyRows.length" class="text-sm text-dimmed">
              {{ t('pages.account.noAbilities') }}
            </p>
          </div>
        </section>
      </div>
    </template>
  </UDashboardPanel>
</template>
