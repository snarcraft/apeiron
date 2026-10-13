# AGENTS.md — {{APP_TITLE}}

You are working in **{{APP_TITLE}}**, a pnpm monorepo:
Nuxt web + webapp · Laravel API{{#if MOBILE}} · Flutter mobile{{/if}} · Docker Swarm deploy.
This file is your map. `ai/` is your curriculum. Read before
writing code.

## Project map

| Path | What | Rules |
|---|---|---|
| `apps/web` | marketing website (static SSG) — {{DOMAIN}} | `ai/conventions/web.md` |
| `apps/frontend` | SaaS webapp (SSR, Sanctum) — {{APP_DOMAIN}} | `ai/conventions/frontend.md` |
| `apps/mobile` | Flutter app (server-driven theme, Sanctum tokens) | `ai/conventions/mobile.md` |
| `apps/backend` | Laravel API (Octane/Swoole, Pest) | `ai/conventions/backend.md` |
| `server/` | Swarm stack, Traefik, deploy scripts | `ai/conventions/infra.md` |
| `.github/` | publish + deploy workflows | `ai/conventions/infra.md` |
| `ai/` | conventions & playbooks | read first |
| `styling` | tokens live in `apps/*/app/assets/css/main.css` | `ai/conventions/styling.md` |
| `docs/SECRETS.md` | provisioning manual | `ai/playbooks/secrets.md` |

## Commands

```bash
make dev                 # everything: webapp + api + websockets + queues + logs
make web                 # marketing website only
make mobile               # flutter app (debug entrypoint)
make codegen              # flutter build_runner watch
make services            # local postgres/redis/minio (server/local.yml)
make test                # backend pest suite
pnpm generate:assets     # mint PWA icons from assets/icon.svg
pnpm lang:extract        # sync i18n keys backend ← frontend
```

Backend only (from `apps/backend`): `composer run format` (style
truth), `composer run test`, `php artisan octane:start --watch`.

## The model

- Groups: {{APP_GROUPS}} — Roles: {{APP_ROLES}} — Features: {{APP_FEATURES}}
- Permissions are **code** (enums + gate), never database rows.
- `operator` + `admin` bypasses every gate.
- Everything you need: `ai/playbooks/rbac.md`.

## Hard rules

1. Follow `ai/conventions/*` for the area you touch. Sibling files
   are the style reference — read one before writing.
2. Never add a roles/permissions table; never name a feature with
   two words.
3. ULID `uuid` is the public identifier; route binding keys on it.
4. Prettier owns TS/Vue/CSS layout, php-cs-fixer owns PHP. Run
   them; never hand-format.
5. Every behavior change ships with or updates a Pest test.
6. Conventional commits (`feat(backend): …`) — see
   `ai/conventions/commits.md`.
7. Secrets never enter the repo. Provisioning goes through
   `docs/SECRETS.md`.
8. MCP servers are configured (Laravel Boost, Nuxt, Nuxt UI) —
   prefer them over guessing package APIs.

## Definition of done

Lint clean · typecheck clean · tests green · fixers ran ·
conventions respected · commit follows the style.
