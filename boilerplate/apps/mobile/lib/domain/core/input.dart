import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'input.freezed.dart';

/// A bound form field: value, label, and its validation error as
/// an Option — mirrors the backend FormRequest contract.
@freezed
class Input<T> with _$Input<T> {
  const factory Input({
    required String name,
    required String label,
    @Default('') T? value,
    @Default(None()) Option<String> error,
  }) = _Input<T>;

  const Input._();

  String? get failure => error.fold(() => null, id);
}
