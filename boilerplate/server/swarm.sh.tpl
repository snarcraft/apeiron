#!/bin/bash
set -e

# ============================================================
# swarm.sh — Create Docker Swarm configs/secrets from VAR_/SEC_
# ============================================================
# Runs ON THE SERVER. No GitHub API access: the deploy workflow
# SSH-passes every value as an environment variable:
#   VAR_<NAME> → Swarm config   (non-secret)
#   SEC_<NAME> → Swarm secret
#
# Objects are named ${APP_NAME}.${APP_ENV}.${APP_VERSION}.<NAME>
# and are immutable — existing objects are skipped, rotation =
# bump APP_VERSION then re-run (stack.yml references the same
# versioned names).
#
# Usage (values arrive via environment from CI):
#   VAR_APP_NAME=acme VAR_APP_ENV=production VAR_APP_VERSION=1.0.2 \
#   VAR_APP_URL=https://acme.io SEC_DB_PASSWORD=*** bash swarm.sh

clean() {
  echo "$1" | tr -d '\r'
}

APP_NAME=$(clean "${VAR_APP_NAME:-{{APP_NAME}}}")
APP_ENV=$(clean "${VAR_APP_ENV:-production}")
APP_VERSION=$(clean "${VAR_APP_VERSION:-1.0.0}")

echo "=== Swarm sync for ${APP_NAME} ${APP_ENV} v${APP_VERSION} ==="

label() {
  local name
  name=$(clean "$1")
  echo "${APP_NAME}.${APP_ENV}.${APP_VERSION}.${name}" | sed 's/[^a-zA-Z0-9._-]//g' | sed 's/\.\././g'
}

deploy_item() {
  local type="$1"
  local name="$2"
  local value="$3"
  local docker_name
  docker_name=$(label "$name")

  echo "Processing $type: ${docker_name}"

  if docker "$type" inspect "$docker_name" > /dev/null 2>&1; then
    echo "  ✓ Exists, skipping"
  else
    printf '%s' "$value" | docker "$type" create "$docker_name" -
    echo "  ✓ Created"
  fi
}

if [ "${1:-}" = "--list" ]; then
  echo "📋 Docker secrets for ${APP_NAME} ${APP_ENV} v${APP_VERSION}:"
  docker secret ls --filter name="${APP_NAME}.${APP_ENV}.${APP_VERSION}" --format "table {{.Name}}\t{{.CreatedAt}}"
  echo ""
  echo "📋 Docker configs for ${APP_NAME} ${APP_ENV} v${APP_VERSION}:"
  docker config ls --filter name="${APP_NAME}.${APP_ENV}.${APP_VERSION}" --format "table {{.Name}}\t{{.CreatedAt}}"
  exit 0
fi

echo "--- Provided variables ---"
env | grep '^VAR_' | cut -d= -f1
env | grep '^SEC_' | cut -d= -f1
echo "---------------------------"

echo "--- Configs (VAR_*) ---"
while IFS='=' read -r var_name _; do
  case "$var_name" in
    VAR_*)
      name="${var_name#VAR_}"
      value="${!var_name}"
      if [ -z "$value" ]; then
        echo "  ⚠ Skipping ${name}: empty"
        continue
      fi
      deploy_item config "$name" "$value"
      ;;
  esac
done < <(env | grep '^VAR_' | cut -d= -f1 | sed 's/^/=/' | head -200)

echo "--- Secrets (SEC_*) ---"
while IFS='=' read -r sec_name _; do
  case "$sec_name" in
    SEC_*)
      name="${sec_name#SEC_}"
      value="${!sec_name}"
      if [ -z "$value" ]; then
        echo "  ⚠ Skipping ${name}: empty"
        continue
      fi
      deploy_item secret "$name" "$value"
      ;;
  esac
done < <(env | grep '^SEC_' | cut -d= -f1 | sed 's/^/=/' | head -200)

echo "=== Sync complete for v${APP_VERSION} ==="
