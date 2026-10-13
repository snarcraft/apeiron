<?php

use App\Models\User;
use Illuminate\Support\Facades\Broadcast;

Broadcast::channel('auth.{uuid}', fn (User $user, string $uuid) => (string) $user->uuid === $uuid);
