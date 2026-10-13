import type { Feature, Action } from '#build/types'

// The single authorization surface for the UI — mirrors the
// backend enum matrix that rides along on the user payload.
export function useAuth() {
  const user = useSanctumUser<User>()

  const can = (feature: Feature, action: Action = 'read') => {
    return computed(() => Boolean(user.value?.policies?.[`${feature}:${action}`]))
  }

  const isAdmin = computed(() => user.value?.group === 'operator' && user.value?.role === 'admin')

  return { user, can, isAdmin }
}
