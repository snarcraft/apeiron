import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../repositories/exceptions/validation_exception.dart';

/// Translates Laravel error shapes into typed failures: 422
/// becomes a ValidationException carrying the field map; 401 is
/// surfaced for the auth cubit to log out.
@injectable
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;

    if (response?.statusCode == 422) {
      return handler.reject(
        ValidationException.fromResponse(response!, err),
      );
    }

    handler.next(err);
  }
}
