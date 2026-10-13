import 'dart:async';

import 'package:injectable/injectable.dart';

import '../store/auth/auth_cubit.dart';
import 'service_provider.dart';

/// Cross-cutting identity reactions live here, not in the UI:
/// anything that must happen on login/logout across cubits.
@LazySingleton(as: ServiceProvider)
class AppServiceProvider extends ServiceProvider {
  AppServiceProvider(this._auth);

  final AuthCubit _auth;

  StreamSubscription<dynamic>? _subscription;

  @override
  Future<void> register() async {
    _subscription = _auth.stream.listen((state) {
      // React to authenticated/unauthenticated transitions —
      // connect realtime, refresh identity, clear caches.
    });
  }

  @override
  Future<void> boot() async {
    await _auth.check();
  }

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
  }
}
