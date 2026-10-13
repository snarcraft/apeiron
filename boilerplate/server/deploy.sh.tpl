#!/bin/bash
set -euo pipefail

# ============================================================
# deploy.sh — pull images, run migrations as one-off jobs, roll
# the stack, wait for replicas, clean up.
# ============================================================
# Runs ON THE SERVER. One-off tasks run as swarm jobs (never
# docker exec — the entrypoint env and the mounted configs/
# secrets are only visible to service tasks) before the stack
# rolls, so services boot against an up-to-date schema.

export DOCKER_CONTENT_TRUST=0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK_NAME="{{APP_NAME}}"
SERVICES="web backend horizon scheduler frontend reverb"
IMAGES="web backend frontend"

# Map a service to the image repository it runs from — horizon,
# reverb and scheduler are roles of the backend image.
image_repo() {
  case "$1" in
    web) echo "web" ;;
    *) echo "backend" ;;
  esac
}

GH_REGISTRY="${GH_REGISTRY:-ghcr.io}"
GH_REPOSITORY="${GH_REPOSITORY:-{{GITHUB_REPOSITORY}}}"
GH_BRANCH="${GH_BRANCH:-main}"
GH_TOKEN="${GH_TOKEN:-}"
APP_NAME="${APP_NAME:-{{APP_NAME}}}"
APP_ENV="${APP_ENV:-production}"
APP_VERSION="${APP_VERSION:-1.0.0}"

# ghcr auth for private images
if [ -n "${GH_TOKEN:-}" ]; then
  if echo "$GH_TOKEN" | docker login ghcr.io -u "{{APP_ORG}}" --password-stdin >/dev/null 2>&1; then
    echo "[ok] ghcr.io auth"
  else
    echo "[warn] ghcr login failed - image may already be local"
  fi
else
  echo "[warn] GH_TOKEN not set - skipping ghcr login"
fi

# The deploy workflow races the publish workflows (both trigger on
# main/tag pushes) — wait for the images to exist before pulling.
wait_image() {
  local repo="$1"
  local tag="$2"
  for _ in $(seq 1 60); do
    if docker manifest inspect "${repo}:${tag}" > /dev/null 2>&1; then
      echo "[wait] ${repo}:${tag} is published"
      return 0
    fi
    sleep 15
  done
  echo "[fail] ${repo}:${tag} not published after 15min"
  return 1
}

for image in $IMAGES; do
  wait_image "${GH_REGISTRY}/${GH_REPOSITORY}/${image}" "${GH_BRANCH}" || exit 1
done

echo ""
echo "[deploy] ${STACK_NAME} stack"
for service in $SERVICES; do
  echo "  image:  ${GH_REGISTRY}/${GH_REPOSITORY}/$(image_repo "$service"):${GH_BRANCH} (${service})"
done
echo "  config: ${APP_NAME} ${APP_ENV} v${APP_VERSION}"
echo ""

for image in $IMAGES; do
  IMAGE="${GH_REGISTRY}/${GH_REPOSITORY}/${image}:${GH_BRANCH}"
  echo "[pull] ${IMAGE}"
  docker pull "$IMAGE"
done

# One-off tasks as swarm jobs with the same versioned mounts.
run_task() {
  local task="$1"
  shift
  local image="${GH_REGISTRY}/${GH_REPOSITORY}/backend:${GH_BRANCH}"
  local prefix="${APP_NAME}.${APP_ENV}.${APP_VERSION}."
  local args=""

  for config in $(docker config ls --filter "name=${prefix}" --format "{{.Name}}"); do
    args="${args} --config source=${config},target=/run/configs/${config##*.}"
  done

  for secret in $(docker secret ls --filter "name=${prefix}" --format "{{.Name}}"); do
    args="${args} --secret source=${secret},target=${secret##*.}"
  done

  if ! echo "$args" | grep -q "DB_HOST"; then
    echo "[fail] no ${prefix}DB_HOST object found — sync configs/secrets for this version first"
    exit 1
  fi

  echo "[task] ${task} — ${image}"
  docker service rm "${STACK_NAME}-${task}" >/dev/null 2>&1 || true
  # shellcheck disable=SC2086
  docker service create --name "${STACK_NAME}-${task}" --detach \
    --network cluster --restart-condition=none --with-registry-auth \
    --entrypoint php \
    $args "$image" "$@" >/dev/null

  local state=""
  for _ in $(seq 1 60); do
    state=$(docker service ps "${STACK_NAME}-${task}" --format "{{.CurrentState}}" | head -1)
    case "$state" in
      Complete*|Failed*|Rejected*) break ;;
    esac
    sleep 5
  done

  docker service logs "${STACK_NAME}-${task}" 2>&1 | grep -v "\[entrypoint\]" || true
  docker service rm "${STACK_NAME}-${task}" >/dev/null 2>&1 || true

  if ! echo "$state" | grep -q "Complete"; then
    echo "[fail] ${task} did not complete (${state:-timeout after 300s})"
    exit 1
  fi

  echo "[ok] ${task} applied"
}

