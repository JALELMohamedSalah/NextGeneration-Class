import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_failure.dart';
import '../../../domain/model/student.dart';
import '../../../domain/repositories/student_repository.dart';

enum UsernameStatus { idle, checking, available, taken }

/// Field errors found before calling the server; the view words them.
enum StudentFormError { firstName, lastName, level, phone, parentName, parentPhone }

class StudentFormState extends Equatable {
  const StudentFormState({
    this.studentId,
    this.firstName = '',
    this.lastName = '',
    this.levelId,
    this.phone = '',
    this.username = '',
    this.usernameEdited = false,
    this.usernameStatus = UsernameStatus.idle,
    this.groupIds = const [],
    this.createLogin = false,
    this.linkedParents = const [],
    this.newParents = const [],
    this.parentAccounts,
    this.errors = const {},
    this.submitting = false,
    this.failure,
    this.saved,
  });

  /// Null when creating.
  final String? studentId;
  final String firstName;
  final String lastName;
  final String? levelId;
  final String phone;
  final String username;

  /// The teacher typed a username herself: it is no longer generated from the name.
  final bool usernameEdited;
  final UsernameStatus usernameStatus;

  /// The child gets their own login. Off by default: primary pupils are followed by their parents.
  final bool createLogin;
  final List<String> groupIds;

  /// Parents already linked (editing): they stay.
  final List<ParentTag> linkedParents;

  /// Parents to link on save: existing accounts or new ones.
  final List<ParentDraft> newParents;

  /// Existing parent accounts, loaded when the picker opens.
  final List<ParentAccount>? parentAccounts;
  final Set<StudentFormError> errors;
  final bool submitting;
  final ApiFailure? failure;

  /// Set once saved: the panel closes and shows the new login details.
  final SavedStudent? saved;

  bool get isEditing => studentId != null;

  int get parentCount => linkedParents.length + newParents.length;

  bool get canAddParent => parentCount < 2;

  StudentFormState copyWith({
    String? firstName,
    String? lastName,
    String? Function()? levelId,
    String? phone,
    String? username,
    bool? usernameEdited,
    UsernameStatus? usernameStatus,
    bool? createLogin,
    List<String>? groupIds,
    List<ParentDraft>? newParents,
    List<ParentAccount>? parentAccounts,
    Set<StudentFormError>? errors,
    bool? submitting,
    ApiFailure? Function()? failure,
    SavedStudent? saved,
  }) => StudentFormState(
    studentId: studentId,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    levelId: levelId != null ? levelId() : this.levelId,
    phone: phone ?? this.phone,
    username: username ?? this.username,
    usernameEdited: usernameEdited ?? this.usernameEdited,
    usernameStatus: usernameStatus ?? this.usernameStatus,
    createLogin: createLogin ?? this.createLogin,
    groupIds: groupIds ?? this.groupIds,
    linkedParents: linkedParents,
    newParents: newParents ?? this.newParents,
    parentAccounts: parentAccounts ?? this.parentAccounts,
    errors: errors ?? this.errors,
    submitting: submitting ?? this.submitting,
    failure: failure != null ? failure() : this.failure,
    saved: saved ?? this.saved,
  );

  @override
  List<Object?> get props => [
    studentId,
    firstName,
    lastName,
    levelId,
    phone,
    username,
    usernameEdited,
    usernameStatus,
    createLogin,
    groupIds,
    linkedParents,
    newParents,
    parentAccounts,
    errors,
    submitting,
    failure?.code,
    failure?.message,
    saved,
  ];
}

/// "Nouvel élève" and "Modifier l'élève" (docs/02-specification/02-students-groups.md).
class StudentFormCubit extends Cubit<StudentFormState> {
  StudentFormCubit(this._repository, {StudentSummary? editing, String? initialGroupId, this.debounce = const Duration(milliseconds: 400)})
    : _originalUsername = editing?.username ?? '',
      super(
        editing == null
            ? StudentFormState(groupIds: [?initialGroupId])
            : StudentFormState(
                studentId: editing.id,
                firstName: editing.firstName,
                lastName: editing.lastName,
                levelId: editing.levelId,
                phone: editing.phone ?? '',
                username: editing.username,
                usernameEdited: true,
                usernameStatus: UsernameStatus.available,
                createLogin: editing.loginEnabled,
                groupIds: [for (final g in editing.groups) g.id],
                linkedParents: editing.parents,
              ),
      );

  final StudentRepository _repository;
  final Duration debounce;
  Timer? _usernameTimer;
  int _check = 0;

  /// When editing, keeping the current username needs no check.
  final String _originalUsername;

  static final _phone = RegExp(r'^\d{8}$');

  void setFirstName(String value) {
    emit(state.copyWith(firstName: value, errors: state.errors.difference({StudentFormError.firstName})));
    _scheduleUsername();
  }

  void setLastName(String value) {
    emit(state.copyWith(lastName: value, errors: state.errors.difference({StudentFormError.lastName})));
    _scheduleUsername();
  }

  void setLevel(String? levelId) => emit(state.copyWith(levelId: () => levelId, errors: state.errors.difference({StudentFormError.level})));

  void setPhone(String value) => emit(state.copyWith(phone: value, errors: state.errors.difference({StudentFormError.phone})));

