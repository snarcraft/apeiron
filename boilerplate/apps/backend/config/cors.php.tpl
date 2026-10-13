<?php

return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],

    'allowed_methods' => ['*'],

    'allowed_origins' => array_filter([
        env('FRONTEND_URL', 'http://localhost:3000'),
        env('WEB_URL', 'http://localhost:3001'),
        env('CORS_ORIGIN'),
        sprintf('#^https://[a-z0-9-]+\\.%s$#', preg_quote(env('APP_DOMAIN', '{{DOMAIN}}'), '#')),
    ]),

    'allowed_origins_patterns' => [],

    'allowed_headers' => ['*'],

    'exposed_headers' => [],

    'max_age' => 0,

    'supports_credentials' => true,
];
