import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:stashly/core/events/data_changes.dart';
import 'package:stashly/core/result/app_failure.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/features/links/domain/link.dart';
import 'package:stashly/features/links/domain/links_repository.dart';

/// State for the item details screen (`GET /links/{id}` and its actions).
class LinkDetailsViewModel extends ChangeNotifier {
  LinkDetailsViewModel({
    required this.linkId,
    required this._links,
    required this._changes,
    this.pollInterval = const Duration(seconds: 3),
    this.maxPolls = 10,
  });

  final String linkId;
  final LinksRepository _links;
  final DataChanges _changes;
  final Duration pollInterval;
  final int maxPolls;

  Link? link;
  bool loading = true;
  bool busy = false;
  AppFailure? failure;
  bool deleted = false;

  Timer? _poll;
  int _polls = 0;
  bool _disposed = false;

  bool get previewPending => link?.metadata.status == MetadataStatus.pending;

  Future<void> load() async {
    loading = link == null;
    failure = null;
    _notify();
    final result = await _links.get(linkId);
    loading = false;
    switch (result) {
      case Ok(:final value):
        link = value;
        _schedulePollIfPending();
      case Err(failure: final error):
        failure = error;
    }
    _notify();
  }

  /// While the background lookup runs, re-read the link a few times so the
  /// title and image appear without a manual refresh.
  void _schedulePollIfPending() {
    _poll?.cancel();
    if (!previewPending || _polls >= maxPolls) return;
    _poll = Timer(pollInterval, () async {
      _polls++;
      final result = await _links.get(linkId);
      if (_disposed) return;
      if (result case Ok(:final value)) {
        final changed = value.metadata.status != link?.metadata.status;
        link = value;
        if (changed) _changes.notify({DataTopic.links});
        _notify();
      }
      _schedulePollIfPending();
    });
  }

  Future<Result<void>> toggleFavorite() async {
    final current = link;
    if (current == null) return const Ok(null);
    link = current.copyWith(isFavorite: !current.isFavorite);
    _notify();
    final result = await _links.update(
      linkId,
      LinkUpdate(isFavorite: !current.isFavorite),
    );
    switch (result) {
      case Ok(:final value):
        link = value;
        _changes.notify({DataTopic.links, DataTopic.account});
      case Err():
        link = current; // roll back the optimistic change
    }
    _notify();
    return result;
  }

  Future<Result<void>> setCollections(List<String> ids) => _apply(
    () => _links.setCollections(linkId, ids),
    {DataTopic.links, DataTopic.collections},
  );

  Future<Result<void>> setTags(List<String> tags) =>
      _apply(() => _links.setTags(linkId, tags), {DataTopic.links});

  Future<Result<void>> refreshPreview() async {
    final result = await _apply(() => _links.refreshMetadata(linkId), {
      DataTopic.links,
    });
    if (result.isOk) {
      _polls = 0;
      _schedulePollIfPending();
    }
    return result;
  }

  Future<Result<void>> delete() async {
    busy = true;
    _notify();
    final result = await _links.delete(linkId);
    busy = false;
    if (result.isOk) {
      deleted = true;
      _changes.notify({
        DataTopic.links,
        DataTopic.collections,
        DataTopic.account,
      });
    }
    _notify();
    return result;
  }

  Future<Result<void>> _apply(
    Future<Result<Link>> Function() call,
    Set<DataTopic> topics,
  ) async {
    busy = true;
    _notify();
    final result = await call();
    busy = false;
    if (result case Ok(:final value)) {
      link = value;
      _changes.notify(topics);
    }
    _notify();
    return result;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _poll?.cancel();
    super.dispose();
  }
}
