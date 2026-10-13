# Static caching tiers for the prerendered marketing site.
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    gzip on;
    gzip_types text/css application/javascript application/json image/svg+xml;

    add_header X-Content-Type-Options nosniff always;
    add_header X-Frame-Options SAMEORIGIN always;
    add_header Referrer-Policy strict-origin-when-cross-origin always;

    # Contact form proxies to the API container.
    location = /api/contacts {
        proxy_pass http://{{APP_NAME}}_backend:8000/api/contacts;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # HTML never caches.
    location ~ ^/(index\.html)?$ {
        add_header Cache-Control no-cache;
        try_files $uri $uri/ /index.html;
    }

    # Plain-text indexers (robots, sitemap, llms) — 1 day, CORS open.
    location ~* \.(txt|xml|ico)$ {
        add_header Cache-Control public,max-age=86400;
        add_header Access-Control-Allow-Origin *;
        try_files $uri =404;
    }

    # Payloads: short cache.
    location = /_payload.json {
        add_header Cache-Control public,max-age=600;
        try_files $uri =404;
    }

    # Hashed assets: immutable.
    location ~* ^/(_nuxt|_fonts)/ {
        add_header Cache-Control public,max-age=31536000,immutable;
        try_files $uri =404;
    }

    location / {
        try_files $uri $uri/ /index.html;
    }
}
