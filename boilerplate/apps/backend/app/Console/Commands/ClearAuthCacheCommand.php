<?php

namespace App\Console\Commands;

use App\Models\User;
use Illuminate\Console\Command;

class ClearAuthCacheCommand extends Command
{
    protected $signature = 'auth:clear-cache';

    protected $description = 'Flush the auth identity cache tag and purge Pennant feature values';

    public function handle(): int
    {
        cache()->tags(User::AUTH_CACHE_TAGS)->flush();

        \Laravel\Pennant\Feature::purge();

        $this->info('Auth cache flushed.');

        return self::SUCCESS;
    }
}
