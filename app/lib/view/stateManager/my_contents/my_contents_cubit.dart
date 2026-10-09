import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_failure.dart';
import '../../../domain/model/content.dart';
import '../../../domain/repositories/content_repository.dart';
import '../common/load_status.dart';

/// A chapter (or "Sans chapitre") of a subject, with its documents, for the Cours list.
class CoursSection extends Equatable {
  const CoursSection({required this.subject, required this.chapter, required this.documents});

  final SubjectRef subject;
  final ChapterRef? chapter;
  final List<SharedDocument> documents;

  @override
  List<Object?> get props => [subject, chapter, documents];
}

class MyContentsState extends Equatable {
  const MyContentsState({this.status = LoadStatus.loading, this.documents = const [], this.subjectId, this.studentId, this.failure});

  final LoadStatus status;

  /// Ordered by the server: subject, chapter, newest share first.
  final List<SharedDocument> documents;

  /// The subject filter; null shows everything.
  final String? subjectId;

  /// The child a parent is looking at.
  final String? studentId;
  final ApiFailure? failure;

  List<SubjectRef> get subjects {
    final seen = <String>{};
    return [
      for (final d in documents)
        if (seen.add(d.subject.id)) d.subject,
    ];
  }

  List<CoursSection> get sections {
    final out = <CoursSection>[];
    for (final d in documents.where((d) => subjectId == null || d.subject.id == subjectId)) {
      final last = out.lastOrNull;
      if (last != null && last.subject.id == d.subject.id && last.chapter?.id == d.chapter?.id) {
        out[out.length - 1] = CoursSection(subject: last.subject, chapter: last.chapter, documents: [...last.documents, d]);
      } else {
        out.add(CoursSection(subject: d.subject, chapter: d.chapter, documents: [d]));
      }
    }
    return out;
  }

  int get newCount => documents.where((d) => d.isNew).length;

  MyContentsState copyWith({
    LoadStatus? status,
    List<SharedDocument>? documents,
    String? Function()? subjectId,
    String? Function()? studentId,
    ApiFailure? Function()? failure,
  }) => MyContentsState(
    status: status ?? this.status,
    documents: documents ?? this.documents,
    subjectId: subjectId != null ? subjectId() : this.subjectId,
    studentId: studentId != null ? studentId() : this.studentId,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [status, documents, subjectId, studentId, failure?.code];
}

/// Cours (spec 09): what is shared with the pupil's groups, for the pupil or for a parent.
class MyContentsCubit extends Cubit<MyContentsState> {
  MyContentsCubit(this._repository) : super(const MyContentsState());

  final ContentRepository _repository;

  /// [studentId] is required for a parent; switching child clears the subject filter.
  Future<void> load({String? studentId}) async {
    final otherChild = studentId != state.studentId;
    emit(
      state.copyWith(
        status: LoadStatus.loading,
        studentId: () => studentId,
        subjectId: otherChild ? () => null : null,
        documents: otherChild ? const [] : null,
        failure: () => null,
      ),
    );
    try {
      final documents = await _repository.mine(studentId: studentId);
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.ready, documents: documents));
    } on Object catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.failure, failure: () => ApiFailure.from(error)));
    }
  }

  void filterSubject(String? subjectId) => emit(state.copyWith(subjectId: () => subjectId));

  /// Back from the viewer: "Nouveau" goes away at once, as it did on the server.
  void opened(String documentId) => emit(state.copyWith(documents: [for (final d in state.documents) d.id == documentId ? d.opened() : d]));
}
