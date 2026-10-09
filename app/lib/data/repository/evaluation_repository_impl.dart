import '../../domain/model/evaluation.dart';
import '../../domain/repositories/evaluation_repository.dart';
import '../dto/school_dto.dart';
import '../remote/evaluation_api.dart';
import 'api_guard.dart';

class EvaluationRepositoryImpl implements EvaluationRepository {
  EvaluationRepositoryImpl(this._api);

  final EvaluationApi _api;

  @override
  Future<List<Evaluation>> list() => guard(() async => [for (final e in await _api.list()) evaluationOf(e)]);

  @override
  Future<EvaluationDetail> create(EvaluationDraft draft) =>
      guard(() async => evaluationDetailOf(await _api.create(_body(draft, withGroup: true))));

  @override
  Future<EvaluationDetail> detail(String id) => guard(() async => evaluationDetailOf(await _api.detail(id)));

  @override
  Future<EvaluationDetail> update(String id, EvaluationDraft draft) =>
      guard(() async => evaluationDetailOf(await _api.update(id, _body(draft))));

  @override
  Future<EvaluationDetail> saveGrades(String id, List<GradeInput> grades) => guard(
    () async => evaluationDetailOf(
      await _api.saveGrades(id, [
        for (final g in grades)
          {
            'studentId': g.studentId,
            'score': g.absent ? null : g.score,
            'absent': g.absent,
            'comment': (g.comment?.trim().isEmpty ?? true) ? null : g.comment!.trim(),
          },
      ]),
    ),
  );

  static Json _body(EvaluationDraft draft, {bool withGroup = false}) => {
    if (withGroup) 'groupId': draft.groupId,
    'title': draft.title.trim(),
    'heldOn': dayParam(draft.heldOn),
    'maxScore': draft.maxScore,
    'chapterId': draft.chapterId,
  };
}

Evaluation evaluationOf(Json json) {
  final chapter = json['chapter'] as Json?;
  return Evaluation(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    group: groupRef(json['group'] as Json),
    heldOn: day(json['heldOn'])!,
    maxScore: (json['maxScore'] as num? ?? 20).toInt(),
    chapterId: chapter?['id'] as String?,
    chapterTitle: chapter?['title'] as String?,
    pupils: (json['pupils'] as num? ?? 0).toInt(),
    graded: (json['graded'] as num? ?? 0).toInt(),
    absent: (json['absent'] as num? ?? 0).toInt(),
    average: (json['average'] as num?)?.toDouble(),
  );
}

EvaluationDetail evaluationDetailOf(Json json) => EvaluationDetail(
  evaluation: evaluationOf(json['evaluation'] as Json),
  grades: [
    for (final g in jsonList(json['grades']))
      EvaluationGrade(
        studentId: g['studentId'] as String,
        firstName: g['firstName'] as String? ?? '',
        lastName: g['lastName'] as String? ?? '',
        score: (g['score'] as num?)?.toDouble(),
        absent: g['absent'] as bool? ?? false,
        comment: g['comment'] as String?,
      ),
  ],
);
