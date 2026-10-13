import 'package:flutter/material.dart';

/// MaterialColor utilities — hex parsing (server theme payloads)
/// and full swatch generation from a single seed.
extension Colorable on Color {
  static MaterialColor fromHex(String hex) {
    final value = hex.replaceFirst('#', '');

    final rgb = int.tryParse('FF$value', radix: 16) ??
        int.parse('FF988CFF', radix: 16);

    return generateMaterialColor(Color(rgb));
  }

  static MaterialColor generateMaterialColor(Color color) {
    final strengths = <double>[0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9];
    final swatch = <int, Color>{};
    final r = color.r, g = color.g, b = color.b;

    for (final strength in strengths) {
      final ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    return MaterialColor(color.toARGB32(), swatch);
  }
}
