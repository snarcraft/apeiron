#!/bin/sh

# Swarm mounts configs and secrets as files; the apps read
# environment variables. Load each file into the environment,
# then hand off to the real command.

set -eu

for config in /run/configs/*; do
  [ -e "$config" ] || continue
  export "$(basename "$config")=$(cat "$config")"
  echo "[entrypoint] loaded config $(basename "$config")" >&2
done

for secret in /run/secrets/*; do
  [ -e "$secret" ] || continue
  export "$(basename "$secret")=$(cat "$secret")"
  echo "[entrypoint] loaded secret $(basename "$secret")" >&2
done

exec "$@"
