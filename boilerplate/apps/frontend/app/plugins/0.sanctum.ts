export default defineNuxtPlugin(() => {
  // Attach device + locale context headers to every sanctum request.
  const sanctumConfig = useSanctumConfig()
  const headers = useRequestHeaders(['x-forwarded-for'])

  sanctumConfig.client = {
    ...sanctumConfig.client,
    onRequest: (context) => {
      const { $i18n } = useNuxtApp()

      context.options.headers.set('X-Device', 'web')
      context.options.headers.set('Accept-Language', $i18n?.locale?.value ?? '{{DEFAULT_LOCALE}}')

      const forwarded = headers['x-forwarded-for']
      if (forwarded) {
        context.options.headers.set('X-Forwarded-For', forwarded)
      }
    }
  }
})
