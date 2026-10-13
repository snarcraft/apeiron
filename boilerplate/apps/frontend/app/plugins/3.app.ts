// Boots the app from /api/settings: tenant identity, option
// lists and theme land in the payload before pages render.
export default defineNuxtPlugin(async () => {
  const appConfig = useAppConfig()
  const client = useSanctumClient()

  try {
    const response = await client<SanctumResponse<Settings>>('/api/settings', {
      server: true
    })

    appConfig.settings = response.data
  } catch {
    appConfig.settings ??= {} as Settings
  }
})
