# Playbook — the RBAC model

**Zero-database permissions.** The entire authorization layer is
four string enums + one gate. If you are adding a roles table,
stop.

## The four enums

| Enum | Meaning | Values |
|---|---|---|
| `Group` | tenant kind — who the team *is* | operator, client, … |
| `Role` | job inside the team | admin, manager, member, … |
| `Feature` | single-word capability | task, invoice, … |
| `Action` | verb on a feature | index, read, create, update, delete, manage |

`operator + admin` is the platform superuser — `Gate::before`
returns true before any matrix lookup.

## Resolution chain

```
request ─► can:widget:read (route middleware)
              │
              ▼
       Gate::before ─ admin? ─► allow
              │
              ▼
       Pennant flag "widget:read" (cached per user)
              │  defined as $user->may($feature, $action)
              ▼
       Group::resolve($user->role)[feature] ─► in_array(action)
```

Membership is virtual: `group`/`role` resolve from
`members → teams` (the `Contractual` concern), never columns on
users. Identity caches (auth tag + Pennant) flush on any
membership/team/user mutation — observers handle it; call
`$user->clearCache()` if you mutate manually.

## Changing the matrix

1. Edit `Group::resolve()` — the match arms are the source of truth.
2. Mirror the change in `apps/frontend/app/app.config.ts`
   (`policies`) so the UI gates match.
3. Extend `tests/Unit/RbacTest.php` — the test is the spec.
4. `php artisan auth:clear-cache` (or wait for the observer).

## Frontend mirror

`useAuth().can('widget', 'create')` reads
`user.policies['widget:create']` — the policy map rides on the
UserResource payload. `<Gate>` wraps fragments declaratively.

## Never

- permission tables, seeders or caches in the DB
- multi-word features (`task_management`)
- `$user->can('widget')` without an action — abilities are always
  `feature:action`
- trusting client-side gates alone — the API always re-checks
