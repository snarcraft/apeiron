import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Attaches the Sanctum bearer token from secure storage.
@injectable
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);

  static const token = 'sanctum';

  final FlutterSecureStorage _storage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final value = await _storage.read(key: token);

    if (value != null && value.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $value';
    }

    handler.next(options);
  }
}
