export default defineNuxtPlugin(async (nuxtApp) => {
  const { $i18n } = nuxtApp
  const client = useSanctumClient()

  try {
    const response = await client<SanctumResponse<Record<string, string>>>('/api/translations')

    for (const [key, message] of Object.entries(response.data)) {
      $i18n.mergeLocaleMessage($i18n.locale.value, { [key]: message })
    }
  } catch {
    // Translations are enhancement, not blocker.
  }
})
