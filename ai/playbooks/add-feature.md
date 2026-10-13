# Playbook — add a feature end-to-end

A feature is a **single lowercase word** (`task`, `invoice`,
`catalog`) that becomes: an enum case, a permission matrix, API
routes, frontend navigation and gate checks — everywhere at once.

## 1. Backend enum

`apps/backend/app/Enums/Feature.php` — add the case:

```php
case WIDGET = 'widget';
```

## 2. Permission matrix

`apps/backend/app/Enums/Group.php` — grant actions per group/role
in `resolve()`. Deny by default: only list what a role may do.

```php
Role::MANAGER => [
    Feature::WIDGET => [
        Action::INDEX,
        Action::READ,
        Action::CREATE,
        Action::UPDATE,
    ],
],
```

## 3. Model + migration

```bash
php artisan make:model Widget --pest
```

Then edit the migration to the house shape (`stubs/migration.create.stub`):
`id`, `ulid('uuid')->unique()`, columns, `timestamps()`,
`softDeletes()`, `index('created_at')`. Extend `App\Models\Model`
(ULIDs, broadcasting, activity, attachments — all inherited).

## 4. Requests + controllers

- `php artisan make:request Widget/StoreWidgetRequest`
- Invokable controllers in `app/Http/Controllers/Widget/`:
  `IndexController`, `StoreController`, `ShowController`,
  `UpdateController`, `DestroyController` — one verb each.

```php
public function __invoke(Request $request): AnonymousResourceCollection
{
    abort_unless($request->user()->can(Feature::WIDGET, Action::READ), 403, 'You cannot read widgets.');

    return WidgetResource::collection(Widget::latest()->get());
}
```

## 5. Resource

One `WidgetResource` with `@mixin` PHPDoc; dates as
`->toIso8601String()`.

## 6. Routes

`routes/api.php`, inside the authenticated group:

```php
Route::get('widgets', Widget\IndexController::class)->middleware('can:widget:read');
Route::post('widgets', Widget\StoreController::class)->middleware('can:widget:create');
```

## 7. Frontend

- `apps/frontend/app/types/index.d.ts` — extend the `Feature`
  union with `'widget'`.
- `app.config.ts` — navigation entry (icon + `to` + `action`:
  `'read'`) and the policy mirror for the matrix cell.
- `pages/widgets.vue` — list page behind the default layout;
  gate fragments with `<Gate feature="widget" action="create">`.
- Backend lang: add `features.widget` to
  `apps/backend/storage/app/lang/*.json` (or `pnpm lang:extract`).

## 8. Test

`tests/Unit/RbacTest.php` — assert the new matrix cell; one Pest
feature test per endpoint (200 for allowed role, 403 for denied).

## 9. Ship

`feat(backend): widget feature` → `feat(frontend): widget pages`
→ tag → deploy.
