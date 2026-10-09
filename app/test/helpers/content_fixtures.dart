import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:ngclass/core/di/injection.dart';
import 'package:ngclass/core/network/api_failure.dart';
import 'package:ngclass/core/platform/file_chooser.dart';
import 'package:ngclass/core/platform/file_opener.dart';
import 'package:ngclass/core/platform/photo_source.dart';
import 'package:ngclass/domain/model/content.dart';
import 'package:ngclass/domain/model/localized_text.dart';
import 'package:ngclass/domain/model/scan.dart';
import 'package:ngclass/domain/repositories/content_repository.dart';
import 'package:ngclass/domain/services/scan_processor.dart';
import 'package:ngclass/view/stateManager/library/library_cubit.dart';

import 'fakes.dart';

/// The library of the mockups (`r2/Contenus.png`): Maths, 4ème année, "Les fractions".
const fractions = Chapter(id: 'ch-fr', subjectId: 'math', levelId: 'l4', title: 'Les fractions', position: 1);
const multiplication = Chapter(id: 'ch-mul', subjectId: 'math', levelId: 'l4', title: 'La multiplication', position: 2);

ContentDocument doc(
  String id,
  String title, {
  String? chapterId = 'ch-fr',
  ContentTag tag = ContentTag.serie,
  ContentStatus status = ContentStatus.published,
  FileKind kind = FileKind.pdf,
  int? pages = 3,
  List<String> shared = const ['g4a'],
  DateTime? updatedAt,
}) => ContentDocument(
  id: id,
  title: title,
  subjectId: 'math',
  levelId: 'l4',
  chapterId: chapterId,
  tag: tag,
  status: status,
  kind: kind,
  fileName:
      '$id.${kind == FileKind.pdf
          ? 'pdf'
          : kind == FileKind.image
          ? 'jpg'
          : 'docx'}',
  sizeBytes: 1258291,
  pageCount: kind == FileKind.pdf ? pages : null,
  sharedGroupIds: shared,
  updatedAt: updatedAt ?? DateTime.utc(2026, 10, 5, 9),
);

Library sampleLibrary() => Library(
  chapters: const [fractions, multiplication],
  documents: [
    doc('serie2', 'Série 2 : les fractions'),
    doc('lecon', 'Leçon : les fractions simples', tag: ContentTag.cours, pages: 2, updatedAt: DateTime.utc(2026, 9, 28, 9)),
    doc('corrige', 'Corrigé de la série 2', tag: ContentTag.corrige, status: ContentStatus.draft, shared: const []),
    doc('photo', 'Photo du tableau, 2 octobre', tag: ContentTag.autre, kind: FileKind.image),
    doc('fiche', 'Fiche de révision', tag: ContentTag.autre, kind: FileKind.word, shared: const []),
    doc('table', 'Table de 7', chapterId: 'ch-mul', updatedAt: DateTime.utc(2026, 9, 1, 9)),
  ],
);

const mathRef = SubjectRef(id: 'math', name: math, color: '#2B3990', position: 1);
const lectureRef = SubjectRef(
  id: 'lec',
  name: LocalizedText(fr: 'Lecture', ar: 'القراءة'),
  color: '#12A39A',
  position: 2,
);

/// A pupil's Cours: two Maths documents in "Les fractions", one new, and a Lecture text.
List<SharedDocument> sampleCours() => [
  SharedDocument(
    id: 'serie2',
    title: 'Série 2 : les fractions',
    tag: ContentTag.serie,
    kind: FileKind.pdf,
    pageCount: 3,
    subject: mathRef,
    chapter: const ChapterRef(id: 'ch-fr', title: 'Les fractions', position: 1),
    sharedAt: DateTime.utc(2026, 10, 5),
    isNew: true,
  ),
  SharedDocument(
    id: 'photo',
    title: 'Photo du tableau, 2 octobre',
    tag: ContentTag.autre,
    kind: FileKind.image,
    subject: mathRef,
    chapter: const ChapterRef(id: 'ch-fr', title: 'Les fractions', position: 1),
    sharedAt: DateTime.utc(2026, 10, 2),
  ),
  SharedDocument(
    id: 'corbeau',
    title: 'Le corbeau et le renard',
    tag: ContentTag.cours,
    kind: FileKind.pdf,
    pageCount: 1,
    subject: lectureRef,
    chapter: const ChapterRef(id: 'ch-contes', title: 'Contes et fables', position: 1),
    sharedAt: DateTime.utc(2026, 9, 30),
  ),
];

