import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const User._();

  const factory User({
    @JsonKey(name: 'id') required String uuid,
    required String name,
    required String email,
    required String group,
    required String role,
    @JsonKey(name: 'email_verified_at') String? emailVerifiedAt,
    @Default({}) Map<String, bool> policies,
  }) = _User;

  bool may(String feature, String action) => policies['$feature:$action'] ?? false;

  bool get isAdmin => group == 'operator' && role == 'admin';

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
