<?php

namespace App\Observers;

use App\Models\Team;
use Illuminate\Support\Facades\Cache;
use Laravel\Pennant\Feature as Pennant;

class TeamObserver
{
    public function updated(Team $team): void
    {
        // Group or plan changes alter what members may do — flush
        // every identity cache so abilities re-resolve.
        if ($team->wasChanged(['group', 'plan'])) {
            Cache::tags(\App\Models\User::AUTH_CACHE_TAGS)->flush();
            Pennant::purge();
        }
    }
}
