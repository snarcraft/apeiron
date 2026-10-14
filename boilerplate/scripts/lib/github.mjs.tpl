// ============================================================
// lib/github.mjs — GitHub environments via `gh` (zero deps)
// ============================================================
// secrets travel by stdin — gh performs the libsodium sealing,
// values never appear on a command line. Auth rides the master
// GITHUB_ACCESS_TOKEN from secrets/master.env (or your own
// GH_TOKEN / `gh auth login`).

import { execFileSync } from 'node:child_process'
import { readFileSync, existsSync } from 'node:fs'

const masterEnv = existsSync('secrets/master.env') ? readFileSync('secrets/master.env', 'utf8') : ''
const masterToken = masterEnv.match(/^GITHUB_ACCESS_TOKEN=(.+)$/m)?.[1]?.trim() ?? ''

const gh = (args, input = '') =>
  execFileSync('gh', args, {
    input,
    env: { ...process.env, GH_TOKEN: process.env.GH_TOKEN || masterToken },
    stdio: ['pipe', 'ignore', 'inherit'],
  })

export const github = {
  // public values (APP_NAME, APP_URL, DB_HOST, …)
  variable: (name, value, env) => gh(['variable', 'set', name, '--env', env, '--body', value]),

  // sealed values (keys, passwords, tokens)
  secret: (name, value, env) => gh(['secret', 'set', name, '--env', env], value),
}
