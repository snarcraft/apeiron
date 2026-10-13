<?php

namespace App\Providers;

use Illuminate\Auth\EloquentUserProvider;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Support\Facades\Cache;

/**
 * The membership auth provider: caches retrieveById behind the
 * `auth` tag (configurable TTL) so every request does not re-hit
 * the database for the session user. UserObserver/User::clearCache
 * invalidate the tag on identity changes.
 */
class CachedUserProvider extends EloquentUserProvider
{
    public function retrieveById($identifier): ?Authenticatable
    {
        if (!$this->shouldCache()) {
            return parent::retrieveById($identifier);
        }

        $key = sprintf('auth:user:%s', $identifier);

        return Cache::tags(['auth'])->remember(
            $key,
            $this->ttl(),
            fn () => parent::retrieveById($identifier),
        );
    }

    private function shouldCache(): bool
    {
        return (bool) config('auth.cache.enabled', false);
    }

    private function ttl(): int
    {
        return (int) config('auth.cache.ttl', 300);
    }
}
