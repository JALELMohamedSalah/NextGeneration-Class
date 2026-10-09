import 'package:equatable/equatable.dart';

import 'localized_text.dart';

/// How the teacher finds a document again (spec 04).
enum ContentTag { serie, cours, corrige, autre }

/// Only a published document can be shared; a draft is never visible to pupils or parents.
enum ContentStatus { draft, published, archived }

/// What the viewer can do: PDF pages and images open in the app, Word only downloads.
enum FileKind { pdf, image, word }

/// Subject > level > chapter.
class Chapter extends Equatable {
  const Chapter({
    required this.id,
    required this.subjectId,
    required this.levelId,
    required this.title,
    required this.position,
    this.sharedGroupIds = const [],
  });

  final String id;
  final String subjectId;
  final String levelId;
  final String title;
  final int position;

  /// Groups that see every published document of the chapter, including later ones.
  final List<String> sharedGroupIds;

  Chapter copyWith({String? title, List<String>? sharedGroupIds}) => Chapter(
    id: id,
    subjectId: subjectId,
    levelId: levelId,
    title: title ?? this.title,
    position: position,
    sharedGroupIds: sharedGroupIds ?? this.sharedGroupIds,
  );

  @override
  List<Object?> get props => [id, subjectId, levelId, title, position, sharedGroupIds];
}

/// A document of the teacher's library. Without [chapterId] it sits in "Sans chapitre".
class ContentDocument extends Equatable {
  const ContentDocument({
    required this.id,
    required this.title,
    required this.subjectId,
    required this.levelId,
    required this.tag,
    required this.status,
    required this.kind,
    required this.fileName,
    required this.sizeBytes,
    required this.updatedAt,
    this.chapterId,
    this.pageCount,
    this.sharedGroupIds = const [],
  });

  final String id;
  final String title;
  final String subjectId;
  final String levelId;
  final String? chapterId;
  final ContentTag tag;
  final ContentStatus status;
  final FileKind kind;
  final String fileName;
  final int sizeBytes;
  final int? pageCount;
  final List<String> sharedGroupIds;
  final DateTime updatedAt;

  bool get published => status == ContentStatus.published;

  ContentDocument copyWith({List<String>? sharedGroupIds}) => ContentDocument(
    id: id,
    title: title,
    subjectId: subjectId,
    levelId: levelId,
    chapterId: chapterId,
    tag: tag,
    status: status,
    kind: kind,
    fileName: fileName,
    sizeBytes: sizeBytes,
    pageCount: pageCount,
    sharedGroupIds: sharedGroupIds ?? this.sharedGroupIds,
    updatedAt: updatedAt,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    subjectId,
    levelId,
    chapterId,
    tag,
    status,
    kind,
    fileName,
    sizeBytes,
    pageCount,
    sharedGroupIds,
    updatedAt,
  ];
}

class Library extends Equatable {
  const Library({this.chapters = const [], this.documents = const []});

  final List<Chapter> chapters;

  /// Last edited first.
  final List<ContentDocument> documents;

  /// Published documents a group sees, alone or through their chapter, last edited first (session mode's
  /// "Contenu du jour").
  List<ContentDocument> sharedWith(String groupId) {
    final chapterIds = {for (final c in chapters) if (c.sharedGroupIds.contains(groupId)) c.id};
    return documents.where((d) => d.published && (d.sharedGroupIds.contains(groupId) || chapterIds.contains(d.chapterId))).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Library copyWith({List<Chapter>? chapters, List<ContentDocument>? documents}) =>
      Library(chapters: chapters ?? this.chapters, documents: documents ?? this.documents);

  @override
  List<Object?> get props => [chapters, documents];
}

/// What the teacher sets on an upload or an edit.
class DocumentDraft extends Equatable {
  const DocumentDraft({
    required this.title,
    required this.subjectId,
    required this.levelId,
    required this.tag,
    this.chapterId,
    this.draft = false,
    this.groupIds = const [],
  });

