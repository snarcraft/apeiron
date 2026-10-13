<?php

namespace App\Listeners;

use App\Events\SendMailFailed;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\RateLimiter;

class MailFailureListener
{
    public function handle(SendMailFailed $event): void
    {
        $email = $event->notifiable?->routeNotificationFor('mail');

        Log::warning(sprintf('[mail] delivery failed for %s', $email ?? 'unknown'));

        // Keyed throttle so a poisoned address cannot wedge the
        // queue: after 3 failures we stop attempting it for an hour.
        if ($email) {
            RateLimiter::hit(sprintf('mail-fail:%s', $email), 3600);
        }
    }
}
