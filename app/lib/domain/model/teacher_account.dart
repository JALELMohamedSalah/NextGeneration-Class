import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart' show StringCharacters;

/// A teacher as the owner of the platform sees her: her account and how big her space is, never what
/// is inside it.
class TeacherAccount extends Equatable {
  const TeacherAccount({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.active,
    required this.awaitingFirstLogin,
    required this.createdAt,
    this.phone,
    this.email,
    this.lastLoginAt,
    this.students = 0,
    this.parents = 0,
    this.groups = 0,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String? phone;
  final String? email;
  final bool active;

  /// She still has the temporary password given at creation (or after a reset).
  final bool awaitingFirstLogin;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final int students;
  final int parents;
  final int groups;

  String get fullName => '$firstName $lastName'.trim();

  String get initials =>
      '${firstName.isEmpty ? '' : firstName.characters.first}${lastName.isEmpty ? '' : lastName.characters.first}'.toUpperCase();

  TeacherAccount withActive(bool value) => TeacherAccount(
    id: id,
    firstName: firstName,
    lastName: lastName,
    username: username,
    phone: phone,
    email: email,
    active: value,
    awaitingFirstLogin: awaitingFirstLogin,
    lastLoginAt: lastLoginAt,
    createdAt: createdAt,
    students: students,
    parents: parents,
    groups: groups,
  );

  TeacherAccount withTemporaryPassword() => TeacherAccount(
    id: id,
    firstName: firstName,
    lastName: lastName,
    username: username,
    phone: phone,
    email: email,
    active: active,
    awaitingFirstLogin: true,
    lastLoginAt: lastLoginAt,
    createdAt: createdAt,
    students: students,
    parents: parents,
    groups: groups,
  );

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    username,
    phone,
    email,
    active,
    awaitingFirstLogin,
    lastLoginAt,
    createdAt,
    students,
    parents,
    groups,
  ];
}

/// The figures across every teacher's space.
class TeachersTotals extends Equatable {
  const TeachersTotals({this.teachers = 0, this.activeTeachers = 0, this.students = 0, this.parents = 0, this.groups = 0});

  final int teachers;
  final int activeTeachers;
  final int students;
  final int parents;
  final int groups;

  @override
  List<Object?> get props => [teachers, activeTeachers, students, parents, groups];
}

class TeachersOverview extends Equatable {
  const TeachersOverview({required this.totals, required this.teachers});

  final TeachersTotals totals;

  /// Oldest first.
  final List<TeacherAccount> teachers;

  @override
  List<Object?> get props => [totals, teachers];
}

class TeacherDraft extends Equatable {
  const TeacherDraft({required this.firstName, required this.lastName, required this.username, this.phone, this.email});

  final String firstName;
  final String lastName;
  final String username;
  final String? phone;
  final String? email;

  Map<String, Object?> toJson() => {
    'firstName': firstName.trim(),
    'lastName': lastName.trim(),
    'username': username.trim(),
    if (phone != null && phone!.trim().isNotEmpty) 'phone': phone!.trim(),
    if (email != null && email!.trim().isNotEmpty) 'email': email!.trim(),
  };

  @override
  List<Object?> get props => [firstName, lastName, username, phone, email];
}
