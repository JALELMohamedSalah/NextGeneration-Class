import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_failure.dart';
import '../../../domain/model/content.dart';
import '../../../domain/model/student.dart' show foldAccents;
import '../../../domain/repositories/content_repository.dart';
import '../common/load_status.dart';

/// Where the teacher is in her library: a subject, one of its levels, and a chapter of that level
/// ([chapterId] null: "Sans chapitre"). A subject without any document has no level yet.
class LibraryPlace extends Equatable {
  const LibraryPlace({required this.subjectId, this.levelId, this.chapterId});

  final String subjectId;
  final String? levelId;
  final String? chapterId;

  @override
  List<Object?> get props => [subjectId, levelId, chapterId];
}

class LibraryState extends Equatable {
  const LibraryState({
    this.status = LoadStatus.loading,
    this.library = const Library(),
    this.place,
    this.query = '',
    this.tag,
    this.documentStatus,
    this.failure,
  });

  final LoadStatus status;
  final Library library;
  final LibraryPlace? place;
  final String query;
  final ContentTag? tag;
  final ContentStatus? documentStatus;
  final ApiFailure? failure;

  bool get isEmpty => library.chapters.isEmpty && library.documents.isEmpty;

  /// The chapters of a subject and level, in their order.
  List<Chapter> chaptersOf(String subjectId, String levelId) =>
      library.chapters.where((c) => c.subjectId == subjectId && c.levelId == levelId).toList()
        ..sort((a, b) => a.position.compareTo(b.position));

  /// Levels of a subject that hold a chapter or a document.
  Set<String> levelsOf(String subjectId) => {
    for (final c in library.chapters)
      if (c.subjectId == subjectId) c.levelId,
    for (final d in library.documents)
      if (d.subjectId == subjectId) d.levelId,
  };

  int countSubject(String subjectId) => library.documents.where((d) => d.subjectId == subjectId).length;

  int countLevel(String subjectId, String levelId) =>
      library.documents.where((d) => d.subjectId == subjectId && d.levelId == levelId).length;

  int countChapter(String chapterId) => library.documents.where((d) => d.chapterId == chapterId).length;

  int countUnfiled(String subjectId, String levelId) =>
      library.documents.where((d) => d.subjectId == subjectId && d.levelId == levelId && d.chapterId == null).length;

  Chapter? get chapter {
    final id = place?.chapterId;
    return id == null ? null : library.chapters.where((c) => c.id == id).firstOrNull;
  }

  /// The documents of the selected place, filtered by title words (accents and case ignored), tag and status.
  List<ContentDocument> get visible {
    final p = place;
    if (p == null || p.levelId == null) return const [];
    final words = foldAccents(query.toLowerCase()).split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    return library.documents.where((d) {
      if (d.subjectId != p.subjectId || d.levelId != p.levelId || d.chapterId != p.chapterId) return false;
      if (tag != null && d.tag != tag) return false;
      if (documentStatus != null && d.status != documentStatus) return false;
      final title = foldAccents(d.title.toLowerCase());
      return words.every(title.contains);
    }).toList();
  }

  /// Documents of the place before any filter: tells "empty chapter" from "no result".
  int get placeCount {
    final p = place;
    if (p == null || p.levelId == null) return 0;
    return library.documents.where((d) => d.subjectId == p.subjectId && d.levelId == p.levelId && d.chapterId == p.chapterId).length;
  }

  ContentDocument? document(String id) => library.documents.where((d) => d.id == id).firstOrNull;

  LibraryState copyWith({
    LoadStatus? status,
    Library? library,
    LibraryPlace? Function()? place,
    String? query,
    ContentTag? Function()? tag,
    ContentStatus? Function()? documentStatus,
    ApiFailure? Function()? failure,
  }) => LibraryState(
    status: status ?? this.status,
    library: library ?? this.library,
    place: place != null ? place() : this.place,
    query: query ?? this.query,
    tag: tag != null ? tag() : this.tag,
    documentStatus: documentStatus != null ? documentStatus() : this.documentStatus,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [status, library, place, query, tag, documentStatus, failure?.code];
}

/// Contenus (spec 04): the teacher's chapters and documents. Actions return their [ApiFailure] (or
/// null) so the screen words the result; panels report what they saved through [documentSaved].
class LibraryCubit extends Cubit<LibraryState> {
  LibraryCubit(this._repository) : super(const LibraryState());

  final ContentRepository _repository;

