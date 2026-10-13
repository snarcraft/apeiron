<p align="center">
  <img src="docs/banner.svg" alt="Apeiron — the boundless, source of platforms" width="880">
</p>

<h1 align="center">A P E I R O N</h1>

<p align="center">
  <em>An opinionated factory for full-stack businesses —<br>
  every project born complete, every line readable by humans and AI agents alike.</em>
</p>

<p align="center">
  <img src="docs/badges.svg" alt="stack: laravel, nuxt, flutter · cloud: aws, cloudflare · ship: swarm, ghcr, app stores · humans + ai agents" width="880">
</p>

---

> **ἄπειρον** — *the boundless.* Anaximander, 26 centuries ago, named the
> immortal source from which all worlds arise and to which they return.
> This is that idea, as a repository: **one boundless source, every
> platform you will ever build.**

## ◆ The concept

Most templates give you a folder. **Apeiron gives you a worldview.**

It encodes one deliberate, opinionated way to build a software
business — so that project number one and project number twenty
share the same skeleton, the same conventions, the same muscle
memory. You answer a handful of questions; a complete, deployed,
branded platform answers back:

| | You are asked | You receive |
|---|---|---|
| ◈ | a name, a domain, an org | identity wired through web, webapp, mobile, API, CI |
| ⬡ | groups · roles · features | the entire RBAC layer as **code** — enums, gates, mirrored UI policies, seed personas, Pest spec |
| ✦ | a hue (or *surprise me*) | a gamut-mapped oklch palette, minted live in your terminal, driving every surface — same brand from landing page to mobile theme, served from the backend |
| ● | a design soul | a distinct, beautiful website — same anatomy every time, a different face every project |
| ▲ | secrets (optional) | an idempotent AWS provisioner — buckets, IAM users, EC2 per environment, Cloudflare DNS — plus a ready-to-run `gh` checklist |

<p align="center">
  <img src="docs/flow.svg" alt="One command to a full platform" width="880">
</p>

## ✦ Four souls, one skeleton

Every generated website shares the same anatomy — hero → features
→ steps → pricing → faq → contact — restyled by a soul. Components
know nothing about which skin is live; the soul owns the surface.

<p align="center">
  <img src="docs/souls.svg" alt="The four design souls" width="880">
</p>

## ◆ The stack

Versions live in the manifests — `composer.json`, `package.json`,
`pubspec.yaml` — and nowhere else. The prose stays evergreen.

| Layer | The opinion |
|---|---|
| API | **Laravel** — Octane (Swoole) · Sanctum · Pennant · Horizon · Reverb · Pest |
| Data | Postgres · Redis · S3 (MinIO locally, AWS in production) |
| Webapp | **Nuxt** — Nuxt UI · Tailwind · Sanctum auth · VueUse · no Pinia |
| Website | **Nuxt** static — Nuxt UI · prerendered, S3 + CDN'd |
| Mobile | **Flutter** — freezed · injectable · Cubits · auto_route · dio |
| Cloud | **AWS** — EC2 swarm host · S3 buckets · IAM users, minted by an idempotent provisioner |
| Edge | **Cloudflare** DNS — Traefik terminates TLS via DNS-01 |
| Ship | Docker Swarm · Traefik · GHCR · GitHub Actions |
| Stores | **Google Play** (internal track) + **App Store** (TestFlight) — every tag, zero human hands |
| Watch | Loki · Grafana · Discord release pings |
| Craft | pnpm workspace · Make · Prettier · php-cs-fixer · dart format · MCP |

## ▲ The remote platform

Tag a release and walk away — the train knows every stop:

```
 Cloudflare DNS
      │
 Traefik — TLS via DNS-01 · the only door
      │
      ├─ web ————— marketing, static + CDN'd
      ├─ frontend — the webapp, SSR
      └─ backend —— one image, four tempers:
                      octane ——— API          horizon ——— queues
                      reverb ——— websockets   scheduler —— cron
      │
 postgres —— redis —— s3 media
      │
 loki → grafana — and Discord gets the ping
```

The stores get theirs too: every tag is signed and uploaded to
**Google Play** and **TestFlight** unattended — no certificates
dragged around laptops, no Xcode opened, no human in the loop.

### ● The zero-ops checklist

Everything between *git tag* and *serving customers* is
idempotent and transparent — Discord narrates every step:

- **DNS + TLS** — Cloudflare records are minted by the provisioner;
  Traefik terminates TLS via DNS-01. No certbot, no renewal cron,
  no certificates to babysit.
- **Hosting** — one EC2 per environment: keypair, security group
  (22/80/443, runner IPs allow-listed per deploy). Re-runs reuse
  everything they find.
