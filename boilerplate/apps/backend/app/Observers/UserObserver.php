<?php

namespace App\Observers;

use App\Models\User;

class UserObserver
{
    public function updated(User $user): void
    {
        // Email changes force re-verification and flush the
        // identity-derived caches (abilities, auth tag).
        if ($user->wasChanged('email')) {
            queueable(function () use ($user) {
                $user->forceFill(['email_verified_at' => null])->save();
                $user->sendEmailVerificationNotification();
            })->delay(now()->addMinutes(2))->dispatch();
        }

        $user->clearCache();
    }
}
