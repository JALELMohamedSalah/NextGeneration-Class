import 'package:equatable/equatable.dart';

import 'localized_text.dart';

/// The three roles (docs/01-product/03-ROLES_PERMISSIONS.md).
/// [admin]: the owner of the platform, who adds teachers (dashboard, web).
enum UserRole { admin, teacher, student, parent }

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.role,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.mustChangePassword,
    this.children = const [],
  });

  final String id;
  final UserRole role;
  final String username;
  final String firstName;
  final String lastName;

  /// The teacher created or reset the password: the user chooses their own before going further.
  final bool mustChangePassword;

  /// Parents only: the children they follow.
  final List<ChildSummary> children;

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final first = firstName.isEmpty ? '' : firstName[0];
    final last = lastName.isEmpty ? '' : lastName[0];
    final value = '$first$last'.toUpperCase();
    return value.isEmpty ? username.substring(0, 1).toUpperCase() : value;
  }

  AppUser copyWith({bool? mustChangePassword}) => AppUser(
    id: id,
    role: role,
    username: username,
    firstName: firstName,
    lastName: lastName,
    mustChangePassword: mustChangePassword ?? this.mustChangePassword,
    children: children,
  );

  @override
  List<Object?> get props => [id, role, username, firstName, lastName, mustChangePassword, children];
}

class ChildSummary extends Equatable {
  const ChildSummary({required this.studentId, required this.firstName, required this.lastName, required this.level});

  final String studentId;
  final String firstName;
  final String lastName;
  final LocalizedText level;

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [studentId, firstName, lastName, level];
}
