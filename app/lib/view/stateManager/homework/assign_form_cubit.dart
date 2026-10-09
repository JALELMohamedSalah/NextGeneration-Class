import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/tunis_time.dart';
import '../../../core/network/api_failure.dart';
import '../../../domain/model/clock_time.dart';
import '../../../domain/model/content.dart';
import '../../../domain/model/group.dart';
import '../../../domain/model/homework.dart';
import '../../../domain/repositories/content_repository.dart';
import '../../../domain/repositories/group_repository.dart';
import '../../../domain/repositories/homework_repository.dart';

enum AssignFormError { document, title, group, students, deadline }

class AssignFormState extends Equatable {
  const AssignFormState({
    required this.date,
    this.time = const ClockTime(18, 0),
    this.documents = const [],
    this.loaded = false,
    this.contentItemId,
    this.title = '',
    this.groupId,
    this.someStudents = false,
    this.members = const [],
    this.studentIds = const [],
    this.mode = SubmissionMode.file,
    this.allowLate = false,
    this.instructions = '',
    this.errors = const {},
    this.submitting = false,
    this.failure,
  });

  /// Published documents of the library, last edited first.
  final List<ContentDocument> documents;

  /// The library has answered (an empty list then means nothing is published).
  final bool loaded;
  final String? contentItemId;
  final String title;
  final String? groupId;

  /// "Des élèves": some pupils of the group, ticked in [members].
  final bool someStudents;
  final List<GroupMember> members;
  final List<String> studentIds;

  /// The deadline in Tunisian time.
  final DateTime date;
  final ClockTime time;
  final SubmissionMode mode;
  final bool allowLate;
  final String instructions;
  final Set<AssignFormError> errors;
  final bool submitting;
  final ApiFailure? failure;

  ContentDocument? get document => documents.where((d) => d.id == contentItemId).firstOrNull;

  DateTime get deadlineAt => TunisTime.instant(date, time);

  AssignFormState copyWith({
    List<ContentDocument>? documents,
    bool? loaded,
    String? Function()? contentItemId,
    String? title,
    String? Function()? groupId,
    bool? someStudents,
    List<GroupMember>? members,
    List<String>? studentIds,
    DateTime? date,
    ClockTime? time,
    SubmissionMode? mode,
    bool? allowLate,
    String? instructions,
    Set<AssignFormError>? errors,
    bool? submitting,
    ApiFailure? Function()? failure,
  }) => AssignFormState(
    documents: documents ?? this.documents,
    loaded: loaded ?? this.loaded,
    contentItemId: contentItemId != null ? contentItemId() : this.contentItemId,
    title: title ?? this.title,
    groupId: groupId != null ? groupId() : this.groupId,
    someStudents: someStudents ?? this.someStudents,
    members: members ?? this.members,
    studentIds: studentIds ?? this.studentIds,
    date: date ?? this.date,
    time: time ?? this.time,
    mode: mode ?? this.mode,
    allowLate: allowLate ?? this.allowLate,
    instructions: instructions ?? this.instructions,
    errors: errors ?? this.errors,
    submitting: submitting ?? this.submitting,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [
    documents,
    loaded,
    contentItemId,
    title,
    groupId,
    someStudents,
    members,
    studentIds,
    date,
    time,
    mode,
    allowLate,
    instructions,
    errors,
    submitting,
    failure?.code,
  ];
}

/// "Nouveau devoir" (design `r2/NouveauDevoir.png`): a published document, a group or some of its pupils, a
/// deadline (in two days at 18:00 by default), photos or nothing to send.
class AssignFormCubit extends Cubit<AssignFormState> {
  AssignFormCubit(this._homework, this._contents, this._groups, Now now, {String? contentItemId, String? groupId})
    : super(AssignFormState(date: TunisTime.addDays(TunisTime.day(now()), 2), contentItemId: contentItemId, groupId: groupId)) {
    _now = now;
  }

  final HomeworkRepository _homework;
  final ContentRepository _contents;
  final GroupRepository _groups;
  late final Now _now;

