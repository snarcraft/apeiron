<?php

// Local secret overrides — consulted after the Swarm file mounts
// (/run/configs, /run/secrets) and only for variables that are
// still unset. Same contract as laravel/vapor's secrets.php: keep
// it empty in git, fill it for offline work.
//
// return [
//     'STRIPE_SECRET' => 'sk_test_…',
// ];

return [
];
