import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../config/app.dart';
import '../config/application.dart';
import '../domain/app/application_facade.dart';
import '../services/contracts/config_contract.dart';
import '../services/interceptors/auth.dart';
import '../services/interceptors/error.dart';
import '../services/interceptors/options.dart';
import '../services/interceptors/response.dart';

/// Third-party factories injectable cannot annotate — the
/// bootstrap heart of the container. @preResolve guarantees the
/// app never starts without its local config and the
/// server-driven Application document.
@module
abstract class RegisterModule {
  @lazySingleton
  FlutterSecureStorage get storage => const FlutterSecureStorage();

  @preResolve
  @lazySingleton
  Future<App> app(ConfigContract service) async => App.fromJson(
        await service.read('app'),
      );

  @preResolve
  @lazySingleton
  Future<Application> application(
    App app,
    ApplicationFacade facade,
  ) async {
    final client = Dio(BaseOptions(baseUrl: app.baseUrl));

    return facade.fetch(client);
  }

  @Named('sanctum')
  @lazySingleton
  Dio sanctum(
    App app,
    OptionsInterceptor options,
    AuthInterceptor auth,
    ResponseInterceptor response,
    ErrorInterceptor error,
  ) =>
      Dio(BaseOptions(baseUrl: app.baseUrl))
        ..interceptors.addAll([options, auth, response, error]);
}
