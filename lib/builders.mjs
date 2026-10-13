// ============================================================
// builders.mjs — generated (non-boilerplate) project files
// ============================================================
// Some files depend on the answer set too much for placeholders:
// composer.json, env files, the Swarm stack, the secrets manual
// with ready-to-run gh commands, the brand monogram and the
// project README. They are assembled here instead.

import { toHex } from './oklch.mjs'

const q = (s) => JSON.stringify(s, null, 4)

// ------------------------------------------------------------
// composer.json
// ------------------------------------------------------------
export function composerJson({ slug, title }) {
  // The full platform ships always — no optional integrations.
  const require = {
    'laravel/framework': '^13.0',
    'laravel/octane': '^2.19',
    'laravel/sanctum': '^4.0',
    'laravel/pennant': '*',
    'laravel/horizon': '^5.49',
    'laravel/tinker': '^3.0',
    'laravel/ai': '^0.11',
    'laravel/reverb': '^1.11',
    'pusher/pusher-php-server': '^7.3',
    'aws/aws-sdk-php': '^3.394',
    'league/flysystem-aws-s3-v3': '^3.35',
  }

  const dev = {
    'barryvdh/laravel-ide-helper': '^3.7',
    'fakerphp/faker': '^1.23',
    'friendsofphp/php-cs-fixer': '^3.95',
    'laravel/boost': '^2.2',
    'laravel/pail': '^1.2',
    'laravel/pint': '^1.27',
    'mockery/mockery': '^1.6',
    'nunomaduro/collision': '^8.6',
    'pestphp/pest': '^5.1',
    'pestphp/pest-plugin-laravel': '^5.0',
  }

  return q({
    name: `${slug}/backend`,
    type: 'project',
    description: `${title} API — Laravel · Octane · Reverb · S3 · AI`,
    license: 'proprietary',
    require,
    'require-dev': dev,
    autoload: {
      'psr-4': { 'App\\': 'app/', 'Database\\Factories\\': 'database/factories/', 'Database\\Seeders\\': 'database/seeders/' },
    },
    'autoload-dev': { 'psr-4': { 'Tests\\': 'tests/' } },
    scripts: {
      setup: [
        '@php artisan migrate:fresh --seed --force --ansi',
      ].filter(Boolean),
      format: [
        '@php artisan package:discover --ansi',
        'vendor/bin/php-cs-fixer fix',
      ],
      generate: [
        '@php artisan ide-helper:generate --nowrite',
        '@php artisan ide-helper:meta --nowrite',
        '@php artisan ide-helper:models --nowrite',
      ],
      test: [
        '@php artisan config:clear --ansi',
        '@php artisan test',
      ],
      'post-autoload-dump': [
        'Illuminate\\Foundation\\ComposerScripts::postAutoloadDump',
        '@php artisan package:discover --ansi',
      ],
      'post-root-package-install': [
        '@php -r "file_exists(\'.env\') || copy(\'.env.example\', \'.env\');"',
      ],
      'post-create-project-cmd': [
        '@php artisan key:generate --ansi',
        '@php artisan migrate --graceful --ansi',
      ],
    },
    'extra': {
      'laravel': { 'dont-discover': [] },
      'php-cs-fixer': { 'config': '.php-cs-fixer.php' },
    },
    config: {
      'optimize-autoloader': true,
      'preferred-install': 'dist',
      'sort-packages': true,
      'allow-plugins': { 'pestphp/pest-plugin': true, 'php-http/discovery': true },
    },
    'minimum-stability': 'stable',
    'prefer-stable': true,
  }) + '\n'
}

