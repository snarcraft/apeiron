import 'package:flutter/material.dart';

Future<void> handle(Environment environment) async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureInjection(environment.name);
  await registerProviders();

  runApp(
    MultiBlocProvider(
      providers: registerBlocs(),
      child: const AppWidget(),
    ),
  );
}

enum Environment {
  prod('prod'),
  dev('dev'),
  test('test');

  const Environment(this.name);

  final String name;
}
