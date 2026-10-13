#!/bin/bash
set -euo pipefail

# ============================================================
# infra.sh — deploy the infrastructure stack (runs in the docker
# group): traefik, postgres, redis, loki, promtail, grafana.
# ============================================================
# The app stack (stack.yml) attaches to the same `cluster`
# network. Data lives under ./storage.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK_NAME="infra"

if ! docker node ls > /dev/null 2>&1; then
  echo "[fail] not a swarm manager — run docker.sh first"
  exit 1
fi

mkdir -p storage/postgres storage/redis storage/grafana storage/loki

echo "[infra] deploying ${STACK_NAME} stack"
docker stack deploy -c "${SCRIPT_DIR}/infrastructure.yml" "$STACK_NAME"

for service in ${STACK_NAME}_traefik ${STACK_NAME}_postgres ${STACK_NAME}_redis; do
  echo "[wait] ${service}..."
  for _ in $(seq 1 30); do
    REPLICAS=$(docker service ls --filter "name=${service}" --format "{{.Replicas}}" | head -1)
    RUNNING="${REPLICAS%%/*}"
    DESIRED="${REPLICAS##*/}"
    if [ -n "$DESIRED" ] && [ "$DESIRED" != "0" ] && [ "$RUNNING" = "$DESIRED" ]; then
      echo "[ok] ${service} is running"
      break
    fi
    sleep 2
  done
done

# autoscaler — traefik rps -> service scale (systemd unit)
if command -v systemctl > /dev/null 2>&1; then
  if sudo install -m 0755 "${SCRIPT_DIR}/autoscale.sh" /usr/local/bin/apeiron-autoscale 2>/dev/null; then
    sudo mkdir -p /etc/apeiron
    sudo tee /etc/systemd/system/apeiron-autoscale.service > /dev/null <<'UNIT'
[Unit]
Description=apeiron swarm autoscaler (traefik rps -> service scale)
After=docker.service
Wants=docker.service

[Service]
ExecStart=/usr/local/bin/apeiron-autoscale
EnvironmentFile=-/etc/apeiron/autoscale.env
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
UNIT
    sudo systemctl daemon-reload
    sudo systemctl enable --now apeiron-autoscale
    echo "[ok] autoscaler enabled — tune /etc/apeiron/autoscale.env"
  else
    echo "[warn] no sudo for systemd — autoscaler not installed"
  fi
fi

echo "[done] infrastructure up — grafana on http://$(hostname -I | awk '{print $1}'):3001"
