import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';

import '../router.dart';
import '../store/auth/auth_cubit.dart';
import '../store/auth/auth_state.dart';

/// Redirects unauthenticated navigation to the login route.
@lazySingleton
class AuthGuard extends AutoRouteGuard {
  AuthGuard(this._auth);

  final AuthCubit _auth;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (_auth.state is AuthAuthenticated) {
      return resolver.next();
    }

    resolver.redirect(const LoginRoute());
  }
}

/// Keeps authenticated users out of guest-only routes.
@lazySingleton
class GuestGuard extends AutoRouteGuard {
  GuestGuard(this._auth);

  final AuthCubit _auth;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (_auth.state is AuthAuthenticated) {
      return resolver.redirect(const HomeRoute());
    }

    resolver.next();
  }
}
