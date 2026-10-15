# ============================================================
# Makefile — developer loop
# ============================================================
# Environment is loaded from secrets/$(APP_ENV).env (never
# committed) and exported for every target. `make dev` runs the
# whole platform locally: webapp, API (octane), websockets
# (reverb), queues (horizon) and logs (pail).

APP_ENV ?= local
APP_NAME ?= {{APP_NAME}}
APP_HOST ?= localhost
ENV_FILE := $(PWD)/secrets/$(APP_ENV).env

RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
NC := \033[0m

uppercase = $(shell echo $(1) | tr '[:lower:]' '[:upper:]')

define log
	@printf "[$$(date +%%H:%%M:%%S)] $(APP_ENV).%s %s\n" $(1) "$(2)"
endef

ifneq ($(wildcard $(ENV_FILE)),)
include $(ENV_FILE)
export $(shell sed 's/=.*//' $(ENV_FILE))
endif

.PHONY: dev frontend backend websocket worker logs generate-key deploy test banner services install mobile codegen

banner:
	@printf "$(BLUE)"
	@printf "  ╭──────────────────────────────────────────────────────────╮\n"
	@printf "  │  $(APP_NAME) — local platform                              │\n"
	@printf "  ├──────────────────────────────────────────────────────────┤\n"
	@printf "  │  webapp    http://app.$(APP_NAME).localhost:3000        │\n"
	@printf "  │  tenants    http://<tenant>.$(APP_NAME).localhost:3000  │\n"
	@printf "  │  website   http://localhost:3001                        │\n"
	@printf "  │  api       http://localhost:8000                        │\n"
	@printf "  ╰──────────────────────────────────────────────────────────╯\n"
	@printf "$(NC)"

services:
	$(call log,info,starting local services (postgres redis minio))
	@command -v docker >/dev/null 2>&1 || { printf "$(RED)✖ docker not found — install it first: https://docs.docker.com$(NC)\n"; exit 1; }
	@docker compose version >/dev/null 2>&1 || { printf "$(RED)✖ docker compose not found — install the compose plugin$(NC)\n"; exit 1; }
	cd server && docker compose -f local.yml up -d

install:
	$(call log,info,install — services, dependencies, migrations, mobile)
	$(MAKE) services
	pnpm install
	cd apps/backend && composer install --no-interaction --prefer-dist
	cd apps/backend && php artisan migrate --seed
	@if [ -d apps/mobile ] && command -v flutter >/dev/null 2>&1; then \
		printf "$(BLUE)…$(NC) mobile: pub get, platform folders, codegen\n"; \
		cd apps/mobile && flutter pub get \
		&& flutter create --org {{MOBILE_ORG}} --project-name {{APP_NAME}} . >/dev/null \
		&& flutter pub run build_runner build --delete-conflicting-outputs; \
	elif [ -d apps/mobile ]; then \
		printf "$(YELLOW)⚠$(NC) flutter not found — mobile skipped (install flutter, re-run make install)\n"; \
	fi
	$(call log,info,done — make dev when ready)

dev: banner
	$(call log,info,starting everything)
	@npx concurrently -k -s first \
		-n "frontend,backend,websocket,worker,logs" \
		-c "blue,green,yellow,magenta,cyan" \
		"make frontend" "make backend" "make websocket" "make worker" "make logs"

frontend:
	$(call log,info,starting webapp (nuxt))
	pnpm --filter "@$(APP_NAME)/frontend" dev --host $(APP_HOST)

backend:
	$(call log,info,starting api (octane))
	php apps/backend/artisan octane:start --watch --host $(APP_HOST)

websocket:
	$(call log,info,starting websockets (reverb))
	php apps/backend/artisan reverb:start --debug

worker:
	$(call log,info,starting queues (horizon))
	php apps/backend/artisan horizon

logs:
	$(call log,info,tailing application logs)
	php apps/backend/artisan pail --timeout=0

web:
	$(call log,info,starting website (nuxt))
	pnpm --filter "@$(APP_NAME)/web" dev --host $(APP_HOST)

generate-key:
	$(call log,info,generating APP_KEY)
	@sed -i '' 's|^APP_KEY=.*|APP_KEY=base64:$$(openssl rand -base64 32)|' $(ENV_FILE)
	@echo "$(GREEN)✓$(NC) APP_KEY rotated in secrets/$(APP_ENV).env"

mobile:
	$(call log,info,starting mobile app (flutter debug))
	cd apps/mobile && flutter run -t lib/debug.dart

codegen:
	$(call log,info,flutter codegen (build_runner watch))
	cd apps/mobile && flutter pub run build_runner watch --delete-conflicting-outputs

test:
	$(call log,info,running backend tests)
	cd apps/backend && ./vendor/bin/pest

deploy:
	$(call log,warn,deploys run from GitHub Actions — see .github/workflows/deploy.yml)
