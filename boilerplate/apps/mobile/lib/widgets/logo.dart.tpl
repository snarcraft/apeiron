import 'package:flutter/material.dart';

/// The gradient monogram — same mark as the website and webapp,
/// recolored by the server-driven theme.
class Logo extends StatelessWidget {
  const Logo({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final letter = '{{APP_LETTER}}';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.secondary],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          color: scheme.onPrimary,
          fontSize: size * 0.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
