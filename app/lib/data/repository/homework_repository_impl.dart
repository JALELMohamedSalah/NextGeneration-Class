import '../../core/config/app_config.dart';
import '../../domain/model/content.dart';
import '../../domain/model/homework.dart';
import '../../domain/repositories/homework_repository.dart';
import '../dto/content_dto.dart';
import '../dto/homework_dto.dart';
import '../files/image_shrinker.dart';
import '../remote/homework_api.dart';
import 'api_guard.dart';

class HomeworkRepositoryImpl implements HomeworkRepository {
  HomeworkRepositoryImpl(this._api, this._config);

  final HomeworkApi _api;
  final AppConfig _config;

  @override
  Future<List<Assignment>> list() => guard(() async => [for (final a in await _api.list()) assignmentOf(a)]);

  @override
  Future<Assignment> assign(AssignmentDraft draft) => guard(() async => assignmentOf(await _api.assign(assignmentDraftJson(draft))));

  @override
  Future<AssignmentDetail> detail(String id) => guard(() async => assignmentDetailOf(await _api.detail(id)));

  @override
  Future<Assignment> changeDeadline(String id, DateTime deadlineAt) =>
      guard(() async => assignmentOf(await _api.deadline(id, deadlineAt.toUtc().toIso8601String())));

  @override
  Future<void> close(String id) => guard(() => _api.close(id));

  @override
  Future<DocumentView> submissionView(String submissionId) =>
      guard(() async => documentViewOf(await _api.submissionView(submissionId), _config.apiBaseUrl));

  @override
  Future<List<MyHomework>> mine({String? studentId}) =>
      guard(() async => [for (final h in await _api.mine(studentId: studentId)) myHomeworkOf(h)]);

  @override
  Future<MyHomeworkDetail> myDetail(String id, {String? studentId}) =>
      guard(() async => myHomeworkDetailOf(await _api.myDetail(id, studentId: studentId)));

  @override
  Future<MyHomeworkDetail> submit(String id, PickedFile file, {String? studentId, void Function(double progress)? onProgress}) =>
      guard(() async {
        final ready = await shrinkPhoto(file);
        final json = await _api.submit(
          id,
          ready.bytes,
          ready.name,
          studentId: studentId,
          onSendProgress: onProgress == null ? null : (sent, total) => onProgress(total <= 0 ? 0 : sent / total),
        );
        return myHomeworkDetailOf(json);
      });

  @override
  Future<DocumentView> mySubmissionView(String id, {String? studentId}) =>
      guard(() async => documentViewOf(await _api.mySubmissionView(id, studentId: studentId), _config.apiBaseUrl));

  @override
  Future<DocumentView> myCorrectionView(String id, {String? studentId}) =>
      guard(() async => documentViewOf(await _api.myCorrectionView(id, studentId: studentId), _config.apiBaseUrl));

  @override
  Future<List<ToCorrectGroup>> toCorrect() => guard(() async => [for (final g in await _api.toCorrect()) toCorrectGroupOf(g)]);

  @override
  Future<List<MissingWork>> missing() => guard(() async => [for (final m in await _api.missing()) missingWorkOf(m)]);

  @override
  Future<CorrectionView> correction(String assignmentId, String studentId) =>
      guard(() async => correctionViewOf(await _api.correction(assignmentId, studentId)));

  @override
  Future<CorrectionView> correct(String assignmentId, String studentId, {required double score, String? comment}) => guard(
    () async => correctionViewOf(
      await _api.correct(assignmentId, studentId, {
        'score': score,
        if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
      }),
    ),
  );

  @override
  Future<CorrectionView> attachCorrection(
    String assignmentId,
    String studentId,
    PickedFile file, {
    void Function(double progress)? onProgress,
  }) => guard(() async {
    final ready = await shrinkPhoto(file);
    final json = await _api.attachCorrection(
      assignmentId,
      studentId,
      ready.bytes,
      ready.name,
      onSendProgress: onProgress == null ? null : (sent, total) => onProgress(total <= 0 ? 0 : sent / total),
    );
    return correctionViewOf(json);
  });

  @override
  Future<CorrectionView> removeCorrectionFile(String assignmentId, String studentId) =>
      guard(() async => correctionViewOf(await _api.removeCorrectionFile(assignmentId, studentId)));

  @override
  Future<DocumentView> correctionFileView(String assignmentId, String studentId) =>
      guard(() async => documentViewOf(await _api.correctionFileView(assignmentId, studentId), _config.apiBaseUrl));
}
