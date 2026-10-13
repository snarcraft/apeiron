<?php

namespace App\Models\Concerns;

use Illuminate\Support\Str;

/**
 * ULID primary keys: sortable, url-safe, no enumeration leaks.
 * Route binding keys on `uuid` (the ulid column) for consistency
 * with the rest of the API surface.
 *
 * @mixin \App\Models\Model
 */
trait InteractsWithUuid
{
    public function getRouteKeyName(): string
    {
        return 'uuid';
    }

    public static function findByUuid(string $uuid): ?static
    {
        return static::where('uuid', $uuid)->first();
    }

    protected static function bootInteractsWithUuid(): void
    {
        static::creating(function (self $model): void {
            if (!$model->getAttribute('uuid')) {
                $model->setAttribute('uuid', (string) Str::ulid());
            }
        });

        static::replicating(function (self $model): void {
            $model->setAttribute('uuid', null);
        });
    }
}
