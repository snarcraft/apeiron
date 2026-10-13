import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_fonts/google_fonts.dart';

import '../extensions/color.dart';

part 'theme.freezed.dart';
part 'theme.g.dart';

/// Server-driven theme — deserialized from the backend's
/// Application document (colors arrive as "#RRGGBB" hex). The
/// scaffolded backend seeds it from the same oklch palette that
/// drives the website and webapp, so every surface matches.
@freezed
class Theme with _$Theme {
  const Theme._();

  const factory Theme({
    @JsonKey(name: 'font_family') @Default('Inter') String fontFamily,
    @StringColorConverter() required MaterialColor primary,
    @StringColorConverter() required MaterialColor secondary,
    @StringColorConverter() required MaterialColor tertiary,
    @Default('light') String brightness,
  }) = _Theme;

  Brightness get _brightness =>
      brightness == 'dark' ? Brightness.dark : Brightness.light;

  ColorScheme get colorScheme => ColorScheme.fromSeed(
        seedColor: primary,
        brightness: _brightness,
        secondary: secondary,
        tertiary: tertiary,
      );

  ThemeData get value {
    final base = ThemeData.useMaterial3
        ? ThemeData(colorScheme: colorScheme)
        : ThemeData(colorScheme: colorScheme);

    final text = GoogleFonts.getTextTheme(
      fontFamily,
      base.textTheme.apply(bodyColor: colorScheme.onSurface),
    );

    return base.copyWith(
      textTheme: text,
      scaffoldBackgroundColor: colorScheme.surface,
      dividerTheme: DividerThemeData(color: colorScheme.outlineVariant),
      appBarTheme: const AppBarTheme(toolbarHeight: 0),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  factory Theme.fromJson(Map<String, dynamic> json) => _$ThemeFromJson(json);
}

class StringColorConverter
    implements JsonConverter<MaterialColor, String> {
  const StringColorConverter();

  @override
  MaterialColor fromJson(String json) => Colorable.fromHex(json);

  @override
  String toJson(MaterialColor object) =>
      '#${object.value.toRadixString(16).padLeft(8, '0')}';
}
