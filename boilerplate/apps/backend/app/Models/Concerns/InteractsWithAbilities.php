<?php

namespace App\Models\Concerns;

use App\Enums\Action;
use App\Enums\Feature;
use App\Enums\Group;
use App\Enums\Role;

/**
 * The ability surface: `$user->may(Feature::TASK, Action::READ)`.
 * Permissions resolve from the enum matrix — never the database.
 *
 * @property ?\App\Enums\Group $group
 * @property ?\App\Enums\Role $role
 *
 * @mixin \App\Models\User
 */
trait InteractsWithAbilities
{
    public function isOperator(): bool
    {
        return Group::OPERATOR === $this->group;
    }

    public function isAdmin(): bool
    {
        return $this->isOperator() && Role::ADMIN === $this->role;
    }

    /**
     * @return array<string, array<int, Action>>
     */
    public function abilities()
    {
        if (null === $this->group || null === $this->role) {
            return [];
        }

        return $this->group->resolve($this->role);
    }

    /**
     * @return array<int, Action>
     */
    public function actions(Feature $feature): array
    {
        return $this->abilities()[$feature->value] ?? [];
    }

    public function may(Feature $feature, Action $action): bool
    {
        if ($this->isAdmin()) {
            return true;
        }

        return in_array($action, $this->actions($feature));
    }

    public function can($abilities, $arguments = []): bool
    {
        if (is_string($abilities) && str_contains($abilities, ':')) {
            [$feature, $action] = explode(':', $abilities, 2);

            if (null !== Feature::tryFrom($feature) && null !== Action::tryFrom($action)) {
                return $this->may(Feature::from($feature), Action::from($action));
            }
        }

        return parent::can($abilities, $arguments);
    }
}
