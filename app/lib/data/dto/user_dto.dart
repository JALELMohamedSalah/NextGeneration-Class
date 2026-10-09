import '../../domain/model/app_user.dart';
import '../../domain/model/localized_text.dart';

/// `MeResponse` of the API.
class UserDto {
  UserDto(this.json);

  final Map<String, dynamic> json;

  AppUser toDomain() => AppUser(
    id: json['id'] as String,
    role: _role(json['role'] as String?),
    username: json['username'] as String? ?? '',
    firstName: json['firstName'] as String? ?? '',
    lastName: json['lastName'] as String? ?? '',
    mustChangePassword: json['mustChangePassword'] as bool? ?? false,
    children: [
      for (final child in (json['children'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>())
        ChildSummary(
          studentId: child['studentId'] as String,
          firstName: child['firstName'] as String? ?? '',
          lastName: child['lastName'] as String? ?? '',
          level: localizedText(child['level']),
        ),
    ],
  );

  static UserRole _role(String? value) => switch (value) {
    'ADMIN' => UserRole.admin,
    'TEACHER' => UserRole.teacher,
    'PARENT' => UserRole.parent,
    _ => UserRole.student,
  };
}

/// `{ "fr": ..., "ar": ... }` from the API.
LocalizedText localizedText(Object? json) {
  final map = json is Map ? json : const {};
  return LocalizedText(fr: map['fr'] as String? ?? '', ar: map['ar'] as String? ?? '');
}

/// `AuthResponse` of the API.
class AuthSessionDto {
  AuthSessionDto.fromJson(Map<String, dynamic> json)
    : accessToken = json['accessToken'] as String,
      refreshToken = json['refreshToken'] as String,
      user = UserDto(json['user'] as Map<String, dynamic>);

  final String accessToken;
  final String refreshToken;
  final UserDto user;
}
