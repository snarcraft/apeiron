<?php

namespace App\Notifications;

use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;
use Illuminate\Support\Facades\URL;

class VerifyEmail extends Notification
{
    /**
     * @param \App\Models\User $notifiable
     *
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        $url = URL::temporarySignedRoute(
            'verification.verify',
            now()->addMinutes(config('auth.verification.expire', 60)),
            [
                'user' => $notifiable->uuid,
                'hash' => sha1($notifiable->getEmailForVerification()),
            ],
        );

        return (new MailMessage())
            ->subject(trans('*.mail.verify.subject'))
            ->line(trans('*.mail.verify.line'))
            ->action(trans('*.mail.verify.action'), $url);
    }
}
