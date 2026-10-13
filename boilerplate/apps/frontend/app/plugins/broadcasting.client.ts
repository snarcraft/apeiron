import Pusher from 'pusher-js'

// Reverb client + sanctum-authorized private channels, exposed as
// $pusher. The user channel refreshes identity on UserUpdated.
export default defineNuxtPlugin(() => {
  const config = useRuntimeConfig()
  const user = useSanctumUser<User>()
  const client = useSanctumClient()

  const pusher = new Pusher(config.public.reverb.key, {
    wsHost: config.public.reverb.host,
    wsPort: Number(config.public.reverb.port),
    forceTLS: config.public.reverb.protocol === 'https',
    enabledTransports: ['ws', 'wss'],
    cluster: config.public.reverb.cluster,
    authorizer: (channel) => ({
      authorize: async (socketId, callback) => {
        try {
          const response = await client('/api/broadcasting/auth', {
            method: 'POST',
            body: { socket_id: socketId, channel_name: channel.name }
          })

          callback(null, response)
        } catch (error: unknown) {
          callback(error as Error, null)
        }
      }
    })
  })

  watchEffect(() => {
    const id = user.value?.id

    if (!id) return

    const channel = pusher.subscribe(`private-auth.${id}`)

    channel.bind('UserUpdated', async () => {
      await refreshIdentity()
      await refreshNuxtData('settings')
    })
  })

  return {
    provide: {
      pusher
    }
  }
})
