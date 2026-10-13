# ai/ — the operating manual for agents

Everything an AI agent (Claude Code, Cursor, opencode, Codex,
Windsurf…) needs to work in this project correctly lives here.
The root `AGENTS.md` is the entrypoint; these files are the
curriculum. Read what covers your task, follow it exactly.

## Reading order

1. `AGENTS.md` (repo root) — orientation, commands, hard rules
2. `conventions/backend.md` — before touching `apps/backend`
3. `conventions/frontend.md` — before touching `apps/frontend`
4. `conventions/web.md` — before touching `apps/web`
5. `conventions/mobile.md` — before touching `apps/mobile`
5. `conventions/styling.md` — before writing any CSS/Tailwind
6. `conventions/commits.md` — before committing
7. `conventions/infra.md` — before touching `server/` or `.github/`

## Playbooks (task-oriented)

| Playbook | When |
|---|---|
| `playbooks/add-feature.md` | Adding a domain feature end-to-end |
| `playbooks/rbac.md` | Changing groups, roles or the permission matrix |
| `playbooks/deploy.md` | Shipping a release |
| `playbooks/secrets.md` | Provisioning env vars, AWS, GitHub |

## Tooling

- `agent-setup.md` — MCP servers (Laravel Boost, Nuxt, Nuxt UI),
  opencode config, and how the toolchain maps to agents.
- Laravel Boost generates `apps/backend/AGENTS.md` +
  `.claude/.cursor` skill folders on `composer install` — those
  are framework-level rules; this folder is project-level truth.

## Hard rules (all agents, all areas)

1. **Permissions are code.** Never add a roles/permissions table.
2. **Models are unguarded.** Validation lives in FormRequests.
3. **ULID uuid everywhere.** Route binding keys on `uuid`.
4. **Single-word identifiers.** Features: `task`, `invoice` —
   never `task_management`.
5. **No new base folders** without asking. Follow the map.
6. **Prettier owns the frontend layout, php-cs-fixer owns PHP.**
   Never hand-format; run the fixers.
7. **Every behavior change ships with a Pest test.**
8. **Every user-facing string is translated** — `t('…')` in the
   webapp (backend dictionary) and the website (local locale
   files). No hardcoded copy in components.
