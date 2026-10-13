# Commit & PR conventions

Conventional commits, lowercase, imperative, scope when it helps:

```
feat(frontend): gate invoice actions behind policy map
fix(server): mount stripe secrets on horizon too
feat(ci): skip tag builds when app paths unchanged
docs(ai): record migration stub rule
chore: bump deps
```

## Scopes

| Scope | Path |
|---|---|
| `backend` | `apps/backend` |
| `frontend` | `apps/frontend` |
| `web` | `apps/web` |
| `ci` | `.github` |
| `server` | `server/` |
| `ai` | `ai/`, `AGENTS.md` |
| (none) | root / cross-cutting |

## Rules

1. One logical change per commit — refactor and feature never mix.
2. Subject ≤ 72 chars, body for the *why* when non-obvious.
3. Breaking changes: `!` + a body note (`BREAKING CHANGE: …`).
4. Never commit secrets, `*.env` values, or lockfiles for
   experiments.
5. PRs describe behavior, not file lists.
