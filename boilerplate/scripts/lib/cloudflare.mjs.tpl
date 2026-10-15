// ============================================================
// lib/cloudflare.mjs — DNS records via the Cloudflare API
// ============================================================
// The provisioner drives the CLI; this lib is for automation
// that runs where the CLI is not — GitHub Actions, bootstrap
// follow-ups, drift repair.

export const cloudflare = {
  zoneByName: async (token, name) => {
    const r = await fetch(`https://api.cloudflare.com/client/v4/zones?name=${encodeURIComponent(name)}`, {
      headers: { Authorization: `Bearer ${token}` },
    })
    if (!r.ok) throw new Error(`cloudflare zone lookup failed: ${r.status}`)
    const zones = (await r.json()).result ?? []
    if (!zones.length) throw new Error(`cloudflare zone not found: ${name}`)
    return zones[0]
  },

  // the account the token belongs to — derived, never asked
  accountId: async (token) => {
    const r = await fetch('https://api.cloudflare.com/client/v4/accounts?per_page=1', {
      headers: { Authorization: `Bearer ${token}` },
    })
    if (!r.ok) throw new Error(`cloudflare account lookup failed: ${r.status}`)
    const accounts = (await r.json()).result ?? []
    if (!accounts.length) throw new Error('cloudflare account not found for this token')
    return accounts[0].id
  },

  // pages: static hosting on the edge — project + custom domain
  pagesEnsureProject: async (token, account, name) => {
    const headers = { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' }
    const existing = await fetch(`https://api.cloudflare.com/client/v4/accounts/${account}/pages/projects/${name}`, { headers })
    if (existing.ok) return (await existing.json()).result
    const created = await fetch(`https://api.cloudflare.com/client/v4/accounts/${account}/pages/projects`, {
      method: 'POST',
      headers,
      body: JSON.stringify({ name, production_branch: 'main' }),
    })
    if (!created.ok) throw new Error(`cloudflare pages project create failed: ${created.status}`)
    return (await created.json()).result
  },

  pagesEnsureDomain: async (token, account, project, domain) => {
    const headers = { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' }
    const list = await fetch(`https://api.cloudflare.com/client/v4/accounts/${account}/pages/projects/${project}/domains`, { headers })
    if (list.ok && ((await list.json()).result ?? []).some((d) => d.name === domain)) {
      return { name: domain, status: 'already attached' }
    }
    const attached = await fetch(`https://api.cloudflare.com/client/v4/accounts/${account}/pages/projects/${project}/domains`, {
      method: 'POST',
      headers,
      body: JSON.stringify({ name: domain }),
    })
    if (!attached.ok) throw new Error(`cloudflare pages domain attach failed: ${attached.status}`)
    return (await attached.json()).result
  },

  createDnsRecord: async (token, zoneId, { type, name, content, proxied = false, ttl = 1 }) => {
    const r = await fetch(`https://api.cloudflare.com/client/v4/zones/${zoneId}/dns_records`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ type, name, content, proxied, ttl }),
    })
    if (!r.ok) throw new Error(`cloudflare dns create failed: ${r.status}`)
    return r.json()
  },

  // idempotent by (name, type) — re-running bootstrap is safe
  ensureDnsRecord: async (token, zoneName, record) => {
    const zone = await cloudflare.zoneByName(token, zoneName)
    const r = await fetch(`https://api.cloudflare.com/client/v4/zones/${zone.id}/dns_records?name=${encodeURIComponent(record.name)}&type=${record.type}`, {
      headers: { Authorization: `Bearer ${token}` },
    })
    const existing = ((await r.json()).result ?? [])[0]
    return existing ?? cloudflare.createDnsRecord(token, zone.id, record)
  },
}
