import '../../core/config/app_config.dart';
import '../../domain/model/content.dart';
import '../../domain/repositories/content_repository.dart';
import '../dto/content_dto.dart';
import '../files/image_shrinker.dart';
import '../remote/content_api.dart';
import 'api_guard.dart';

class ContentRepositoryImpl implements ContentRepository {
  ContentRepositoryImpl(this._api, this._config);

  final ContentApi _api;
  final AppConfig _config;

  @override
  Future<Library> library() => guard(() async => libraryOf(await _api.library()));

  @override
  Future<Chapter> createChapter({required String subjectId, required String levelId, required String title}) =>
      guard(() async => chapterOf(await _api.createChapter({'subjectId': subjectId, 'levelId': levelId, 'title': title.trim()})));

  @override
  Future<Chapter> renameChapter(String id, String title) => guard(() async => chapterOf(await _api.renameChapter(id, title.trim())));

  @override
  Future<void> deleteChapter(String id) => guard(() => _api.deleteChapter(id));

  @override
  Future<Chapter> shareChapter(String id, List<String> groupIds) => guard(() async => chapterOf(await _api.shareChapter(id, groupIds)));

  @override
  Future<ContentDocument> upload(DocumentDraft draft, PickedFile file, {void Function(double progress)? onProgress}) => guard(() async {
    final ready = await shrinkPhoto(file);
    final json = await _api.upload(
      draftJson(draft, withGroups: true),
      ready.bytes,
      ready.name,
      onSendProgress: onProgress == null ? null : (sent, total) => onProgress(total <= 0 ? 0 : sent / total),
    );
    return documentOf(json);
  });

  @override
  Future<ContentDocument> update(String id, DocumentDraft draft) => guard(() async => documentOf(await _api.update(id, draftJson(draft))));

  @override
  Future<ContentDocument> share(String id, List<String> groupIds) => guard(() async => documentOf(await _api.share(id, groupIds)));

  @override
  Future<void> archive(String id) => guard(() => _api.archive(id));

  @override
  Future<DocumentView> view(String id) => guard(() async => documentViewOf(await _api.view(id), _config.apiBaseUrl));

  @override
  Future<List<SharedDocument>> mine({String? studentId}) =>
      guard(() async => [for (final d in await _api.mine(studentId: studentId)) sharedDocumentOf(d)]);
}