- **Datastores** — Postgres, Redis, and two S3 buckets (media +
  immutable asset/CDN with CORS), each with a least-privilege IAM
  user. Local dev mirrors the trio on MinIO — same code, no ifdefs.
- **Caching** — Redis carries cache, sessions and queues; the API
  itself stays hot in Octane worker memory; identity caches live
  behind an `auth` tag that flushes itself when identity changes.
- **Storage** — S3-backed media with lifecycle cleanup: delete a
  model and its files queue themselves for removal five minutes
  later. Nothing orphans, nothing lingers.
- **Email** — verification, resets and notifications ride the
  queue; a failed send broadcasts `SendMailFailed`. `log` driver
  out of the box, one variable to SES when you're ready.
- **Migrations** — one-off swarm jobs that run *before* the stack
  rolls, so every service boots on the new schema, never mid-flight.
- **Observability** — Loki scrapes every container, Grafana answers
  on `:3001`, and Discord reports every deploy — green or red.

### ⚡ An API that never boots twice

Classic PHP folds the framework after every request. Octane +
Swoole boot the application **once** and keep it hot in worker
memory — Swoole's coroutine I/O serves requests in the time
php-fpm spends waking up. Per-request services bind `scoped()` so
state stays honest between workers, and the same image runs API,
queues, websockets and cron. The result is Laravel with Node-class
latency — on the same hardware, routinely faster.

## ⬡ Permissions are code

No roles tables. No permission seeders. No cache drift. Four string
enums and one gate — the matrix *is* the source of truth, mirrored
to the frontend on the user payload, tested as a spec:

```php
// apps/backend/app/Enums/Group.php — generated from your answers
public function resolve(Role $role): array
{
    return match ($this) {
        default => [],
        Group::CLIENT => match ($role) {
            default => [],
            Role::MANAGER => [
                Feature::WIDGET => [
                    Action::INDEX,
                    Action::READ,
                    Action::CREATE,
                    Action::UPDATE,
                ],
            ],
        },
    };
}
```

```ts
// apps/frontend — the same matrix, mirrored at scaffold time
can('widget', 'create')   // ← reads user.policies['widget:create']
<Gate feature="widget" action="create"> … </Gate>
```

```dart
// apps/mobile — same payload, same gate
user.can('widget', 'create');
```

One matrix. Three surfaces. Zero divergence.

## ● Built for two readers

Every project ships with an **agent curriculum** — not an
afterthought, a first-class artifact:

```
AGENTS.md                    ← the map an agent reads first
ai/conventions/backend.md    ← the law per surface
ai/conventions/frontend.md   ← components: global vs feature · composables: app vs feature
ai/conventions/mobile.md     ← injectable · cubits · freezed · server-driven theme
ai/playbooks/add-feature.md  ← enum → matrix → controller → nav → gates, end to end
ai/playbooks/rbac.md         ← the model, the resolution chain, the never-list
```

The style law is enforced by fixers — Prettier, php-cs-fixer, dart
format — so a human's commit and an agent's commit converge on
**byte-identical formatting**. Pest is the shared truth both must
keep green. MCP servers (Laravel Boost, Nuxt, Nuxt UI) are wired in
`.mcp.json` so any agent works with live, version-matched docs.

An agent that has never seen your project can add a feature
end-to-end by reading one playbook. A human can too. That's the
point.

## ▲ Quickstart

```bash
git clone <this repo> && cd apeiron

node scaffold.mjs                      # interactive — palette preview in your terminal
node scaffold.mjs --list-souls         # meet the four souls
node scaffold.mjs --answers answers.example.json --out ../my-next-business
```

Then, inside the newborn platform:

```bash
pnpm install
cd apps/backend && composer install && cp .env.example .env
php artisan key:generate && php artisan migrate --seed
cd ../..
make services   # postgres + redis + minio
make dev        # webapp + api + websockets + queues + logs — color-coded, real local domains
```

Push a tag → images publish to GHCR → the Swarm rolls → Play and
TestFlight get their builds → Discord pings. That's the whole
release train.

## ◆ The map

| Path | Role |
|---|---|
| `scaffold.mjs` | the factory gate — interactive or `--answers` for agents |
| `lib/` | prompts TUI · oklch engine · renderer · rbac generator · builders · provisioner |
| `boilerplate/` | the platform tree — 250+ files, rendered per project |
| `styling/souls/` | aurora · blueprint · editorial · neon |
| `ai/` | the agent curriculum, shipped into every project |
| `docs/` | the SVGs above — drawn in Apeiron's own generated palette |

Agents working *on* Apeiron itself: read [`AGENTS.md`](AGENTS.md).

---

<p align="center">
  <em>The palette of this very page — <code>#988cff</code> violet,
  <code>#00b4bf</code> teal — was generated by Apeiron from hue 286.</em><br>
  <strong>From the boundless, worlds.</strong>
</p>
