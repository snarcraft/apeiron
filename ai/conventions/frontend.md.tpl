# Frontend conventions — apps/frontend (webapp)

Nuxt 4 · Nuxt UI v4 · Tailwind v4 (CSS-first) · Sanctum auth · no Pinia.

## Architecture

```
app/
├── app.vue               UApp + runtime tenant theming
├── app.config.ts         navigation + policy mirror + ui theme
├── assets/css/main.css   design tokens (generated, then per-tenant override)
├── components/
│   ├── global/           Logo, Mark, Sidebar, Menu, Profile, Gate
│   └── dashboard/        per-widget components
├── composables/          useAuth (can), useSanctum — tiny, single-purpose
├── layouts/              default (UDashboardGroup), auth (aurora card)
├── pages/                one file per route; feature pages gated
├── plugins/              0.sanctum, 1.i18n, 3.app (settings boot), date, error
└── types/index.d.ts      GLOBAL types (User, Feature, Policies…) — no imports
```

## Nuxt UI usage rules

1. **Reach for a `U*` component first** — buttons, inputs,
   selects, modals, toasts, tables, accordions, dashboards. Never
   hand-roll a primitive that Nuxt UI ships.
2. **Style through props and semantic slots**, not CSS overrides:
   `color="primary"`, `variant="subtle"`, `size="lg"`. Structural
   tweaks go through the `:ui` prop slot classes.
3. **Icons are props** (`icon="i-lucide-*"`), never inline SVG
   inside templates (Logo/Mark monograms are the only exception).
4. **Theme centrally**: `app.config.ts` `ui` block carries global
   component tweaks (button block variant, input rounding). Don't
   repeat the same prop overrides per page — lift them into the
   theme block.
5. **Semantic color classes over raw palette**: `text-muted`,
   `bg-elevated`, `border-default` follow color mode; raw
   `primary-500` only for intentional brand moments.
6. `useToast()` for feedback, `UFormField` for validation rows,
   `UAccordion`/`UTable`/`UModal` before any custom equivalent.

## Components: global vs feature-based

| Kind | Location | Auto-import name | Rule |
|---|---|---|---|
| **Global** | `components/global/` | `Sidebar`, `Gate`, `Logo` | Cross-feature chrome: navigation, auth boundary, brand, layout shells. If it appears on every screen or outlives any single feature, it lives here. |
| **Feature** | `components/<feature>/` | `TaskBoard` (from `task/Board.vue`) | Everything used by exactly one feature. Directory named after the feature, files named after what they render. |
| **Dashboard widgets** | `components/dashboard/` | `DashboardStatCard` | Composable dashboard fragments shared across feature pages. |

- A component migrates `feature → global` only when a second
  feature starts importing it.
- Never import components across feature folders — if two
  features need the same piece, promote it.
- One component per file, PascalCase, template first if trivial,
  `<script setup lang="ts">` always.

## Composables: app-related vs feature-based

| Kind | Location | Rule |
|---|---|---|
| **App** | `composables/` root | Platform services: `useAuth` (can/isAdmin), `useSanctum` (typed API). Zero feature knowledge. |
| **Feature** | `composables/use<Task>X.ts` or colocated | Prefixed with the feature (`useTaskFilters`). Talks to one feature's endpoints, returns typed refs. |

- Composables are **tiny and single-purpose** — data in, refs out.
  No stores, no god-composables.
- All API access goes through `useSanctum<T>()` — feature
  composables wrap it, pages never call `$fetch` directly.
- Return `computed` refs, not raw values, so they stay reactive.

## House rules

- **State**: composables + `useSanctumUser` + app config payload.
  No Pinia, no Vuex — add a store only with explicit approval.
- **API**: everything through `useSanctum<T>(...)` which unwraps
  the `{ data }` envelope. No raw `$fetch` to the backend.
- **Auth**: `nuxt-auth-sanctum` global middleware handles routes;
  gate UI fragments with `<Gate feature="task" action="create">`
  or `useAuth().can('task', 'read')`.
- **Types are global** (`types/index.d.ts`, `export global {}`) —
  `User`, `Feature`, `Policies` need no imports. Keep them in sync
  with the backend enums.
- **Navigation is config**: entries in `app.config.navigation`,
  icons per feature, visibility derived from the user's policies.
  Never hardcode a sidebar.
- **Theming**: tokens live in `main.css` (`--color-primary-*`);
  tenants override at runtime via `:root` injection in `app.vue`.
  Never hardcode hex in components.
- **Semantic utility classes** first: `text-muted`,
  `text-highlighted`, `border-default`, `bg-elevated` — they follow
  color mode automatically.
- **Single attribute per line** in templates (Prettier enforces).
- **i18n**: translations come **from the backend** — messages
  boot from `/api/translations` (nested JSON, dotted keys) into
  vue-i18n; `pnpm lang:extract` syncs missing keys into
  `apps/backend/storage/app/lang/*.json`. Only the **global
  website** (`apps/web`) keeps local dictionaries
  (`i18n/locales/*.json`) because it renders fully static. No
  hardcoded copy, ever.
- **Types**: import the real types (`ofetch`'s `FetchRequest` /
  `FetchOptions` / `ResponseType` in `useSanctum`) — never
  invent stand-ins for library types.

## Commands

```bash
pnpm --filter "@{{APP_NAME}}/frontend" dev
pnpm --filter "@{{APP_NAME}}/frontend" typecheck
pnpm --filter "@{{APP_NAME}}/frontend" lint
```