// ------------------------------------------------------------
// backend .env.example
// ------------------------------------------------------------
export function backendEnvExample({ slug, domain, locales }) {
  const L = [
    `APP_NAME=${slug}`,
    'APP_ENV=local',
    'APP_KEY=',
    'APP_DEBUG=true',
    `APP_TIMEZONE=${tokensTimezone()}`,
    '',
    'DB_CONNECTION=sqlite',
    '# DB_CONNECTION=pgsql',
    '# DB_HOST=127.0.0.1',
    '# DB_PORT=5432',
    '# DB_DATABASE=postgres',
    '# DB_USERNAME=postgres',
    '# DB_PASSWORD=secret',
    '',
    'SESSION_DRIVER=database',
    'SESSION_LIFETIME=120',
    'SESSION_ENCRYPT=false',
    'SESSION_PATH=/',
    'SESSION_DOMAIN=.localhost',
    '',
    'BROADCAST_CONNECTION=reverb',
    'FILESYSTEM_DISK=s3',
    'QUEUE_CONNECTION=database',
    'CACHE_STORE=database',
    '',
    'REDIS_CLIENT=phpredis',
    'REDIS_HOST=127.0.0.1',
    'REDIS_PASSWORD=null',
    'REDIS_PORT=6379',
    '',
    'MAIL_MAILER=log',
    'MAIL_FROM_ADDRESS="hello@example.com"',
    `MAIL_FROM_NAME="\${APP_NAME}"`,
    '',
    `FRONTEND_URL=http://localhost:3000`,
    `WEB_URL=http://localhost:3001`,
    'SANCTUM_STATEFUL_DOMAINS=localhost:3000',
    '',
    `APP_LOCALE=${locales[0]}`,
    `APP_FALLBACK_LOCALE=${locales[0]}`,
  ]

  L.push(
    '',
    'AWS_ACCESS_KEY_ID=minio',
    'AWS_SECRET_ACCESS_KEY=password',
    'AWS_DEFAULT_REGION=local',
    'AWS_BUCKET=media',
    'AWS_USE_PATH_STYLE_ENDPOINT=true',
    'AWS_ENDPOINT_URL=http://localhost:9000',
  )
  L.push(
    '',
    'REVERB_APP_ID=1',
    'REVERB_APP_KEY=local',
    'REVERB_APP_SECRET=local',
    'REVERB_HOST=localhost',
    'REVERB_PORT=8080',
    'REVERB_SCHEME=http',
    '',
    'STRIPE_KEY=',
    'STRIPE_SECRET=',
    'STRIPE_WEBHOOK_SECRET=',
    '',
    'DISCORD_CONTACT_WEBHOOK_URL=',
    'DISCORD_USER_ID=',
  )

  L.push('', 'API_RATE_LIMIT=60')

  return L.join('\n') + '\n'
}

function tokensTimezone() {
  return 'UTC'
}

