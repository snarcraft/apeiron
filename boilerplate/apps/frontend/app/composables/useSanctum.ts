import type { FetchRequest, FetchOptions, ResponseType } from 'ofetch'

// Typed API access — every fetch in the app goes through here.
// The { data } envelope stays intact (callers read `.data`).

export const useSanctum = <T, R extends ResponseType = 'json'>(
  request: FetchRequest,
  options?: FetchOptions<R> | undefined
) => {
  const sanctum = useSanctumClient()

  return sanctum<SanctumResponse<T>, R>(request, options)
}
