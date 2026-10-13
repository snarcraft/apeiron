<?php

namespace App\Notifications;

use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class ResetPassword extends Notification
{
    public function __construct(public string $token)
    {
    }

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
        $url = sprintf(
            '%s/password/reset/%s?email=%s',
            config('app.frontend_url'),
            $this->token,
            $notifiable->getEmailForPasswordReset(),
        );

        return (new MailMessage())
            ->subject(trans('*.mail.reset.subject'))
            ->line(trans('*.mail.reset.line'))
            ->action(trans('*.mail.reset.action'), $url)
            ->line(trans('*.mail.reset.expiry', ['count' => config('auth.passwords.'.config('auth.defaults.passwords').'.expire')]));
    }
}
