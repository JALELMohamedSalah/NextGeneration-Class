import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/formatting.dart';
import '../../../core/network/api_failure.dart';
import '../../../core/platform/file_chooser.dart';
import '../../../domain/model/content.dart';
import '../../../domain/model/homework.dart';
import '../../../domain/repositories/homework_repository.dart';
import '../common/load_status.dart';

class CorrectionState extends Equatable {
  const CorrectionState({
    this.status = LoadStatus.loading,
    this.assignment,
    this.copies = const [],
    this.index = 0,
    this.view,
    this.score = '',
    this.comment = '',
    this.scoreError = false,
    this.saving = false,
    this.progress,
    this.problem,
    this.failure,
  });

  final LoadStatus status;
  final Assignment? assignment;

  /// The pupils to go through: the copy opened first, then those waiting, oldest first.
  final List<RecipientRow> copies;
  final int index;

  /// The copy shown; null while it loads.
  final CorrectionView? view;

  /// What the teacher typed.
  final String score;
  final String comment;
  final bool scoreError;
  final bool saving;

  /// 0 to 1 while the corrected copy is sent.
  final double? progress;
  final FileProblem? problem;
  final ApiFailure? failure;

  RecipientRow? get current => index < copies.length ? copies[index] : null;

  RecipientRow? get following => index + 1 < copies.length ? copies[index + 1] : null;

  bool get attaching => progress != null;

  CorrectionState copyWith({
    LoadStatus? status,
    Assignment? assignment,
    List<RecipientRow>? copies,
    int? index,
    CorrectionView? Function()? view,
    String? score,
    String? comment,
    bool? scoreError,
    bool? saving,
    double? Function()? progress,
    FileProblem? Function()? problem,
    ApiFailure? Function()? failure,
  }) => CorrectionState(
    status: status ?? this.status,
    assignment: assignment ?? this.assignment,
    copies: copies ?? this.copies,
    index: index ?? this.index,
    view: view != null ? view() : this.view,
    score: score ?? this.score,
    comment: comment ?? this.comment,
    scoreError: scoreError ?? this.scoreError,
    saving: saving ?? this.saving,
    progress: progress != null ? progress() : this.progress,
    problem: problem != null ? problem() : this.problem,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [
    status,
    assignment,
    copies,
    index,
    view,
    score,
    comment,
    scoreError,
    saving,
    progress,
    problem,
    failure?.code,
  ];
}

/// What a save led to: the next copy, the end of the copies, or a refusal shown on the screen.
enum SaveOutcome { saved, finished, refused }

/// The correction screen (design `r2/Corriger.png`): one copy after the other, "Enregistrer et suivant".
class CorrectionCubit extends Cubit<CorrectionState> {
  CorrectionCubit(this._repository, this._chooser, this.assignmentId, this.studentId) : super(const CorrectionState());

  final HomeworkRepository _repository;
  final FileChooser _chooser;
  final String assignmentId;

