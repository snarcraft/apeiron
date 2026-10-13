<?php

namespace App\Events;

use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class SendMailFailed
{
    use Dispatchable;
    use SerializesModels;

    public function __construct(public ?object $notifiable)
    {
    }
}
