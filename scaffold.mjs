#!/usr/bin/env node

// ============================================================
// scaffold.mjs — interactive project scaffolder
// ============================================================
// Renders a full monorepo from the answers to a few questions:
// identity → domains → RBAC (groups/roles/features) → palette →
// design soul → integrations → secrets. Zero dependencies.
//
//   node scaffold.mjs                        interactive
//   node scaffold.mjs --answers a.json       non-interactive (agents)
//   node scaffold.mjs --out ../acme          target directory
//   node scaffold.mjs --list-souls           show design souls
//
// Node >= 20 required.

import { parseArgs } from 'node:util'
import { readFile, access } from 'node:fs/promises'
import process from 'node:process'
import { resolve, dirname, join, relative } from 'node:path'
import { fileURLToPath } from 'node:url'
import { execSync } from 'node:child_process'

import { c, sym, hr, title, note, done, fail, text, confirm, select, multiselect, secret } from './lib/prompts.mjs'
import { NAMED_HUES, scale, themeBlock, ansiRamp, ansiSwatch, toHex, suggestSecondaryHue, randomHuePair } from './lib/oklch.mjs'
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
  console.log(`usage: node scaffold.mjs [--answers answers.json] [--out ../target] [--list-souls]`)
  process.exit(0)
}

if (args['list-souls']) {
  for (const [key, soul] of Object.entries(SOULS)) {
    console.log(`${c.bold(soul.label.padEnd(11))} ${c.dim(key)} — ${soul.description}`)
  }
  process.exit(0)
}

// ------------------------------------------------------------
// banner
// ------------------------------------------------------------
function banner() {
  console.log('')
  console.log(c.bold(c.cyan('  ╭──────────────────────────────────────────────╮')))
  console.log(c.bold(c.cyan('  │  ') + '◆  m o n o r e p e   s c a f f o l d e r     ' + c.bold(c.cyan('│'))))
  console.log(c.bold(c.cyan('  ╰──────────────────────────────────────────────╯')))
  console.log(c.dim('  Nuxt 4 · Laravel 13 · Tailwind v4 · Swarm · GH Actions'))
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
  a.groups = await multiselect({
    label: 'Groups (tenant kinds)',
    options: Object.entries(rbac.GROUP_CATALOG)
      .filter(([k]) => k !== 'operator')
      .map(([k, v]) => ({ label: k, value: k, hint: v.hint, checked: k === 'client' })),
    required: true,
  })
  a.roles = await multiselect({
    label: 'Roles (within a group)',
    options: Object.entries(rbac.ROLE_CATALOG)
      .filter(([k]) => k !== 'admin')
      .map(([k, v]) => ({ label: k, value: k, hint: v.hint, checked: k === 'manager' || k === 'member' })),
    required: true,
  })
  const featurePick = await multiselect({
    label: 'Features (single lowercase words)',
    options: Object.entries(rbac.FEATURE_CATALOG)
      .filter(([, v]) => !v.locked)
      .map(([k, v]) => ({ label: k, value: k, hint: v.hint, checked: ['team', 'user', 'invoice'].includes(k) })),
  })
  const extraFeatures = await text({ label: 'Custom features (comma-separated)', default: '' })
  // account, home and media are the platform spine — always present.
  a.features = rbac.normalizeIdentifiers(['account', 'home', 'media', ...featurePick, ...extraFeatures.split(',')]).sort()

  title('Palette — generated, perceptual, yours')
  const namedEntries = Object.entries(NAMED_HUES)
  const primaryChoice = await select({
    label: 'Primary color',
    options: [
      ...namedEntries.map(([k, v]) => ({ label: k, value: k, hint: v.hint })),
      { label: 'surprise me', value: '__random__', hint: 'a curated random pair' },
      { label: 'custom hue', value: '__custom__', hint: '0–360 oklch hue number' },
    ],
    defaultIndex: 0,
  })

  let primaryHue
  let secondaryHue
  if (primaryChoice === '__random__') {
    ;[primaryHue, secondaryHue] = randomHuePair()
  } else if (primaryChoice === '__custom__') {
    primaryHue = Number(await text({ label: 'Primary hue (0–360)', default: '286' }))
  } else {
    primaryHue = NAMED_HUES[primaryChoice].hue
  }

  const secondaryChoice = await select({
    label: 'Secondary color',
    options: [
      { label: 'suggested', value: '__suggested__', hint: `hue ${suggestSecondaryHue(primaryHue)} — complementary split` },
      ...namedEntries.map(([k, v]) => ({ label: k, value: k, hint: v.hint })),
      { label: 'custom hue', value: '__custom__', hint: '0–360 oklch hue number' },
    ],
  })
  if (secondaryChoice === '__suggested__') secondaryHue = suggestSecondaryHue(primaryHue)
  else if (secondaryChoice === '__custom__') secondaryHue = Number(await text({ label: 'Secondary hue (0–360)', default: String(suggestSecondaryHue(primaryHue)) }))
  else secondaryHue = NAMED_HUES[secondaryChoice].hue

  a.primaryHue = primaryHue
  a.secondaryHue = secondaryHue

  title('Website soul — same anatomy, different skin')
  const soul = await select({
    label: 'Design direction',
    options: Object.entries(SOULS).map(([k, v]) => ({ label: v.label, value: k, hint: v.description })),
  })
  a.soul = soul

  title('Integrations')
  note('Stripe · Reverb · S3 media · Discord · Laravel AI — the full platform ships always, no toggles.')
  a.secrets = {}
  const wantsSecrets = await confirm({ label: 'Enter secret values now? (else placeholders)', default: false })
  if (wantsSecrets) {
    const keys = [
      'STRIPE_KEY', 'STRIPE_SECRET', 'STRIPE_WEBHOOK_SECRET',
      'AWS_ACCESS_KEY_ID', 'AWS_SECRET_ACCESS_KEY',
      'DISCORD_CONTACT_WEBHOOK_URL', 'DISCORD_USER_ID',
      'CF_DNS_API_TOKEN', 'DB_PASSWORD', 'REDIS_PASSWORD',
    ]
    for (const key of keys) {
      a.secrets[key] = await secret({ label: key })
    }
  }

  a.gitInit = await confirm({ label: 'git init the project?', default: true })

  a.mobile = await confirm({
    label: 'Include the Flutter mobile app? (scaffolded kernel, needs flutter to generate platforms)',
    default: true,
  })
  if (a.mobile) {
    a.mobileOrg = await text({ label: 'Mobile reverse-domain org', default: `com.${a.org || a.slug}` })
  }

  a.provision = await confirm({
    label: 'Provision AWS + DNS now? (buckets, IAM users, EC2 per env, Cloudflare records — needs aws CLI)',
    default: false,
  })
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
    features: ['account', 'home', 'team', 'user', 'invoice'],
    primaryHue: 286,
    secondaryHue: null,
    soul: 'aurora',
    secrets: {},
    gitInit: false,
    provision: false,
    mobile: true,
    mobileOrg: null,
    out: null,
  }
  const a = { ...defaults, ...raw }
  a.slug = a.slug || a.name.trim().toLowerCase().split(/[^a-z0-9]+/)[0] || 'app'
  a.org = a.org || a.slug
  a.domain = a.domain || `${a.slug}.io`
  a.mobileOrg = a.mobileOrg || `com.${a.org}`
  if (a.secondaryHue === null) a.secondaryHue = suggestSecondaryHue(a.primaryHue)
  a.groups = rbac.normalizeIdentifiers(['operator', ...a.groups])
  a.roles = rbac.normalizeIdentifiers(['admin', ...a.roles])
  // The platform spine — media, realtime and the agent surface are
  // always present, never choices.
  a.features = rbac.normalizeIdentifiers(['account', 'home', 'media', 'agent', ...a.features]).sort()
  return a
}

