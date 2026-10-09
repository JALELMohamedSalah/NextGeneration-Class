import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_failure.dart';
import '../../../core/platform/file_chooser.dart';
import '../../../domain/model/content.dart';
import '../../../domain/repositories/content_repository.dart';

enum DocumentFormError { file, title, subject, level }

class DocumentFormState extends Equatable {
  const DocumentFormState({
    this.editing,
    this.file,
    this.title = '',
    this.subjectId,
    this.levelId,
    this.chapterId,
    this.tag = ContentTag.serie,
    this.draft = false,
    this.groupIds = const [],
    this.errors = const {},
    this.submitting = false,
    this.progress,
    this.failure,
  });

  /// Null for an upload; the document whose details are edited otherwise.
  final ContentDocument? editing;
  final PickedFile? file;
  final String title;
  final String? subjectId;
  final String? levelId;
  final String? chapterId;
  final ContentTag tag;
  final bool draft;
  final List<String> groupIds;
  final Set<DocumentFormError> errors;
  final bool submitting;

  /// 0 to 1 while the file is sent.
  final double? progress;
  final ApiFailure? failure;

  bool get isEditing => editing != null;

  FileProblem? get fileProblem => file?.problem;

  DocumentFormState copyWith({
    PickedFile? Function()? file,
    String? title,
    String? Function()? subjectId,
    String? Function()? levelId,
    String? Function()? chapterId,
    ContentTag? tag,
    bool? draft,
    List<String>? groupIds,
    Set<DocumentFormError>? errors,
    bool? submitting,
    double? Function()? progress,
    ApiFailure? Function()? failure,
  }) => DocumentFormState(
    editing: editing,
    file: file != null ? file() : this.file,
    title: title ?? this.title,
    subjectId: subjectId != null ? subjectId() : this.subjectId,
    levelId: levelId != null ? levelId() : this.levelId,
    chapterId: chapterId != null ? chapterId() : this.chapterId,
    tag: tag ?? this.tag,
    draft: draft ?? this.draft,
    groupIds: groupIds ?? this.groupIds,
    errors: errors ?? this.errors,
    submitting: submitting ?? this.submitting,
    progress: progress != null ? progress() : this.progress,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [
    editing,
    file,
    title,
    subjectId,
    levelId,
    chapterId,
    tag,
    draft,
    groupIds,
    errors,
    submitting,
    progress,
    failure?.code,
  ];
}

/// "Importer un document" and "Modifier les détails" (spec 04, uploads). The file is checked here,
/// before anything is sent: type and size (the server checks again).
class DocumentFormCubit extends Cubit<DocumentFormState> {
  /// An upload, placed where the teacher is in her library.
  DocumentFormCubit.upload(this._repository, this._chooser, {String? subjectId, String? levelId, String? chapterId})
    : super(DocumentFormState(subjectId: subjectId, levelId: levelId, chapterId: chapterId));

  DocumentFormCubit.edit(this._repository, this._chooser, ContentDocument document)
    : super(
        DocumentFormState(
          editing: document,
          title: document.title,
          subjectId: document.subjectId,
          levelId: document.levelId,
          chapterId: document.chapterId,
          tag: document.tag,
          draft: document.status == ContentStatus.draft,
        ),
      );

  final ContentRepository _repository;
  final FileChooser _chooser;

  /// The title starts from the file name when the teacher has not typed one.
  Future<void> pickFile() async {
    final PickedFile? picked;
    try {
      picked = await _chooser.pickDocument();
    } on Object catch (error) {
      if (!isClosed) emit(state.copyWith(failure: () => ApiFailure.from(error)));
      return;
    }
    if (picked == null || isClosed) return;
    emit(
      state.copyWith(
        file: () => picked,
        title: state.title.trim().isEmpty ? picked.suggestedTitle : null,
        errors: state.errors.difference({DocumentFormError.file, DocumentFormError.title}),
        failure: () => null,
      ),
    );
  }

  /// A PDF made by the scan: like a chosen file, its name starts the title.
  void useFile(PickedFile file) => emit(
    state.copyWith(
      file: () => file,
      title: state.title.trim().isEmpty ? file.suggestedTitle : null,
      errors: state.errors.difference({DocumentFormError.file, DocumentFormError.title}),
      failure: () => null,
    ),
  );

  void setTitle(String value) => emit(state.copyWith(title: value, errors: state.errors.difference({DocumentFormError.title})));

  /// A chapter belongs to one subject and level: changing either leaves "Sans chapitre".
  void setSubject(String? id) => emit(
    state.copyWith(
      subjectId: () => id,
      chapterId: id == state.subjectId ? null : () => null,
      errors: state.errors.difference({DocumentFormError.subject}),
    ),
  );

  void setLevel(String? id) => emit(
    state.copyWith(
      levelId: () => id,
      chapterId: id == state.levelId ? null : () => null,
      errors: state.errors.difference({DocumentFormError.level}),
    ),
  );

  void setChapter(String? id) => emit(state.copyWith(chapterId: () => id));

  void setTag(ContentTag tag) => emit(state.copyWith(tag: tag));

  /// A draft is never shared: keeping one empties the groups.
  void setDraft(bool value) => emit(state.copyWith(draft: value, groupIds: value ? const [] : null));

  void toggleGroup(String groupId) => emit(
    state.copyWith(
      groupIds: state.groupIds.contains(groupId) ? state.groupIds.where((g) => g != groupId).toList() : [...state.groupIds, groupId],
    ),
  );

  /// The saved document, or null with the reason in the state.
  Future<ContentDocument?> submit() async {
    if (state.submitting) return null;
    final errors = {
      if (!state.isEditing && (state.file == null || state.fileProblem != null)) DocumentFormError.file,
      if (state.title.trim().isEmpty) DocumentFormError.title,
      if (state.subjectId == null) DocumentFormError.subject,
      if (state.levelId == null) DocumentFormError.level,
    };
    if (errors.isNotEmpty) {
      emit(state.copyWith(errors: errors));
      return null;
    }
    emit(state.copyWith(submitting: true, progress: () => state.isEditing ? null : 0, failure: () => null));
    final draft = DocumentDraft(
      title: state.title,
      subjectId: state.subjectId!,
      levelId: state.levelId!,
      chapterId: state.chapterId,
      tag: state.tag,
      draft: state.draft,
      groupIds: state.draft ? const [] : state.groupIds,
    );
    try {
      final saved = state.isEditing
          ? await _repository.update(state.editing!.id, draft)
          : await _repository.upload(
              draft,
              state.file!,
              onProgress: (p) {
                if (!isClosed) emit(state.copyWith(progress: () => p));
              },
            );
      if (!isClosed) emit(state.copyWith(submitting: false, progress: () => null));
      return saved;
    } on Object catch (error) {
      if (!isClosed) emit(state.copyWith(submitting: false, progress: () => null, failure: () => ApiFailure.from(error)));
      return null;
    }
  }
}
