import 'package:get_it/get_it.dart';

import '../injection.dart';
import 'service_provider.dart';

/// Resolves every ServiceProvider from the container, then boots
/// them two-phase — exactly Laravel's register/boot lifecycle.
Future<void> registerProviders() async {
  final providers = getIt.all<ServiceProvider>();

  await Future.wait(providers.map((provider) => provider.register()));
  await Future.wait(providers.map((provider) => provider.boot()));
}
