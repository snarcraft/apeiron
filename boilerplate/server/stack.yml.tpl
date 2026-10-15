# ============================================================
# stack.yml — application services on Docker Swarm
# ============================================================
# Configs & secrets are external, immutable objects versioned
# `${APP_NAME}.${APP_ENV}.${APP_VERSION}.<NAME>` — created by
# swarm.sh from VAR_*/SEC_* environment variables. Rotation =
# bump APP_VERSION and re-run swarm.sh + deploy.sh.
#
# Every non-secret config mounts at /run/configs/<NAME>; secrets
# mount at /run/secrets/<NAME>. The entrypoint exports both into
# the environment before handing off to the runner.

configs:

  DISCORD_CONTACT_WEBHOOK_URL:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.DISCORD_CONTACT_WEBHOOK_URL"

  CF_DNS_API_TOKEN:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.CF_DNS_API_TOKEN"
  AWS_ACCESS_KEY_ID:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.AWS_ACCESS_KEY_ID"
  AWS_SECRET_ACCESS_KEY:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.AWS_SECRET_ACCESS_KEY"

  STRIPE_KEY:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.STRIPE_KEY"
  STRIPE_SECRET:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.STRIPE_SECRET"
  STRIPE_WEBHOOK_SECRET:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.STRIPE_WEBHOOK_SECRET"

  APP_KEY:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.APP_KEY"
  DB_PASSWORD:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.DB_PASSWORD"
  REDIS_PASSWORD:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.REDIS_PASSWORD"

  REVERB_APP_KEY:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.REVERB_APP_KEY"
  REVERB_APP_SECRET:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.REVERB_APP_SECRET"

  APP_NAME:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.APP_NAME"
  APP_ENV:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.APP_ENV"
  APP_URL:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.APP_URL"
  APP_DEBUG:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.APP_DEBUG"
  APP_LOCALE:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.APP_LOCALE"
  APP_FALLBACK_LOCALE:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.APP_FALLBACK_LOCALE"
  APP_TIMEZONE:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.APP_TIMEZONE"
  LOG_CHANNEL:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.LOG_CHANNEL"
  DB_CONNECTION:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.DB_CONNECTION"
  DB_HOST:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.DB_HOST"
  DB_PORT:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.DB_PORT"
  DB_DATABASE:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.DB_DATABASE"
  DB_USERNAME:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.DB_USERNAME"
  SESSION_DRIVER:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.SESSION_DRIVER"
  SESSION_DOMAIN:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.SESSION_DOMAIN"
  BROADCAST_CONNECTION:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.BROADCAST_CONNECTION"
  FILESYSTEM_DISK:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.FILESYSTEM_DISK"
  QUEUE_CONNECTION:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.QUEUE_CONNECTION"
  CACHE_STORE:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.CACHE_STORE"
  CACHE_PREFIX:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.CACHE_PREFIX"
  REDIS_CLIENT:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.REDIS_CLIENT"
  REDIS_HOST:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.REDIS_HOST"
  REDIS_PORT:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.REDIS_PORT"

  REVERB_APP_ID:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.REVERB_APP_ID"
  REVERB_HOST:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.REVERB_HOST"
  REVERB_PORT:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.REVERB_PORT"
  REVERB_SCHEME:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.REVERB_SCHEME"

  CDN_URL:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.CDN_URL"
  AWS_DEFAULT_REGION:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.AWS_DEFAULT_REGION"
  AWS_BUCKET:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.AWS_BUCKET"
  FRONTEND_URL:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.FRONTEND_URL"
  WEB_URL:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.WEB_URL"
  SANCTUM_STATEFUL_DOMAINS:
    external: true
    name: "${APP_NAME}.${APP_ENV}.${APP_VERSION}.SANCTUM_STATEFUL_DOMAINS"

x-backend-configs: &backend-configs
  - source: APP_NAME
    target: /run/configs/APP_NAME
  - source: APP_ENV
    target: /run/configs/APP_ENV
  - source: APP_URL
    target: /run/configs/APP_URL
  - source: APP_DEBUG
    target: /run/configs/APP_DEBUG
  - source: APP_LOCALE
    target: /run/configs/APP_LOCALE
  - source: APP_FALLBACK_LOCALE
    target: /run/configs/APP_FALLBACK_LOCALE
  - source: APP_TIMEZONE
    target: /run/configs/APP_TIMEZONE
  - source: LOG_CHANNEL
    target: /run/configs/LOG_CHANNEL
  - source: DB_CONNECTION
    target: /run/configs/DB_CONNECTION
  - source: DB_HOST
    target: /run/configs/DB_HOST
  - source: DB_PORT
    target: /run/configs/DB_PORT
  - source: DB_DATABASE
    target: /run/configs/DB_DATABASE
  - source: DB_USERNAME
    target: /run/configs/DB_USERNAME
  - source: SESSION_DRIVER
    target: /run/configs/SESSION_DRIVER
  - source: SESSION_DOMAIN
    target: /run/configs/SESSION_DOMAIN
  - source: BROADCAST_CONNECTION
    target: /run/configs/BROADCAST_CONNECTION
  - source: FILESYSTEM_DISK
    target: /run/configs/FILESYSTEM_DISK
  - source: QUEUE_CONNECTION
    target: /run/configs/QUEUE_CONNECTION
  - source: CACHE_STORE
    target: /run/configs/CACHE_STORE
  - source: CACHE_PREFIX
    target: /run/configs/CACHE_PREFIX
  - source: REDIS_CLIENT
    target: /run/configs/REDIS_CLIENT
  - source: REDIS_HOST
    target: /run/configs/REDIS_HOST
  - source: REDIS_PORT
    target: /run/configs/REDIS_PORT

  - source: REVERB_APP_ID
    target: /run/configs/REVERB_APP_ID
  - source: REVERB_HOST
    target: /run/configs/REVERB_HOST
  - source: REVERB_PORT
    target: /run/configs/REVERB_PORT
  - source: REVERB_SCHEME
    target: /run/configs/REVERB_SCHEME

  - source: CDN_URL
    target: /run/configs/CDN_URL
  - source: AWS_DEFAULT_REGION
    target: /run/configs/AWS_DEFAULT_REGION
  - source: AWS_BUCKET
    target: /run/configs/AWS_BUCKET
  - source: FRONTEND_URL
    target: /run/configs/FRONTEND_URL
  - source: WEB_URL
    target: /run/configs/WEB_URL
  - source: SANCTUM_STATEFUL_DOMAINS
    target: /run/configs/SANCTUM_STATEFUL_DOMAINS

