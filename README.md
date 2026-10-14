<p align="center">
  <img src="docs/banner.svg" alt="Apeiron — the boundless, source of platforms" width="1200">
</p>

<h1 align="center"> ἄ π ε ι ρ ο ν </h1>

<p align="center">
  <em>An opinionated factory for full-stack businesses —<br>
  every project born complete, every line readable by humans and AI agents alike.</em>
</p>

<p align="center">
  <img src="docs/badges.svg" alt="stack: laravel, nuxt, flutter · cloud: cloudflare, aws · ship: swarm, ghcr, app stores · humans + agents" width="1200">
</p>

> ⚠️ **In active development** — expect breaking changes between releases. Built for professionals who run their own infrastructure; others should wait for the stable release.

---

<p align="center">
  <sub><em>·&nbsp;&nbsp;A P E I R O N&nbsp;&nbsp;·</em></sub>
</p>

<p align="center">
  <em>Anaximander, twenty-six centuries ago, named the immortal source<br>
  from which all worlds arise — and to which they return.</em>
</p>

<p align="center">
  <strong>This is that idea, as a repository:</strong><br>
  one boundless source, every platform you will ever build.
</p>

<p align="center">
  <sub>◆&nbsp;&nbsp;✦&nbsp;&nbsp;⬡&nbsp;&nbsp;●&nbsp;&nbsp;▲</sub>
</p>

## ◆ The concept

Most templates give you a folder. **Apeiron gives you a worldview** — one deliberate, opinionated way to build a software business, so that project one and project twenty share the same skeleton, the same conventions, the same muscle memory.

You answer five questions. A complete, deployed, branded platform answers back.

> **◈** _a name, a domain, an org_

**Identity** — wired through the website, the webapp, mobile, the API and CI. Every surface knows who it is.

> **⬡** _groups · roles · features_

**Permissions** — the whole RBAC layer as code: enums, gates, mirrored UI policies, seed personas, and a Pest spec that proves it.

> **✦** _a hue — or “surprise me”_

**A palette** — gamut-mapped oklch, minted live in your terminal, driving every surface from landing page to mobile theme. One brand, served from the backend.

> **●** _a design soul_

**A website** — the same anatomy every time, a different face every project. Hero to contact, restyled by the soul.

> **▲** _secrets_

**A cloud** — an idempotent AWS provisioner: buckets, IAM users, EC2 per environment, Cloudflare DNS — and one command pushes every derived secret to GitHub for you.

## ✦ Four souls, one skeleton

Every generated website shares the same anatomy — hero → features → steps → pricing → faq → contact — restyled by a soul. Components know nothing about which skin is live; the soul owns the surface.

<p align="center">
  <img src="docs/souls.svg" alt="The four design souls" width="1200">
</p>

## ◆ The stack

Versions live in the manifests — `composer.json`, `package.json`, `pubspec.yaml` — and nowhere else; the prose stays evergreen. Five strata, one opinion each — the platform arises from the cloud substrate upward:

<p align="center">
  <img src="docs/stack.svg" alt="The stack in five strata — interfaces: flutter, nuxt web and webapp; api: laravel with octane, sanctum, pennant, horizon, reverb, pest; data: aurora, elasticache, s3; cloud: aws, cloudflare; ship: docker swarm, ghcr, actions, app stores, loki, grafana, discord — worlds arise from the cloud substrate upward" width="1200">
</p>

## ▲ The remote platform

Tag a release and walk away — the train knows every stop:

<p align="center">
  <img src="docs/remote.svg" alt="The remote platform — cloudflare dns through traefik to web, frontend and backend (octane, horizon, reverb, scheduler), down to postgres, redis, s3, stripe, and out to loki, grafana and discord" width="1200">
</p>

The stores get theirs too — every tag is signed and uploaded unattended: no certificates dragged around laptops, no Xcode opened, no human in the loop.

<p align="center">
  <img src="docs/stores.svg" alt="Every git tag ships itself to the app store via TestFlight and to Google Play on the internal track — unattended" width="1200">
</p>

### ● The zero-ops checklist

Everything between _git tag_ and _serving customers_ is idempotent, self-healing, and narrated on Discord — green or red. The checklist runs itself; you watch it happen:

