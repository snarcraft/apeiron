import 'package:freezed_annotation/freezed_annotation.dart';

part 'app.freezed.dart';
part 'app.g.dart';

/// The local bootstrap config — `assets/app.json`, gitignored,
/// linked from `secrets/mobile.json` (exactly like the
/// backend's `.env` → `secrets/local.env`). CI materializes it
/// from the APP_CONFIG secret.
///
/// Everything else is server-driven: once this file points at a
/// backend, `Application` (fetched from `GET /`) takes over —
/// theme, locale, keys.
@freezed
class App with _$App {
  const App._();

  const factory App({
    @JsonKey(name: 'base_url') required String baseUrl,
    @JsonKey(name: 'domain') required String domain,
  }) = _App;

  String get path => 'api/$domain';

  String get url => '$baseUrl/$path';

  factory App.fromJson(Map<String, dynamic> json) => _$AppFromJson(json);
}
