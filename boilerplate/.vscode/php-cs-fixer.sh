#!/bin/bash

# Wrapper so php-cs-fixer resolves the backend composer context.
set -euo pipefail

cd "$(dirname "$0")/../apps/backend"
unset PHP_CS_FIXER_IGNORE_ENV
exec ./vendor/bin/php-cs-fixer "$@"
