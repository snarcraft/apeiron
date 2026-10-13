<script setup lang="ts">
import { capitalize } from 'lodash-es'

const appConfig = useAppConfig()
const { t } = useI18n()
const { can } = useAuth()

// Sections and entries come from app.config.navigation — generated
// from the scaffold's feature list, gated by each entry's action.
const sections = computed(() =>
  Object.entries(appConfig.navigation ?? {}).map(([section, entries]) => ({
    label: capitalize(t(`sections.${section}`)),
    icon: appConfig.menu?.[section as MenuSection] ?? 'i-lucide-layout-grid',
    items: Object.entries(entries)
      .filter(([feature, entry]) => !entry.action || can(feature as Feature, entry.action).value)
      .map(([feature, entry]) => ({
        label: capitalize(t(`features.${feature}`)),
        icon: entry.icon,
        to: entry.to
      }))
  }))
)
</script>

<template>
  <UNavigationMenu orientation="vertical" :items="sections" class="px-1" />
</template>
