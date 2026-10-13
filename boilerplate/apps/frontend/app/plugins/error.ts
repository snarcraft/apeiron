export default defineNuxtPlugin((nuxtApp) => {
  nuxtApp.vueApp.config.errorHandler = (error, instance, info) => {
    console.error('[vue]', info, error)
  }

  nuxtApp.hook('vue:error', (error) => {
    console.error('[hook]', error)
  })
})
