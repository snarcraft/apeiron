#!/usr/bin/env node

// ============================================================
// bootstrap.mjs — master credentials → a fully wired pipeline
// ============================================================
// One command, three moves, idempotent:
//   1. every public value in secrets/<env>.env  → GitHub variables
//   2. every sealed value + the master app keys  → GitHub secrets
//   3. the Stripe webhook is DERIVED via API — endpoint registered
//      against this deployment, signing secret pushed to GitHub
//      and mirrored into secrets/local.env (nobody ever types it)
//
//   node scripts/bootstrap.mjs             # staging (default)
//   node scripts/bootstrap.mjs production  # the day you go live
//
// AWS resources (buckets, IAM users, EC2, security groups) stay
// with `scripts/provision.mjs` — the aws CLI does the signing.

import { readFileSync, existsSync, appendFileSync } from 'node:fs'
import { github } from './lib/github.mjs'
import { stripe } from './lib/stripe.mjs'

const readEnv = (file) => {
  const out = {}
  for (const line of readFileSync(file, 'utf8').split('\n')) {
    const m = line.match(/^([A-Z0-9_]+)=(.*)$/)
    if (m) out[m[1]] = m[2].trim()
  }
  return out
}

const target = process.argv[2] || 'staging'
const envFile = `secrets/${target}.env`

for (const file of ['secrets/master.env', envFile]) {
  if (!existsSync(file)) {
    if (file === envFile) {
      console.error(`[fail] ${file} not found — cp secrets/staging.env ${envFile} and adjust, then re-run`)
    } else {
      console.error(`[fail] ${file} not found — re-run the factory or fill it by hand`)
    }
    process.exit(1)
  }
}

const master = readEnv('secrets/master.env')
const env = readEnv(envFile)

const SECRET_RE = /KEY|SECRET|TOKEN|PASSWORD|PRIVATE/
const MASTER_APP_KEYS = [
  'AWS_ACCESS_KEY_ID', 'AWS_SECRET_ACCESS_KEY',
  'CF_DNS_API_TOKEN', 'DISCORD_BOT_TOKEN',
  'STRIPE_KEY', 'STRIPE_SECRET',
]
const STORE_KEYS = [
  'APP_STORE_ISSUER_ID', 'APP_STORE_KEY_ID', 'APP_STORE_PRIVATE_KEY',
  'ANDROID_SERVICE_ACCOUNT',
]

let vars = 0
let secrets = 0

const guard = (run) => {
  try {
    run()
  } catch {
    console.error('[fail] gh could not reach the repository — add a remote (git remote add origin OWNER/REPO.git) or export GH_REPO=owner/name, then re-run. Idempotent: nothing is half-pushed that a re-run cannot finish.')
    process.exit(1)
  }
}

for (const [k, v] of Object.entries(env)) {
  if (!v || v.includes('REPLACE_ME')) continue
  if (SECRET_RE.test(k)) {
    guard(() => github.secret(k, v, target))
    console.log(`secret ${target}/${k}`)
    secrets += 1
  } else {
    guard(() => github.variable(k, v, target))
    console.log(`var    ${target}/${k}`)
    vars += 1
  }
}

for (const k of MASTER_APP_KEYS) {
  if (!master[k]) continue
  guard(() => github.secret(k, master[k], target))
  console.log(`secret ${target}/${k} (master)`)
  secrets += 1
}

// master keys ride both deploy environments — main pushes roll
// staging, tags roll production. One bootstrap arms both.
if (target === 'staging') {
  for (const k of MASTER_APP_KEYS) {
    if (!master[k]) continue
    guard(() => github.secret(k, master[k], 'production'))
    console.log(`secret production/${k} (master)`)
    secrets += 1
  }
}

for (const k of STORE_KEYS) {
  if (!master[k]) continue
  guard(() => github.secret(k, master[k], 'mobile'))
  console.log(`secret mobile/${k} (master)`)
  secrets += 1
}

// the derived webhook — endpoint registered, secret pushed
if (master.STRIPE_SECRET && env.APP_URL) {
  try {
    const url = `${env.APP_URL}/api/stripe/webhook`
    const webhook = await stripe.ensureWebhookEndpoint(master.STRIPE_SECRET, url)
    await github.secret('STRIPE_WEBHOOK_SECRET', webhook.secret, target)
    appendFileSync('secrets/local.env', `\nSTRIPE_WEBHOOK_SECRET=${webhook.secret}\n`)
    console.log(`secret ${target}/STRIPE_WEBHOOK_SECRET (derived via stripe api → ${url})`)
    secrets += 1
  } catch (error) {
    console.error(`[warn] stripe webhook not derived — ${error.message}`)
  }
}

console.log(`\n${vars} variables · ${secrets} secrets — tag a release and CI does the rest.`)