<p align="center">
  <img src="docs/checklist.svg" alt="The zero-ops checklist — dns and tls, hosting, datastores, caching, storage, email, migrations, observability: all automated, idempotent, narrated on Discord" width="1200">
</p>

### ⚡ An API that never boots twice

Classic PHP folds the framework after every request. Octane + Swoole boot once and stay hot in worker memory — coroutine I/O, `scoped()` per-request state, one image running API, queues, websockets and cron.

<p align="center">
  <img src="docs/octane.svg" alt="Classic php reboots the framework for every request; Octane plus Swoole boots once and serves hot from worker memory" width="1200">
</p>

Laravel with Node-class latency — on the same hardware, routinely faster.

### ◈ Scaling — the cluster bill, skipped

Scaling is role-shaped, not instance-shaped: `docker service scale <stack>_backend=4` grows the API, `<stack>_horizon=2` grows the queues — same image, another temper. No control plane to feed, no balancer to rent.

<p align="center">
  <img src="docs/bill.svg" alt="Two monthly bills — the aws cluster stacks a control plane, managed nodes, a nat gateway and a load balancer for roughly 205 a month; ec2 plus swarm is one instance for roughly 40 a month, everything else zero" width="1200">
</p>

Vertical first — Octane keeps the app hot in memory with coroutine I/O, and Swarm packs replicas onto the instance edge to edge: one host does the work of a small fleet. Horizontal when you outgrow it: `docker swarm join` a second EC2 and the overlay network, placement and Traefik re-converge themselves; Horizon workers fit Spot instances perfectly, since Swarm reschedules a killed node's replicas. And it is automatic: `autoscale.sh` runs on the host as a systemd unit, watches **Traefik's own request metrics**, and calls `docker service scale` — replicas rise the moment traffic does, and step back down only after three calm windows, so it never flaps. Bounds and sensitivity live in `/etc/apeiron/autoscale.env`.

## ⬡ Permissions are code

No roles tables. No permission seeders. No cache drift. Four string enums and one gate — the matrix _is_ the source of truth, mirrored to the frontend on the user payload, tested as a spec:

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
can('widget', 'create')
<Gate feature="widget" action="create"> … </Gate>
```

```dart
// apps/mobile — same payload, same gate
user.can('widget', 'create');
```

One matrix. Three surfaces. Zero divergence.

## ● Built for two readers

Every project ships an **agent curriculum** — a first-class artifact, not an afterthought. `AGENTS.md` is the map, `ai/conventions` the law per surface, `ai/playbooks` the end-to-end recipes. Humans and agents read the same book — and land byte-identical commits.

<p align="center">
  <img src="docs/readers.svg" alt="Two readers — human and ai agent — converge on one repo: same conventions, same fixers, byte-identical commits, same green Pest suite" width="1200">
</p>

An agent that has never seen your project can add a feature end-to-end by reading one playbook. A human can too. That's the point.

## ▲ Quickstart

```bash
git clone https://github.com/snarcraft/apeiron.git && cd apeiron

node .                                 # interactive — palette preview in your terminal
node . --list-souls                    # meet the four souls
node . --answers answers.example.json --out ../my-next-business
```

Then, inside the newborn platform:

```bash
pnpm install
cd apps/backend && composer install
php artisan key:generate && php artisan migrate --seed
cd ../..
make services   # postgres + redis + minio
make dev        # webapp + api + websockets + queues + logs — color-coded, real local domains
```

Mobile, when you want the app too:

```bash
cd apps/mobile && flutter pub get
flutter create --org com.yourorg --project-name yourapp .   # platform folders — once
cd ../..
make codegen    # freezed · json · router codegen, watch mode
make mobile     # the app, against the same backend
```

Push a tag → images publish to GHCR → the Swarm rolls → Play and TestFlight get their builds → Discord pings. That's the whole release train.

## ◆ The map

<p align="center">
  <img src="docs/map.svg" alt="The map — apeiron root branching into index.mjs the factory gate, lib the engines, boilerplate the platform tree, styling souls, ai the agent curriculum, docs the visuals" width="1200">
</p>

Agents working _on_ Apeiron itself: read [`AGENTS.md`](AGENTS.md).

---

<p align="center">
  <em>The palette of this very page — <code>#988cff</code> violet, <code>#00b4bf</code> teal — was generated by Apeiron from hue 286.</em><br>
  <strong>From the boundless, worlds.</strong>
</p>
