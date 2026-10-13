<?php

namespace App\Runtime;

/**
 * Swarm mounts configs at /run/configs and secrets at
 * /run/secrets; the app reads environment variables. This loads
 * every mounted file into the environment — real environment
 * variables always win — then consults the committed secrets.php
 * for any local overrides (the laravel/vapor contract, kept for
 * offline work).
 */
class Secrets
{
    public static function addToEnvironment(): void
    {
        foreach (['/run/configs', '/run/secrets'] as $dir) {
            if (!is_dir($dir)) {
                continue;
            }

            foreach (scandir($dir) ?: [] as $file) {
                if (str_starts_with($file, '.')) {
                    continue;
                }

                $path = sprintf('%s/%s', $dir, $file);
                $value = trim((string) @file_get_contents($path));

                if ('' === $value) {
                    continue;
                }

                static::set($file, $value);
            }
        }

        $local = require dirname(__DIR__, 2) . '/secrets.php';

        foreach (is_array($local) ? $local : [] as $key => $value) {
            static::set((string) $key, (string) $value);
        }
    }

    private static function set(string $key, string $value): void
    {
        if (!array_key_exists($key, $_ENV) && !array_key_exists($key, $_SERVER) && false === getenv($key)) {
            $_ENV[$key] = $value;
            $_SERVER[$key] = $value;
            putenv(sprintf('%s=%s', $key, $value));
        }
    }
}
