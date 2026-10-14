// ============================================================
// lib/stripe.mjs — the Stripe API surface the platform needs
// ============================================================
// API keys cannot be minted by the API (Stripe's design — the
// master pair you gave at onboarding is the key set); webhooks
// can. The signing secret bootstrap derives here is the only
// Stripe value nobody ever types.

export const stripe = {
  listWebhookEndpoints: async (secret) => {
    const r = await fetch('https://api.stripe.com/v1/webhook_endpoints', {
      headers: { Authorization: `Bearer ${secret}` },
    })
    if (!r.ok) throw new Error(`stripe list webhooks failed: ${r.status}`)
    return (await r.json()).data ?? []
  },

  createWebhookEndpoint: async (secret, url) => {
    const body = new URLSearchParams({
      url,
      description: 'apeiron platform',
      'enabled_events[]': '*',
    })
    const r = await fetch('https://api.stripe.com/v1/webhook_endpoints', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${secret}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body,
    })
    if (!r.ok) throw new Error(`stripe create webhook failed: ${r.status}`)
    return r.json()
  },

  // find-or-create by url — bootstrap is idempotent
  ensureWebhookEndpoint: async (secret, url) => {
    const existing = (await stripe.listWebhookEndpoints(secret)).find((w) => w.url === url)
    return existing ?? stripe.createWebhookEndpoint(secret, url)
  },
}