// ------------------------------------------------------------
// derive everything from answers
// ------------------------------------------------------------
function derive(a) {
  const primary = scale(a.primaryHue)
  const secondary = scale(a.secondaryHue)
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
    SOUL_FONT: SOULS[a.soul].font,
    MOBILE: a.mobile,
    MOBILE_ORG: a.mobileOrg,
  }

  for (const step of [50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950]) {
    tokens[`PRIMARY_${step}`] = primary[step].oklch
    tokens[`SECONDARY_${step}`] = secondary[step].oklch
  }
  tokens.PRIMARY_500_HEX = toHex(primary[500].rgb)
  tokens.SECONDARY_500_HEX = toHex(secondary[500].rgb)
  tokens.PRIMARY_600_HEX = toHex(primary[600].rgb)
  tokens.SECONDARY_600_HEX = toHex(secondary[600].rgb)

  return { primary, secondary, groups, roles, features, matrix, tokens }
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

  const { primary, secondary, groups, roles, features, matrix, tokens } = derive(a)

  // palette preview — the wow moment
  title('Generated palette')
  console.log(`  primary   ${ansiRamp(primary)}  ${c.dim(`hue ${Math.round(a.primaryHue)}`)}`)
  console.log(`  secondary ${ansiRamp(secondary)}  ${c.dim(`hue ${Math.round(a.secondaryHue)}`)}`)
  note(`500s → ${toHex(primary[500].rgb)} / ${toHex(secondary[500].rgb)} — full 50–950 scales land in main.css`)
  note(`soul → ${c.bold(SOULS[a.soul].label)} (${SOULS[a.soul].description})`)

  const target = resolve(args.out || a.out || join(process.cwd(), a.slug))

  title(`Scaffolding → ${c.bold(target)}`)
  const skipMobile = (rel) => !a.mobile && (rel.startsWith('apps/mobile') || rel.startsWith('secrets/mobile') || rel === join('.github', 'workflows', 'mobile.yml.tpl'))
  const created = await renderTree({
    source: join(here, 'boilerplate'),
    target,
    tokens,
    skip: skipMobile,
  })

  // The agent knowledge base ships into every project.
  created.push(...(await renderTree({
    source: join(here, 'ai'),
    target: join(target, 'ai'),
    tokens,
  })))
  done(`${created.length} boilerplate files rendered`)

  // ----- generated files (beyond placeholder rendering) -----
  const g = async (rel, content) => {
    await writeGenerated(join(target, rel), content)
  }

  const ctx = { ...a, groups, roles, features, matrix, domain: a.domain, title: a.name.trim() }

  // The scaffolded brand rides on the platform Setting — every
  // surface (webapp injection, mobile boot) reads it at runtime.
  const brand = {
    font_family: SOULS[a.soul].font,
    primary: toHex(primary[500].rgb),
    secondary: toHex(secondary[500].rgb),
    tertiary: toHex(secondary[600].rgb),
    brightness: SOULS[a.soul].colorMode === 'dark' ? 'dark' : 'light',
  }

  await g('apps/backend/composer.json', builders.composerJson(a))
  await g('apps/backend/.env.example', builders.backendEnvExample(a))
  await g('secrets/local.env', builders.secretsEnv({ kind: 'local', ...ctx, values: a.secrets, locales: a.locales }))
  await g('secrets/staging.env', builders.secretsEnv({ kind: 'staging', ...ctx, values: {}, locales: a.locales }))
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
    await g(`apps/web/i18n/locales/${locale}.json`, builders.webMessages(locale, a.name.trim()))
  }
  await g('apps/frontend/app/app.config.ts', rbac.tsAppConfig({ matrix, features }))
  await g('apps/frontend/app/types/index.d.ts', rbac.tsTypes({ groups, roles, features }))
  done('RBAC enums, matrix, policies, types, seeders & tests generated')

  // souls
  const soulSrc = join(here, 'styling', 'souls', a.soul)
  const { copyFile, mkdir } = await import('node:fs/promises')
  await mkdir(join(target, 'apps/web/app/assets/css'), { recursive: true })
  await mkdir(join(target, 'apps/frontend/app/assets/css'), { recursive: true })
  await mkdir(join(target, 'apps/web/app/components/landing'), { recursive: true })
  const { renderString } = await import('./lib/render.mjs')
  for (const [from, to] of [
    [join(soulSrc, 'web.css'), join(target, 'apps/web/app/assets/css/main.css')],
    [join(soulSrc, 'app.css'), join(target, 'apps/frontend/app/assets/css/main.css')],
    [join(soulSrc, 'Hero.vue'), join(target, 'apps/web/app/components/landing/Hero.vue')],
  ]) {
    const content = renderString(await readFile(from, 'utf8'), tokens)
    await writeGenerated(to, content)
  }
  void copyFile
  done(`soul "${a.soul}" applied — fonts, tokens, keyframes, hero`)

  if (a.mobile) {
    // Link the mobile bootstrap config exactly like the backend
    // .env → secrets/local.env. (Symlink skipped if it exists.)
    try {
      const { symlink } = await import('node:fs/promises')
      await mkdir(join(target, 'apps/mobile/assets'), { recursive: true })
      await symlink('../../../secrets/mobile/app.json', join(target, 'apps/mobile/assets/app.json'), 'file')
      done('mobile config linked: secrets/mobile/app.json → apps/mobile/assets/app.json')
    } catch {
      note('mobile config link skipped (already present)')
    }
  }

  // pwa icons copy
  const pwa = ['favicon.ico', 'pwa-64x64.png', 'pwa-192x192.png', 'pwa-512x512.png', 'maskable-icon-512x512.png']
  for (const app of ['web', 'frontend']) {
    await mkdir(join(target, `apps/${app}/public`), { recursive: true })
  }
  note('run `pnpm generate:assets` after install to mint PWA icons from assets/icon.svg')

  if (a.gitInit && !args.answers) {
    try {
      execSync(`git init -q && git add -A`, { cwd: target, stdio: 'ignore' })
      done('git repository initialized')
    } catch {
      fail('git init failed — run it manually')
    }
  }

  // ----- optional one-shot cloud provisioning -----
  if (a.provision) {
    title('Provisioning AWS + DNS')
    const env = {
      ...process.env,
      CF_DNS_API_TOKEN: a.secrets.CF_DNS_API_TOKEN || process.env.CF_DNS_API_TOKEN || '',
    }
    try {
      execSync('node scripts/provision.mjs --apply', { cwd: target, stdio: 'inherit', env })
      done('cloud resources provisioned (idempotent — re-runnable)')
    } catch {
      fail('provisioning incomplete — run `node scripts/provision.mjs --apply` inside the project (idempotent)')
    }
  }

  // summary
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
  console.log(`  ${ansiSwatch(primary[500].rgb, '█')} ${c.bold(a.name.trim())} is ready. Make it real.`)
  console.log(hr())
  console.log('')
}

main().catch((error) => {
  fail(error.message)
  process.exit(1)
})
