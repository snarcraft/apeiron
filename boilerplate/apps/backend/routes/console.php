<?php

use App\Models\Setting;
use App\Models\Team;
use App\Models\User;
use Illuminate\Support\Facades\Artisan;

/*
 * Inspire — idempotent demo seeding, run by deploy.sh as a
 * one-off swarm job right after migrations.
 */
Artisan::command('inspire', function (): void {
    if (!app()->environment('production')) {
        $this->components->info('Seeding demo personas…');

        $this->call(\Database\Seeders\DatabaseSeeder::class);
    }

    $this->components->info(sprintf(
        '%s v%s — %d users, %d teams, %d settings.',
        config('app.name'),
        config('app.version'),
        User::count(),
        Team::count(),
        Setting::count(),
    ));
})->purpose('Seed demo data and print platform stats');
