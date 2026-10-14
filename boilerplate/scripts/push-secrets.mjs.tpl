#!/usr/bin/env node

// ============================================================
// push-secrets.mjs — master credentials → GitHub environments
// ============================================================
// One command closes the provisioning loop: the master keys you
// gave at onboarding (secrets/master.env) plus the scaffold-
// generated database and redis passwords go up as encrypted
// GitHub environment secrets. `gh` performs the libsodium
// sealing; values never appear on a command line or in git.
//
//   node scripts/push-secrets.mjs             # staging (default)
//   node scripts/push-secrets.mjs production  # the day you go live
//
// Auth: the GITHUB_ACCESS_TOKEN from master.env is used as
// GH_TOKEN (or bring your own — `gh auth login` works too).

import { readFileSync, existsSync } from 'node:fs'
import { execFileSync } from 'node:child_process'

const readEnv = (file) => {
  if (!existsSync(file)) return {}
  const out = {}
  for (const line of readFileSync(file, 'utf8').split('\n')) {
    const m = line.match(/^([A-Z0-9_]+)=(.*)$/)
    if (m) out[m[1]] = m[2].trim()
  }
  return out
}

const master = readEnv('secrets/master.env')
const target = process.argv[2] || 'staging'
const targetFile = `secrets/${target}.env`

if (!existsSync('secrets/master.env')) {
  console.error('[fail] secrets/master.env not found — re-run the factory or fill it by hand')
  process.exit(1)
}

const APP_KEYS = [
  'AWS_ACCESS_KEY_ID', 'AWS_SECRET_ACCESS_KEY',
  'CF_DNS_API_TOKEN', 'DISCORD_BOT_TOKEN',
  'STRIPE_KEY', 'STRIPE_SECRET',
]
const STORE_KEYS = [
  'APP_STORE_ISSUER_ID', 'APP_STORE_KEY_ID', 'APP_STORE_PRIVATE_KEY',
  'ANDROID_SERVICE_ACCOUNT',
]
const GENERATED_KEYS = ['DB_PASSWORD', 'REDIS_PASSWORD']

const plan = [
  { env: target, source: { ...readEnv(targetFile), ...master }, keys: [...APP_KEYS, ...GENERATED_KEYS] },
  { env: 'mobile', source: master, keys: STORE_KEYS },
]

const gh = (args, value) =>
  execFileSync('gh', args, {
    input: value,
    env: { ...process.env, GH_TOKEN: process.env.GH_TOKEN || master.GITHUB_ACCESS_TOKEN || '' },
    stdio: ['pipe', 'ignore', 'inherit'],
  })

let pushed = 0
for (const { env, source, keys } of plan) {
  for (const key of keys) {
    const value = source[key]
    if (!value) {
      console.log(`skip  ${env}/${key} (empty)`)
      continue
    }
    gh(['secret', 'set', key, '--env', env], value)
    console.log(`set   ${env}/${key}`)
    pushed += 1
  }
}

console.log(`\n${pushed} secrets pushed — tag a release and CI does the rest.`)
