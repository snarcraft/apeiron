providers:
  swarm:
    endpoint: unix:///var/run/docker.sock
    exposedByDefault: false

entryPoints:
  web:
    address: :80
    http:
      redirections:
        entryPoint:
          to: secured
          scheme: https
          permanent: true
  secured:
    address: :443

certificatesResolvers:
  cloudflare:
    acme:
      email: {{CONTACT_EMAIL}}
      storage: /letsencrypt/acme.json
      dnsChallenge:
        provider: cloudflare
