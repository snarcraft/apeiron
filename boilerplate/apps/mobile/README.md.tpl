# {{APP_TITLE}} — mobile

Flutter · injectable DI · Cubits · auto_route · server-driven
theme. One palette drives web, webapp and this app — colors and
font arrive from the backend's `GET /` Application document.

## First run

```bash
cd apps/mobile
flutter pub get
flutter pub run build_runner watch --delete-conflicting-outputs   # codegen
flutter create --org {{MOBILE_ORG}} --project-name {{APP_SLUG}} . # platforms (once)
flutter run -t lib/debug.dart
```

## Config

`assets/app.json` (gitignored) points at a backend — linked from
`secrets/mobile.json` locally, materialized from the
`APP_CONFIG` secret in CI:

```json
{ "base_url": "http://localhost:8000", "domain": "{{APP_SLUG}}" }
```

## Commands

| Command | What |
|---|---|
| `make codegen` | build_runner watch |
| `make mobile` | flutter run (debug entrypoint) |
| `flutter pub run flutter_launcher_icons` | brand icons from assets/icon.png |
| `flutter pub run flutter_native_splash:create` | brand splash |
| `flutter test` | widget/unit tests |

## Layout

| Path | Role |
|---|---|
| `lib/config` | freezed config models (app.json + server Application) |
| `lib/providers` | injectable module + Laravel-style ServiceProviders |
| `lib/domain/core` | the kernel: Input, Failure, Success |
| `lib/domain/<feature>` | facades + models per feature |
| `lib/repositories` | facade implementations (dio → Either) |
| `lib/store` | cubits — `watcher/`, `form/`, `action/` per feature |
| `lib/services` | contracts, dio interceptors, config service |
| `lib/views` | @RoutePage screens |
| `lib/widgets` | generic reusable primitives |

Conventions: `ai/conventions/mobile.md`.
