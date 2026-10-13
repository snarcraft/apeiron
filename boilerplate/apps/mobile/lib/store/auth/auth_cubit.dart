import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/auth/auth_facade.dart';
import '../../domain/auth/user.dart';
import 'auth_state.dart';

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._facade) : super(const AuthState.initial());

  final AuthFacade _facade;

  Future<void> check() async {
    final user = await _facade.user();

    emit(
      user.fold(
        () => const AuthState.unauthenticated(),
        (user) => AuthState.authenticated(user: user),
      ),
    );
  }

  Future<void> login(String email, String password) async {
    final result = await _facade.attempt(email, password);

    result.fold(
      (failure) => emit(const AuthState.unauthenticated()),
      (user) => emit(AuthState.authenticated(user: user)),
    );
  }

  Future<void> logout() async {
    await _facade.logout();

    emit(const AuthState.unauthenticated());
  }
}
