# Agent tooling setup

## MCP servers (root `.mcp.json` + `opencode.json`)

| Server | Transport | Purpose |
|---|---|---|
| `laravel-boost` | local — `php apps/backend/artisan boost:mcp` | schema, queries, docs, error logs, project rules |
| `nuxt` | remote — `https://nuxt.com/mcp` | Nuxt docs, version-matched |
| `nuxt-ui` | remote — `https://ui.nuxt.com/mcp` | Nuxt UI component docs |

Any MCP-capable agent picks these up from `.mcp.json` (Claude Code
format). opencode reads `opencode.json`, which adds LSPs:
intelephense + laravel-lsp (PHP), typescript/vue language servers.

## Laravel Boost

After `composer install` in `apps/backend`, Boost generates:

- `apps/backend/AGENTS.md` / `CLAUDE.md` — framework-level rules
  (Octane discipline, Pest, Artisan usage…)
- `.claude/skills/` + `.cursor/skills/` — skill libraries
  (pennant, octane, horizon, testing)

Those are *framework* rules; `ai/` at the root is *project* truth.
When they conflict on project structure, `ai/` wins.

## Boost habits

- `database-schema` before writing migrations.
- `search-docs` before using package APIs (version-matched!).
- `record-rule` when a decision settles — it lands in
  `apps/backend/.ai/rules/` and future agents inherit it.

## VS Code

`.vscode/settings.json` wires format-on-save: Prettier for the
workspace, php-cs-fixer (via the wrapper script) for PHP, ESLint
fix-all. Tailwind IntelliSense anchored to the webapp's main.css.

## The chain, summarized

```
agent boot ─► AGENTS.md (map + hard rules)
           ─► ai/conventions/* (area rules)
           ─► ai/playbooks/* (task recipes)
           ─► MCP servers (live knowledge)
```
