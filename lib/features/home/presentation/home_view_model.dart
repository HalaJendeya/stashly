import 'package:flutter/foundation.dart';

import 'package:stashly/core/events/data_changes.dart';
import 'package:stashly/core/result/app_failure.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/features/home/domain/home.dart';
import 'package:stashly/features/links/domain/link.dart';
import 'package:stashly/features/links/domain/links_repository.dart';

/// Home dashboard state (`GET /home`), plus per-type "Recently saved" lists.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required this._home,
    required this._links,
    required this._changes,
  }) {
    _changes.addListener(_onChanged);
    _seen = _versions();
  }

  final HomeRepository _home;
  final LinksRepository _links;
  final DataChanges _changes;
  late int _seen;
  bool _disposed = false;

  HomeSummary? summary;
  bool loading = true;
  AppFailure? failure;

  /// Selected "Recently saved" chip; null means All.
  ContentType? type;
  List<Link>? typedLinks;
  bool typedLoading = false;
  AppFailure? typedFailure;

  List<Link> get recentLinks =>
      type == null ? summary?.recentLinks ?? const [] : typedLinks ?? const [];

  int _versions() =>
      _changes.version(DataTopic.links) +
      _changes.version(DataTopic.collections) +
      _changes.version(DataTopic.account);

  void _onChanged() {
    final versions = _versions();
    if (versions != _seen) {
      _seen = versions;
      load(silent: true);
    }
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      loading = summary == null;
      failure = null;
      _notify();
    }
    final result = await _home.load(recentLimit: 10);
    loading = false;
    switch (result) {
      case Ok(:final value):
        summary = value;
        failure = null;
      case Err(failure: final error):
        if (summary == null || !silent) failure = error;
    }
    _notify();
    if (type != null) await _loadTyped();
  }

  Future<void> selectType(ContentType? value) async {
    type = value;
    typedLinks = null;
    _notify();
    if (value != null) await _loadTyped();
  }

  Future<void> _loadTyped() async {
    final selected = type;
    if (selected == null) return;
    typedLoading = true;
    typedFailure = null;
    _notify();
    final result = await _links.list(
      LinkQuery(contentTypes: {selected}, limit: 5),
    );
    if (type != selected) return;
    typedLoading = false;
    switch (result) {
      case Ok(:final value):
        typedLinks = value.items;
      case Err(failure: final error):
        typedFailure = error;
    }
    _notify();
  }

  /// Optimistic favourite toggle used by the cards.
  Future<Result<Link>> toggleFavorite(Link link) async {
    final result = await _links.update(
      link.id,
      LinkUpdate(isFavorite: !link.isFavorite),
    );
    // The change notification triggers a silent reload through _onChanged.
    if (result.isOk) _changes.notify({DataTopic.links, DataTopic.account});
    return result;
  }

  Future<Result<void>> delete(Link link) async {
    final result = await _links.delete(link.id);
    if (result.isOk) {
      _changes.notify({
        DataTopic.links,
        DataTopic.collections,
        DataTopic.account,
      });
    }
    return result;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _changes.removeListener(_onChanged);
    super.dispose();
  }
}
