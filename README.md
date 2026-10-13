# Apeiron

> ἄπειρον — *the boundless*: the primordial source from which all
> worlds arise. — Anaximander

One command → a complete platform in your style: Nuxt 4 web +
webapp, Laravel 13 API, enum-driven RBAC, generated oklch design
system, Docker Swarm deploy, agent docs included.

```
node scaffold.mjs
```

## What you get

| Layer | Delivered |
|---|---|
| **RBAC** | Groups / Roles / Features as code (enums) — matrix, gates, mirrored frontend policies, seed personas, Pest spec |
| **Backend** | Laravel 13 · Octane · Sanctum · Pennant · Horizon · Reverb* · S3 media (always) · Stripe* · Discord relay* · Laravel AI* |
| **Mobile** | Flutter kernel — injectable DI, Cubits, auto_route, server-driven theme from the same palette, `assets/app.json` linked from `secrets/` |
| **Webapp** | Nuxt 4 SSR · Nuxt UI v4 · dashboard shell · login · policy-gated nav · tenant theming · realtime* |
| **Website** | Static marketing site with a **generated design soul** — same anatomy every time, a different face every project |
| **Design** | oklch palette generated from a hue (gamut-mapped 50–950), 4 souls: aurora · blueprint · editorial · neon |
| **Infra** | Dockerfile (3 targets) · Swarm stack · Traefik · one-off-job migrations · GH Actions publish/deploy · Loki/Grafana |
| **AI** | `AGENTS.md` entrypoint + `ai/` conventions & playbooks + MCP servers (Laravel Boost, Nuxt, Nuxt UI) |

No optional integrations — Stripe, Reverb, S3 media, Discord and
Laravel AI ship in every project, always.

## Usage

```bash
# interactive — questions about identity, RBAC, palette, soul,
# integrations, and optionally the secret values themselves
node scaffold.mjs

# non-interactive (agents / CI)
node scaffold.mjs --answers answers.json --out ../acme

# explore design souls
node scaffold.mjs --list-souls
```

Requires Node ≥ 20. Zero dependencies.

## After scaffolding

```bash
cd <project>
pnpm install
cd apps/backend && composer install && cp .env.example .env
php artisan key:generate && php artisan migrate --seed
cd ../..
make services   # postgres + redis + minio
make dev        # → http://localhost:3000
```

Provisioning (AWS buckets, IAM, GitHub vars/secrets, first
deploy): the generated `docs/SECRETS.md` is a runnable checklist.

## Layout

```
scaffold.mjs        the scaffolder (start here)
lib/                prompts · oklch engine · renderer · rbac · builders
boilerplate/        the project tree ({{tokens}} + {{#if toggles}})
styling/souls/      the four design skins
ai/                 conventions & playbooks copied into every project
AGENTS.md           entrypoint for agents working on this template
```

Agents: read `AGENTS.md` — it explains how to scaffold for a human
and how to evolve Apeiron itself.
