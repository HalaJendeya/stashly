import 'package:stashly/core/result/result.dart';
import 'package:stashly/features/links/domain/link.dart';

/// A filter option with the number of the user's links it matches.
class FilterOption<T> {
  const FilterOption({
    required this.value,
    required this.label,
    required this.count,
  });

  final T value;
  final String label;
  final int count;
}

/// Everything the Filters sheet offers (`GET /search/filters`).
class FilterOptions {
  const FilterOptions({
    required this.contentTypes,
    required this.sources,
    required this.collections,
    required this.tags,
    required this.datePresets,
  });

  static const empty = FilterOptions(
    contentTypes: [],
    sources: [],
    collections: [],
    tags: [],
    datePresets: [],
  );

  final List<FilterOption<ContentType>> contentTypes;
  final List<FilterOption<String>> sources;

  /// Value is the collection id; label its name.
  final List<FilterOption<String>> collections;
  final List<FilterOption<String>> tags;

  /// Value is the number of days (7 or 30).
  final List<FilterOption<int>> datePresets;
}

abstract interface class SearchRepository {
  Future<Result<FilterOptions>> filterOptions();
}

/// Recent searches are kept on the device only (BR-SRCH-004).
abstract interface class RecentSearchStore {
  Future<List<String>> load();
  Future<List<String>> add(String query);
  Future<void> clear();
}