  /// The teacher types her own username; an empty field goes back to the generated one.
  void setUsername(String value) {
    final edited = value.trim().isNotEmpty;
    emit(state.copyWith(username: value, usernameEdited: edited));
    _scheduleUsername();
  }

  /// Turning the child's access on suggests a username; off, nothing about it is sent.
  void setCreateLogin(bool value) {
    emit(state.copyWith(createLogin: value));
    if (value) _scheduleUsername();
  }

  void toggleGroup(String groupId) {
    final ids = state.groupIds.contains(groupId) ? state.groupIds.where((id) => id != groupId).toList() : [...state.groupIds, groupId];
    emit(state.copyWith(groupIds: ids));
  }

  Future<void> loadParentAccounts() async {
    if (state.parentAccounts != null) return;
    try {
      emit(state.copyWith(parentAccounts: await _repository.parents()));
    } on Object catch (error) {
      emit(state.copyWith(failure: () => ApiFailure.from(error)));
    }
  }

  void addParent(ParentDraft parent) {
    if (!state.canAddParent) return;
    emit(state.copyWith(newParents: [...state.newParents, parent], errors: _withoutParentErrors()));
  }

  void updateParent(int index, ParentDraft parent) {
    final list = [...state.newParents]..[index] = parent;
    emit(state.copyWith(newParents: list, errors: _withoutParentErrors()));
  }

  void removeParent(int index) {
    final list = [...state.newParents]..removeAt(index);
    emit(state.copyWith(newParents: list, errors: _withoutParentErrors()));
  }

  Future<void> submit() async {
    if (state.submitting) return;
    final errors = _validate();
    if (errors.isNotEmpty) {
      emit(state.copyWith(errors: errors));
      return;
    }
    emit(state.copyWith(submitting: true, failure: () => null));
    final draft = StudentDraft(
      firstName: state.firstName.trim(),
      lastName: state.lastName.trim(),
      levelId: state.levelId!,
      phone: _digits(state.phone).isEmpty ? null : _digits(state.phone),
      username: state.createLogin && state.usernameEdited && state.username.trim().isNotEmpty ? state.username.trim() : null,
      groupIds: state.groupIds,
      createLogin: state.createLogin,
      parents: [
        for (final p in state.newParents)
          p.isExisting
              ? p
              : ParentDraft(
                  firstName: p.firstName.trim(),
                  lastName: p.lastName.trim(),
                  phone: _digits(p.phone),
                  email: (p.email?.trim().isEmpty ?? true) ? null : p.email!.trim(),
                  relation: p.relation,
                ),
      ],
    );
    try {
      final saved = state.isEditing ? await _repository.update(state.studentId!, draft) : await _repository.create(draft);
      emit(state.copyWith(submitting: false, saved: saved));
    } on Object catch (error) {
      emit(state.copyWith(submitting: false, failure: () => ApiFailure.from(error)));
    }
  }

  Set<StudentFormError> _validate() => {
    if (state.firstName.trim().isEmpty) StudentFormError.firstName,
    if (state.lastName.trim().isEmpty) StudentFormError.lastName,
    if (state.levelId == null) StudentFormError.level,
    if (state.phone.trim().isNotEmpty && !_phone.hasMatch(_digits(state.phone))) StudentFormError.phone,
    for (final p in state.newParents.where((p) => !p.isExisting)) ...{
      if (p.firstName.trim().isEmpty || p.lastName.trim().isEmpty) StudentFormError.parentName,
      if (!_phone.hasMatch(_digits(p.phone))) StudentFormError.parentPhone,
    },
  };

  Set<StudentFormError> _withoutParentErrors() => state.errors.difference({StudentFormError.parentName, StudentFormError.parentPhone});

  /// "+216 22 345 678" and "22.345.678" give "22345678".
  static String _digits(String phone) {
    var digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length == 11 && digits.startsWith('216')) digits = digits.substring(3);
    return digits;
  }

  /// Generated username while the teacher has not typed one, or a live check of hers.
  void _scheduleUsername() {
    _usernameTimer?.cancel();
    if (!state.createLogin) return;
    final editedValue = state.username.trim();
    if (state.usernameEdited && editedValue == _originalUsername && state.isEditing) {
      emit(state.copyWith(usernameStatus: UsernameStatus.available));
      return;
    }
    if (!state.usernameEdited && (state.firstName.trim().isEmpty || state.lastName.trim().isEmpty)) {
      emit(state.copyWith(username: '', usernameStatus: UsernameStatus.idle));
      return;
    }
    emit(state.copyWith(usernameStatus: UsernameStatus.checking));
    _usernameTimer = Timer(debounce, _checkUsername);
  }

  Future<void> _checkUsername() async {
    final ticket = ++_check;
    try {
      final result = state.usernameEdited
          ? await _repository.checkUsername(username: state.username.trim())
          : await _repository.checkUsername(firstName: state.firstName.trim(), lastName: state.lastName.trim());
      if (isClosed || ticket != _check) return;
      emit(
        state.copyWith(
          username: state.usernameEdited ? null : result.username,
          usernameStatus: result.available ? UsernameStatus.available : UsernameStatus.taken,
        ),
      );
    } on Object {
      // The server checks again on save; a failed live check just clears the hint.
      if (!isClosed && ticket == _check) emit(state.copyWith(usernameStatus: UsernameStatus.idle));
    }
  }

  @override
  Future<void> close() {
    _usernameTimer?.cancel();
    return super.close();
  }
}
