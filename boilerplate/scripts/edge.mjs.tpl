#!/usr/bin/env node

// ============================================================
// edge.mjs — cloudflare pages project + custom domain, once
// ============================================================
// Runs in the deploy (edge) workflow before the upload: derives
// the account from the token, ensures the pages project exists,
// attaches the custom domain. Writes the account id to
// $GITHUB_OUTPUT so the upload step reuses it. Idempotent.

import { cloudflare } from './lib/cloudflare.mjs'

const token = process.env.CF_DNS_API_TOKEN
const project = '{{APP_NAME}}-web'
const domain = '{{DOMAIN}}'

if (!token) {
  console.error('[fail] CF_DNS_API_TOKEN not set — push it with bootstrap (scopes: zone dns edit + pages edit + account read)')
  process.exit(1)
}

const account = await cloudflare.accountId(token)
await cloudflare.pagesEnsureProject(token, account, project)
const attached = await cloudflare.pagesEnsureDomain(token, account, project, domain)

console.log(`[edge] pages project ${project} ready`)
console.log(`[edge] ${domain} → ${attached.status ?? 'attached'}`)

if (process.env.GITHUB_OUTPUT) {
  const fs = await import('node:fs')
  fs.appendFileSync(process.env.GITHUB_OUTPUT, `account=${account}\n`)
}
