import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/formatting.dart';
import '../../../core/network/api_failure.dart';
import '../../../domain/model/evaluation.dart';
import '../../../domain/repositories/evaluation_repository.dart';
import '../common/load_status.dart';

/// Why a typed score cannot be saved: above the scale, or not in half points.
enum ScoreProblem { tooHigh, halfPoints }

/// What the teacher typed for one pupil: the score as text ("11,5"), absent, a comment.
class ScoreEntry extends Equatable {
  const ScoreEntry({this.text = '', this.absent = false, this.comment = ''});

  factory ScoreEntry.of(EvaluationGrade grade) =>
      ScoreEntry(text: grade.score == null ? '' : scoreText(grade.score!), absent: grade.absent, comment: grade.comment ?? '');

  final String text;
  final bool absent;
  final String comment;

  double? get score => absent ? null : parseScore(text);

  ScoreEntry copyWith({String? text, bool? absent, String? comment}) =>
      ScoreEntry(text: text ?? this.text, absent: absent ?? this.absent, comment: comment ?? this.comment);

  @override
  List<Object?> get props => [text, absent, comment];
}

class EvaluationState extends Equatable {
  const EvaluationState({
    this.status = LoadStatus.loading,
    this.detail,
    this.entries = const {},
    this.saved = const {},
    this.saving = false,
    this.failure,
  });

  final LoadStatus status;
  final EvaluationDetail? detail;

  /// By pupil, as typed now; [saved] as the server has it.
  final Map<String, ScoreEntry> entries;
  final Map<String, ScoreEntry> saved;
  final bool saving;
  final ApiFailure? failure;

  Evaluation? get evaluation => detail?.evaluation;

  ScoreEntry entryOf(String studentId) => entries[studentId] ?? const ScoreEntry();

  /// Something typed since the last save.
  bool get dirty => entries.entries.any((e) => e.value != (saved[e.key] ?? const ScoreEntry()));

  ScoreProblem? problemOf(String studentId) {
    final entry = entryOf(studentId);
    if (entry.absent || entry.text.trim().isEmpty) return null;
    final score = entry.score;
    final max = evaluation?.maxScore ?? 20;
    if (score == null || score < 0 || (score * 2) != (score * 2).roundToDouble()) return ScoreProblem.halfPoints;
    if (score > max) return ScoreProblem.tooHigh;
    return null;
  }

  bool get valid => entries.keys.every((id) => problemOf(id) == null);

  /// Live, as typed: the tiles follow the keyboard.
  List<double> get _scores => [
    for (final e in entries.entries)
      if (!e.value.absent && e.value.score != null && problemOf(e.key) == null) e.value.score!,
  ];

  int get typed => _scores.length;

  int get absent => entries.values.where((e) => e.absent).length;

  int get pupils => detail?.grades.length ?? 0;

  int get toType => pupils - typed - absent;

  double? get average => _scores.isEmpty ? null : _scores.reduce((a, b) => a + b) / _scores.length;

  EvaluationState copyWith({
    LoadStatus? status,
    EvaluationDetail? detail,
    Map<String, ScoreEntry>? entries,
    Map<String, ScoreEntry>? saved,
    bool? saving,
    ApiFailure? Function()? failure,
  }) => EvaluationState(
    status: status ?? this.status,
    detail: detail ?? this.detail,
    entries: entries ?? this.entries,
    saved: saved ?? this.saved,
    saving: saving ?? this.saving,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [status, detail, entries, saved, saving, failure?.code];
}

/// The score table of a paper evaluation (design `r2/Evaluation.png`): type, Tab, save the whole table.
class EvaluationCubit extends Cubit<EvaluationState> {
  EvaluationCubit(this._repository, this.id) : super(const EvaluationState());

  final EvaluationRepository _repository;
  final String id;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading, failure: () => null));
    try {
      final detail = await _repository.detail(id);
      if (isClosed) return;
      _show(detail);
    } on Object catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.failure, failure: () => ApiFailure.from(error)));
    }
  }

  /// After "Modifier", or right after the evaluation was created.
  void replaced(EvaluationDetail detail) {
    final typed = state.entries;
    _show(detail);
    // What was typed and not saved stays.
    if (typed.isNotEmpty) emit(state.copyWith(entries: {...state.entries, ...typed}));
  }

  void setScore(String studentId, String text) => _change(studentId, (e) => e.copyWith(text: text, absent: false));

  void setAbsent(String studentId, bool absent) => _change(studentId, (e) => e.copyWith(absent: absent));

  void setComment(String studentId, String comment) => _change(studentId, (e) => e.copyWith(comment: comment));

  /// The whole table; null when saved, or when nothing changed.
  Future<ApiFailure?> save() async {
    if (state.saving || !state.valid || !state.dirty) return null;
    emit(state.copyWith(saving: true));
    try {
      final changed = [
        for (final e in state.entries.entries)
          if (e.value != (state.saved[e.key] ?? const ScoreEntry()))
            GradeInput(studentId: e.key, score: e.value.score, absent: e.value.absent, comment: e.value.comment),
      ];
      final detail = await _repository.saveGrades(id, changed);
      if (isClosed) return null;
      _show(detail);
      return null;
    } on Object catch (error) {
      if (!isClosed) emit(state.copyWith(saving: false));
      return ApiFailure.from(error);
    }
  }

  void _show(EvaluationDetail detail) {
    final entries = {for (final g in detail.grades) g.studentId: ScoreEntry.of(g)};
    emit(state.copyWith(status: LoadStatus.ready, detail: detail, entries: entries, saved: entries, saving: false));
  }

  void _change(String studentId, ScoreEntry Function(ScoreEntry) update) =>
      emit(state.copyWith(entries: {...state.entries, studentId: update(state.entryOf(studentId))}));
}
