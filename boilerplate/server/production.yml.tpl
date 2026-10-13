services:
  web:
    deploy:
      mode: replicated
      replicas: 1
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
      labels:
        traefik.enable: "true"
        traefik.http.routers.web.service: web
        traefik.http.routers.web.entrypoints: secured
        traefik.http.routers.web.rule: Host(`{{DOMAIN}}`)
        traefik.http.routers.web.tls: "true"
        traefik.http.routers.web.tls.certresolver: cloudflare
        traefik.http.services.web.loadbalancer.server.port: 80

  frontend:
    deploy:
      mode: replicated
      replicas: 1
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
      labels:
        traefik.enable: "true"
        traefik.http.routers.frontend.service: frontend
        traefik.http.routers.frontend.entrypoints: secured
        traefik.http.routers.frontend.rule: "HostRegexp(`^[a-z0-9-]+\\.{{DOMAIN}}$$`)"
        # Wildcard must lose to exact-host routers (socket.) — traefik
        # defaults priority to rule length, and this regexp is the longest.
        traefik.http.routers.frontend.priority: "1"
        traefik.http.routers.frontend.tls: "true"
        traefik.http.routers.frontend.tls.certresolver: cloudflare
        traefik.http.routers.frontend.tls.domains[0].main: {{DOMAIN}}
        traefik.http.routers.frontend.tls.domains[0].sans: "*.{{DOMAIN}}"
        traefik.http.services.frontend.loadbalancer.server.port: 3000

  backend:
    deploy:
      mode: replicated
      replicas: 1
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure

  horizon:
    deploy:
      mode: replicated
      replicas: 1
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure

  scheduler:
    deploy:
      # Singleton — replicated/1, not global: two schedulers would fire every
      # job twice. Swarm reschedules it to another node if this one dies.
      mode: replicated
      replicas: 1
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure

  reverb:
    deploy:
      mode: replicated
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
      labels:
        traefik.enable: "true"
        traefik.http.routers.reverb.service: reverb
        traefik.http.routers.reverb.entrypoints: secured
        traefik.http.routers.reverb.rule: Host(`{{SOCKET_DOMAIN}}`)
        traefik.http.routers.reverb.tls: "true"
        traefik.http.routers.reverb.tls.certresolver: cloudflare
        traefik.http.services.reverb.loadbalancer.server.port: 8080


networks:
  default:
    name: cluster
    external: true
