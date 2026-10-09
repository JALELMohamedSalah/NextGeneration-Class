import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_failure.dart';
import '../../../core/platform/file_chooser.dart';
import '../../../domain/model/student_import.dart';
import '../../../domain/repositories/student_import_repository.dart';

enum ImportStep { file, check, done }

class StudentImportState extends Equatable {
  const StudentImportState({
    this.step = ImportStep.file,
    this.groupId,
    this.levelId,
    this.createLogins = false,
    this.reading = false,
    this.importing = false,
    this.preview,
    this.kept = const {},
    this.result,
    this.failure,
  });

  final ImportStep step;

  /// For everyone in the file; [levelId] when a line has no level.
  final String? groupId;
  final String? levelId;

  /// The pupils' own logins too (parents only by default, user decision 2026-10-08).
  final bool createLogins;
  final bool reading;
  final bool importing;
  final ImportPreview? preview;

  /// The lines the teacher keeps.
  final Set<int> kept;
  final ImportResult? result;
  final ApiFailure? failure;

  List<ImportRow> get keptRows => [
    for (final row in preview?.rows ?? const <ImportRow>[])
      if (kept.contains(row.line)) row,
  ];

  /// Parent accounts the import will create: the new phones among the lines kept.
  int get newParents => {
    for (final row in keptRows)
      if (row.hasParent && row.state != ImportState.parentKnown) row.parentPhone,
  }.length;

  StudentImportState copyWith({
    ImportStep? step,
    String? Function()? groupId,
    String? Function()? levelId,
    bool? createLogins,
    bool? reading,
    bool? importing,
    ImportPreview? Function()? preview,
    Set<int>? kept,
    ImportResult? Function()? result,
    ApiFailure? Function()? failure,
  }) => StudentImportState(
    step: step ?? this.step,
    groupId: groupId != null ? groupId() : this.groupId,
    levelId: levelId != null ? levelId() : this.levelId,
    createLogins: createLogins ?? this.createLogins,
    reading: reading ?? this.reading,
    importing: importing ?? this.importing,
    preview: preview != null ? preview() : this.preview,
    kept: kept ?? this.kept,
    result: result != null ? result() : this.result,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [step, groupId, levelId, createLogins, reading, importing, preview, kept, result, failure?.code];
}

/// Importing a class (spec 02 "CSV import", design `r2/ImportEleves*.png`): choose the file, check every line,
/// then hand over the login details. Nothing is created before [importKept].
class StudentImportCubit extends Cubit<StudentImportState> {
  StudentImportCubit(this._repository, this._chooser) : super(const StudentImportState());

  final StudentImportRepository _repository;
  final FileChooser _chooser;

  /// [levelOfGroup]: the group's level, taken as the default level when none was chosen.
  void setGroup(String? groupId, {String? levelOfGroup}) => emit(
    state.copyWith(groupId: () => groupId, levelId: state.levelId == null && levelOfGroup != null ? () => levelOfGroup : null),
  );

  void setLevel(String? levelId) => emit(state.copyWith(levelId: () => levelId));

  void setCreateLogins(bool value) => emit(state.copyWith(createLogins: value));

  /// Opens the picker, then sends the file to be read; the lines ready (or with a known parent) start ticked.
  Future<void> chooseFile() async {
    if (state.reading) return;
    final file = await _chooser.pickSpreadsheet();
    if (file == null || isClosed) return;
    emit(state.copyWith(reading: true, failure: () => null));
    try {
      final preview = await _repository.preview(file, groupId: state.groupId, levelId: state.levelId);
      if (isClosed) return;
      emit(
        state.copyWith(
          step: ImportStep.check,
          reading: false,
          preview: () => preview,
          kept: {
            for (final row in preview.rows)
              if (row.keptByDefault) row.line,
          },
        ),
      );
    } on Object catch (error) {
      if (isClosed) return;
      emit(state.copyWith(reading: false, failure: () => ApiFailure.from(error)));
    }
  }

  /// A line in error cannot be kept.
  void toggle(ImportRow row) {
    if (!row.importable) return;
    final kept = {...state.kept};
    kept.contains(row.line) ? kept.remove(row.line) : kept.add(row.line);
    emit(state.copyWith(kept: kept));
  }

  /// Back to the first step, the options kept.
  void restart() => emit(
    StudentImportState(groupId: state.groupId, levelId: state.levelId, createLogins: state.createLogins),
  );

  Future<void> importKept() async {
    if (state.importing || state.keptRows.isEmpty) return;
    emit(state.copyWith(importing: true, failure: () => null));
    try {
      final result = await _repository.importRows(state.keptRows, createLogins: state.createLogins);
      if (isClosed) return;
      emit(state.copyWith(step: ImportStep.done, importing: false, result: () => result));
    } on Object catch (error) {
      if (isClosed) return;
      emit(state.copyWith(importing: false, failure: () => ApiFailure.from(error)));
    }
  }

  String templateUrl(String languageCode) => _repository.templateUrl(languageCode);
}
