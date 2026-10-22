import 'package:flutter/foundation.dart';

import 'package:stashly/core/result/app_failure.dart';
import 'package:stashly/core/result/paging.dart';
import 'package:stashly/core/result/result.dart';

typedef PageFetcher<T> = Future<Result<Paged<T>>> Function(String? cursor);

/// Cursor-paginated list state shared by Library, Search and Collection
/// screens: first load, "Load more", refresh, errors and local edits.
class PagedController<T> extends ChangeNotifier {
  PagedController({required this._fetch, required this._idOf});

  PageFetcher<T> _fetch;
  final String Function(T) _idOf;

  List<T> items = const [];
  int? total;
  bool loading = false;
  bool loadingMore = false;
  bool loadedOnce = false;
  AppFailure? failure;

  /// Failure of the last "Load more"; the loaded items stay visible.
  AppFailure? loadMoreFailure;
  String? _cursor;
  bool _hasMore = false;
  int _generation = 0;
  bool _disposed = false;

  bool get hasMore => _hasMore;
  bool get isEmpty => loadedOnce && items.isEmpty && failure == null;

  /// Replaces the query (e.g. new filters) and reloads from the first page.
  Future<void> reload({PageFetcher<T>? fetch}) {
    if (fetch != null) _fetch = fetch;
    return refresh();
  }

  Future<void> refresh() async {
    final generation = ++_generation;
    loading = true;
    failure = null;
    loadMoreFailure = null;
    _notify();
    final result = await _fetch(null);
    // A newer request (filters changed meanwhile) wins.
    if (generation != _generation) return;
    loading = false;
    loadedOnce = true;
    switch (result) {
      case Ok(:final value):
        items = value.items;
        total = value.total ?? value.items.length;
        _cursor = value.nextCursor;
        _hasMore = value.hasMore && value.nextCursor != null;
      case Err(failure: final error):
        failure = error;
    }
    _notify();
  }

  Future<void> loadMore() async {
    if (!_hasMore || loadingMore || loading) return;
    final generation = _generation;
    loadingMore = true;
    loadMoreFailure = null;
    _notify();
    final result = await _fetch(_cursor);
    if (generation != _generation) return;
    loadingMore = false;
    switch (result) {
      case Ok(:final value):
        final known = {for (final item in items) _idOf(item)};
        items = [
          ...items,
          ...value.items.where((i) => !known.contains(_idOf(i))),
        ];
        _cursor = value.nextCursor;
        _hasMore = value.hasMore && value.nextCursor != null;
      case Err(failure: final error):
        // An invalid cursor means the list changed: start over.
        if (error.kind == FailureKind.invalidCursor) {
          loadingMore = false;
          await refresh();
          return;
        }
        loadMoreFailure = error;
    }
    _notify();
  }

  void replace(T item) {
    final id = _idOf(item);
    items = [
      for (final existing in items) _idOf(existing) == id ? item : existing,
    ];
    _notify();
  }

  /// Shows [optimistic] at once, then the server's version from [commit];
  /// puts [original] back if the server refused.
  Future<Result<T>> replaceOptimistically(
    T optimistic, {
    required T original,
    required Future<Result<T>> Function() commit,
  }) async {
    replace(optimistic);
    final result = await commit();
    replace(switch (result) {
      Ok(:final value) => value,
      Err() => original,
    });
    return result;
  }

  void remove(String id) {
    final before = items.length;
    items = [
      for (final item in items)
        if (_idOf(item) != id) item,
    ];
    if (items.length != before && total != null) total = total! - 1;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
