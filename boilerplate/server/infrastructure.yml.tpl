# ============================================================
# infrastructure.yml — the platform under the app stack
# ============================================================
# traefik (TLS via Cloudflare DNS-01) · postgres · redis ·
# loki + promtail (log aggregation) · grafana (dashboards).
# Deployed as its own `infra` stack on the shared cluster
# network; app services talk to postgres/redis by hostname.

services:
  traefik:
    image: traefik:v3
    command:
      - --providers.swarm.endpoint=unix:///var/run/docker.sock
      - --providers.swarm.exposedByDefault=false
      - --providers.file.filename=/etc/traefik/traefik.yml
      - --entryPoints.web.address=:80
      - --entryPoints.web.http.redirections.entryPoint.to=secured
      - --entryPoints.web.http.redirections.entryPoint.scheme=https
      - --entryPoints.secured.address=:443
      - --certificatesResolvers.cloudflare.acme.email={{CONTACT_EMAIL}}
      - --certificatesResolvers.cloudflare.acme.storage=/letsencrypt/acme.json
      - --certificatesResolvers.cloudflare.acme.dnsChallenge.provider=cloudflare
      - --certificatesResolvers.cloudflare.acme.dnsChallenge.resolvers=1.1.1.1:53,8.8.8.8:53
    ports:
      - target: 80
        published: 80
        mode: host
      - target: 443
        published: 443
        mode: host
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./traefik.yml:/etc/traefik/traefik.yml:ro
      - ./storage/traefik/acme.json:/letsencrypt/acme.json
    environment:
      CF_DNS_API_TOKEN: ${CF_DNS_API_TOKEN}
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
    networks:
      - cluster

  postgres:
    image: postgres:18
    environment:
      POSTGRES_USER: ${DB_USERNAME}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: ${DB_DATABASE}
    volumes:
      - ./storage/postgres:/var/lib/postgresql
    deploy:
      mode: replicated
      replicas: 1
    networks:
      - cluster

  redis:
    image: redis:8-alpine
    command: redis-server --requirepass ${REDIS_PASSWORD} --appendonly yes
    volumes:
      - ./storage/redis:/data
    deploy:
      mode: replicated
      replicas: 1
    networks:
      - cluster

  loki:
    image: grafana/loki:latest
    command: -config.file=/etc/loki/local-config.yaml
    volumes:
      - ./loki.yml:/etc/loki/local-config.yaml:ro
      - ./storage/loki:/loki
    deploy:
      mode: replicated
      replicas: 1
    networks:
      - cluster

  promtail:
    image: grafana/promtail:latest
    command: -config.file=/etc/promtail/promtail.yml
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./promtail.yml:/etc/promtail/promtail.yml:ro
    deploy:
      mode: global
    networks:
      - cluster

  grafana:
    image: grafana/grafana:latest
    environment:
      GF_SECURITY_ADMIN_USER: admin
      GF_SECURITY_ADMIN_PASSWORD: ${GF_SECURITY_ADMIN_PASSWORD}
      GF_SERVER_DOMAIN: grafana.{{DOMAIN}}
      GF_INSTALL_PLUGINS: ''
    volumes:
      - ./storage/grafana:/var/lib/grafana
    deploy:
      mode: replicated
      replicas: 1
      labels:
        traefik.enable: "true"
        traefik.http.routers.grafana.service: grafana
        traefik.http.routers.grafana.entrypoints: secured
        traefik.http.routers.grafana.rule: Host(`grafana.{{DOMAIN}}`)
        traefik.http.routers.grafana.tls: "true"
        traefik.http.routers.grafana.tls.certresolver: cloudflare
        traefik.http.services.grafana.loadbalancer.server.port: 3000
    networks:
      - cluster

networks:
  cluster:
    external: true
    name: cluster
