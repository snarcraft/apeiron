# Playbook — deploy

## Prerequisites (once)

`docs/SECRETS.md` walks the full provisioning (AWS buckets, IAM,
GitHub vars/secrets, EC2 host). Then:

1. **Infrastructure up** (GitHub Actions, manual) — bootstraps the
   host, Swarm, Traefik, Postgres, Redis, observability.
2. **Swarm up** (GitHub Actions, manual) — creates versioned
   configs/secrets and rolls the app stack.

## Release

```bash
# 1. bump the version variable (immutable config names depend on it)
gh variable set APP_VERSION --body "1.1.0" --env production

# 2. tag (publish workflows only run on tags)
git tag v1.1.0 && git push origin v1.1.0

# 3. wait for backend/frontend/web publishes (change-detected —
#    unchanged apps skip), then: Actions → Swarm up
```

`deploy.sh` on the host: pulls images, runs `migrate --force` and
`inspire` as one-off swarm jobs, rolls the stack, waits for
replicas, prunes old images. Discord gets a ping either way.

## Environments

- branch `main` → staging (`server/staging.yml`, `staging.` hosts)
- any other ref (workflow_dispatch on a branch/tag) → production
- `development` env exists for ephemeral branch deploys

## Rollback

Images are tagged by branch name; the previous tag's images are
still on the host until pruned:

```bash
ssh ubuntu@host
docker service update --image ghcr.io/{{APP_ORG}}/{{APP_REPO}}/backend:v1.0.9 {{APP_NAME}}_backend
```

Config rollbacks: re-run swarm.sh with the old `APP_VERSION` —
versioned objects are immutable, both versions coexist.

## Local parity

`make services` (server/local.yml) runs the same postgres/redis/
minio the stack uses. `make dev` runs the full platform.
