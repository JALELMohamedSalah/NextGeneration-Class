import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_failure.dart';
import '../../../domain/model/evaluation.dart';
import '../../../domain/model/homework.dart';
import '../../../domain/repositories/evaluation_repository.dart';
import '../../../domain/repositories/homework_repository.dart';
import '../common/load_status.dart';

/// "À corriger" first (design `r2/ACorriger.png`), then in progress, finished, and paper evaluations
/// (design `r2/NouvelleEvaluation.png`).
enum HomeworkTab { toCorrect, open, done, evaluations }

class HomeworkListState extends Equatable {
  const HomeworkListState({
    this.status = LoadStatus.loading,
    this.items = const [],
    this.queue = const [],
    this.evaluations = const [],
    this.tab = HomeworkTab.open,
    this.groupId,
    this.subjectId,
    this.failure,
  });

  final LoadStatus status;
  final List<Assignment> items;

  /// Copies waiting, grouped by homework, the oldest first (the server's order).
  final List<ToCorrectGroup> queue;

  /// Paper evaluations, latest first (the server's order).
  final List<Evaluation> evaluations;
  final HomeworkTab tab;
  final String? groupId;
  final String? subjectId;
  final ApiFailure? failure;

  bool _shown(Assignment a) => (groupId == null || a.group.id == groupId) && (subjectId == null || a.subjectId == subjectId);

  List<Assignment> _of(HomeworkTab tab) => items.where((a) => (tab == HomeworkTab.done) == a.done && _shown(a)).toList();

  /// The queue under the filters.
  List<ToCorrectGroup> get visibleQueue => queue.where((g) => _shown(g.assignment)).toList();

  /// Evaluations under the group filter.
  List<Evaluation> get visibleEvaluations => evaluations.where((e) => groupId == null || e.group.id == groupId).toList();

  /// Copies for "À corriger", evaluations for theirs, homework for the two other tabs.
  int countOf(HomeworkTab tab) => switch (tab) {
    HomeworkTab.toCorrect => visibleQueue.fold(0, (sum, g) => sum + g.items.length),
    HomeworkTab.evaluations => visibleEvaluations.length,
    _ => _of(tab).length,
  };

  /// In progress: nearest deadline first. Finished: latest first.
  List<Assignment> get visible {
    final list = _of(tab)..sort((a, b) => a.deadlineAt.compareTo(b.deadlineAt));
    return tab == HomeworkTab.open ? list : list.reversed.toList();
  }

  /// The subjects of the teacher's homework (for the "Matière" filter).
  Set<String> get subjectIds => {for (final a in items) ?a.subjectId};

  HomeworkListState copyWith({
    LoadStatus? status,
    List<Assignment>? items,
    List<ToCorrectGroup>? queue,
    List<Evaluation>? evaluations,
    HomeworkTab? tab,
    String? Function()? groupId,
    String? Function()? subjectId,
    ApiFailure? Function()? failure,
  }) => HomeworkListState(
    status: status ?? this.status,
    items: items ?? this.items,
    queue: queue ?? this.queue,
    evaluations: evaluations ?? this.evaluations,
    tab: tab ?? this.tab,
    groupId: groupId != null ? groupId() : this.groupId,
    subjectId: subjectId != null ? subjectId() : this.subjectId,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [status, items, queue, evaluations, tab, groupId, subjectId, failure?.code];
}

/// Devoirs (designs `r2/Devoirs.png`, `r2/ACorriger.png`): the copies to correct, and the teacher's homework.
class HomeworkListCubit extends Cubit<HomeworkListState> {
  HomeworkListCubit(this._repository, {EvaluationRepository? evaluations}) : _evaluations = evaluations, super(const HomeworkListState());

  final HomeworkRepository _repository;
  final EvaluationRepository? _evaluations;

  /// The first load opens on "À corriger" when copies are waiting.
  Future<void> load() async {
    final first = state.items.isEmpty && state.queue.isEmpty;
    emit(state.copyWith(status: LoadStatus.loading, failure: () => null));
    try {
      final (items, queue) = await (_repository.list(), _repository.toCorrect()).wait;
      if (isClosed) return;
      emit(
        state.copyWith(
          status: LoadStatus.ready,
          items: items,
          queue: queue,
          tab: first ? (queue.isEmpty ? HomeworkTab.open : HomeworkTab.toCorrect) : null,
        ),
      );
      await _loadEvaluations();
    } on ParallelWaitError<(List<Assignment>?, List<ToCorrectGroup>?), (AsyncError?, AsyncError?)> catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.failure, failure: () => ApiFailure.from((error.errors.$1 ?? error.errors.$2)!.error)));
    } on Object catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.failure, failure: () => ApiFailure.from(error)));
    }
  }

  /// Apart from homework: a failure here leaves the homework tabs working.
  Future<void> _loadEvaluations() async {
    final repository = _evaluations;
    if (repository == null) return;
    try {
      final evaluations = await repository.list();
      if (!isClosed) emit(state.copyWith(evaluations: evaluations));
    } on Object {
      // Read again at the next load.
    }
  }

  /// An evaluation created or changed: in its tab at once.
  void evaluationSaved(Evaluation evaluation) {
    if (isClosed) return;
    final others = state.evaluations.where((e) => e.id != evaluation.id);
    emit(state.copyWith(evaluations: [evaluation, ...others], tab: HomeworkTab.evaluations));
  }

  void setTab(HomeworkTab tab) => emit(state.copyWith(tab: tab));

  void filterGroup(String? groupId) => emit(state.copyWith(groupId: () => groupId));

  void filterSubject(String? subjectId) => emit(state.copyWith(subjectId: () => subjectId));

  /// A homework given or changed elsewhere: in the list at once.
  void saved(Assignment assignment) {
    if (isClosed) return;
    final others = state.items.where((a) => a.id != assignment.id);
    emit(state.copyWith(items: [...others, assignment], tab: assignment.done ? HomeworkTab.done : HomeworkTab.open));
  }
}
