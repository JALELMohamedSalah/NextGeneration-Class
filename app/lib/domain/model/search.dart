import 'package:equatable/equatable.dart';

import 'content.dart';
import 'localized_text.dart';
import 'session.dart';

/// The families of the teacher's search (design `r2/Recherche.png`), in the order they are shown.
enum SearchKind { student, parent, group, document, chapter, homework, evaluation }

/// One result: what it is, what it opens, and the facts its line shows.
sealed class SearchHit extends Equatable {
  const SearchHit({required this.id});

  final String id;

  SearchKind get kind;

  /// The words the typed letters are found in.
  String get title;
}

class StudentHit extends SearchHit {
  const StudentHit({required super.id, required this.firstName, required this.lastName, this.level, this.groups = const []});

  final String firstName;
  final String lastName;
  final LocalizedText? level;
  final List<String> groups;

  @override
  SearchKind get kind => SearchKind.student;

  @override
  String get title => '$firstName $lastName';

  @override
  List<Object?> get props => [id, firstName, lastName, level, groups];
}

class ChildRef extends Equatable {
  const ChildRef({required this.id, required this.firstName});

  final String id;
  final String firstName;

  @override
  List<Object?> get props => [id, firstName];
}

/// A parent opens their first child's fiche.
class ParentHit extends SearchHit {
  const ParentHit({required super.id, required this.firstName, required this.lastName, this.phone, this.children = const []});

  final String firstName;
  final String lastName;
  final String? phone;
  final List<ChildRef> children;

  @override
  SearchKind get kind => SearchKind.parent;

  @override
  String get title => '$firstName $lastName';

  @override
  List<Object?> get props => [id, firstName, lastName, phone, children];
}

class GroupHit extends SearchHit {
  const GroupHit({required super.id, required this.name, required this.code, required this.color, this.privateLesson = false, this.memberCount = 0});

  final String name;
  final String code;
  final String color;
  final bool privateLesson;
  final int memberCount;

  @override
  SearchKind get kind => SearchKind.group;

  @override
  String get title => name;

  @override
  List<Object?> get props => [id, name, code, color, privateLesson, memberCount];
}

class DocumentHit extends SearchHit {
  const DocumentHit({required super.id, required this.name, required this.tag, required this.fileKind, this.subject, this.level, this.chapter});

  final String name;
  final ContentTag tag;
  final FileKind fileKind;
  final LocalizedText? subject;
  final LocalizedText? level;
  final String? chapter;

  @override
  SearchKind get kind => SearchKind.document;

  @override
  String get title => name;

  @override
  List<Object?> get props => [id, name, tag, fileKind, subject, level, chapter];
}

class ChapterHit extends SearchHit {
  const ChapterHit({required super.id, required this.name, this.subject, this.level, this.documents = 0});

  final String name;
  final LocalizedText? subject;
  final LocalizedText? level;
  final int documents;

  @override
  SearchKind get kind => SearchKind.chapter;

  @override
  String get title => name;

  @override
  List<Object?> get props => [id, name, subject, level, documents];
}

class HomeworkHit extends SearchHit {
  const HomeworkHit({required super.id, required this.name, required this.group, required this.deadlineAt, this.toCorrect = 0, this.done = false});

  final String name;
  final GroupRef group;
  final DateTime deadlineAt;
  final int toCorrect;
  final bool done;

  @override
  SearchKind get kind => SearchKind.homework;

  @override
  String get title => name;

  @override
  List<Object?> get props => [id, name, group, deadlineAt, toCorrect, done];
}

class EvaluationHit extends SearchHit {
  const EvaluationHit({required super.id, required this.name, required this.group, required this.heldOn});

  final String name;
  final GroupRef group;
  final DateTime heldOn;

  @override
  SearchKind get kind => SearchKind.evaluation;

  @override
  String get title => name;

  @override
  List<Object?> get props => [id, name, group, heldOn];
}

class SearchResults extends Equatable {
  const SearchResults({this.hits = const []});

  /// Grouped by [SearchKind], each family in the server's order (the best placed first).
  final List<SearchHit> hits;

  bool get isEmpty => hits.isEmpty;

  @override
  List<Object?> get props => [hits];
}