  final String title;
  final String subjectId;
  final String levelId;
  final String? chapterId;
  final ContentTag tag;
  final bool draft;

  /// Upload only: the groups to share with right away.
  final List<String> groupIds;

  @override
  List<Object?> get props => [title, subjectId, levelId, chapterId, tag, draft, groupIds];
}

/// A file chosen on the device, before upload.
class PickedFile extends Equatable {
  const PickedFile({required this.name, required this.bytes});

  /// Spec 04: 20 MB per file.
  static const maxBytes = 20 * 1024 * 1024;

  static const _extensions = {'pdf', 'jpg', 'jpeg', 'png', 'docx'};

  final String name;
  final List<int> bytes;

  int get size => bytes.length;

  String get extension {
    final dot = name.lastIndexOf('.');
    return dot < 0 ? '' : name.substring(dot + 1).toLowerCase();
  }

  /// Checked before upload (spec 04 acceptance criteria): the server checks again.
  FileProblem? get problem {
    if (bytes.isEmpty) return FileProblem.empty;
    if (!_extensions.contains(extension)) return FileProblem.unsupported;
    if (size > maxBytes) return FileProblem.tooLarge;
    return null;
  }

  /// "serie2_fractions.pdf" becomes "serie2 fractions": a starting point for the title.
  String get suggestedTitle {
    final dot = name.lastIndexOf('.');
    final base = (dot > 0 ? name.substring(0, dot) : name).replaceAll(RegExp(r'[_\-]+'), ' ').trim();
    return base.isEmpty ? name : base[0].toUpperCase() + base.substring(1);
  }

  @override
  List<Object?> get props => [name, size];
}

enum FileProblem { empty, unsupported, tooLarge }

class SubjectRef extends Equatable {
  const SubjectRef({required this.id, required this.name, required this.color, required this.position});

  final String id;
  final LocalizedText name;
  final String color;
  final int position;

  @override
  List<Object?> get props => [id, name, color, position];
}

class ChapterRef extends Equatable {
  const ChapterRef({required this.id, required this.title, required this.position});

  final String id;
  final String title;
  final int position;

  @override
  List<Object?> get props => [id, title, position];
}

/// A document in a pupil's or parent's Cours. [isNew]: not opened yet by this user.
class SharedDocument extends Equatable {
  const SharedDocument({
    required this.id,
    required this.title,
    required this.tag,
    required this.kind,
    required this.subject,
    this.chapter,
    this.pageCount,
    this.sharedAt,
    this.isNew = false,
  });

  final String id;
  final String title;
  final ContentTag tag;
  final FileKind kind;
  final int? pageCount;
  final SubjectRef subject;
  final ChapterRef? chapter;
  final DateTime? sharedAt;
  final bool isNew;

  SharedDocument opened() => SharedDocument(
    id: id,
    title: title,
    tag: tag,
    kind: kind,
    pageCount: pageCount,
    subject: subject,
    chapter: chapter,
    sharedAt: sharedAt,
  );

  @override
  List<Object?> get props => [id, title, tag, kind, pageCount, subject, chapter, sharedAt, isNew];
}

/// What the viewer shows: page images (none for Word) and the file, behind short-lived links.
class DocumentView extends Equatable {
  const DocumentView({
    required this.id,
    required this.title,
    required this.subjectName,
    required this.kind,
    required this.tag,
    required this.fileName,
    required this.sizeBytes,
    required this.pageUrls,
    required this.downloadUrl,
    this.chapterTitle,
  });

  final String id;
  final String title;
  final LocalizedText subjectName;
  final String? chapterTitle;
  final FileKind kind;
  final ContentTag tag;
  final String fileName;
  final int sizeBytes;
  final List<String> pageUrls;
  final String downloadUrl;

  @override
  List<Object?> get props => [id, title, subjectName, chapterTitle, kind, tag, fileName, sizeBytes, pageUrls, downloadUrl];
}
