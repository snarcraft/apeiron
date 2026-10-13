<script setup lang="ts">
defineProps<{ collapsed?: boolean }>()

const { user, logout } = useSanctumAuth()
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
  <UDropdownMenu
    :items="[[
      { label: 'Account', icon: 'i-lucide-settings', to: '/account' },
      { label: 'Sign out', icon: 'i-lucide-log-out', onSelect: () => logout() }
    ]]"
  >
    <UButton
      color="neutral"
      variant="ghost"
      block
      :square="collapsed"
      class="data-[state=open]:bg-elevated"
    >
      <span class="grid size-8 shrink-0 place-items-center rounded-full bg-primary-500/15 text-xs font-bold text-primary-500">
        {{ initials }}
      </span>
      <span v-if="!collapsed" class="truncate text-sm">
        {{ user?.name }}
      </span>
    </UButton>
  </UDropdownMenu>
</template>
