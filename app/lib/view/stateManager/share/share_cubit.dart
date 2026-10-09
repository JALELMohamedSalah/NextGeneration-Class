import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_failure.dart';
import '../../../domain/model/content.dart';
import '../../../domain/repositories/content_repository.dart';

/// What is shared: one document, or a whole chapter (its later documents too).
sealed class ShareTarget {
  const ShareTarget();

  List<String> get groupIds;
}

class DocumentTarget extends ShareTarget {
  const DocumentTarget(this.document);

  final ContentDocument document;

  @override
  List<String> get groupIds => document.sharedGroupIds;
}

class ChapterTarget extends ShareTarget {
  const ChapterTarget(this.chapter);

  final Chapter chapter;

  @override
  List<String> get groupIds => chapter.sharedGroupIds;
}

class ShareState extends Equatable {
  const ShareState({required this.selected, this.saving = false, this.failure});

  final Set<String> selected;
  final bool saving;
  final ApiFailure? failure;

  ShareState copyWith({Set<String>? selected, bool? saving, ApiFailure? Function()? failure}) =>
      ShareState(selected: selected ?? this.selected, saving: saving ?? this.saving, failure: failure != null ? failure() : this.failure);

  @override
  List<Object?> get props => [selected, saving, failure?.code];
}

/// "Partager": the groups that see a document or a chapter in their Cours. Unticking a group takes it
/// out of their Cours; nothing is deleted.
class ShareCubit extends Cubit<ShareState> {
  ShareCubit(this._repository, this.target) : super(ShareState(selected: target.groupIds.toSet()));

  final ContentRepository _repository;
  final ShareTarget target;

  void toggle(String groupId) => emit(
    state.copyWith(selected: state.selected.contains(groupId) ? ({...state.selected}..remove(groupId)) : {...state.selected, groupId}),
  );

  /// The saved document or chapter, or null with the reason in the state.
  Future<Object?> save() async {
    if (state.saving) return null;
    emit(state.copyWith(saving: true, failure: () => null));
    try {
      final ids = state.selected.toList();
      final saved = switch (target) {
        DocumentTarget(:final document) => await _repository.share(document.id, ids),
        ChapterTarget(:final chapter) => await _repository.shareChapter(chapter.id, ids),
      };
      if (!isClosed) emit(state.copyWith(saving: false));
      return saved;
    } on Object catch (error) {
      if (!isClosed) emit(state.copyWith(saving: false, failure: () => ApiFailure.from(error)));
      return null;
    }
  }
}
