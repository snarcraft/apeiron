<?php

namespace App\Models\Concerns;

use App\Models\Media;
use Illuminate\Database\Eloquent\Relations\MorphMany;
use Illuminate\Support\Facades\Storage;

/**
 * S3 attachments with lifecycle cleanup: deleting the model
 * queues removal of its stored files.
 *
 * @mixin \App\Models\Model
 */
trait Attachable
{
    public function media(): MorphMany
    {
        return $this->morphMany(Media::class, 'mediable');
    }

    public static function bootAttachable(): void
    {
        static::deleted(function (self $model): void {
            queueable(function () use ($model) {
                $model->media()->cursor()->each(function (Media $media): void {
                    Storage::disk($media->disk)->delete($media->path);
                    $media->delete();
                });
            })->delay(now()->addMinutes(5))->dispatch();
        });
    }
}
