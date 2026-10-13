#!/bin/bash
set -euo pipefail

# ============================================================
# autoscale.sh — rps-driven swarm scaler (systemd service)
# ============================================================
# Watches traefik's prometheus metrics and scales the app's
# `_backend` service on requests-per-second: replicas rise the
# moment traffic does, and step back down only after DOWN_GRACE
# calm windows (no flapping). The app stack is autodetected.
# Every knob can arrive via /etc/apeiron/autoscale.env through
# the unit's EnvironmentFile. Horizon scales separately on
# queue depth — see ai/conventions/infra.md.

METRICS_URL="${METRICS_URL:-http://127.0.0.1:8082/metrics}"
INTERVAL="${INTERVAL:-15}"
MIN_REPLICAS="${MIN_REPLICAS:-2}"
MAX_REPLICAS="${MAX_REPLICAS:-8}"
RPS_PER_REPLICA="${RPS_PER_REPLICA:-400}"
DOWN_GRACE="${DOWN_GRACE:-3}"

prev_total=0
prev_ts=0
calm=0

log() { echo "[scale] $(date -u +%H:%M:%S) $*"; }

fetch_total() { # $1 = service -> summed requests_total
  curl -fsS --max-time 5 "$METRICS_URL" | awk -v svc="$1" '
    /^traefik_service_requests_total\{/ && $0 ~ ("service=\"" svc "\"") { sum += $NF }
    END { printf "%.0f\n", sum + 0 }'
}

desired_of() { docker service ls --filter "name=$1" --format '{{.Replicas}}' | head -1 | cut -d/ -f2; }

log "watching ${METRICS_URL} — min=${MIN_REPLICAS} max=${MAX_REPLICAS} target=${RPS_PER_REPLICA} rps/replica"

while true; do
  sleep "$INTERVAL"

  SVC="$(docker service ls --format '{{.Name}}' | grep -E '_backend$' | head -n1 || true)"
  if [ -z "$SVC" ]; then
    continue
  fi

  TOTAL="$(fetch_total "$SVC" || echo 0)"
  NOW=$(date +%s)
  if [ "$NOW" -le "$prev_ts" ]; then
    continue
  fi
  DT=$((NOW - prev_ts))

  if [ "$prev_ts" -eq 0 ] || [ "$TOTAL" -lt "$prev_total" ]; then
    # first sample, or traefik restarted (counter reset)
    prev_total=$TOTAL
    prev_ts=$NOW
    continue
  fi

  RPS=$(( (TOTAL - prev_total) / DT ))
  prev_total=$TOTAL
  prev_ts=$NOW

  CURRENT="$(desired_of "$SVC")"
  if [ -z "$CURRENT" ]; then
    continue
  fi

  NEED=$(( (RPS + RPS_PER_REPLICA - 1) / RPS_PER_REPLICA ))
  if [ "$NEED" -lt "$MIN_REPLICAS" ]; then NEED=$MIN_REPLICAS; fi
  if [ "$NEED" -gt "$MAX_REPLICAS" ]; then NEED=$MAX_REPLICAS; fi

  if [ "$NEED" -gt "$CURRENT" ]; then
    calm=0
    log "${SVC} rps=${RPS} -> ${NEED} replicas"
    docker service scale "$SVC=$NEED" > /dev/null
  elif [ "$NEED" -lt "$CURRENT" ]; then
    calm=$((calm + 1))
    if [ "$calm" -ge "$DOWN_GRACE" ]; then
      log "${SVC} rps=${RPS} calm x${calm} -> ${NEED} replicas"
      docker service scale "$SVC=$NEED" > /dev/null
      calm=0
    else
      log "${SVC} rps=${RPS} calm x${calm}/${DOWN_GRACE} (holding ${CURRENT})"
    fi
  else
    calm=0
  fi
done