// ------------------------------------------------------------
// secrets/local.env + secrets/staging.env
// ------------------------------------------------------------
export function secretsEnv({ kind, slug, domain, appDomain, socketDomain, values = {}, locales }) {
  const isLocal = kind === 'local'
  const url = isLocal ? 'http://localhost:8000' : `https://api.${domain}`
  const v = (key, fallback = '') => values[key] || fallback

  const L = [
    `APP_NAME=${slug}`,
    `APP_ENV=${isLocal ? 'local' : kind}`,
    isLocal ? 'APP_KEY=' : `APP_KEY=${v('APP_KEY', 'base64:REPLACE_ME=')}`,
    `APP_URL=${url}`,
    `APP_DEBUG=${isLocal}`,
    `APP_LOCALE=${locales[0]}`,
    '',
    'LOG_CHANNEL=stack',
    '',
    `DB_CONNECTION=${isLocal ? 'pgsql' : 'pgsql'}`,
    `DB_HOST=${v('DB_HOST', '127.0.0.1')}`,
    'DB_PORT=5432',
    `DB_DATABASE=${slug}`,
    'DB_USERNAME=postgres',
    `DB_PASSWORD=${v('DB_PASSWORD', isLocal ? 'password' : 'REPLACE_ME')}`,
    '',
    'SESSION_DRIVER=redis',
    `SESSION_DOMAIN=.${isLocal ? 'localhost' : domain}`,
    '',
    'BROADCAST_CONNECTION=reverb',
    'FILESYSTEM_DISK=s3',
    'QUEUE_CONNECTION=redis',
    'CACHE_STORE=redis',
    `CACHE_PREFIX=${slug}`,
    '',
    'REDIS_CLIENT=phpredis',
    `REDIS_HOST=${v('REDIS_HOST', '127.0.0.1')}`,
    `REDIS_PASSWORD=${v('REDIS_PASSWORD', isLocal ? 'password' : 'REPLACE_ME')}`,
    'REDIS_PORT=6379',
    '',
    'MAIL_MAILER=log',
    `MAIL_FROM_ADDRESS="no-reply@${domain}"`,
  ]

  L.push(
    '',
    `REVERB_APP_ID=${v('REVERB_APP_ID', slug)}`,
    `REVERB_APP_KEY=${v('REVERB_APP_KEY', isLocal ? 'reverb-local-key' : 'REPLACE_ME')}`,
    `REVERB_APP_SECRET=${v('REVERB_APP_SECRET', isLocal ? 'reverb-local-secret' : 'REPLACE_ME')}`,
    `REVERB_HOST=${isLocal ? 'localhost' : socketDomain}`,
    `REVERB_PORT=${isLocal ? 8080 : 443}`,
    `REVERB_SCHEME=${isLocal ? 'http' : 'https'}`,
  )

  L.push(
    '',
    isLocal
      ? 'AWS_ACCESS_KEY_ID=minio\nAWS_SECRET_ACCESS_KEY=password\nAWS_DEFAULT_REGION=local\nAWS_BUCKET=media\nAWS_ENDPOINT_URL=http://localhost:9000\nAWS_USE_PATH_STYLE_ENDPOINT=true'
      : `AWS_ACCESS_KEY_ID=${v('AWS_ACCESS_KEY_ID', 'REPLACE_ME')}\nAWS_SECRET_ACCESS_KEY=${v('AWS_SECRET_ACCESS_KEY', 'REPLACE_ME')}\nAWS_DEFAULT_REGION=${v('AWS_DEFAULT_REGION', 'eu-west-3')}\nAWS_BUCKET=${slug}-media-${kind}`,
  )

  L.push(
    '',
    `STRIPE_KEY=${v('STRIPE_KEY', 'REPLACE_ME')}`,
    `STRIPE_SECRET=${v('STRIPE_SECRET', 'REPLACE_ME')}`,
    `STRIPE_WEBHOOK_SECRET=${v('STRIPE_WEBHOOK_SECRET', 'REPLACE_ME')}`,
  )

  L.push(
    '',
    `DISCORD_CONTACT_WEBHOOK_URL=${v('DISCORD_CONTACT_WEBHOOK_URL', 'REPLACE_ME')}`,
    `DISCORD_USER_ID=${v('DISCORD_USER_ID', 'REPLACE_ME')}`,
  )

  if (isLocal) {
    // No local proxy: vite allowedHosts serves *.slug.localhost on
    // :3000 directly; API and website answer on their ports.
    L.push(
      '',
      `FRONTEND_URL=http://app.${slug}.localhost:3000`,
      `WEB_URL=http://localhost:3001`,
      `SANCTUM_STATEFUL_DOMAINS=localhost:3000,app.${slug}.localhost`,
    )
  } else {
    L.push(
      '',
      `APP_URL=https://api.${domain}`,
      `FRONTEND_URL=https://${appDomain}`,
      `WEB_URL=https://${domain}`,
      `SANCTUM_STATEFUL_DOMAINS=${appDomain}`,
    )
  }

  return L.join('\n').replace(/\n\n+/g, '\n\n') + '\n'
}

