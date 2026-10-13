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
        traefik.http.routers.staging-web.service: web
        traefik.http.routers.staging-web.entrypoints: secured
        traefik.http.routers.staging-web.rule: Host(`staging.{{DOMAIN}}`)
        traefik.http.routers.staging-web.tls: "true"
        traefik.http.routers.staging-web.tls.certresolver: cloudflare
        traefik.http.services.staging-web.loadbalancer.server.port: 80

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
        traefik.http.routers.staging-frontend.service: frontend
        traefik.http.routers.staging-frontend.entrypoints: secured
        traefik.http.routers.staging-frontend.rule: HostRegexp(`^[a-z0-9-]+\\.staging\\.{{DOMAIN}}$$`)
        traefik.http.routers.staging-frontend.priority: "1"
        traefik.http.routers.staging-frontend.tls: "true"
        traefik.http.routers.staging-frontend.tls.certresolver: cloudflare
        traefik.http.routers.staging-frontend.tls.domains[0].main: staging.{{DOMAIN}}
        traefik.http.routers.staging-frontend.tls.domains[0].sans: "*.staging.{{DOMAIN}}"
        traefik.http.services.staging-frontend.loadbalancer.server.port: 3000

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
        traefik.http.routers.staging-reverb.service: reverb
        traefik.http.routers.staging-reverb.entrypoints: secured
        traefik.http.routers.staging-reverb.rule: Host(`socket.staging.{{DOMAIN}}`)
        traefik.http.routers.staging-reverb.tls: "true"
        traefik.http.routers.staging-reverb.tls.certresolver: cloudflare
        traefik.http.services.staging-reverb.loadbalancer.server.port: 8080


networks:
  default:
    name: cluster
    external: true
