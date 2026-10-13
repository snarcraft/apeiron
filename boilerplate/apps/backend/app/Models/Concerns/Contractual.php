<?php

namespace App\Models\Concerns;

/**
 * Team membership is virtual: `group` and `role` are exposed as
 * enum-casted attributes resolved from the active membership
 * (members → teams). No group/role columns exist on users.
 *
 * @property ?\App\Enums\Group $group
 * @property ?\App\Enums\Role $role
 * @property ?int $team_id
 *
 * @mixin \App\Models\User
 */
trait Contractual
{
    public function teams()
    {
        return $this->belongsToMany(\App\Models\Team::class, 'members')
            ->using(\App\Models\Member::class)
            ->withPivot('role')
            ->withTimestamps();
    }

    public function activeTeam()
    {
        return $this->hasOneThrough(
            \App\Models\Team::class,
            \App\Models\Member::class,
            'user_id',
            'id',
            'id',
            'team_id',
        );
    }

    public function memberships()
    {
        return $this->hasMany(\App\Models\Member::class);
    }

    /**
     * The current (first active) membership's role.
     */
    public function getRoleAttribute(): ?\App\Enums\Role
    {
        return $this->memberships()
            ->latest('id')
            ->first()
            ?->role;
    }

    /**
     * The current team's group — the tenant the user acts inside.
     */
    public function getGroupAttribute(): ?\App\Enums\Group
    {
        return $this->activeTeam()->first()?->group;
    }
}
