<?php

return [
    'name' => env('APP_NAME', '{{APP_NAME}}'),
    'version' => env('APP_VERSION', '1.0.0'),
    'env' => env('APP_ENV', 'production'),
    'debug' => (bool) env('APP_DEBUG', false),
    'url' => env('APP_URL', 'http://localhost:8000'),
    'domain' => env('APP_DOMAIN', '{{DOMAIN}}'),
    'frontend_url' => env('FRONTEND_URL', 'http://localhost:3000'),
    'web_url' => env('WEB_URL', 'http://localhost:3001'),
    'timezone' => env('APP_TIMEZONE', 'UTC'),
    'locale' => env('APP_LOCALE', 'en'),
    'fallback_locale' => env('APP_FALLBACK_LOCALE', 'en'),
    'faker_locale' => env('APP_FAKER_LOCALE', 'en_US'),
    'country' => env('APP_COUNTRY', 'FR'),
    'cipher' => 'AES-256-CBC',
    'key' => env('APP_KEY'),
    'previous_keys' => [...array_filter(explode(',', (string) env('APP_PREVIOUS_KEYS', '')))],
    'maintenance' => [
        'driver' => env('APP_MAINTENANCE_DRIVER', 'file'),
        'store' => env('APP_MAINTENANCE_STORE', 'database'),
    ],
];
