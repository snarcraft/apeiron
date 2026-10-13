# AGENTS.md — Apeiron

ἄπειρον — *the boundless*: Anaximander's primordial source from
which all worlds arise. You (an agent) are inside the **platform
factory** that spawns them. Your job here is either to *scaffold a
new project*, or to *improve Apeiron*.

## Scaffolding a new project

```bash
# interactive (human at the keyboard)
node .

# non-interactive (you fill the answers)
node . --answers answers.json --out /path/to/new-project
```

The answers schema is documented in `answers.example.json`.
Anything omitted falls back to defaults (see `loadAnswers` in
`index.mjs`). When a human is directing you: ask them for the
values you genuinely need (name, domain, groups/roles/features,
palette, soul, integrations) and write an answers file — do not
guess brand decisions.

After scaffolding, follow the generated project's own
`AGENTS.md`.

## Apeiron map

| Path | Role |
|---|---|
| `index.mjs` | interactive/non-interactive scaffolder |
| `lib/prompts.mjs` | zero-dep TUI prompts (text/select/multiselect/secret) |
| `lib/oklch.mjs` | perceptual palette engine (hue → 50–950 scale) |
| `lib/render.mjs` | `{{TOKEN}}` + `{{#if TOGGLE}}` renderer |
| `lib/rbac.mjs` | enums/matrix/types/seeder/tests generator |
| `lib/builders.mjs` | composer.json, env files, SECRETS.md, monogram, README |
| `boilerplate/` | the project file tree (tokens + conditionals; mobile is opt-in via the `MOBILE` toggle) |
| `styling/souls/` | the four design skins (web.css, app.css, Hero.vue) |
| `ai/` | conventions & playbooks copied into projects |

## Template conventions

- `.tpl` files render; the suffix is dropped.
- Tokens are `{{UPPER_SNAKE}}` and resolve from scaffold answers.
- The renderer retains `{{#if}}` support, but the platform ships
  everything always — no integration is conditional.
- Souls must implement the class contract in `styling/README.md`.

## Improving Apeiron

1. Change the source (boilerplate, lib, souls, ai) — never a
   rendered project.
2. Add a token or toggle in `index.mjs` (`derive`) first.
3. Test: `node . --answers answers.example.json --out
   /tmp/probe` then inspect the rendered tree.
4. Keep every surface in sync: backend ↔ frontend ↔ web ↔ mobile ↔ ai docs.
