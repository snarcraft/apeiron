# Mobile conventions — apps/mobile

Flutter · injectable DI · Cubits · auto_route · freezed codegen ·
server-driven theme. 100% compatible with the platform backend:
Sanctum tokens, `{ data }` envelope, 422 validation shape, and the
`GET /` Application document (identity, locale, theme, keys).

## Architecture (Laravel in Dart)

```
lib/
├── main.dart            handle(Environment) — shared bootstrap
├── debug/release.dart   entrypoints per injectable environment
├── injection.dart       getIt + @InjectableInit
├── app.dart             AppWidget — MaterialApp.router
├── router.dart          @AutoRouterConfig → router.gr.dart
├── config/              freezed models: app.json + server Application
├── providers/           @module RegisterModule + ServiceProviders
├── domain/core/         the kernel: Input, Failure, Success
├── domain/<feature>/    facades + models (pure — no Flutter/DI)
├── repositories/        facade impls: dio → Either<Failure, T>
├── services/            contracts, config, dio interceptors
├── guards/              AuthGuard / GuestGuard (DI singletons)
├── store/               cubits — watcher/ form/ action/ per feature
├── views/               @RoutePage screens (+ AutoRouteWrapper)
└── widgets/             generic reusable primitives
```

## House rules

- **Bootstrap order is sacred**: `configureInjection` (loads
  `assets/app.json`, fetches the Application document @preResolve)
  → `registerProviders()` (register, then boot) → `runApp`.
- **Config is two-stage**: gitignored `assets/app.json` (linked
  from `secrets/mobile.json`, materialized from the
  `APP_CONFIG` secret in CI) points at a backend; everything else
  arrives from `GET /`. No `--dart-define`, no flavors.
- **Theme is server-driven**: colors/font from the Application
  document — the same palette that drives web and webapp. Never
  hardcode colors; `Theme.of(context)` only.
- **DI**: `@injectable`/`@lazySingleton` on owned classes,
  `@module RegisterModule` for third-party factories, `@Named`
  Dio clients, `@LazySingleton(as: Facade)` for bindings.
- **State**: Cubits + freezed sealed states. Global cubits in
  `store/register.dart`; feature cubits via `AutoRouteWrapper`.
  watcher = streams, form = Input fields, action = mutations.
- **Results**: `Either<Failure<T>, T>` out of repositories —
  dartz everywhere, never throw across layers.
- **Models**: freezed + json_serializable, snake_case JSON via
  `@JsonKey`, computed getters in a private constructor + `X`
  extensions.
- **Generated files are gitignored** (`*.freezed.dart`, `*.g.dart`,
  `*.gr.dart`, `*.config.dart`) — `make codegen` regenerates.
- **Screens**: `@RoutePage()`, register in `router.dart`, gate
  with guards. Widgets: `const` constructors aggressively,
  `super.key`, trailing commas (dart format owns layout).

## Commands

```bash
cd apps/mobile
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run -t lib/debug.dart          # or `make mobile`
flutter analyze
flutter test
```

## Adding a feature module

Copy the kernel rhythm: `domain/<feature>/` (facade + freezed
model) → `repositories/<feature>_repository.dart`
(`@LazySingleton(as: <Feature>Facade)`) → `store/<feature>/`
(watcher or form cubit) → `views/<feature>/` screen +
router entry. Gate UI with `user.can('<feature>', '<action>')` —
the policy map rides on the User payload, same as the webapp.

## Release

Tags publish themselves: the `mobile` workflow signs the AAB/IPA
in CI and uploads to Google Play (internal track) and TestFlight.
Never build a store artifact locally — push a tag instead.
