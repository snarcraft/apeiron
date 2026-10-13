import 'package:auto_route/auto_route.dart';

part 'router.gr.dart';
import 'package:injectable/injectable.dart';

import 'guards/guards.dart';
import 'views/auth/login.dart';
import 'views/index.dart';
import 'views/splash.dart';

@AutoRouterConfig(replaceInRouteName: 'View,Route')
@lazySingleton
class AppRouter extends $AppRouter {
  AppRouter(this._authGuard, this._guestGuard);

  final AuthGuard _authGuard;
  final GuestGuard _guestGuard;

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: LoginRoute.page, guards: [_guestGuard]),
        AutoRoute(page: HomeRoute.page, guards: [_authGuard]),
      ];
}
