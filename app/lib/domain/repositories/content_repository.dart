import '../model/content.dart';

/// The teacher's library (spec 04) and the pupil's and parent's Cours (spec 09).
abstract interface class ContentRepository {
  Future<Library> library();

  Future<Chapter> createChapter({required String subjectId, required String levelId, required String title});

  Future<Chapter> renameChapter(String id, String title);

  Future<void> deleteChapter(String id);

  Future<Chapter> shareChapter(String id, List<String> groupIds);

  /// [onProgress] goes from 0 to 1 while the file is sent.
  Future<ContentDocument> upload(DocumentDraft draft, PickedFile file, {void Function(double progress)? onProgress});

  Future<ContentDocument> update(String id, DocumentDraft draft);

  Future<ContentDocument> share(String id, List<String> groupIds);

  Future<void> archive(String id);

  /// For anyone allowed to read the document; opening it takes "Nouveau" off for a pupil or a parent.
  Future<DocumentView> view(String id);

  /// [studentId] is required for a parent (one of their children).
  Future<List<SharedDocument>> mine({String? studentId});
}
