<?php

namespace App\Models\Concerns;

/**
 * Structured activity logging: every saved model writes a JSON
 * line with the acting user and the log context (see
 * TrackLogContext middleware + Logging\ActivityFormatter).
 *
 * @mixin \App\Models\Model
 */
trait LogsActivity
{
    public static function bootLogsActivity(): void
    {
        static::saved(function (self $model): void {
            logger()->channel(config('logging.activity_channel', 'stack'))->info(sprintf(
                '[activity] %s:%s %s by %s',
                $model->getTable(),
                $model->getAttribute('uuid') ?? $model->getKey(),
                $model->wasRecentlyCreated ? 'created' : 'updated',
                auth()->id() ?? 'system',
            ));
        });

        static::deleted(function (self $model): void {
            logger()->channel(config('logging.activity_channel', 'stack'))->info(sprintf(
                '[activity] %s:%s deleted by %s',
                $model->getTable(),
                $model->getAttribute('uuid') ?? $model->getKey(),
                auth()->id() ?? 'system',
            ));
        });
    }
}
