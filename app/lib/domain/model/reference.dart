import 'package:equatable/equatable.dart';

import 'localized_text.dart';

class Subject extends Equatable {
  const Subject({required this.id, required this.name, required this.color});

  final String id;
  final LocalizedText name;

  /// "#2B3990".
  final String color;

  @override
  List<Object?> get props => [id, name, color];
}

/// A subject in Paramètres, with how many groups use it (archived ones included).
class SubjectUsage extends Equatable {
  const SubjectUsage({required this.subject, required this.groupCount});

  final Subject subject;
  final int groupCount;

  /// The server refuses to delete a subject a group uses.
  bool get inUse => groupCount > 0;

  SubjectUsage withSubject(Subject subject) => SubjectUsage(subject: subject, groupCount: groupCount);

  @override
  List<Object?> get props => [subject, groupCount];
}

/// A subject the teacher creates: French name, Arabic name (optional), color.
class SubjectDraft extends Equatable {
  const SubjectDraft({required this.nameFr, this.nameAr = '', this.color});

  final String nameFr;
  final String nameAr;

  /// Null: the next palette color.
  final String? color;

  @override
  List<Object?> get props => [nameFr, nameAr, color];
}

class Level extends Equatable {
  const Level({required this.id, required this.name});

  final String id;
  final LocalizedText name;

  @override
  List<Object?> get props => [id, name];
}

class SchoolYear extends Equatable {
  const SchoolYear({required this.id, required this.label, required this.startsOn, required this.endsOn});

  final String id;
  final String label;
  final DateTime startsOn;
  final DateTime endsOn;

  @override
  List<Object?> get props => [id, label, startsOn, endsOn];
}

/// Subjects, levels and the current school year, in both languages.
class Reference extends Equatable {
  const Reference({required this.subjects, required this.levels, required this.currentYear});

  final List<Subject> subjects;
  final List<Level> levels;
  final SchoolYear? currentYear;

  Level? level(String id) => levels.where((l) => l.id == id).firstOrNull;

  Subject? subject(String id) => subjects.where((s) => s.id == id).firstOrNull;

  /// A new subject goes last; an edited one keeps its place.
  Reference withSubject(Subject subject) => Reference(
    subjects: subjects.any((s) => s.id == subject.id)
        ? [for (final s in subjects) s.id == subject.id ? subject : s]
        : [...subjects, subject],
    levels: levels,
    currentYear: currentYear,
  );

  Reference withoutSubject(String id) =>
      Reference(subjects: subjects.where((s) => s.id != id).toList(), levels: levels, currentYear: currentYear);

  @override
  List<Object?> get props => [subjects, levels, currentYear];
}
