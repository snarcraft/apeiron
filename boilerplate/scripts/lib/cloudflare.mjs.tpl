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
