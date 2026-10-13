name: {{APP_SLUG}}
description: {{APP_TITLE}} — mobile.
publish_to: "none"
version: 0.1.0+1

environment:
  sdk: ">=3.5.0 <4.0.0"

dependencies:
  auto_route: ^10.0.0
  bloc: ^9.0.0
  bot_toast: ^4.1.0
  cached_network_image: ^3.4.1
  dartz: ^0.10.1
  dio: ^5.8.0
  flutter:
    sdk: flutter
  flutter_bloc: ^9.0.0
  flutter_localizations:
    sdk: flutter
  flutter_secure_storage: ^10.0.0
  freezed_annotation: ^3.0.0
  get_it: ^8.0.3
  google_fonts: ^6.2.1
  injectable: ^2.7.0
  intl: ^0.20.2
  json_annotation: ^4.9.0
  logger: ^2.5.0
  timeago: ^3.7.0
  uuid: ^4.5.1

dev_dependencies:
  auto_route_generator: ^10.0.0
  build_runner: ^2.4.15
  flutter_launcher_icons: ^0.14.3
  flutter_lints: ^6.0.0
  flutter_native_splash: ^2.4.6
  flutter_test:
    sdk: flutter
  freezed: ^3.0.6
  injectable_generator: ^2.7.0
  json_serializable: ^6.9.4

flutter:
  uses-material-design: true
  assets:
    - assets/

# Regenerate platform launcher icons + splash from the brand:
#   flutter pub run flutter_launcher_icons
#   flutter pub run flutter_native_splash:create
flutter_launcher_icons:
  ios: true
  android: "launcher_icon"
  web: { generate: true, image_path: "assets/icon.png" }
  image_path: "assets/icon.png"
  remove_alpha_ios: true
  adaptive_icon_foreground: "assets/icon.png"
  adaptive_icon_background: "{{PRIMARY_500_HEX}}"

flutter_native_splash:
  android: true
  ios: true
  color: "{{PRIMARY_500_HEX}}"
  image: assets/icon.png