DocumentView viewOf(String id, {FileKind kind = FileKind.pdf, int pages = 3}) => DocumentView(
  id: id,
  title: 'Série 2 : les fractions',
  subjectName: math,
  chapterTitle: 'Les fractions',
  kind: kind,
  tag: ContentTag.serie,
  fileName: '$id.pdf',
  sizeBytes: 1258291,
  pageUrls: [for (var i = 1; i <= (kind == FileKind.word ? 0 : pages); i++) 'http://localhost/files/$id-p$i'],
  downloadUrl: 'http://localhost/files/$id-download',
);

/// Keeps the library in memory and records what was asked.
class FakeContentRepository implements ContentRepository {
  FakeContentRepository({Library? library, List<SharedDocument>? cours})
    : library_ = library ?? sampleLibrary(),
      cours = cours ?? sampleCours();

  Library library_;
  List<SharedDocument> cours;
  ApiFailure? failure;
  final List<(DocumentDraft, PickedFile)> uploads = [];
  final List<(String, DocumentDraft)> updates = [];
  final List<(String, List<String>)> shares = [];
  final List<String> archived = [];
  final List<String?> mineAskedFor = [];
  final Map<String, DocumentView> views = {};

  @override
  Future<Library> library() async {
    if (failure != null) throw failure!;
    return library_;
  }

  @override
  Future<Chapter> createChapter({required String subjectId, required String levelId, required String title}) async {
    final chapter = Chapter(id: 'ch-new', subjectId: subjectId, levelId: levelId, title: title.trim(), position: 9);
    library_ = library_.copyWith(chapters: [...library_.chapters, chapter]);
    return chapter;
  }

  @override
  Future<Chapter> renameChapter(String id, String title) async => library_.chapters.firstWhere((c) => c.id == id).copyWith(title: title);

  @override
  Future<void> deleteChapter(String id) async {
    library_ = Library(
      chapters: library_.chapters.where((c) => c.id != id).toList(),
      documents: [for (final d in library_.documents) d.chapterId == id ? _withoutChapter(d) : d],
    );
  }

  @override
  Future<Chapter> shareChapter(String id, List<String> groupIds) async {
    shares.add((id, groupIds));
    return library_.chapters.firstWhere((c) => c.id == id).copyWith(sharedGroupIds: groupIds);
  }

  @override
  Future<ContentDocument> upload(DocumentDraft draft, PickedFile file, {void Function(double progress)? onProgress}) async {
    if (failure != null) throw failure!;
    uploads.add((draft, file));
    onProgress?.call(0.5);
    onProgress?.call(1);
    return ContentDocument(
      id: 'uploaded',
      title: draft.title.trim(),
      subjectId: draft.subjectId,
      levelId: draft.levelId,
      chapterId: draft.chapterId,
      tag: draft.tag,
      status: draft.draft ? ContentStatus.draft : ContentStatus.published,
      kind: FileKind.pdf,
      fileName: file.name,
      sizeBytes: file.size,
      pageCount: 2,
      sharedGroupIds: draft.groupIds,
      updatedAt: DateTime.utc(2026, 10, 6, 11),
    );
  }

  @override
  Future<ContentDocument> update(String id, DocumentDraft draft) async {
    updates.add((id, draft));
    final old = library_.documents.firstWhere((d) => d.id == id);
    return ContentDocument(
      id: id,
      title: draft.title.trim(),
      subjectId: draft.subjectId,
      levelId: draft.levelId,
      chapterId: draft.chapterId,
      tag: draft.tag,
      status: draft.draft ? ContentStatus.draft : ContentStatus.published,
      kind: old.kind,
      fileName: old.fileName,
      sizeBytes: old.sizeBytes,
      pageCount: old.pageCount,
      sharedGroupIds: draft.draft ? const [] : old.sharedGroupIds,
      updatedAt: DateTime.utc(2026, 10, 6, 11),
    );
  }

