<?php

namespace App\Models;

use App\Models\Concerns\Attachable;
use App\Models\Concerns\InteractsWithUuid;
use App\Models\Concerns\LogsActivity;
use Illuminate\Database\Eloquent\BroadcastsEvents;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model as BaseModel;
use Illuminate\Database\Eloquent\SoftDeletes;

abstract class Model extends BaseModel
{
    use Attachable;
    use BroadcastsEvents;
    use HasFactory;
    use InteractsWithUuid;
    use LogsActivity;
    use SoftDeletes;

    /**
     * @return array<int, \Illuminate\Broadcasting\Channel>
     */
    public function broadcastOn(string $event): array
    {
        return [
            new \Illuminate\Broadcasting\PrivateChannel(sprintf('%s.%s', $this->getTable(), $this->getAttribute('uuid') ?? $this->getKey())),
        ];
    }
}
