<?php

namespace App\Models;

use App\Enums\Group;
use App\Observers\TeamObserver;
use App\Enums\Plan;
use Illuminate\Database\Eloquent\Attributes\ObservedBy;

#[ObservedBy(TeamObserver::class)]
class Team extends Model
{
    protected $table = 'teams';

    protected function casts(): array
    {
        return [
            'group' => Group::class,
            'plan' => Plan::class,
            'trial_ends_at' => 'datetime',
            'theme' => 'array',
        ];
    }

    public function members()
    {
        return $this->hasMany(Member::class);
    }

    public function users()
    {
        return $this->belongsToMany(User::class, 'members')
            ->using(Member::class)
            ->withPivot('role')
            ->withTimestamps();
    }

    public function invitations()
    {
        return $this->hasMany(Invitation::class);
    }

    public function setting()
    {
        return $this->hasOne(Setting::class);
    }
}
