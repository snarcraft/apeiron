# Playbook — deploy

## One-time

`node scripts/bootstrap.mjs` (after the GitHub repo exists) pushes
the master credentials, the generated passwords and the derived
Stripe webhook into GitHub environments — staging, production and
mobile in one run. `docs/SECRETS.md` covers any value bootstrap
cannot know (server PEM of an existing host, signing materials).

## The train

- **push to `main`** → the Deploy workflow provisions (idempotent:
  buckets, IAM, EC2, Cloudflare records, host bootstrap — a fast
  re-check once resources exist) and rolls **staging** on the
  prefixed domains: `staging.<domain>`, `app.staging.<domain>`,
  `socket.staging.<domain>`, `*.staging.<domain>`
- **push a `v*` tag** → **production** rolls, no prefix domains
- deploy.sh waits for the publish workflows' images before pulling
- rollback: `docker service update --image …:v1.0.9 <stack>_backend`
  or re-run swarm.sh with the old `APP_VERSION` (immutable objects)

## Rollback

```bash
ssh ubuntu@host
docker service update --image ghcr.io/{{APP_ORG}}/{{APP_REPO}}/backend:v1.0.9 {{APP_NAME}}_backend
```

## Local parity

`make services` (server/local.yml) runs the same postgres/redis/
minio the stack uses. `make dev` runs the full platform.