// ------------------------------------------------------------
// docs/SECRETS.md — the provisioning manual (gh-ready commands)
// ------------------------------------------------------------
export function secretsDoc({ org, repo, slug, domain, appDomain, socketDomain }) {
  const vars = [
    ['APP_NAME', slug],
    ['APP_ENV', 'staging → production'],
    ['APP_VERSION', '1.0.0 — bump every deploy (immutable config versions)'],
    ['APP_URL', `https://api.${domain}`],
    ['APP_DEBUG', 'false'],
    ['APP_LOCALE', 'en'],
    ['APP_FALLBACK_LOCALE', 'en'],
    ['APP_TIMEZONE', 'UTC'],
    ['APP_MAINTENANCE_DRIVER', 'file'],
    ['LOG_CHANNEL', 'stack'],
    ['DB_CONNECTION', 'pgsql'],
    ['DB_HOST', `${slug}-postgres`],
    ['DB_PORT', '5432'],
    ['DB_DATABASE', slug],
    ['DB_USERNAME', 'postgres'],
    ['SESSION_DRIVER', 'redis'],
    ['SESSION_DOMAIN', `.${domain}`],
    ['BROADCAST_CONNECTION', 'reverb'],
    ['FILESYSTEM_DISK', 's3'],
    ['QUEUE_CONNECTION', 'redis'],
    ['CACHE_STORE', 'redis'],
    ['CACHE_PREFIX', slug],
    ['REDIS_CLIENT', 'phpredis'],
    ['REDIS_HOST', `${slug}-redis`],
    ['REDIS_PORT', '6379'],
    ['CDN_URL', `https://cdn.${domain}`],
    ['AWS_DEFAULT_REGION', 'eu-west-3'],
    ['AWS_ASSET_BUCKET', `${slug}-assets`],
    ['AWS_BUCKET', `${slug}-media`],
            ['REVERB_APP_ID', slug],
          ['REVERB_HOST', socketDomain],
          ['REVERB_PORT', '443'],
          ['REVERB_SCHEME', 'https'],
    ['FRONTEND_URL', `https://${appDomain}`],
    ['WEB_URL', `https://${domain}`],
    ['SANCTUM_STATEFUL_DOMAINS', appDomain],
  ]

  const secrets = [
    ['APP_KEY', '`make generate-key` locally'],
    ['DB_PASSWORD', '`openssl rand -base64 24`'],
    ['REDIS_PASSWORD', '`openssl rand -base64 24`'],
            ['REVERB_APP_KEY', '`openssl rand -hex 16`'],
          ['REVERB_APP_SECRET', '`openssl rand -hex 16`'],
    ['APP_AWS_ACCESS_KEY_ID', 'IAM user · see config/media-policy.json'],
    ['APP_AWS_SECRET_ACCESS_KEY', 'IAM user · see config/media-policy.json'],
            ['STRIPE_KEY', 'Stripe dashboard → API keys'],
          ['STRIPE_SECRET', 'Stripe dashboard → API keys'],
          ['STRIPE_WEBHOOK_SECRET', 'Stripe → Webhooks → signing secret'],
            ['DISCORD_CONTACT_WEBHOOK_URL', 'Discord channel → Integrations → Webhook'],
          ['DISCORD_USER_ID', 'your Discord user id (for deploy mentions)'],
          ['DISCORD_SERVER_WEBHOOK_URL', 'deploy notifications webhook'],
    ['CF_DNS_API_TOKEN', 'Cloudflare → My Profile → API Tokens → Zone.DNS edit'],
    ['AWS_ACCESS_KEY_ID', 'CI user · see config/github-policy.json'],
    ['AWS_SECRET_ACCESS_KEY', 'CI user · see config/github-policy.json'],
    ['AWS_SECURITY_GROUP_ID', 'sg-… of the EC2 runner allow-list'],
    ['SERVER_HOST', 'EC2 host address'],
    ['SERVER_USER', 'ubuntu'],
    ['SERVER_KEY', 'PEM private key of the deploy keypair'],
    ['SERVER_PORT', '22'],
    ['GH_TOKEN', 'personal access token with read: packages'],
  ]

  const mobileSecrets = [
    ['APP_CONFIG', 'base64 of secrets/mobile/app.json — the mobile bootstrap config'],
    ['ANDROID_KEYSTORE', 'base64 of upload-keystore.jks'],
    ['ANDROID_STORE_PASSWORD', 'keystore store password'],
    ['ANDROID_KEY_PASSWORD', 'keystore key password'],
    ['ANDROID_KEY_ALIAS', 'keystore key alias'],
    ['ANDROID_SERVICE_ACCOUNT', 'base64 Play Console service-account JSON'],
    ['IOS_CERTIFICATE', 'base64 p12 — Apple Distribution certificate'],
    ['IOS_CERTIFICATE_PASSWORD', 'p12 password'],
    ['IOS_MOBILEPROVISION', 'base64 App Store provisioning profile (.mobileprovision)'],
    ['APP_STORE_ISSUER_ID', 'App Store Connect API issuer id'],
    ['APP_STORE_KEY_ID', 'App Store Connect API key id'],
    ['APP_STORE_PRIVATE_KEY', 'AuthKey_*.p8 contents'],
  ]

  const gh = `# Provisioning — ${slug}

Every value the pipeline needs lives in GitHub **variables**
(public) and **secrets** (sensitive), per environment
(\`development\`, \`staging\`, \`production\` — plus \`mobile\`,
which scopes the store-signing secrets).

Run the blocks below from the repo root — they call the
\`gh\` CLI directly, so auth once with \`gh auth login\`.

## Variables

\`\`\`bash
${vars.map(([k, v]) => `gh variable set ${k} --body "${v}" --env staging`).join('\n')}
\`\`\`

## Secrets

\`\`\`bash
${secrets.map(([k, v]) => `gh secret set ${k} --env staging   # ${v}`).join('\n')}
\`\`\`

### Mobile signing (environment \`mobile\`)

The mobile workflow declares \`environment: mobile\` — its secrets
live there, not per-env:

\`\`\`bash
${mobileSecrets.map(([k, v]) => `gh secret set ${k} --env mobile   # ${v}`).join('\n')}
\`\`\`

Repeat the staging block with \`--env production\` (and different
values) when ready.

## AWS resources

1. **Buckets** — \`${slug}-assets\` (CI build artifacts, immutable cache) and \`${slug}-media\` (user uploads).
2. **CI user** — create IAM user \`${slug}-github\`, attach \`config/github-policy.json\`.
3. **Media user** — create IAM user, attach \`config/media-policy.json\`.
4. **CORS** — apply \`config/asset-cors.json\` on the assets bucket.
5. **EC2** — one instance, security group allowing 22 (CI adds its
   runner IP per deploy), 80 and 443. Note the security group id in
   \`AWS_SECURITY_GROUP_ID\`.

## First deploy

\`\`\`bash
git tag v1.0.0 && git push origin v1.0.0   # publishes the images
# then, GitHub → Actions → "Infrastructure up" (once)
# then, GitHub → Actions → "Swarm up"
\`\`\`
`

  void org
  void repo
  return gh
}

