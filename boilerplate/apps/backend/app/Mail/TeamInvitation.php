<?php

namespace App\Mail;

use App\Models\Invitation;
use App\Models\Team;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class TeamInvitation extends Mailable
{
    use Queueable;
    use SerializesModels;

    public function __construct(public Team $team, public Invitation $invitation)
    {
    }

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: sprintf('You have been invited to join %s', $this->team->name),
        );
    }

    public function content(): Content
    {
        return new Content(
            markdown: 'mail.team-invitation',
            with: [
                'acceptUrl' => sprintf(
                    '%s/invitations/%s?email=%s',
                    config('app.frontend_url'),
                    $this->invitation->uuid,
                    $this->invitation->email,
                ),
            ],
        );
    }
}
