# Infra conventions — server/ + .github/

Docker Swarm on one EC2 host · Traefik (Cloudflare DNS-01) ·
GHCR images · S3 asset CDN · Loki/Grafana observability.

## Mental model

```
tag push ──► publish workflows (per-app, change-detected vs previous tag)
              ├─ build artifacts in CI (composer/pnpm)
              ├─ sync static assets → S3 (immutable, 1y cache)
              └─ buildx multi-arch → ghcr.io/<org>/<repo>/{backend,frontend,web}:<tag>

manual ────► "Infrastructure up" (once per host)
              ├─ add runner IP to EC2 security group
              └─ scp server/ → host; docker.sh (bootstrap) + swarm.sh + infra.sh

manual ────► "Swarm up" (every release)
              ├─ swarm.sh  → versioned configs/secrets (${app}.${env}.${version}.*)
              ├─ deploy.sh → pull, migrate (one-off swarm jobs), stack deploy, wait
              └─ Discord ping
```

## House rules

1. **CI builds, Docker packages.** No compilation inside
   Dockerfiles — they only COPY staged artifacts.
2. **Configs/secrets are immutable, versioned objects.** Rotation
   = bump `APP_VERSION`, re-run `swarm.sh`. Never edit in place.
3. **One-off tasks are swarm jobs** (`docker service create`),
   never `docker exec` — exec shells lack the mounted env.
4. **Healthchecks are `pgrep`/`curl`**, never artisan (no env in
   exec shells).
5. **Backend services share one image** — `RUNNER=octane|horizon|reverb|scheduler`
   selects the entrypoint role.
6. **Migrations run before the stack rolls** so services boot on
   the new schema.
7. Traefik labels live in `server/<env>.yml` — exact-host routers
   beat the tenant wildcard (priority 1).

## Files

| File | Role |
|---|---|
| `stack.yml` | app services + versioned config/secret mounts |
| `local.yml` | dev compose: postgres, redis, minio (+bucket bootstrap) |
| `production.yml` / `staging.yml` | per-env replicas + traefik routes |
| `infrastructure.yml` | traefik, postgres, redis, loki, promtail, grafana |
| `swarm.sh` | VAR_*/SEC_* env → docker configs/secrets |
| `deploy.sh` | pull + migrate-as-job + stack roll + wait |
| `docker.sh` | host bootstrap (docker, swarm init, cluster net) |
| `infra.sh` | deploy the infra stack |

## Scaling

Role-shaped, not instance-shaped — one image, `RUNNER` selects the temper:

```bash
docker service scale {{APP_NAME}}_backend=4    # api workers (octane)
docker service scale {{APP_NAME}}_horizon=2    # queue workers
```

- **Vertical first**: Octane is hot in memory (coroutine I/O) and
  Swarm packs replicas edge to edge — one host does the work of a
  small fleet.
- **Horizontal**: `docker swarm join` a second EC2 — overlay net,
  placement, traefik re-converge. Horizon fits **Spot**: swarm
  reschedules a killed node's replicas.
- **No autoscaler daemon** by design: scale is a command or a
  pipeline line; a small watchdog on queue depth / `docker stats`
  automates it when needed.
- Marketing + media never touch EC2 (S3/CDN), so compute scales
  only with the app.