// ------------------------------------------------------------
// Brand monogram (assets/icon.svg)
// ------------------------------------------------------------
export function monogramSvg({ letter, primary500, secondary500 }) {
  const from = toHex(primary500.rgb)
  const to = toHex(secondary500.rgb)
  const id = `${letter.toLowerCase()}-mark`

  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <defs>
    <linearGradient id="${id}" x1="0" y1="0" x2="64" y2="64" gradientUnits="userSpaceOnUse">
      <stop offset="0" stop-color="${from}"/>
      <stop offset="1" stop-color="${to}"/>
    </linearGradient>
  </defs>
  <rect width="64" height="64" rx="14" fill="url(#${id})"/>
  <text x="32" y="32" dy=".36em" text-anchor="middle"
        font-family="system-ui, -apple-system, sans-serif" font-size="34"
        font-weight="700" fill="#fff">${letter.toUpperCase()}</text>
</svg>
`
}

// ------------------------------------------------------------
// Website landing copy (i18n messages per locale)
// ------------------------------------------------------------
// One dictionary drives every locale file in apps/web — the
// landing copy lives here, never in components.
const WEB_COPY_EN = {
  nav: { features: 'Features', how: 'How it works', pricing: 'Pricing', faq: 'FAQ', contact: 'Get in touch' },
  hero: {
    tag: 'platform · realtime · role-aware',
    title: 'Work that flows.',
    highlight: 'Errors that don\u2019t.',
    subtitle: ' brings your teams, customers and operations onto one calm surface — roles, groups and features wired from day one.',
    cta: 'Start today',
    secondary: 'See how it works',
    proof: 'operations kept on track · no credit card required',
    quote: '“We stopped managing the process and started reading it.”',
    badges: { security: 'SOC2-ready', realtime: 'realtime', selfhosted: 'self-hosted' }
  },
  sections: {
    features: { eyebrow: 'features', title: 'Everything the platform does', description: 'A complete operating base — so you ship the product, not the plumbing.' },
    how: { eyebrow: 'how it works', title: 'Three moves, then it runs itself' },
    pricing: { eyebrow: 'pricing', title: 'Simple, honest pricing', description: 'Start free. Upgrade when the platform earns it.' },
    faq: { eyebrow: 'faq', title: 'Questions, answered' },
    contact: { eyebrow: 'contact', title: 'Start the conversation', description: 'Tell us what you are building — we answer within a day.' }
  },
  features: {
    teams: { title: 'Teams & roles', body: 'Groups and roles arrive pre-wired. Permissions are code, so onboarding is an invite — not a spreadsheet.' },
    fast: { title: 'Fast by default', body: 'Octane keeps the API warm; static assets ship from the CDN edge. Interactions feel instant.' },
    audit: { title: 'Audited actions', body: 'Every mutation leaves a line in the record: who, what, when. Compliance without the anxiety.' },
    media: { title: 'Media that scales', body: 'S3-backed attachments with lifecycle cleanup. Local dev runs MinIO — same API, zero cloud.' },
    realtime: { title: 'Realtime', body: 'Websockets out of the box: presence, notifications and live updates on every screen.' },
    ai: { title: 'AI-ready', body: 'An agent surface with permission-aware tools, ready when you are.' }
  },
  steps: {
    one: { title: 'Invite your team', body: 'People join a group with a role. That single fact decides everything they can touch.' },
    two: { title: 'Describe the work', body: 'Features are single words — task, invoice, asset — with actions wired end to end.' },
    three: { title: 'Watch it run', body: 'The record builds itself: activity logs, realtime updates, audit trails.' },
    chips: { rbac: 'enum-driven RBAC', zero: 'zero-database permissions', realtime: 'realtime by default', media: 'S3 media', dark: 'dark mode' }
  },
  pricing: {
    starter: { name: 'Starter', price: '€29', period: '/month', description: 'For small teams finding their rhythm.', cta: 'Choose Starter' },
    professional: { name: 'Professional', price: '€99', period: '/month', description: 'For teams that run real operations.', cta: 'Choose Professional', badge: 'Most popular' },
    enterprise: { name: 'Enterprise', price: 'Custom', period: '', description: 'For platforms with their own gravity.', cta: 'Choose Enterprise' },
    lists: {
      starter: ['Up to 5 members', 'Core features', 'Community support'],
      professional: ['Up to 25 members', 'All features', 'Priority support', 'Audit exports'],
      enterprise: ['Unlimited members', 'SSO & SCIM', 'Dedicated support', 'Custom SLAs']
    }
  },
  faq: {
    setup: { q: 'How long does setup take?', a: 'Minutes. Clone, install, migrate, run. The demo personas let you log in as every role immediately.' },
    selfhost: { q: 'Can I self-host?', a: 'Yes — the whole platform ships as Docker images with a Swarm stack. One command rolls it out.' },
    permissions: { q: 'How are permissions managed?', a: 'In code, not the database. Groups and roles are enums; every ability is a feature:action pair enforced by the gate.' },
    api: { q: 'Is there an API?', a: 'The API is the product. Sanctum tokens for mobile, session cookies for the webapp, the same routes for both.' },
    export: { q: 'What about data export?', a: 'Everything is yours. JSON exports, S3 media, standard Postgres backups — no lock-in.' }
  },
  contact: {
    name: 'Name', email: 'Email', message: 'Message',
    namePlaceholder: 'Ada Lovelace', emailPlaceholder: 'ada@example.com', messagePlaceholder: 'Tell us what you are building…',
    submit: 'Send message',
    successTitle: 'Message received', successBody: 'We will get back to you within a day.',
    errorTitle: 'Something went wrong', errorBody: 'Please try again.'
  },
  footer: { rights: 'built with calm' },
  seo: { title: ' — the platform that runs itself', description: ' — teams, customers and operations on one calm surface.' }
}

const WEB_COPY_FR = {
  nav: { features: 'Fonctionnalités', how: 'Comment ça marche', pricing: 'Tarifs', faq: 'FAQ', contact: 'Nous contacter' },
  hero: {
    tag: 'plateforme · temps réel · rôles',
    title: 'Un travail qui flu.',
    highlight: 'Des erreurs qui n\u2019existent pas.',
    subtitle: ' réunit vos équipes, clients et opérations sur une surface calme — rôles, groupes et fonctionnalités câblés dès le premier jour.',
    cta: 'Commencer',
    secondary: 'Voir comment ça marche',
    proof: 'opérations suivies · sans carte bancaire',
    quote: '« Nous avons cessé de gérer le processus pour commencer à le lire. »',
    badges: { security: 'SOC2-ready', realtime: 'temps réel', selfhosted: 'auto-hébergé' }
  },
  sections: {
    features: { eyebrow: 'fonctionnalités', title: 'Tout ce que la plateforme fait', description: 'Une base opérationnelle complète — vous livrez le produit, pas la plomberie.' },
    how: { eyebrow: 'comment ça marche', title: 'Trois gestes, puis ça tourne seul' },
    pricing: { eyebrow: 'tarifs', title: 'Des prix simples et honnêtes', description: 'Commencez gratuitement. Évoluez quand la plateforme le mérite.' },
    faq: { eyebrow: 'faq', title: 'Questions, réponses' },
    contact: { eyebrow: 'contact', title: 'Démarrez la conversation', description: 'Dites-nous ce que vous construisez — réponse sous un jour.' }
  },
  features: {
    teams: { title: 'Équipes & rôles', body: 'Groupes et rôles pré-câblés. Les permissions sont du code : l\u2019onboarding est une invitation — pas un tableur.' },
    fast: { title: 'Rapide par défaut', body: 'Octane garde l\u2019API au chaud ; les assets statiques sortent du CDN. Tout semble instantané.' },
    audit: { title: 'Actions auditées', body: 'Chaque mutation laisse une trace : qui, quoi, quand. La conformité sans angoisse.' },
    media: { title: 'Médias qui passent à l\u2019échelle', body: 'Pièces jointes S3 avec nettoyage automatique. En local, MinIO — même API, zéro cloud.' },
    realtime: { title: 'Temps réel', body: 'Websockets intégrés : présence, notifications et mises à jour sur chaque écran.' },
    ai: { title: 'Prêt pour l\u2019IA', body: 'Une surface d\u2019agent avec des outils respectueux des permissions, quand vous êtes prêt.' }
  },
  steps: {
    one: { title: 'Invitez votre équipe', body: 'Chacun rejoint un groupe avec un rôle. Ce seul fait décide de tout ce qu\u2019il peut toucher.' },
    two: { title: 'Décrivez le travail', body: 'Les fonctionnalités sont des mots simples — task, invoice, asset — avec des actions câblées de bout en bout.' },
    three: { title: 'Regardez tourner', body: 'Le registre se construit tout seul : journaux d\u2019activité, temps réel, pistes d\u2019audit.' },
    chips: { rbac: 'RBAC par enums', zero: 'permissions sans base de données', realtime: 'temps réel natif', media: 'médias S3', dark: 'mode sombre' }
  },
  pricing: {
    starter: { name: 'Starter', price: '29 €', period: '/mois', description: 'Pour les petites équipes qui trouvent leur rythme.', cta: 'Choisir Starter' },
    professional: { name: 'Professional', price: '99 €', period: '/mois', description: 'Pour les équipes qui pilotent de vraies opérations.', cta: 'Choisir Professional', badge: 'Le plus choisi' },
    enterprise: { name: 'Enterprise', price: 'Sur mesure', period: '', description: 'Pour les plateformes avec leur propre gravité.', cta: 'Choisir Enterprise' },
    lists: {
      starter: ['Jusqu\u2019à 5 membres', 'Fonctionnalités de base', 'Support communautaire'],
      professional: ['Jusqu\u2019à 25 membres', 'Toutes les fonctionnalités', 'Support prioritaire', 'Exports d\u2019audit'],
      enterprise: ['Membres illimités', 'SSO & SCIM', 'Support dédié', 'SLA sur mesure']
    }
  },
  faq: {
    setup: { q: 'Combien de temps pour démarrer ?', a: 'Des minutes. Cloner, installer, migrer, lancer. Les personas de démo permettent de se connecter dans chaque rôle.' },
    selfhost: { q: 'Peut-on self-héberger ?', a: 'Oui — toute la plateforme arrive en images Docker avec une stack Swarm. Une commande déploie tout.' },
    permissions: { q: 'Comment sont gérées les permissions ?', a: 'Dans le code, pas en base. Groupes et rôles sont des enums ; chaque capacité est une paire feature:action appliquée par la gate.' },
    api: { q: 'Y a-t-il une API ?', a: 'L\u2019API est le produit. Jetons Sanctum pour le mobile, cookies de session pour la webapp, les mêmes routes partout.' },
    export: { q: 'Et l\u2019export des données ?', a: 'Tout est à vous. Exports JSON, médias S3, sauvegardes Postgres standard — aucun lock-in.' }
  },
  contact: {
    name: 'Nom', email: 'E-mail', message: 'Message',
    namePlaceholder: 'Ada Lovelace', emailPlaceholder: 'ada@example.com', messagePlaceholder: 'Dites-nous ce que vous construisez…',
    submit: 'Envoyer le message',
    successTitle: 'Message reçu', successBody: 'Nous revenons vers vous sous un jour.',
    errorTitle: 'Une erreur est survenue', errorBody: 'Merci de réessayer.'
  },
  footer: { rights: 'construit avec calme' },
  seo: { title: ' — la plateforme qui tourne toute seule', description: ' — équipes, clients et opérations sur une surface calme.' }
}

const WEB_COPY = { en: WEB_COPY_EN, fr: WEB_COPY_FR }

export function webMessages(locale, title) {
  const copy = WEB_COPY[locale] ?? WEB_COPY_EN
  const messages = structuredClone(copy)
  // The product name prefixes hero/seo strings.
  messages.hero.subtitle = title + messages.hero.subtitle
  messages.seo.title = title + messages.seo.title
  messages.seo.description = title + messages.seo.description
  return JSON.stringify(messages, null, 2) + '\n'
}

// ------------------------------------------------------------
// PWA manifest (assets/manifest.webmanifest)
// ------------------------------------------------------------
export function manifestWebmanifest({ title, primaryHex, secondaryHex }) {
  return JSON.stringify(
    {
      name: title,
      short_name: title,
      description: `${title} — the platform that runs itself`,
      start_url: '/',
      display: 'standalone',
      background_color: '#09090b',
      theme_color: primaryHex,
      icons: [
        { src: 'pwa-64x64.png', sizes: '64x64', type: 'image/png' },
        { src: 'pwa-192x192.png', sizes: '192x192', type: 'image/png' },
        { src: 'pwa-512x512.png', sizes: '512x512', type: 'image/png' },
        { src: 'maskable-icon-512x512.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' },
      ],
      shortcuts: [
        {
          name: 'Dashboard',
          url: '/',
          icons: [{ src: 'pwa-64x64.png', sizes: '64x64' }],
        },
      ],
    },
    null,
    2,
  ) + `\n<!-- brand: ${primaryHex} → ${secondaryHex} -->\n`
}

// ------------------------------------------------------------
// Project README
// ------------------------------------------------------------
export function projectReadme({ title, slug, org, repo, domain, appDomain, groups, roles, features, soul, mobile }) {
  const mobileRow = mobile ? `| \`apps/mobile\` | Flutter app (freezed · injectable · Cubits · auto_route) |\n` : '';

  return `# ${title}

${slug} monorepo — pnpm workspace · Nuxt web + webapp · Laravel API${mobile ? ' · Flutter mobile' : ''} · Docker Swarm.

## Map

| Path | What |
|---|---|
| \`apps/web\` | Marketing website (static, Nuxt UI) — \`${domain}\` |
| \`apps/frontend\` | SaaS webapp (SSR, Sanctum auth) — \`${appDomain}\` |
| \`apps/backend\` | Laravel API (Octane/Swoole, Pest) |
${mobileRow}| \`server/\` | Swarm stack, Traefik, deploy scripts |
| \`.github/\` | Publish + deploy workflows |
| \`ai/\` | Agent conventions & playbooks — start at \`AGENTS.md\` |
| \`styling notes\` | design system lives in \`apps/*/app/assets/css/main.css\` |

## Quickstart

\`\`\`bash
pnpm install
cd apps/backend && composer install && cp .env.example .env && php artisan key:generate && php artisan migrate --seed && cd ../..
make dev            # webapp + octane + reverb + horizon + pail
\`\`\`

- webapp: http://localhost:3000
- website: \`pnpm --filter @${slug}/web dev\` → http://localhost:3001
- API: http://localhost:8000

Demo personas (password \`password\`): \`admin@${domain}\`${
    groups.filter((g) => g !== 'operator')
      .map((g) => `, \`manager.${g}@${domain}\``)
      .join('')
  }.

## Model

- Groups: ${groups.join(', ')}
- Roles: ${roles.join(', ')}
- Features: ${features.join(', ')}
- Permissions are code (enums), never database rows — see \`ai/playbooks/rbac.md\`.

## Integrations

Always on — the platform ships complete:

- **Stripe** — subscriptions & checkout
- **Reverb** — realtime broadcasting
- **S3** — media & attachments (MinIO locally)
- **Discord** — contact form relay + deploy pings
- **Laravel AI** — agent tools behind the \`agent\` feature
- **Stores** — Google Play + TestFlight, published unattended on every tag

Provisioning manual: \`docs/SECRETS.md\` (GitHub vars/secrets + AWS setup).

## Deploy

1. Push a tag → publish workflows build images to \`ghcr.io/${org}/${repo}/*\`.
2. Actions → *Infrastructure up* (once per host).
3. Actions → *Swarm up* (every release).
4. Mobile tags land on Google Play (internal track) + TestFlight — automatically.

Design soul: **${soul}** — palette & typography generated at scaffold time.
`
}
