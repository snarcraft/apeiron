# Playbook — secrets & provisioning

**Rule: no secret is ever committed.** `secrets/` self-ignores;
values live in GitHub environments (CI) and Docker secrets
(runtime). DB and redis passwords are generated at scaffold —
never asked, never typed.

## Where secrets live

| Layer | Store |
|---|---|
| master credentials | `secrets/master.env` (git-ignored) → GitHub via `node scripts/bootstrap.mjs` |
| local dev | `secrets/local.env` (git-ignored) |
| staging/production CI | GitHub environments `staging` / `production` |
| runtime | Docker secrets, versioned `${app}.${env}.${version}.<NAME>` |

`docs/SECRETS.md` (generated at scaffold) lists every variable
and secret with ready-to-run `gh variable set` / `gh secret set`
commands — run it from the repo root after `gh auth login`.

## Generating values

```bash
openssl rand -base64 24   # APP_KEY material, DB/Redis passwords
openssl rand -hex 16      # Reverb key/secret
make generate-key         # writes APP_KEY into secrets/local.env
```

## AWS resources (per project)

1. `<slug>-assets` bucket — CI build artifacts, immutable cache,
   `config/asset-cors.json` applied.
2. `<slug>-media` bucket — user uploads.
3. IAM CI user ← `config/github-policy.json` (sync assets, manage
   the runner-IP security-group rule).
4. IAM media user ← `config/media-policy.json`.

## Rotation

Bump `APP_VERSION`, set the new GitHub secret value, re-run
"Swarm up" — `swarm.sh` creates the new versioned objects; the old
ones remain until pruned (instant rollback path).

## Verifying

```bash
bash server/swarm.sh --list   # on the host: versioned objects
gh secret list --env production
```
