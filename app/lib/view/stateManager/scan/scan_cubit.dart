import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/platform/photo_source.dart';
import '../../../domain/model/content.dart';
import '../../../domain/model/scan.dart';
import '../../../domain/services/scan_processor.dart';

/// Why the scan stopped: a photo that cannot be read, or a PDF that could not be made.
enum ScanProblem { photo, pdf }

class ScanState extends Equatable {
  const ScanState({this.pages = const [], this.color = ScanColor.color, this.adding = false, this.building = false, this.problem});

  final List<ScanPage> pages;
  final ScanColor color;

  /// A photo is being prepared (shown as a waiting tile).
  final bool adding;
  final bool building;
  final ScanProblem? problem;

  ScanState copyWith({List<ScanPage>? pages, ScanColor? color, bool? adding, bool? building, ScanProblem? Function()? problem}) =>
      ScanState(
        pages: pages ?? this.pages,
        color: color ?? this.color,
        adding: adding ?? this.adding,
        building: building ?? this.building,
        problem: problem != null ? problem() : this.problem,
      );

  @override
  List<Object?> get props => [pages, color, adding, building, problem];
}

/// "Scanner des feuilles" (design `r2/Scanner.png`): photos one after another, in order, then one PDF.
class ScanCubit extends Cubit<ScanState> {
  ScanCubit(this._source, this._processor) : super(const ScanState());

  final PhotoSource _source;
  final ScanProcessor _processor;
  int _next = 0;

  Future<void> takePhoto() => _add(() async {
    final photo = await _source.takePhoto();
    return photo == null ? const [] : [photo];
  });

  Future<void> pickPhotos() => _add(_source.pickPhotos);

  Future<void> _add(Future<List<Uint8List>> Function() photos) async {
    if (state.adding || state.building) return;
    emit(state.copyWith(adding: true, problem: () => null));
    try {
      for (final photo in await photos()) {
        final page = await _processor.load('page-${_next++}', photo);
        if (isClosed) return;
        if (page == null) {
          emit(state.copyWith(problem: () => ScanProblem.photo));
          continue;
        }
        emit(state.copyWith(pages: [...state.pages, page]));
      }
    } on Object {
      if (!isClosed) emit(state.copyWith(problem: () => ScanProblem.photo));
    }
    if (!isClosed) emit(state.copyWith(adding: false));
  }

  void remove(String id) => emit(state.copyWith(pages: state.pages.where((p) => p.id != id).toList()));

  /// The page [id] takes the place [index] (drag and drop).
  void move(String id, int index) {
    final pages = [...state.pages];
    final from = pages.indexWhere((p) => p.id == id);
    if (from < 0) return;
    final page = pages.removeAt(from);
    pages.insert(index.clamp(0, pages.length), page);
    emit(state.copyWith(pages: pages));
  }

  void setColor(ScanColor color) => emit(state.copyWith(color: color));

  /// Back from the crop screen: the page keeps its place, its preview follows.
  Future<void> updatePage(ScanPage page) async {
    final refreshed = await _processor.refresh(page);
    if (isClosed) return;
    emit(state.copyWith(pages: [for (final p in state.pages) p.id == page.id ? refreshed : p]));
  }

  /// One PDF named [fileName]; null when there is no page or it failed.
  Future<PickedFile?> build(String fileName) async {
    if (state.pages.isEmpty || state.building) return null;
    emit(state.copyWith(building: true, problem: () => null));
    try {
      final file = await _processor.buildPdf(state.pages, state.color, fileName);
      if (!isClosed) emit(state.copyWith(building: false));
      return file;
    } on Object {
      if (!isClosed) emit(state.copyWith(building: false, problem: () => ScanProblem.pdf));
      return null;
    }
  }
}
