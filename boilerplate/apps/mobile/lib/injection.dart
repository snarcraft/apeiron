import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  asExtension: true,
  preferRelativeImports: true,
)
Future<void> configureInjection(String environment) async {
  await getIt.init(environment: environment);
}
