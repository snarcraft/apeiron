import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'
import duration from 'dayjs/plugin/duration'
import timezone from 'dayjs/plugin/timezone'
import 'dayjs/locale/{{DEFAULT_LOCALE}}'

export default defineNuxtPlugin((nuxtApp) => {
  dayjs.extend(relativeTime)
  dayjs.extend(duration)
  dayjs.extend(timezone)

  const { $i18n } = nuxtApp
  dayjs.locale($i18n?.locale?.value ?? '{{DEFAULT_LOCALE}}')

  return {
    provide: {
      dayjs: (...args: Parameters<typeof dayjs>) => dayjs(...args)
    }
  }
})