  /// The documents to choose from, and the pupils of a preset group.
  Future<void> load() async {
    try {
      final library = await _contents.library();
      if (isClosed) return;
      final documents = library.documents.where((d) => d.published).toList();
      emit(
        state.copyWith(
          documents: documents,
          loaded: true,
          title: state.title.isEmpty ? documents.where((d) => d.id == state.contentItemId).firstOrNull?.title : null,
        ),
      );
    } on Object catch (error) {
      if (!isClosed) emit(state.copyWith(loaded: true, failure: () => ApiFailure.from(error)));
    }
    final group = state.groupId;
    if (group != null) await _loadMembers(group);
  }

  /// The title follows the document until the teacher writes her own.
  void setDocument(String? id) {
    final previous = state.document?.title;
    final next = state.documents.where((d) => d.id == id).firstOrNull?.title;
    final keep = state.title.trim().isNotEmpty && state.title != previous;
    emit(
      state.copyWith(
        contentItemId: () => id,
        title: keep ? null : (next ?? ''),
        errors: state.errors.difference({AssignFormError.document, AssignFormError.title}),
      ),
    );
  }

  void setTitle(String value) => emit(state.copyWith(title: value, errors: state.errors.difference({AssignFormError.title})));

  Future<void> setGroup(String? id) async {
    emit(
      state.copyWith(groupId: () => id, studentIds: const [], members: const [], errors: state.errors.difference({AssignFormError.group})),
    );
    if (id != null) await _loadMembers(id);
  }

  void setSomeStudents(bool value) =>
      emit(state.copyWith(someStudents: value, studentIds: const [], errors: state.errors.difference({AssignFormError.students})));

  void toggleStudent(String id) => emit(
    state.copyWith(
      studentIds: state.studentIds.contains(id) ? state.studentIds.where((s) => s != id).toList() : [...state.studentIds, id],
      errors: state.errors.difference({AssignFormError.students}),
    ),
  );

  void setDate(DateTime date) => emit(state.copyWith(date: date, errors: state.errors.difference({AssignFormError.deadline})));

  void setTime(ClockTime time) => emit(state.copyWith(time: time, errors: state.errors.difference({AssignFormError.deadline})));

  void setMode(SubmissionMode mode) => emit(state.copyWith(mode: mode, allowLate: mode == SubmissionMode.none ? false : null));

  void setAllowLate(bool value) => emit(state.copyWith(allowLate: value));

  void setInstructions(String value) => emit(state.copyWith(instructions: value));

  /// The homework given, or null with the reason in the state.
  Future<Assignment?> submit() async {
    if (state.submitting) return null;
    final errors = {
      if (state.contentItemId == null) AssignFormError.document,
      if (state.title.trim().isEmpty) AssignFormError.title,
      if (state.groupId == null) AssignFormError.group,
      if (state.someStudents && state.studentIds.isEmpty) AssignFormError.students,
      if (!state.deadlineAt.isAfter(_now())) AssignFormError.deadline,
    };
    if (errors.isNotEmpty) {
      emit(state.copyWith(errors: errors));
      return null;
    }
    emit(state.copyWith(submitting: true, failure: () => null));
    try {
      final saved = await _homework.assign(
        AssignmentDraft(
          contentItemId: state.contentItemId!,
          title: state.title,
          groupId: state.groupId!,
          studentIds: state.someStudents ? state.studentIds : const [],
          deadlineAt: state.deadlineAt,
          mode: state.mode,
          allowLate: state.allowLate,
          instructions: state.instructions,
        ),
      );
      if (!isClosed) emit(state.copyWith(submitting: false));
      return saved;
    } on Object catch (error) {
      if (!isClosed) emit(state.copyWith(submitting: false, failure: () => ApiFailure.from(error)));
      return null;
    }
  }

  Future<void> _loadMembers(String groupId) async {
    try {
      final detail = await _groups.detail(groupId);
      if (!isClosed && state.groupId == groupId) emit(state.copyWith(members: detail.members));
    } on Object catch (error) {
      if (!isClosed) emit(state.copyWith(failure: () => ApiFailure.from(error)));
    }
  }
}
