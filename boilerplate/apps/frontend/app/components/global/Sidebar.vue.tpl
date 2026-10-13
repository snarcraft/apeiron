<script setup lang="ts">
defineProps<{ id?: string }>()
</script>

<template>
  <UDashboardSidebar
    :id="id"
    collapsible
    resizable
    :min-size="14"
    :default-size="16"
    :max-size="20"
  >
    <template #header="{ collapsed }">
      <NuxtLink to="/" class="flex items-center gap-2.5">
        <Mark :class="collapsed ? 'size-7' : 'size-8'" />
        <span v-if="!collapsed" class="truncate text-highlighted font-semibold">
          {{ useAppConfig().settings?.title ?? '{{APP_TITLE}}' }}
        </span>
      </NuxtLink>
    </template>

    <Menu />

    <template #footer="{ collapsed }">
      <Profile :collapsed="collapsed" />
    </template>
  </UDashboardSidebar>
</template>