run_task migrate artisan migrate --force
run_task inspire artisan inspire

# Swarm cannot change a service's mode in place (global <->
# replicated) — remove any existing global service so deploy
# recreates it as replicated.
for service in $SERVICES; do
  SERVICE="${STACK_NAME}_${service}"
  MODE=$(docker service inspect -f '{{.Spec.Mode.Global}}' "$SERVICE" 2>/dev/null || true)
  if [ -n "$MODE" ] && [ "$MODE" != "<no value>" ]; then
    echo "[recreate] ${SERVICE} is global — removing so deploy can recreate as replicated"
    docker service rm "$SERVICE"
  fi
done

echo "[stack] ${SCRIPT_DIR}/${APP_ENV}.yml"

APP_NAME="$APP_NAME" APP_ENV="$APP_ENV" APP_VERSION="$APP_VERSION" \
GH_REGISTRY="$GH_REGISTRY" GH_REPOSITORY="$GH_REPOSITORY" GH_BRANCH="$GH_BRANCH" \
  docker stack deploy --with-registry-auth -c "${SCRIPT_DIR}/stack.yml" -c "${SCRIPT_DIR}/${APP_ENV}.yml" "$STACK_NAME"

for service in $SERVICES; do
  SERVICE="${STACK_NAME}_${service}"

  echo ""
  echo "[wait] ${SERVICE} replicas..."
  REPLICAS=""
  for _ in $(seq 1 30); do
    REPLICAS=$(docker service ls --filter "name=${SERVICE}" --format "{{.Replicas}}" | head -1)
    RUNNING="${REPLICAS%%/*}"
    DESIRED="${REPLICAS##*/}"
    if [ -n "$DESIRED" ] && [ "$DESIRED" != "0" ] && [ "$RUNNING" = "$DESIRED" ]; then
      break
    fi
    sleep 2
  done

  RUNNING="${REPLICAS:-/}"
  DESIRED="${RUNNING##*/}"
  RUNNING="${RUNNING%%/*}"
  if [ -n "$DESIRED" ] && [ "$DESIRED" != "0" ] && [ "$RUNNING" = "$DESIRED" ]; then
    echo "[ok] ${SERVICE} is running"
    docker service ps "$SERVICE" --format "table {{.Name}}\t{{.CurrentState}}" | head -3
  else
    echo "[fail] ${SERVICE} did not become ready (replicas: ${REPLICAS:-none})"
    docker service ps "$SERVICE" --format "table {{.Name}}\t{{.CurrentState}}\t{{.Error}}" | head -5
    docker service logs --tail 20 "$SERVICE" || true
    exit 1
  fi
done

docker service update --force infra_traefik >/dev/null 2>&1 || echo "[warn] could not force-update infra_traefik"

echo ""
echo "[cleanup] old images"
docker image prune -f >/dev/null 2>&1 || true

for image in $IMAGES; do
  APP_IMAGE="${GH_REGISTRY}/${GH_REPOSITORY}/${image}"
  USED_IMAGE=$(docker inspect --format '{{.Image}}' "$(docker ps -q --filter "ancestor=${APP_IMAGE}" | head -1)" 2>/dev/null || echo "")
  if [ -n "$USED_IMAGE" ]; then
    docker images --format '{{.ID}} {{.Repository}}:{{.Tag}}' \
      | awk -v used="$USED_IMAGE" -v app="${APP_IMAGE}" \
        'index($2, app) == 1 && $1 != used { print $2 }' \
      | xargs -r docker rmi >/dev/null 2>&1 || true
  fi
done
echo "[ok] kept only the images in use"

echo ""
echo "[done] stack deployed: ${STACK_NAME}"
echo ""
echo "services:"
docker service ls --filter "label=com.docker.stack.namespace=${STACK_NAME}" --format "table {{.Name}}\t{{.Image}}\t{{.Replicas}}"
