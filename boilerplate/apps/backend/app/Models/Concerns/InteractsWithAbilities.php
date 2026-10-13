<?php

namespace App\Models\Concerns;

use App\Enums\Action;
use App\Enums\Feature;
use App\Enums\Group;
use App\Enums\Role;

/**
 * The ability surface: `$user->can(Feature::TASK, Action::READ)` or
 * `$user->can('task:read')`. Permissions resolve from the enum
 * matrix — never the database.
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

    public function can($abilities, $arguments = []): bool
    {
        if ($abilities instanceof Feature && $arguments instanceof Action) {
            return $this->permits($abilities, $arguments);
        }

        if (is_string($abilities) && str_contains($abilities, ':')) {
            [$feature, $action] = explode(':', $abilities, 2);

            if (null !== Feature::tryFrom($feature) && null !== Action::tryFrom($action)) {
                return $this->permits(Feature::from($feature), Action::from($action));
            }
        }

        return parent::can($abilities, $arguments);
    }

    private function permits(Feature $feature, Action $action): bool
    {
        if ($this->isAdmin()) {
            return true;
        }

        return in_array($action, $this->actions($feature));
    }
}
