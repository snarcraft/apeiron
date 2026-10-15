#!/usr/bin/env node

// ============================================================
// index.mjs — interactive project scaffolder
// ============================================================
// Renders a full monorepo from the answers to a few questions:
// services → identity → RBAC (groups/roles/features) → palette
// (one hex) → design soul → typeface → master credentials.
// Zero dependencies.
//
//   npx artiste                       interactive (published)
//   pnpm dlx artiste                  same, via pnpm
//   node .                            from a clone of this repo
//   node . --answers a.json           non-interactive (agents)
//   node . --list-souls               show design souls
//
// Node >= 20 required.

import { parseArgs } from 'node:util'
import { readFile, access } from 'node:fs/promises'
import { rmSync } from 'node:fs'
import process from 'node:process'
import { resolve, dirname, join, relative } from 'node:path'
import { fileURLToPath } from 'node:url'
import { execSync } from 'node:child_process'
import { randomBytes } from 'node:crypto'

import { c, sym, hr, title, note, done, fail, text, confirm, select, multiselect, secret, gradient, live, liveEnd } from './lib/prompts.mjs'
import { scale, themeBlock, ansiRamp, ansiSwatch, toHex, suggestSecondaryHue, hexToOklchHue } from './lib/oklch.mjs'
import { renderTree, writeGenerated } from './lib/render.mjs'
import * as rbac from './lib/rbac.mjs'
import * as builders from './lib/builders.mjs'

const here = dirname(fileURLToPath(import.meta.url))

// ------------------------------------------------------------
// souls
// ------------------------------------------------------------
const SOULS = {
  aurora: { label: 'Aurora', colorMode: 'system', font: 'Inter', description: 'floating light orbs, glass surfaces, gradient headlines — calm and premium' },
  blueprint: { label: 'Blueprint', colorMode: 'light', font: 'IBM Plex Sans', description: 'technical drawing: fine grids, mono labels, square corners, engineered' },
  editorial: { label: 'Editorial', colorMode: 'light', font: 'DM Serif Display', description: 'serif display, generous whitespace, hairline rules — the journal look' },
  neon: { label: 'Neon', colorMode: 'dark', font: 'Space Grotesk', description: 'dark-first, glow borders, electric gradients — nightlife for devtools' },
}

// ------------------------------------------------------------
// args
// ------------------------------------------------------------
const { values: args } = parseArgs({
  options: {
    answers: { type: 'string' },
    out: { type: 'string' },
    'list-souls': { type: 'boolean' },
    help: { type: 'boolean', short: 'h' },
  },
})

if (args.help) {
  console.log(`usage: node . [--answers answers.json] [--out ../target] [--list-souls]`)
  process.exit(0)
}

if (args['list-souls']) {
  const SOUL_BARS = {
    aurora: [[152, 140, 255], [0, 180, 191]],
    blueprint: [[122, 162, 255], [143, 211, 255]],
    editorial: [[201, 185, 138], [232, 228, 255]],
    neon: [[255, 78, 205], [0, 229, 255]],
  }
  for (const [key, soul] of Object.entries(SOULS)) {
    const [from, to] = SOUL_BARS[key]
    const bar = gradient('████████████████', from, to)
    console.log(`${c.bold(soul.label.padEnd(11))} ${bar} ${c.dim(key)} — ${soul.description}`)
  }
  process.exit(0)
}

// ------------------------------------------------------------
// banner — the factory's own gradient (violet 286 → teal 202)
// ------------------------------------------------------------
const VIOLET = [152, 140, 255]
const TEAL = [0, 180, 191]

function banner() {
  console.log('')
  console.log(`  ${gradient('ἄ π ε ι ρ ο ν', VIOLET, TEAL)}`)
  console.log(c.dim('  the platform factory — laravel · nuxt · flutter'))
  console.log(`  ${gradient('─'.repeat(46), VIOLET, TEAL)}`)
  console.log('')
}

