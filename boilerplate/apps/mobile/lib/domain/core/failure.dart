import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

/// The error side of every repository result —
/// `Either<Failure<T>, T>` everywhere, like the backend's
/// typed exceptions.
@freezed
class Failure<T> with _$Failure<T> {
  const factory Failure.network({required String message}) = _Network<T>;

  const factory Failure.validation({Map<String, String>? errors}) =
      _Validation<T>;

  const factory Failure.unauthorized() = _Unauthorized<T>;

  const factory Failure.unexpected(Object? error) = _Unexpected<T>;
}