x-backend-secrets: &backend-secrets

  - source: DISCORD_CONTACT_WEBHOOK_URL
    target: DISCORD_CONTACT_WEBHOOK_URL

  - source: CF_DNS_API_TOKEN
    target: CF_DNS_API_TOKEN
  - source: AWS_ACCESS_KEY_ID
    target: AWS_ACCESS_KEY_ID
  - source: AWS_SECRET_ACCESS_KEY
    target: AWS_SECRET_ACCESS_KEY

  - source: STRIPE_KEY
    target: STRIPE_KEY
  - source: STRIPE_SECRET
    target: STRIPE_SECRET
  - source: STRIPE_WEBHOOK_SECRET
    target: STRIPE_WEBHOOK_SECRET

  - source: APP_KEY
    target: APP_KEY
  - source: DB_PASSWORD
    target: DB_PASSWORD
  - source: REDIS_PASSWORD
    target: REDIS_PASSWORD

  - source: REVERB_APP_KEY
    target: REVERB_APP_KEY
  - source: REVERB_APP_SECRET
    target: REVERB_APP_SECRET


services:
{{#if WEBSITE}}
  web:
    image: $GH_REGISTRY/$GH_REPOSITORY/web:$GH_BRANCH
    hostname: ${APP_NAME}-web-${APP_ENV}
    healthcheck:
      test: ["CMD-SHELL", "curl -sf http://localhost:80/ || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s
{{/if}}

{{#if WEBAPP}}
  frontend:
    image: $GH_REGISTRY/$GH_REPOSITORY/frontend:$GH_BRANCH
    hostname: ${APP_NAME}-frontend-${APP_ENV}
    healthcheck:
      # 127.0.0.1, not localhost: busybox wget resolves localhost to ::1 (musl)
      # while nitro binds IPv4 — curl falls back, wget does not.
      test: ["CMD-SHELL", "wget -q --spider http://127.0.0.1:3000/ || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s
{{/if}}

{{#if API}}
  backend:
    image: $GH_REGISTRY/$GH_REPOSITORY/backend:$GH_BRANCH
    hostname: ${APP_NAME}-backend-${APP_ENV}
    environment:
      RUNNER: octane
    configs: *backend-configs
    secrets: *backend-secrets
    healthcheck:
      test: ["CMD-SHELL", "curl -sf http://localhost:8000/ || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
{{/if}}

{{#if QUEUE}}
  horizon:
    image: $GH_REGISTRY/$GH_REPOSITORY/backend:$GH_BRANCH
    hostname: ${APP_NAME}-horizon-${APP_ENV}
    environment:
      RUNNER: horizon
    configs: *backend-configs
    secrets: *backend-secrets
    healthcheck:
      test: ["CMD-SHELL", "pgrep -f 'horizon:[s]upervisor' || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
{{/if}}

{{#if BROADCASTING}}
  reverb:
    image: $GH_REGISTRY/$GH_REPOSITORY/backend:$GH_BRANCH
    hostname: ${APP_NAME}-reverb-${APP_ENV}
    environment:
      RUNNER: reverb
    configs: *backend-configs
    secrets: *backend-secrets
    healthcheck:
      test: ["CMD-SHELL", "pgrep -f 'reverb:[s]tart' || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
{{/if}}

{{#if CRON}}
  scheduler:
    image: $GH_REGISTRY/$GH_REPOSITORY/backend:$GH_BRANCH
    hostname: ${APP_NAME}-scheduler-${APP_ENV}
    environment:
      RUNNER: scheduler
    configs: *backend-configs
    secrets: *backend-secrets
    healthcheck:
      test: ["CMD-SHELL", "pgrep -f 'schedule:[r]un|slee[p] 60' || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
{{/if}}

networks:
  default:
    name: cluster
    external: true
