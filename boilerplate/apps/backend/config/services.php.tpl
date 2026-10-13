<?php

return [
    // The scaffolded brand fallback — the tenant Setting theme
    // overrides these at runtime (see ApplicationController).
    'theme' => [
        'font' => '{{SOUL_FONT}}',
        'primary' => '{{PRIMARY_500_HEX}}',
        'secondary' => '{{SECONDARY_500_HEX}}',
        'tertiary' => '{{SECONDARY_600_HEX}}',
    ],

    'stripe' => [
        'key' => env('STRIPE_KEY'),
        'secret' => env('STRIPE_SECRET'),
        'webhook_secret' => env('STRIPE_WEBHOOK_SECRET'),
    ],

    'reverb' => [
        'app_id' => env('REVERB_APP_ID'),
        'app_key' => env('REVERB_APP_KEY'),
        'app_secret' => env('REVERB_APP_SECRET'),
        'host' => env('REVERB_HOST'),
        'port' => env('REVERB_PORT', 443),
        'scheme' => env('REVERB_SCHEME', 'https'),
    ],

    'discord' => [
        'user' => env('DISCORD_USER_ID'),
        'webhooks' => [
            'contact' => env('DISCORD_CONTACT_WEBHOOK_URL'),
        ],
    ],
];
