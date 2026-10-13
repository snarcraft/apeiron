import 'package:flutter/material.dart';

import '../../config/application.dart';
import '../../injection.dart';
import '../widgets/logo.dart';

/// Splash while identity resolves — brand colors from the
/// server-driven theme, no hardcoded palette.
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final application = getIt<Application>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Logo(size: 72),
            const SizedBox(height: 16),
            Text(
              application.name,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
