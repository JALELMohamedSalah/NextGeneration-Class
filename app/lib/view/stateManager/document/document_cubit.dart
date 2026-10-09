import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_failure.dart';
import '../../../core/platform/file_opener.dart';
import '../../../domain/model/content.dart';
import '../../../domain/repositories/content_repository.dart';
import '../common/load_status.dart';

class DocumentState extends Equatable {
  const DocumentState({this.status = LoadStatus.loading, this.view, this.page = 0, this.failure});

  final LoadStatus status;
  final DocumentView? view;

  /// Index in [DocumentView.pageUrls].
  final int page;
  final ApiFailure? failure;

  int get pageCount => view?.pageUrls.length ?? 0;

  DocumentState copyWith({LoadStatus? status, DocumentView? view, int? page, ApiFailure? Function()? failure}) => DocumentState(
    status: status ?? this.status,
    view: view ?? this.view,
    page: page ?? this.page,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [status, view, page, failure?.code];
}

/// The in-app viewer: page by page for PDFs and images, a download for Word (spec 04).
class DocumentCubit extends Cubit<DocumentState> {
  /// [loader] opens something else than a library document (a pupil's work, spec 06).
  DocumentCubit(this._repository, this._opener, this.documentId, {Future<DocumentView> Function()? loader})
    : _loader = loader,
      super(const DocumentState());

  final ContentRepository _repository;
  final FileOpener _opener;
  final String documentId;
  final Future<DocumentView> Function()? _loader;

  /// Also after half an hour: the links are signed for that long, a reload signs new ones.
  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading, failure: () => null));
    try {
      final view = await (_loader ?? () => _repository.view(documentId))();
      if (isClosed) return;
      emit(
        state.copyWith(
          status: LoadStatus.ready,
          view: view,
          page: state.page.clamp(0, view.pageUrls.isEmpty ? 0 : view.pageUrls.length - 1),
        ),
      );
    } on Object catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.failure, failure: () => ApiFailure.from(error)));
    }
  }

  void next() => goTo(state.page + 1);

  void previous() => goTo(state.page - 1);

  void goTo(int page) {
    if (page < 0 || page >= state.pageCount) return;
    emit(state.copyWith(page: page));
  }

  /// False when nothing could open the link.
  Future<bool> download() async {
    final view = state.view;
    if (view == null) return false;
    return _opener.download(view.downloadUrl);
  }
}
