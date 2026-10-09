import 'package:equatable/equatable.dart';

import 'student.dart';

/// What the check says of a line (spec 02 "CSV import", design `r2/ImportElevesVerifier.png`).
/// [parentKnown]: the parent's phone is one of the teacher's parents (the child joins them, no new account);
/// [exists]: a pupil of that name already (left out unless the teacher keeps it); [error]: never imported.
enum ImportState { ready, parentKnown, exists, error }

/// One line of the teacher's file, as the server read and checked it. [problems] are codes the app words
/// ("level_unknown" with [levelText], "duplicate_in_file" with [sameAs]...).
class ImportRow extends Equatable {
  const ImportRow({
    required this.line,
    required this.firstName,
    required this.lastName,
    required this.state,
    this.levelId,
    this.levelText = '',
    this.groupIds = const [],
    this.groupText = '',
    this.phone = '',
    this.parentFirstName = '',
    this.parentLastName = '',
    this.parentPhone = '',
    this.problems = const [],
    this.knownParent,
    this.sameParentAs,
    this.sameAs,
  });

  final int line;
  final String firstName;
  final String lastName;
  final String? levelId;
  final String levelText;
  final List<String> groupIds;
  final String groupText;
  final String phone;
  final String parentFirstName;
  final String parentLastName;
  final String parentPhone;
  final ImportState state;
  final List<String> problems;

  /// [ImportState.parentKnown]: the parent's name as the app knows them.
  final String? knownParent;

  /// An earlier line with the same new parent (one account for both).
  final int? sameParentAs;

  /// [problems] "duplicate_in_file": the earlier line of the same pupil.
  final int? sameAs;

  String get fullName => '$firstName $lastName'.trim();

  String get parentName => '$parentFirstName $parentLastName'.trim();

  bool get hasParent => parentPhone.isNotEmpty;

  /// Can be kept: everything but an error.
  bool get importable => state != ImportState.error;

  /// Kept unless the teacher unticks it; a pupil already registered starts unticked.
  bool get keptByDefault => state == ImportState.ready || state == ImportState.parentKnown;

  @override
  List<Object?> get props => [
    line,
    firstName,
    lastName,
    levelId,
    levelText,
    groupIds,
    groupText,
    phone,
    parentFirstName,
    parentLastName,
    parentPhone,
    state,
    problems,
    knownParent,
    sameParentAs,
    sameAs,
  ];
}

class ImportPreview extends Equatable {
  const ImportPreview({required this.fileName, required this.rows});

  final String fileName;

  /// In file order.
  final List<ImportRow> rows;

  int count(ImportState state) => rows.where((r) => r.state == state).length;

  @override
  List<Object?> get props => [fileName, rows];
}

/// A new account to hand over; for a parent, the imported children it is for.
class ImportedAccount extends Equatable {
  const ImportedAccount({required this.account, this.children = const []});

  final NewAccount account;
  final List<String> children;

  @override
  List<Object?> get props => [account, children];
}

/// [linked]: children who joined a parent already known.
class ImportResult extends Equatable {
  const ImportResult({required this.created, required this.linked, required this.accounts});

  final int created;
  final int linked;
  final List<ImportedAccount> accounts;

  @override
  List<Object?> get props => [created, linked, accounts];
}
