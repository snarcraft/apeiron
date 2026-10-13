<script setup lang="ts">
// Declarative authorization boundary — renders the slot only when
// the current user may perform feature:action.
const props = withDefaults(
  defineProps<{
    feature: Feature
    action?: Action
    fallback?: boolean
  }>(),
  { action: 'read', fallback: false }
)

const { can } = useAuth()
const allowed = can(props.feature, props.action)
</script>

<template>
  <slot v-if="allowed" />
  <slot v-else-if="fallback" name="fallback" />
</template>
