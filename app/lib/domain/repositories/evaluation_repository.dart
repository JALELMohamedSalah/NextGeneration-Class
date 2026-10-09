import '../model/evaluation.dart';

/// Paper evaluations (`/evaluations`), teacher only. Every call throws an `ApiFailure` when refused.
abstract interface class EvaluationRepository {
  /// Latest first.
  Future<List<Evaluation>> list();

  Future<EvaluationDetail> create(EvaluationDraft draft);

  Future<EvaluationDetail> detail(String id);

  /// "Modifier": title, date, scale, chapter.
  Future<EvaluationDetail> update(String id, EvaluationDraft draft);

  /// The whole table at once.
  Future<EvaluationDetail> saveGrades(String id, List<GradeInput> grades);
}
