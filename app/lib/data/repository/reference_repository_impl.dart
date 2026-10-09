import '../../domain/model/reference.dart';
import '../../domain/repositories/reference_repository.dart';
import '../dto/school_dto.dart';
import '../remote/school_api.dart';
import 'api_guard.dart';

class ReferenceRepositoryImpl implements ReferenceRepository {
  ReferenceRepositoryImpl(this._api);

  final SchoolApi _api;

  @override
  Future<Reference> load() => guard(() async => ReferenceDto(await _api.reference()).toDomain());

  @override
  Future<List<SubjectUsage>> subjectsWithUsage() => guard(
    () async => [
      for (final s in await _api.subjects()) SubjectUsage(subject: subjectOf(s), groupCount: (s['groupCount'] as num? ?? 0).toInt()),
    ],
  );

  @override
  Future<Subject> createSubject(SubjectDraft draft) => guard(() async => subjectOf(await _api.createSubject(_json(draft))));

  @override
  Future<Subject> updateSubject(String id, SubjectDraft draft) => guard(() async => subjectOf(await _api.updateSubject(id, _json(draft))));

  @override
  Future<void> deleteSubject(String id) => guard(() => _api.deleteSubject(id));

  static Json _json(SubjectDraft draft) => {'nameFr': draft.nameFr.trim(), 'nameAr': draft.nameAr.trim(), 'color': draft.color};
}
