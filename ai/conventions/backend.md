# Backend conventions — apps/backend

Laravel 13 · PHP 8.4 · Octane (Swoole) · Pest · Sanctum · Pennant.

## Architecture

```
app/
├── Enums/          Role, Group, Feature, Action + Plan, Interval, …
├── Http/
│   ├── Controllers/   flat for platform, <Feature>/ per verb (invokable)
│   ├── Middleware/    DetectDevice, DetectSubdomain, Localization, Track*
│   ├── Requests/      FormRequest base + <Feature>/<Verb>Request
│   └── Resources/     one per model, @mixin PHPDoc
├── Models/         Model base + Concerns (traits carry behavior)
├── Observers/      cache invalidation & derived reactions
├── Providers/      AppServiceProvider (the wiring), CachedUserProvider
└── Runtime/        Secrets (swarm files → env)
```

## House rules

- **Invokable controllers per verb**: `Task/IndexController`,
  `Task/StoreController` — `__invoke` only, feature folders.
- **Authorization**: `abort_unless($request->user()->may(Feature::TASK,
  Action::CREATE), 403, '…')` in the controller, or
  `->middleware('can:task:create')` on the route. Both are fine;
  pick per controller and stay consistent within it.
- **Responses**: API Resources for models, `response()->noContent()`
  for empties. The envelope is always `{ "data": … }`.
- **Validation** lives in `App\Http\Requests\<Feature>\*Request`,
  never inline in controllers. Normalize in `prepareForValidation()`
  (lowercase emails, slug subdomains).
- **No `$fillable`** — models are globally unguarded; FormRequests
  are the guard. `Model::shouldBeStrict()` covers non-production.
- **Enums carry logic**: matrix (`Group::resolve()`), pricing,
  labels (`trans('*.roles.%s')`). Match expressions with
  `default => []` — deny by default.
- **Octane discipline**: no request state in singletons; per-request
  services bind `$app->scoped()`.
- **Caching**: identity caches live behind the `auth` tag; any
  identity mutation calls `$user->clearCache()`. Pennant values
  purge with it.
- **Queues**: queued closures via `queueable()` for small cleanup,
  real classes in `app/Listeners` for domain reactions.

## Migrations

House shape — copy `stubs/migration.create.stub`:

```php
$table->id();
$table->ulid('uuid')->unique();
// … columns, foreignIdFor + constrained for relations
$table->timestamps();
$table->softDeletes();
$table->index('created_at');
```

## Testing

- Pest. `php artisan make:test --pest {Name}`.
- Narrowest run: `php artisan test --compact --filter=testName`.
- Factories with states (`UserFactory::member($team, $role)`) —
  never construct users by hand in tests.
- Assert the matrix in `tests/Unit/RbacTest.php` when permissions
  change — that file is the spec.

## Commands

```bash
cd apps/backend
composer run format     # php-cs-fixer — the source of style truth
composer run test       # pest
php artisan octane:start --watch   # dev server (or `make backend`)
```
