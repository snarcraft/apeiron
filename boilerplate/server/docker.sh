#!/bin/bash
set -euo pipefail

# ============================================================
# docker.sh — one-time host bootstrap (idempotent)
# ============================================================
# Installs Docker, initializes the Swarm manager, creates the
# shared `cluster` network, prepares ACME storage. Runs with
# sudo from the infrastructure workflow.

if ! command -v docker > /dev/null 2>&1; then
  echo "[docker] installing"
  curl -fsSL https://get.docker.com | sh
else
  echo "[docker] already installed"
fi

if ! docker info > /dev/null 2>&1; then
  echo "[docker] waiting for daemon"
  sleep 5
fi

if ! docker node ls > /dev/null 2>&1; then
  echo "[swarm] initializing manager"
  docker swarm init --advertise-addr "$(hostname -I | awk '{print $1}')" || true
else
  echo "[swarm] already initialized"
fi

if ! docker network inspect cluster > /dev/null 2>&1; then
  echo "[network] creating overlay 'cluster'"
  docker network create --driver overlay --attachable cluster
else
  echo "[network] cluster exists"
fi

mkdir -p storage/traefik
if [ ! -f storage/traefik/acme.json ]; then
  echo '{}' > storage/traefik/acme.json
fi
chmod 600 storage/traefik/acme.json

echo "[docker] prune timers"
cat > /etc/cron.d/docker-prune <<'EOF'
0 4 * * * root docker system prune -f --volumes 2>/dev/null
EOF

echo "[ok] host ready"
