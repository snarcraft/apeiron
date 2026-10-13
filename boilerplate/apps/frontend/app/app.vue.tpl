<script setup lang="ts">
const appConfig = useAppConfig()
const user = useSanctumUser<User>()

// Runtime tenant theming: the backend ships brand colors with the
// settings payload — inject them as :root CSS variable overrides.
const themeCss = computed(() => {
  const colors = appConfig.settings?.theme?.colors as Record<string, string> | undefined
  if (!colors) return ''

  return `:root {
${Object.entries(colors)
  .map(([name, value]) => `  --color-${name}: ${value};`)
  .join('\n')}
}`
})

useHead(() => ({
  titleTemplate: title => (title ? `${title} · ${appConfig.settings?.title ?? '{{APP_TITLE}}'}` : (appConfig.settings?.title ?? '{{APP_TITLE}}')),
  style: themeCss.value ? [{ key: 'app-theme', innerHTML: themeCss.value }] : []
}))
</script>

<template>
  <UApp>
    <NuxtLayout>
      <NuxtPage />
    </NuxtLayout>
  </UApp>
</template>
