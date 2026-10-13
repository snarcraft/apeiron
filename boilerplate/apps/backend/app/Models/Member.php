<?php

namespace App\Models;

use App\Enums\Role;
use App\Observers\MemberObserver;
use Illuminate\Database\Eloquent\Attributes\ObservedBy;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Pivot;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[ObservedBy(MemberObserver::class)]
class Member extends Pivot
{
    use HasFactory;

    public $timestamps = true;

    protected $table = 'members';

    protected function casts(): array
    {
        return [
            'role' => Role::class,
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function team(): BelongsTo
    {
        return $this->belongsTo(Team::class);
    }
}