  @override
  Future<ContentDocument> share(String id, List<String> groupIds) async {
    shares.add((id, groupIds));
    return library_.documents.firstWhere((d) => d.id == id).copyWith(sharedGroupIds: groupIds);
  }

  @override
  Future<void> archive(String id) async => archived.add(id);

  @override
  Future<DocumentView> view(String id) async {
    if (failure != null) throw failure!;
    return views[id] ?? viewOf(id);
  }

  @override
  Future<List<SharedDocument>> mine({String? studentId}) async {
    if (failure != null) throw failure!;
    mineAskedFor.add(studentId);
    return cours;
  }

  static ContentDocument _withoutChapter(ContentDocument d) => ContentDocument(
    id: d.id,
    title: d.title,
    subjectId: d.subjectId,
    levelId: d.levelId,
    tag: d.tag,
    status: d.status,
    kind: d.kind,
    fileName: d.fileName,
    sizeBytes: d.sizeBytes,
    pageCount: d.pageCount,
    sharedGroupIds: d.sharedGroupIds,
    updatedAt: d.updatedAt,
  );
}

class FakeFileChooser implements FileChooser {
  PickedFile? next;

  @override
  Future<PickedFile?> pickDocument() async => next;

  @override
  Future<PickedFile?> pickSpreadsheet() async => next;
}

class RecordingFileOpener implements FileOpener {
  final opened = <String>[];

  @override
  Future<bool> download(String url) async {
    opened.add(url);
    return true;
  }
}

/// A small real image: screens can draw it.
final Uint8List tinyPng = img.encodePng(img.Image(width: 30, height: 40));

class FakePhotoSource implements PhotoSource {
  FakePhotoSource({this.hasCamera = true});

  @override
  bool hasCamera;

  /// What the next photo is; null closes the camera.
  Uint8List? nextPhoto = tinyPng;
  List<Uint8List> gallery = [tinyPng, tinyPng];

  @override
  Future<Uint8List?> takePhoto() async => nextPhoto;

  @override
  Future<List<Uint8List>> pickPhotos() async => gallery;
}

/// Pages without image work; a "PDF" of a few bytes.
class FakeScanProcessor implements ScanProcessor {
  bool failPdf = false;
  final List<(List<ScanPage>, ScanColor, String)> built = [];
  int refreshed = 0;

  @override
  Future<ScanPage?> load(String id, Uint8List photo) async =>
      photo.isEmpty ? null : ScanPage(id: id, bytes: tinyPng, width: 30, height: 40, preview: tinyPng);

  @override
  Future<ScanPage> refresh(ScanPage page) async {
    refreshed++;
    return page;
  }

  @override
  Future<PickedFile> buildPdf(List<ScanPage> pages, ScanColor color, String fileName) async {
    if (failPdf) throw StateError('no pdf');
    built.add((pages, color, fileName));
    return PickedFile(name: fileName, bytes: List.filled(2048, 1));
  }
}

/// The content services the screens read from the locator.
({FakeContentRepository repository, FakeFileChooser chooser, RecordingFileOpener opener}) registerContentServices({
  FakeContentRepository? repository,
}) {
  final repo = repository ?? FakeContentRepository();
  final chooser = FakeFileChooser();
  final opener = RecordingFileOpener();
  sl.registerSingleton<ContentRepository>(repo);
  sl.registerSingleton<FileChooser>(chooser);
  sl.registerSingleton<FileOpener>(opener);
  sl.registerSingleton<PhotoSource>(FakePhotoSource());
  sl.registerSingleton<ScanProcessor>(FakeScanProcessor());
  sl.registerFactory<LibraryCubit>(() => LibraryCubit(repo));
  return (repository: repo, chooser: chooser, opener: opener);
}

/// A small PDF-looking file of [size] bytes.
PickedFile pdfFile(String name, {int size = 2048}) => PickedFile(name: name, bytes: List.filled(size, 1));
