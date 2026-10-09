import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_failure.dart';
import '../../../domain/model/content.dart';
import '../../../domain/repositories/content_repository.dart';
import '../common/load_status.dart';

class DayContentState extends Equatable {
  const DayContentState({this.status = LoadStatus.loading, this.documents = const [], this.chapter, this.failure});

  final LoadStatus status;

  /// The group's latest documents (three at most).
  final List<ContentDocument> documents;

  /// The chapter of the latest one, shown beside the title.
  final Chapter? chapter;
  final ApiFailure? failure;

  @override
  List<Object?> get props => [status, documents, chapter, failure?.code];
}

/// Session mode's "Contenu du jour" (design `SessionMode.png`): what the group has from the library, to open
/// in class.
class DayContentCubit extends Cubit<DayContentState> {
  DayContentCubit(this._repository, this.groupId) : super(const DayContentState());

  static const shown = 3;

  final ContentRepository _repository;
  final String groupId;

  Future<void> load() async {
    emit(const DayContentState());
    try {
      final library = await _repository.library();
      if (isClosed) return;
      final documents = library.sharedWith(groupId).take(shown).toList();
      final chapterId = documents.firstOrNull?.chapterId;
      emit(
        DayContentState(
          status: LoadStatus.ready,
          documents: documents,
          chapter: library.chapters.where((c) => c.id == chapterId).firstOrNull,
        ),
      );
    } on Object catch (error) {
      if (!isClosed) emit(DayContentState(status: LoadStatus.failure, failure: ApiFailure.from(error)));
    }
  }
}
