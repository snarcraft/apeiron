import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../domain/auth/auth_facade.dart';
import '../domain/auth/user.dart';
import '../domain/core/failure.dart';
import '../domain/core/success.dart';
import '../services/contracts/network_contract.dart';
import '../services/interceptors/auth.dart';

@LazySingleton(as: AuthFacade)
class AuthRepository implements AuthFacade {
  AuthRepository(this._network, this._storage);

  final NetworkContract _network;
  final FlutterSecureStorage _storage;

  @override
  Future<Either<Failure<User>, User>> attempt(
    String email,
    String password,
  ) async {
    try {
      final response = await _network.submit(
        'auth/token',
        data: {
          'email': email,
          'password': password,
          'device': 'mobile',
        },
      );

      final data = response.data?['data'] as Map<String, dynamic>? ?? {};
      final token = data['token'] as String?;

      if (token != null) {
        await _storage.write(key: AuthInterceptor.token, value: token);
      }

      return Right(User.fromJson(data['user'] as Map<String, dynamic>));
    } on DioException catch (error) {
      return Left(Failure.network(message: error.message ?? 'Sign in failed.'));
    }
  }

  @override
  Future<Option<User>> user() async {
    final token = await _storage.read(key: AuthInterceptor.token);

    if (token == null || token.isEmpty) {
      return const None();
    }

    try {
      final response = await _network.get('user');

      return Some(
        User.fromJson(response.data?['data'] as Map<String, dynamic>),
      );
    } on DioException {
      return const None();
    }
  }

  @override
  Future<Either<Failure<Success>, Success>> logout() async {
    try {
      await _network.submit('auth/token');

      await _storage.delete(key: AuthInterceptor.token);

      return const Right(Success());
    } on DioException catch (error) {
      await _storage.delete(key: AuthInterceptor.token);

      return Left(Failure.network(message: error.message ?? 'Sign out failed.'));
    }
  }
}
