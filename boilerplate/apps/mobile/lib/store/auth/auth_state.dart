import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/auth/user.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;

  const factory AuthState.authenticated({required User user}) = AuthAuthenticated;

  const factory AuthState.unauthenticated() = AuthUnauthenticated;
}
