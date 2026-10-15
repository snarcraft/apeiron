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
//   node scripts/bootstrap.mjs             # staging + production (default)
//   node scripts/bootstrap.mjs production  # repair a single environment
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

const targets = process.argv[2] ? [process.argv[2]] : ['staging', 'production']

if (!existsSync('secrets/master.env')) {
  console.error('[fail] secrets/master.env not found — re-run the factory or fill it by hand')
  process.exit(1)
}

for (const t of targets) {
  if (!existsSync(`secrets/${t}.env`)) {
    console.error(`[fail] secrets/${t}.env not found — cp secrets/staging.env secrets/${t}.env and adjust, then re-run`)
    process.exit(1)
  }
}

const master = readEnv('secrets/master.env')

// preflight — aws credentials via the signed api: fail fast with
// one line instead of a provision-time cascade.
if (master.AWS_ACCESS_KEY_ID && master.AWS_SECRET_ACCESS_KEY) {
  const { aws } = await import('./lib/aws.mjs')
  try {
    const identity = await aws.callerIdentity(env.AWS_DEFAULT_REGION || 'eu-west-3', {
      accessKeyId: master.AWS_ACCESS_KEY_ID,
      secretAccessKey: master.AWS_SECRET_ACCESS_KEY,
    })
    console.log(`aws ok — account ${identity?.GetCallerIdentityResult?.Account ?? 'verified'}`)
  } catch (error) {
    console.error(`[fail] AWS credentials rejected — ${error.message}`)
    process.exit(1)
  }
}

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

for (const target of targets) {
  const env = readEnv(`secrets/${target}.env`)

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

  // the derived webhook — endpoint registered per environment
  if (master.STRIPE_SECRET && env.APP_URL && !env.APP_URL.includes('REPLACE_ME')) {
    try {
      const url = `${env.APP_URL}/api/stripe/webhook`
      const webhook = await stripe.ensureWebhookEndpoint(master.STRIPE_SECRET, url)
      await github.secret('STRIPE_WEBHOOK_SECRET', webhook.secret, target)
      if (target === 'production') {
        appendFileSync('secrets/local.env', `\nSTRIPE_WEBHOOK_SECRET=${webhook.secret}\n`)
      }
      console.log(`secret ${target}/STRIPE_WEBHOOK_SECRET (derived via stripe api → ${url})`)
      secrets += 1
    } catch (error) {
      console.error(`[warn] ${target}: stripe webhook not derived — ${error.message}`)
    }
  }
}

for (const k of STORE_KEYS) {
  if (!master[k]) continue
  guard(() => github.secret(k, master[k], 'mobile'))
  console.log(`secret mobile/${k} (master)`)
  secrets += 1
}

console.log(`\n${vars} variables · ${secrets} secrets — tag a release and CI does the rest.`)
