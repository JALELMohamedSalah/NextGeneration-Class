import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_failure.dart';
import '../../../domain/model/search.dart';
import '../../../domain/repositories/search_repository.dart';
import '../common/load_status.dart';

class SearchState extends Equatable {
  const SearchState({this.query = '', this.status = LoadStatus.ready, this.results = const SearchResults(), this.highlighted = 0, this.failure});

  final String query;
  final LoadStatus status;

  /// For [query]; empty below two letters.
  final SearchResults results;

  /// The line ↑ ↓ point at; Entrée opens it.
  final int highlighted;
  final ApiFailure? failure;

  /// Two letters at least: below, nothing is searched.
  bool get searching => query.trim().length >= SearchCubit.minLength;

  SearchHit? get current => highlighted < results.hits.length ? results.hits[highlighted] : null;

  SearchState copyWith({String? query, LoadStatus? status, SearchResults? results, int? highlighted, ApiFailure? Function()? failure}) => SearchState(
    query: query ?? this.query,
    status: status ?? this.status,
    results: results ?? this.results,
    highlighted: highlighted ?? this.highlighted,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [query, status, results, highlighted, failure?.code];
}

/// The teacher's search (design `r2/Recherche.png`): asks the server a short moment after the last letter typed;
/// an answer to an older query is dropped.
class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._repository, {this.delay = const Duration(milliseconds: 220)}) : super(const SearchState());

  static const minLength = 2;

  final SearchRepository _repository;
  final Duration delay;
  Timer? _timer;

  void changed(String query) {
    _timer?.cancel();
    if (query.trim().length < minLength) {
      emit(SearchState(query: query));
      return;
    }
    emit(state.copyWith(query: query, status: LoadStatus.loading, failure: () => null));
    _timer = Timer(delay, () => _search(query));
  }

  Future<void> _search(String query) async {
    try {
      final results = await _repository.search(query.trim());
      if (isClosed || query != state.query) return;
      emit(state.copyWith(status: LoadStatus.ready, results: results, highlighted: 0));
    } on Object catch (error) {
      if (isClosed || query != state.query) return;
      emit(state.copyWith(status: LoadStatus.failure, failure: () => ApiFailure.from(error)));
    }
  }

  /// ↑ (-1) or ↓ (+1), within the lines shown.
  void move(int step) {
    final count = state.results.hits.length;
    if (count == 0) return;
    emit(state.copyWith(highlighted: (state.highlighted + step).clamp(0, count - 1)));
  }

  void highlight(int index) => emit(state.copyWith(highlighted: index));

  void clear() {
    _timer?.cancel();
    emit(const SearchState());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
