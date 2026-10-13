<script setup lang="ts">
const { t } = useI18n()

const year = new Date().getFullYear()
</script>

<template>
  <UFooter>
    <template #left>
      <Logo />
    </template>

    <template #right>
      <p class="text-sm text-muted">
        © {{ year }} {{APP_TITLE}} ·
        <span class="text-dimmed">{{ t('footer.rights') }}</span>
      </p>
    </template>
  </UFooter>
</template>