  /// The copy opened first.
  final String studentId;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading, failure: () => null));
    try {
      final detail = await _repository.detail(assignmentId);
      if (isClosed) return;
      final waiting = detail.recipients.where((r) => r.status == HomeworkStatus.submitted || r.status == HomeworkStatus.late).toList()
        ..sort((a, b) => (a.submittedAt ?? DateTime(0)).compareTo(b.submittedAt ?? DateTime(0)));
      final first = detail.recipients.where((r) => r.studentId == studentId).firstOrNull;
      final copies = [if (first != null && !waiting.contains(first)) first, ...waiting];
      final index = copies.indexWhere((r) => r.studentId == studentId);
      emit(state.copyWith(assignment: detail.assignment, copies: copies, index: index < 0 ? 0 : index));
      await _open(index < 0 ? 0 : index);
    } on Object catch (error) {
      if (!isClosed) emit(state.copyWith(status: LoadStatus.failure, failure: () => ApiFailure.from(error)));
    }
  }

  Future<void> previous() => _go(state.index - 1);

  Future<void> next() => _go(state.index + 1);

  void setScore(String value) => emit(state.copyWith(score: value, scoreError: false));

  void setComment(String value) => emit(state.copyWith(comment: value));

  /// A quick phrase ("Très bien !") goes after what is already written.
  void addPhrase(String phrase) {
    final current = state.comment.trim();
    emit(state.copyWith(comment: current.isEmpty ? phrase : '$current $phrase'));
  }

  /// Saves the score and the comment; with [andNext], opens the next copy (or tells the copies are done).
  Future<SaveOutcome> save({bool andNext = false}) async {
    final view = state.view;
    if (view == null || state.saving) return SaveOutcome.refused;
    final score = parseScore(state.score);
    if (score == null || score < 0 || score > view.maxScore || (score * 2) != (score * 2).roundToDouble()) {
      emit(state.copyWith(scoreError: true));
      return SaveOutcome.refused;
    }
    emit(state.copyWith(saving: true, failure: () => null));
    try {
      final saved = await _repository.correct(assignmentId, view.studentId, score: score, comment: state.comment);
      if (isClosed) return SaveOutcome.refused;
      final copies = [
        for (final r in state.copies)
          r.studentId == saved.studentId
              ? RecipientRow(
                  studentId: r.studentId,
                  firstName: r.firstName,
                  lastName: r.lastName,
                  status: saved.status,
                  submittedAt: r.submittedAt,
                  submissionId: r.submissionId,
                  score: saved.score,
                )
              : r,
      ];
      emit(state.copyWith(saving: false, view: () => saved, copies: copies));
      if (!andNext) return SaveOutcome.saved;
      if (state.following == null) return SaveOutcome.finished;
      await _open(state.index + 1);
      return SaveOutcome.saved;
    } on Object catch (error) {
      if (!isClosed) emit(state.copyWith(saving: false, failure: () => ApiFailure.from(error)));
      return SaveOutcome.refused;
    }
  }

  /// The teacher's corrected copy: the scanned PDF, or a PDF or photo from the device.
  Future<void> attach(PickedFile file) async {
    final view = state.view;
    if (view == null || state.attaching) return;
    final problem = file.problem ?? (file.extension == 'docx' ? FileProblem.unsupported : null);
    if (problem != null) {
      emit(state.copyWith(problem: () => problem));
      return;
    }
    emit(state.copyWith(progress: () => 0, problem: () => null, failure: () => null));
    try {
      final saved = await _repository.attachCorrection(
        assignmentId,
        view.studentId,
        file,
        onProgress: (p) {
          if (!isClosed) emit(state.copyWith(progress: () => p));
        },
      );
      if (!isClosed) emit(state.copyWith(progress: () => null, view: () => saved));
    } on Object catch (error) {
      if (!isClosed) emit(state.copyWith(progress: () => null, failure: () => ApiFailure.from(error)));
    }
  }

  Future<void> chooseAndAttach() async {
    final PickedFile? picked;
    try {
      picked = await _chooser.pickDocument();
    } on Object catch (error) {
      if (!isClosed) emit(state.copyWith(failure: () => ApiFailure.from(error)));
      return;
    }
    if (picked != null && !isClosed) await attach(picked);
  }

  Future<void> removeFile() async {
    final view = state.view;
    if (view == null) return;
    try {
      final saved = await _repository.removeCorrectionFile(assignmentId, view.studentId);
      if (!isClosed) emit(state.copyWith(view: () => saved));
    } on Object catch (error) {
      if (!isClosed) emit(state.copyWith(failure: () => ApiFailure.from(error)));
    }
  }

  Future<void> _go(int index) async {
    if (index < 0 || index >= state.copies.length || index == state.index) return;
    await _open(index);
  }

  Future<void> _open(int index) async {
    if (state.copies.isEmpty) {
      emit(state.copyWith(status: LoadStatus.ready));
      return;
    }
    emit(
      state.copyWith(index: index, view: () => null, score: '', comment: '', scoreError: false, problem: () => null, failure: () => null),
    );
    try {
      final view = await _repository.correction(assignmentId, state.copies[index].studentId);
      if (isClosed || state.index != index) return;
      emit(
        state.copyWith(
          status: LoadStatus.ready,
          view: () => view,
          score: view.score == null ? '' : scoreText(view.score!),
          comment: view.comment ?? '',
        ),
      );
    } on Object catch (error) {
      if (!isClosed) emit(state.copyWith(status: LoadStatus.failure, failure: () => ApiFailure.from(error)));
    }
  }
}
