<?php

namespace App\Models;

use App\Enums\Role;

class Invitation extends Model
{
    protected $table = 'invitations';

    protected function casts(): array
    {
        return [
            'role' => Role::class,
        ];
    }

    public function team()
    {
        return $this->belongsTo(Team::class);
    }
}