  /// [chapterId]: open on that chapter (from the search) rather than where the teacher was.
  Future<void> load({String? chapterId}) async {
    emit(state.copyWith(status: LoadStatus.loading, failure: () => null));
    try {
      final library = await _repository.library();
      if (isClosed) return;
      final chapter = chapterId == null ? null : library.chapters.where((c) => c.id == chapterId).firstOrNull;
      final place = chapter != null ? LibraryPlace(subjectId: chapter.subjectId, levelId: chapter.levelId, chapterId: chapter.id) : null;
      emit(state.copyWith(status: LoadStatus.ready, library: library, place: () => place ?? state.place ?? _firstPlace(library)));
    } on Object catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.failure, failure: () => ApiFailure.from(error)));
    }
  }

  void select(LibraryPlace place) => emit(state.copyWith(place: () => place));

  /// A subject chosen in the tree: its first level and first chapter, or the subject alone when empty.
  void selectSubject(String subjectId, List<String> levelOrder) {
    final levels = state.levelsOf(subjectId);
    final level = levelOrder.where(levels.contains).firstOrNull;
    if (level == null) return select(LibraryPlace(subjectId: subjectId));
    selectLevel(subjectId, level);
  }

  void selectLevel(String subjectId, String levelId) {
    final first = state.chaptersOf(subjectId, levelId).firstOrNull;
    select(LibraryPlace(subjectId: subjectId, levelId: levelId, chapterId: first?.id));
  }

  void search(String query) => emit(state.copyWith(query: query));

  void filterTag(ContentTag? tag) => emit(state.copyWith(tag: () => tag));

  void filterStatus(ContentStatus? status) => emit(state.copyWith(documentStatus: () => status));

  /// The new chapter becomes the selected place.
  Future<(Chapter?, ApiFailure?)> createChapter({required String subjectId, required String levelId, required String title}) async {
    try {
      final chapter = await _repository.createChapter(subjectId: subjectId, levelId: levelId, title: title);
      if (!isClosed) {
        emit(
          state.copyWith(
            library: state.library.copyWith(chapters: [...state.library.chapters, chapter]),
            place: () => LibraryPlace(subjectId: subjectId, levelId: levelId, chapterId: chapter.id),
          ),
        );
      }
      return (chapter, null);
    } on Object catch (error) {
      return (null, ApiFailure.from(error));
    }
  }

  Future<ApiFailure?> renameChapter(String id, String title) async {
    try {
      chapterSaved(await _repository.renameChapter(id, title));
      return null;
    } on Object catch (error) {
      return ApiFailure.from(error);
    }
  }

  /// Its documents stay, in "Sans chapitre", which becomes the selected place.
  Future<ApiFailure?> deleteChapter(Chapter chapter) async {
    try {
      await _repository.deleteChapter(chapter.id);
      final library = await _repository.library();
      if (!isClosed) {
        emit(
          state.copyWith(
            library: library,
            place: () => LibraryPlace(subjectId: chapter.subjectId, levelId: chapter.levelId),
          ),
        );
      }
      return null;
    } on Object catch (error) {
      return ApiFailure.from(error);
    }
  }

  void chapterSaved(Chapter chapter) {
    if (isClosed) return;
    emit(
      state.copyWith(library: state.library.copyWith(chapters: [for (final c in state.library.chapters) c.id == chapter.id ? chapter : c])),
    );
  }

  /// An uploaded or edited document goes first, and its place is shown.
  void documentSaved(ContentDocument document) {
    if (isClosed) return;
    final others = state.library.documents.where((d) => d.id != document.id);
    emit(
      state.copyWith(
        library: state.library.copyWith(documents: [document, ...others]),
        place: () => LibraryPlace(subjectId: document.subjectId, levelId: document.levelId, chapterId: document.chapterId),
      ),
    );
  }

  /// Hidden from the library and from every Cours; nothing is deleted.
  Future<ApiFailure?> archive(ContentDocument document) async {
    try {
      await _repository.archive(document.id);
      if (!isClosed) {
        emit(
          state.copyWith(library: state.library.copyWith(documents: state.library.documents.where((d) => d.id != document.id).toList())),
        );
      }
      return null;
    } on Object catch (error) {
      return ApiFailure.from(error);
    }
  }

  /// The place of the last edited document, so the teacher lands where she worked.
  static LibraryPlace? _firstPlace(Library library) {
    final last = library.documents.firstOrNull;
    if (last != null) return LibraryPlace(subjectId: last.subjectId, levelId: last.levelId, chapterId: last.chapterId);
    final chapter = library.chapters.firstOrNull;
    if (chapter != null) return LibraryPlace(subjectId: chapter.subjectId, levelId: chapter.levelId, chapterId: chapter.id);
    return null;
  }
}
