import 'package:dio/dio.dart';

/// Laravel's 422 shape as a typed exception — the field→message
/// map, flattened to the first error per field.
class ValidationException implements DioException {
  ValidationException({
    required this.message,
    required this.errors,
    required this.requestOptions,
  });

  factory ValidationException.fromResponse(
    Response<dynamic> response,
    DioException cause,
  ) {
    final data = response.data as Map<String, dynamic>?;
    final raw = data?['errors'] as Map<String, dynamic>? ?? {};

    return ValidationException(
      message: (data?['message'] as String?) ?? 'The given data was invalid.',
      errors: {
        for (final entry in raw.entries)
          entry.key: (entry.value as List).first.toString(),
      },
      requestOptions: response.requestOptions,
    );
  }

  @override
  final String message;

  final Map<String, String> errors;

  @override
  final RequestOptions requestOptions;

  @override
  DioException copyWith({
    Object? error,
    StackTrace? stackTrace,
    String? message,
    RequestOptions? requestOptions,
    Response? response,
    DioExceptionType? type,
  }) =>
      this;

  @override
  Object? get error => message;

  @override
  StackTrace? get stackTrace => StackTrace.current;

  @override
  Response? get response => null;

  @override
  DioExceptionType get type => DioExceptionType.badResponse;
}
