import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Unwraps the Laravel envelope defensively — surfaces the raw
/// response and lets repositories decode `data` into models.
@injectable
class ResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;

      if (!data.containsKey('data')) {
        response.data = {'data': data};
      }
    }

    handler.next(response);
  }
}
