<?php

return [
    'defaults' => [
        'guard' => env('AUTH_GUARD', 'web'),
        'passwords' => env('AUTH_PASSWORD_BROKER', 'users'),
    ],

    'guards' => [
        'web' => [
            'driver' => 'session',
            'provider' => 'membership',
        ],
    ],

    // The membership provider caches retrieveById behind the auth
    // tag — abilities and identity resolve without re-querying.
    'providers' => [
        'membership' => [
            'driver' => 'membership',
            'model' => App\Models\User::class,
        ],
    ],

    'cache' => [
        'enabled' => (bool) env('AUTH_CACHE_ENABLED', true),
        'ttl' => (int) env('AUTH_CACHE_TTL', 300),
    ],

    'passwords' => [
        'users' => [
            'provider' => 'membership',
            'table' => 'password_reset_tokens',
            'expire' => 60,
            'throttle' => 60,
        ],
    ],

    'password_timeout' => env('AUTH_PASSWORD_TIMEOUT', 10800),

    'verification' => [
        'expire' => 60,
    ],
];
