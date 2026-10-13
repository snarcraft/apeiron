import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

import 'theme.dart';

part 'application.freezed.dart';
part 'application.g.dart';

/// The server-driven application document — fetched from `GET /`
/// during DI bootstrap (@preResolve). Swapping the backend swaps
/// the whole app identity: theme, locale, keys.
@freezed
class Application with _$Application {
  const Application._();

  const factory Application({
    required String name,
    required String version,
    @JsonKey(name: 'env') required String environment,
    @JsonKey(name: 'timezone') required String timeZone,
    @JsonKey(name: 'language') required String language,
    @JsonKey(name: 'country') required String country,
    @JsonKey(name: 'frontend_url') required String frontendUrl,
    @JsonKey(name: 'web_url') required String webUrl,
    required Theme theme,
    Reverb? reverb,
    Stripe? stripe,
    @Default([]) List<String> locales,
  }) = _Application;

  Locale get locale => Locale(language, country);

  String get formattedLocale => Intl.canonicalizedLocale(
        Intl.defaultLocale ?? locale.toString(),
      );

  factory Application.fromJson(Map<String, dynamic> json) =>
      _$ApplicationFromJson(json);
}

@freezed
class Reverb with _$Reverb {
  const factory Reverb({
    required String host,
    required String port,
    required String scheme,
    @JsonKey(name: 'app_key') required String appKey,
  }) = _Reverb;

  factory Reverb.fromJson(Map<String, dynamic> json) =>
      _$ReverbFromJson(json);
}

@freezed
class Stripe with _$Stripe {
  const factory Stripe({required String key}) = _Stripe;

  factory Stripe.fromJson(Map<String, dynamic> json) =>
      _$StripeFromJson(json);
}
