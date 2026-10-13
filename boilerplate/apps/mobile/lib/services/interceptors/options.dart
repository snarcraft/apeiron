import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../config/app.dart';

/// Prefixes every request with the API domain path, sets
/// timeouts and the platform/device headers.
@injectable
class OptionsInterceptor extends Interceptor {
  OptionsInterceptor(this._app);

  final App _app;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options
      ..baseUrl = _app.url
      ..connectTimeout = const Duration(seconds: 5)
      ..receiveTimeout = const Duration(seconds: 15)
      ..headers['X-Requested-With'] = 'XMLHttpRequest'
      ..headers['X-Device'] = 'mobile';

    handler.next(options);
  }
}
