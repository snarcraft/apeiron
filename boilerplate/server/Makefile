# server/Makefile — host-side helpers (run on the EC2 host)
.PHONY: up down logs ps

up:
	docker stack deploy -c infrastructure.yml infra

down:
	docker stack rm infra

services:
	docker stack services infra

logs:
	docker service logs -f infra_traefik
