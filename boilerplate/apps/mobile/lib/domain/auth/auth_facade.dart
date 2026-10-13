import 'package:dartz/dartz.dart';

import 'core/failure.dart';
import 'core/success.dart';
import 'user.dart';

/// The auth surface — mirrors the backend's Sanctum token flow
/// (`POST /auth/token`, `DELETE /auth/token`).
abstract class AuthFacade {
  Future<Either<Failure<User>, User>> attempt(String email, String password);

  Future<Option<User>> user();

  Future<Either<Failure<Success>, Success>> logout();
}
