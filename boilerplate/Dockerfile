# ============================================================
# Multi-stage build — CI builds the artifacts, Docker packages
# them. Three targets, one per app:
#   frontend : Nitro server output on node:alpine  (port 3000)
#   backend  : Laravel on the swoole/octane image   (port 8000)
#   web      : static marketing site on nginx       (port 80)
# ============================================================

FROM node:current-alpine3.22 AS frontend
WORKDIR /app

RUN addgroup -g 1001 nodejs && adduser -S -u 1001 -G nodejs nitro

COPY --chown=nitro:nodejs apps/frontend/.output/server ./

USER nitro
EXPOSE 3000
ENV HOST=0.0.0.0
ENV PORT=3000
ENV NODE_ENV=production

CMD ["node", "index.mjs"]

FROM snarcraft/laravel:php-8.4-swoole-universal AS backend
ARG ASSET_URL=
ENV ASSET_URL=${ASSET_URL}

COPY --chown=docker:docker apps/backend/archive/server/ ./

FROM nginx:alpine AS web
COPY apps/web/nginx.conf /etc/nginx/conf.d/default.conf
COPY apps/web/.server /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
