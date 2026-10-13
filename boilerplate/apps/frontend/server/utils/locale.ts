// SSR locale detector: header → cookie → query → default.
export default defineI18nLocaleDetector((event, { defaultLocale }) => {
  const query = getQuery(event)
  if (typeof query.locale === 'string') return query.locale

  const cookie = getCookie(event, 'i18n_locale')
  if (cookie) return cookie

  const header = getHeader(event, 'accept-language')?.split(',')[0]?.split('-')[0]
  if (header) return header

  return defaultLocale
})