// ------------------------------------------------------------
// interactive questions
// ------------------------------------------------------------
async function ask() {
  const a = {}

  title('Identity')
  a.name = await text({
    label: 'Project name',
    placeholder: 'Acme',
    default: 'Acme',
    validate: (v) => (v.length >= 2 ? true : Object.assign(() => {}, { message: 'At least 2 characters' })),
  })
  a.slug = a.name.trim().toLowerCase().split(/[^a-z0-9]+/)[0] || 'app'
  a.org = await text({ label: 'GitHub org/owner', default: a.slug })
  a.repo = await text({ label: 'Repository', default: 'platform' })
  a.domain = await text({ label: 'Primary domain', default: `${a.slug}.io` })
  a.appSubdomain = await text({ label: 'Webapp subdomain', default: 'app' })
  a.socketSubdomain = await text({ label: 'Websocket subdomain', default: 'socket' })

  title('Locale')
  a.locales = await multiselect({
    label: 'Locales',
    options: [
      { label: 'en', value: 'en', checked: true },
      { label: 'fr', value: 'fr', checked: true },
      { label: 'de', value: 'de' },
      { label: 'es', value: 'es' },
    ],
    required: true,
  })
  a.timezone = await text({ label: 'Timezone', default: 'Europe/Paris' })
  a.country = await text({ label: 'Country code', default: 'FR' })
  a.currency = await text({ label: 'Currency', default: 'EUR' })

  title('Access model — groups, roles, features')
  note('operator + admin are always included (platform staff, bypasses every gate).')
  a.groups = rbac.normalizeIdentifiers((await text({ label: 'Groups (comma-separated)', default: 'client' })).split(','))
  if (!a.groups.length) {
    a.groups = ['client']
  }

  a.roles = await multiselect({
    label: 'Roles (within a group)',
    options: Object.entries(rbac.ROLE_CATALOG)
      .filter(([k]) => k !== 'admin')
      .map(([k, v]) => ({ label: k, value: k, hint: v.hint })),
    required: true,
  })
  const extraRoles = await text({ label: 'Custom roles (comma-separated)', default: '' })
  a.roles = rbac.normalizeIdentifiers([...a.roles, ...extraRoles.split(',')])

  const featurePick = await multiselect({
    label: 'Features',
    options: Object.entries(rbac.FEATURE_CATALOG)
      .filter(([, v]) => !v.locked)
      .map(([k, v]) => ({ label: k, value: k, hint: v.hint })),
  })
  const extraFeatures = await text({ label: 'Custom features (comma-separated)', default: '' })
  // account, home and media are the platform spine — always present.
  a.features = rbac.normalizeIdentifiers(['account', 'home', 'media', ...featurePick, ...extraFeatures.split(',')]).sort()

  title('Services — what ships')
  note('database, storage and cache ride with the api — never separate choices.')
  const servicePick = await multiselect({
    label: 'Services',
    options: [
      { label: 'website', value: 'website', hint: 'marketing site — static, cdn', checked: true },
      { label: 'webapp', value: 'webapp', hint: 'the application — ssr', checked: true },
      { label: 'api', value: 'api', hint: 'laravel backend — octane', checked: true },
      { label: 'queue', value: 'queue', hint: 'background jobs — horizon', checked: true },
      { label: 'broadcasting', value: 'broadcasting', hint: 'websockets — reverb', checked: true },
      { label: 'cron', value: 'cron', hint: 'the scheduler', checked: true },
      { label: 'mobile', value: 'mobile', hint: 'the flutter app', checked: true },
    ],
    required: true,
  })
  a.services = {
    website: servicePick.includes('website'),
    webapp: servicePick.includes('webapp'),
    api: servicePick.includes('api'),
    queue: servicePick.includes('queue'),
    broadcasting: servicePick.includes('broadcasting'),
    cron: servicePick.includes('cron'),
    mobile: servicePick.includes('mobile'),
  }
  if (!a.services.api && (a.services.queue || a.services.broadcasting || a.services.cron)) {
    note('queue, broadcasting and cron run from the api image — api rides along.')
    a.services.api = true
  }

  title('Palette — one color in, a system out')
  note('give the primary as hex — the full 50–950 scale, contrast, dark and light')
  note('handling, and a compatible secondary are all derived. no swatch books.')
  const primaryHexAnswer = await text({
    label: 'Primary color (hex)',
    default: '#988cff',
    validate: (v) => (/^#?[0-9a-fA-F]{6}$/.test(v) ? true : Object.assign(() => {}, { message: 'six hex digits — 988cff or #988cff' })),
  })
  a.primaryHex = primaryHexAnswer.startsWith('#') ? primaryHexAnswer : `#${primaryHexAnswer}`
  a.primaryHue = hexToOklchHue(a.primaryHex)
  a.secondaryHue = suggestSecondaryHue(a.primaryHue)

  title('Website soul — same anatomy, different skin')
  const soul = await select({
    label: 'Design direction',
    options: Object.entries(SOULS).map(([k, v]) => ({ label: v.label, value: k, hint: v.description })),
  })
  a.soul = soul

  title('Type — the voice of the surface')
  const FONTS = ['Inter', 'Geist', 'IBM Plex Sans', 'Space Grotesk', 'DM Serif Display', 'Playfair Display']
  a.font = await select({
    label: 'Typeface',
    options: FONTS.map((f) => ({ label: f, value: f, hint: f.includes('Serif') || f.includes('Playfair') ? 'display serif' : 'grotesk' })),
    defaultIndex: Math.max(0, FONTS.indexOf(SOULS[a.soul].font)),
  })

  title('Master credentials — everything else is derived')
  note('Eleven keys with API powers. From these the platform provisions and')
  note('operates itself — AWS admin, Cloudflare DNS, a Discord bot, Stripe,')
  note('the stores — and a GitHub token to push every derived secret for you.')
  note('Enter to skip any; they also live in secrets/master.env afterwards.')
  a.secrets = {}
  const keys = [
    'AWS_ACCESS_KEY_ID', 'AWS_SECRET_ACCESS_KEY',
    'CF_DNS_API_TOKEN',
    'DISCORD_BOT_TOKEN',
    'GITHUB_ACCESS_TOKEN',
    'STRIPE_KEY', 'STRIPE_SECRET',
    'APP_STORE_ISSUER_ID', 'APP_STORE_KEY_ID', 'APP_STORE_PRIVATE_KEY',
    'ANDROID_SERVICE_ACCOUNT',
  ]
  for (const key of keys) {
    a.secrets[key] = await secret({ label: key })
  }

  a.gitInit = true

  // Mobile follows the services pick — and store credentials
  // force it on: App Store or Play keys mean the app ships.
  const storeKeys = ['APP_STORE_ISSUER_ID', 'APP_STORE_KEY_ID', 'APP_STORE_PRIVATE_KEY', 'ANDROID_SERVICE_ACCOUNT']
  if (storeKeys.some((key) => a.secrets[key])) {
    if (!a.services.mobile) {
      done('store credentials detected — the mobile app ships')
    }
    a.services.mobile = true
  }
  a.mobile = a.services.mobile
  if (a.mobile) {
    a.mobileOrg = await text({ label: 'Mobile reverse-domain org', default: `com.${a.org || a.slug}` })
  }

  // Provisioning is not an onboarding concern: the pipeline
  // provisions AWS + Cloudflare + the host on the first push to
  // main (idempotent on every later one). See deploy.yml.
  return a
}

// ------------------------------------------------------------
// answers file → same shape, with defaults
// ------------------------------------------------------------
async function loadAnswers(file) {
  const raw = JSON.parse(await readFile(file, 'utf8'))
  const defaults = {
    name: 'Acme',
    org: null,
    repo: 'platform',
    domain: null,
    appSubdomain: 'app',
    socketSubdomain: 'socket',
    locales: ['en', 'fr'],
    timezone: 'Europe/Paris',
    country: 'FR',
    currency: 'EUR',
    groups: ['client'],
    roles: ['manager', 'member'],
    features: ['account', 'home', 'team', 'user', 'contract', 'agent'],
    primaryHue: 286,
    secondaryHue: null,
    soul: 'aurora',
    secrets: {},
    services: null,
    gitInit: true,
    mobile: true,
    mobileOrg: null,
    out: null,
  }
  const a = { ...defaults, ...raw }
  a.slug = a.slug || a.name.trim().toLowerCase().split(/[^a-z0-9]+/)[0] || 'app'
  a.org = a.org || a.slug
  a.domain = a.domain || `${a.slug}.io`
  a.mobileOrg = a.mobileOrg || `com.${a.org}`
  if (a.primaryHex) {
    a.primaryHue = hexToOklchHue(a.primaryHex)
  }
  a.font = a.font || SOULS[a.soul].font
  const allServices = { website: true, webapp: true, api: true, queue: true, broadcasting: true, cron: true, mobile: true }
  a.services = { ...allServices, ...(a.services || {}) }
  if (!a.services.api && (a.services.queue || a.services.broadcasting || a.services.cron)) {
    a.services.api = true
  }
  a.mobile = a.services.mobile
  if (a.secondaryHue === null) a.secondaryHue = suggestSecondaryHue(a.primaryHue)
  a.groups = rbac.normalizeIdentifiers(['operator', ...a.groups])
  a.roles = rbac.normalizeIdentifiers(['admin', ...a.roles])
  // The platform spine — media and realtime surfaces are always
  // present, never choices; agent ships with the default answers.
  a.features = rbac.normalizeIdentifiers(['account', 'home', 'media', ...a.features]).sort()
  return a
}

// ------------------------------------------------------------
// derive everything from answers
// ------------------------------------------------------------
function derive(a) {
  const primary = scale(a.primaryHue)
  const secondary = scale(a.secondaryHue)
  const services = a.services
  const groups = a.groups
  const roles = a.roles
  const features = a.features
  const matrix = rbac.buildMatrix({ groups, roles, features })

  const tokens = {
    APP_NAME: a.slug,
    APP_TITLE: a.name.trim(),
    APP_SLUG: a.slug,
    APP_ORG: a.org,
    APP_REPO: a.repo,
    GITHUB_REPOSITORY: `${a.org}/${a.repo}`,
    STACK_NAME: a.slug,
    DOMAIN: a.domain,
    APP_DOMAIN: `${a.appSubdomain}.${a.domain}`,
    SOCKET_DOMAIN: `${a.socketSubdomain}.${a.domain}`,
    API_URL: `https://api.${a.domain}`,
    FRONTEND_URL: `https://${a.appSubdomain}.${a.domain}`,
    WEB_URL: `https://${a.domain}`,
    CONTACT_EMAIL: `contact@${a.domain}`,
    YEAR: String(new Date().getFullYear()),
    COMPATIBILITY_DATE: new Date().toISOString().slice(0, 10),
    APP_LETTER: (a.name.trim()[0] ?? 'A').toUpperCase(),
    LOCALES: a.locales.join(','),
    DEFAULT_LOCALE: a.locales[0],
    WEB_LOCALES: a.locales.map((l) => `{ code: '${l}' }`).join(', '),
    TIMEZONE: a.timezone,
    COUNTRY: a.country,
    CURRENCY: a.currency,
    APP_GROUPS: groups.join('`, `'),
    APP_ROLES: roles.join('`, `'),
    APP_FEATURES: features.join('`, `'),
    COLOR_MODE_PREFERENCE: SOULS[a.soul].colorMode,
    SOUL_FONT: a.font || SOULS[a.soul].font,
    MOBILE: a.mobile,
    MOBILE_ORG: a.mobileOrg,
    WEBSITE: services.website,
    WEBAPP: services.webapp,
    API: services.api,
    QUEUE: services.queue,
    BROADCASTING: services.broadcasting,
    CRON: services.cron,
  }

  for (const step of [50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950]) {
    tokens[`PRIMARY_${step}`] = primary[step].oklch
    tokens[`SECONDARY_${step}`] = secondary[step].oklch
  }
  tokens.PRIMARY_500_HEX = toHex(primary[500].rgb)
  tokens.SECONDARY_500_HEX = toHex(secondary[500].rgb)
  tokens.PRIMARY_600_HEX = toHex(primary[600].rgb)
  tokens.SECONDARY_600_HEX = toHex(secondary[600].rgb)

  return { primary, secondary, services, groups, roles, features, matrix, tokens }
}

// ------------------------------------------------------------
// main
// ------------------------------------------------------------
async function main() {
  banner()

  let a
  if (args.answers) {
    a = await loadAnswers(resolve(args.answers))
    console.log(`${c.green(sym.check)} answers loaded from ${c.bold(args.answers)} — ${a.name}`)
  } else {
    a = await ask()
  }

  // Generated credentials — never asked, never in git: passwords,
  // the app key and the reverb pair are minted here and ride
  // secrets/*.env (git-ignored) up to GitHub via bootstrap.
  a.secrets.DB_PASSWORD ||= randomBytes(18).toString('base64url')
  a.secrets.REDIS_PASSWORD ||= randomBytes(18).toString('base64url')
  a.secrets.APP_KEY ||= 'base64:' + randomBytes(32).toString('base64')
  a.secrets.REVERB_APP_KEY ||= randomBytes(16).toString('hex')
  a.secrets.REVERB_APP_SECRET ||= randomBytes(16).toString('hex')

  const { primary, secondary, services, groups, roles, features, matrix, tokens } = derive(a)

  // palette preview — the wow moment
  title('Generated palette')
  console.log(`  primary   ${ansiRamp(primary)}  ${c.dim(`hue ${Math.round(a.primaryHue)}`)}`)
  console.log(`  secondary ${ansiRamp(secondary)}  ${c.dim(`hue ${Math.round(a.secondaryHue)}`)}`)
  note(`500s → ${toHex(primary[500].rgb)} / ${toHex(secondary[500].rgb)} — full 50–950 scales land in main.css`)
  note(`soul → ${c.bold(SOULS[a.soul].label)} (${SOULS[a.soul].description})`)

  const target = resolve(args.out || a.out || join(process.cwd(), a.slug))

  title(`Scaffolding → ${c.bold(target)}`)
  const skip = (rel) => {
    if (!services.website && (rel.startsWith('apps/web') || rel === join('.github', 'workflows', 'web.yml'))) return true
    if (!services.webapp && (rel.startsWith('apps/frontend') || rel === join('.github', 'workflows', 'frontend.yml'))) return true
    if (!services.api && rel.startsWith('apps/backend')) return true
    if (!services.mobile && (rel.startsWith('apps/mobile') || rel.startsWith('secrets/mobile') || rel === join('.github', 'workflows', 'mobile.yml.tpl'))) return true
    return false
  }
  let rendered = 0
  const tick = (rel) => {
    rendered += 1
    live(`${c.cyan(sym.dot)} rendering ${c.bold(String(rendered))} files ${c.dim(`— ${rel}`)}`)
  }
  const created = await renderTree({
    source: join(here, 'boilerplate'),
    target,
    tokens,
    skip,
    log: tick,
  })

  // The agent knowledge base ships into every project.
  created.push(...(await renderTree({
    source: join(here, 'ai'),
    target: join(target, 'ai'),
    tokens,
    log: (rel) => tick(`ai/${rel}`),
  })))
  liveEnd()
  done(`${created.length} boilerplate files rendered`)

  // ----- generated files (beyond placeholder rendering) -----
  let generated = 0
  const g = async (rel, content) => {
    generated += 1
    await writeGenerated(join(target, rel), content)
  }

  const ctx = {
    ...a,
    groups,
    roles,
    features,
    matrix,
    domain: a.domain,
    appDomain: `${a.appSubdomain}.${a.domain}`,
    socketDomain: `${a.socketSubdomain}.${a.domain}`,
    title: a.name.trim(),
  }

  // The scaffolded brand rides on the platform Setting — every
  // surface (webapp injection, mobile boot) reads it at runtime.
  const brand = {
    font_family: a.font || SOULS[a.soul].font,
    primary: toHex(primary[500].rgb),
    secondary: toHex(secondary[500].rgb),
    tertiary: toHex(secondary[600].rgb),
    brightness: SOULS[a.soul].colorMode === 'dark' ? 'dark' : 'light',
  }

  await g('apps/backend/composer.json', builders.composerJson(ctx))
  await g('apps/backend/.env.example', builders.backendEnvExample(a))
  await g('secrets/local.env', builders.secretsEnv({ kind: 'local', ...ctx, values: a.secrets, locales: a.locales }))
  // Staging and production values are minted per environment,
  // pushed to GitHub by bootstrap, then removed from disk —
  // environments live in CI; the local pc keeps dev only.
  const envValues = () => ({
    APP_KEY: 'base64:' + randomBytes(32).toString('base64'),
    DB_PASSWORD: randomBytes(18).toString('base64url'),
    REDIS_PASSWORD: randomBytes(18).toString('base64url'),
    REVERB_APP_KEY: randomBytes(16).toString('hex'),
    REVERB_APP_SECRET: randomBytes(16).toString('hex'),
  })
  await g('secrets/staging.env', builders.secretsEnv({ kind: 'staging', ...ctx, values: envValues(), locales: a.locales }))
  await g('secrets/production.env', builders.secretsEnv({ kind: 'production', ...ctx, values: envValues(), locales: a.locales }))
  await g('secrets/master.env', builders.masterEnv(a))
  await g('docs/SECRETS.md', builders.secretsDoc({ org: a.org, repo: a.repo, ...ctx }))
  await g('README.md', builders.projectReadme({ org: a.org, repo: a.repo, ...ctx }))
  await g('assets/icon.svg', builders.monogramSvg({ letter: a.slug[0], primary500: primary[500], secondary500: secondary[500] }))
  await g(
    'assets/manifest.webmanifest',
    builders.manifestWebmanifest({
      title: a.name.trim(),
      primaryHex: toHex(primary[500].rgb),
      secondaryHex: toHex(secondary[500].rgb),
    }),
  )

  // RBAC layer
  await g('apps/backend/app/Enums/Role.php', rbac.phpRole(roles))
  await g('apps/backend/app/Enums/Group.php', rbac.phpGroup({ groups, matrix, features }))
  await g('apps/backend/app/Enums/Feature.php', rbac.phpFeature(features))
  await g('apps/backend/app/Enums/Action.php', rbac.phpAction())
  await g('apps/backend/database/seeders/DatabaseSeeder.php', rbac.phpSeeder({ ...ctx, theme: brand }))
  await g('apps/backend/tests/Unit/RbacTest.php', rbac.phpRbacTest(ctx))
  for (const locale of a.locales) {
    await g(`apps/backend/storage/app/lang/${locale}.json`, rbac.langFile({ ...ctx, locale }))
    if (services.website) {
      await g(`apps/web/i18n/locales/${locale}.json`, builders.webMessages(locale, a.name.trim()))
    }
  }
  if (services.webapp) {
    await g('apps/frontend/app/app.config.ts', rbac.tsAppConfig({ matrix, features }))
    await g('apps/frontend/app/types/index.d.ts', rbac.tsTypes({ groups, roles, features }))
  }
  done('RBAC enums, matrix, policies, types, seeders & tests generated')

  // souls — each surface wears its skin only when it ships
  const soulSrc = join(here, 'styling', 'souls', a.soul)
  const { copyFile, mkdir } = await import('node:fs/promises')
  const soulFiles = []
  if (services.website) {
    await mkdir(join(target, 'apps/web/app/assets/css'), { recursive: true })
    await mkdir(join(target, 'apps/web/app/components/landing'), { recursive: true })
    soulFiles.push(
      [join(soulSrc, 'web.css'), join(target, 'apps/web/app/assets/css/main.css')],
      [join(soulSrc, 'Hero.vue'), join(target, 'apps/web/app/components/landing/Hero.vue')],
    )
  }
  if (services.webapp) {
    await mkdir(join(target, 'apps/frontend/app/assets/css'), { recursive: true })
    soulFiles.push([join(soulSrc, 'app.css'), join(target, 'apps/frontend/app/assets/css/main.css')])
  }
  const { renderString } = await import('./lib/render.mjs')
  for (const [from, to] of soulFiles) {
    const content = renderString(await readFile(from, 'utf8'), tokens)
    await writeGenerated(to, content)
  }
  void copyFile
  done(`soul "${a.soul}" applied — fonts, tokens, keyframes${services.website ? ', hero' : ''}`)

  if (a.mobile) {
    // Link the mobile bootstrap config exactly like the backend
    // .env → secrets/local.env. (Symlink skipped if it exists.)
    try {
      const { symlink } = await import('node:fs/promises')
      await mkdir(join(target, 'apps/mobile/assets'), { recursive: true })
      await symlink('../../../secrets/mobile.json', join(target, 'apps/mobile/assets/app.json'), 'file')
      done('mobile config linked: secrets/mobile.json → apps/mobile/assets/app.json')
    } catch {
      note('mobile config link skipped (already present)')
    }
  }

  // pwa icons copy — only for surfaces that ship
  for (const [app, on] of [['web', services.website], ['frontend', services.webapp]]) {
    if (on) {
      await mkdir(join(target, `apps/${app}/public`), { recursive: true })
    }
  }
  note('run `pnpm generate:assets` after install to mint PWA icons from assets/icon.svg')

  if (a.gitInit) {
    try {
      execSync(`git init -q && git add -A && git commit -qm "feat: born from apeiron"`, { cwd: target, stdio: 'ignore' })
      done('git repository initialized')
    } catch {
      fail('git init failed — run it manually')
    }
  }

  // github — with the master token the factory finishes the loop
  // itself: repo created, code pushed, environments wired. Every
  // failure is captured and answered with one line — no cascades.
  if (a.secrets.GITHUB_ACCESS_TOKEN) {
    title('GitHub — repo + environments')
    const ghEnv = { ...process.env, GH_TOKEN: a.secrets.GITHUB_ACCESS_TOKEN }
    const run = (cmd) => {
      try {
        execSync(cmd, { cwd: target, stdio: 'pipe', env: ghEnv })
        return null
      } catch (error) {
        return `${error.stderr || error.stdout || ''}`
      }
    }

    let repoOk = false
    const created = run(`gh repo create ${a.org}/${a.repo} --private --source . --push`)

    if (created && /401|Bad credentials/.test(created)) {
      fail('GITHUB_ACCESS_TOKEN rejected — fix it in secrets/master.env, then run: node scripts/bootstrap.mjs')
    } else if (created) {
      run(`git remote add origin https://github.com/${a.org}/${a.repo}.git`)
      const pushed = run('git push -u origin HEAD')
      if (pushed && /401|Bad credentials/.test(pushed)) {
        fail('GITHUB_ACCESS_TOKEN rejected — fix it in secrets/master.env, then run: node scripts/bootstrap.mjs')
      } else if (pushed) {
        fail(`could not create or push ${a.org}/${a.repo} — check the org and repo names, then: node scripts/bootstrap.mjs`)
      } else {
        done(`bound to existing repo — ${a.org}/${a.repo}`)
        repoOk = true
      }
    } else {
      done(`github repo created and pushed — ${a.org}/${a.repo}`)
      repoOk = true
    }

    if (repoOk) {
      try {
        execSync('node scripts/bootstrap.mjs', { cwd: target, stdio: 'inherit', env: ghEnv })
        done('environments wired — staging, production and mobile carry every secret')
        // the files did their job: master credentials and per-env
        // values live in GitHub now — the local pc keeps dev only.
        for (const file of ['master.env', 'staging.env', 'production.env']) {
          rmSync(join(target, 'secrets', file), { force: true })
        }
        done('secrets/ trimmed — local.env and mobile.json remain, dev only')
      } catch {
        fail('bootstrap incomplete — master.env and the env files stay on disk for a re-run (idempotent)')
      }
    }
  } else {
    note('no GITHUB_ACCESS_TOKEN — after creating the repo, fill secrets/master.env,')
    note('add a remote, push, then run: node scripts/bootstrap.mjs (idempotent)')
  }

  // ----- the birth card -----
  const W = 46
  const visible = (s) => s.replace(/\x1b\[[0-9;]*m/g, '')
  const row = (s) => `  │  ${s}${' '.repeat(Math.max(0, W - visible(s).length))}│`
  title('Born')
  console.log(`  ${c.dim(`╭${'─'.repeat(W + 2)}╮`)}`)
  console.log(row(c.bold(a.name.trim())))
  console.log(row(c.dim(`${a.domain} · ${SOULS[a.soul].label} · hues ${Math.round(a.primaryHue)}/${Math.round(a.secondaryHue)}`)))
  console.log(row(''))
  console.log(row(`${ansiRamp(primary)}  ${c.dim('primary')}`))
  console.log(row(`${ansiRamp(secondary)}  ${c.dim('secondary')}`))
  console.log(row(''))
  console.log(row(`${created.length + generated} files · ${groups.length} groups · ${roles.length} roles · ${features.length} features`))
  console.log(`  ${c.dim(`╰${'─'.repeat(W + 2)}╯`)}`)

  title('Next steps')
  console.log(`  ${c.dim('1.')} cd ${join('.', relative(process.cwd(), target) || '.')} `)
  console.log(`  ${c.dim('2.')} pnpm install`)
  console.log(`  ${c.dim('3.')} cd apps/backend && composer install && cp .env.example .env`)
  console.log(`  ${c.dim('4.')} php artisan key:generate && php artisan migrate --seed`)
  console.log(`  ${c.dim('5.')} cd ../.. && make dev ${c.dim('# → http://localhost:3000')}`)
  console.log('')
  console.log(`  ${c.dim('provisioning manual → docs/SECRETS.md')}`)
  console.log(`  ${c.dim('agent entrypoint        → AGENTS.md')}`)
  console.log('')
  console.log(hr())
  console.log(`  ${ansiSwatch(primary[500].rgb, '█')} ${c.bold(a.name.trim())} is ready — ${gradient('from the boundless, worlds.', VIOLET, TEAL)}`)
  console.log(hr())
  console.log('')

  // Raw-mode prompts leave stdin flowing; the exit is ours to call.
  process.exit(0)
}

main().catch((error) => {
  fail(error.message)
  process.exit(1)
})
