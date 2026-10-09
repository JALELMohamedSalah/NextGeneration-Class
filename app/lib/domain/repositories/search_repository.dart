import '../model/search.dart';

/// The teacher's search (`/search`). Throws an `ApiFailure` when refused.
abstract interface class SearchRepository {
  /// From two letters; five results per family at most.
  Future<SearchResults> search(String query);
}
