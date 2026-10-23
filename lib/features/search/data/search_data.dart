import 'package:stashly/core/network/api_client.dart';
import 'package:stashly/core/network/json.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/core/storage/key_value_store.dart';
import 'package:stashly/features/links/domain/link.dart';
import 'package:stashly/features/search/domain/search.dart';

/// [SearchRepository] over `GET /search/filters` (API-SRCH-001).
class HttpSearchRepository implements SearchRepository {
  HttpSearchRepository(this._api);

  final ApiClient _api;

  @override
  Future<Result<FilterOptions>> filterOptions() => guard(() async {
    final data = (await _api.get('/search/filters')).data;
    return FilterOptions(
      contentTypes: [
        for (final item in data.objList('content_types'))
          FilterOption(
            value: ContentType.fromApi(item.strOrNull('value')),
            // Shown via the localized `contentType` message in the UI.
            label: item.str('value'),
            count: item.intOrNull('count') ?? 0,
          ),
      ],
      sources: [
        for (final item in data.objList('sources'))
          FilterOption(
            value: item.str('value'),
            label: item.str('value'),
            count: item.intOrNull('count') ?? 0,
          ),
      ],
      collections: [
        for (final item in data.objList('collections'))
          FilterOption(
            value: item.str('id'),
            label: item.str('name'),
            count:
                item.intOrNull('count') ?? item.intOrNull('links_count') ?? 0,
          ),
      ],
      tags: [
        for (final item in data.objList('tags'))
          FilterOption(
            value: item.str('name'),
            label: '#${item.str('name')}',
            count: item.intOrNull('count') ?? 0,
          ),
      ],
      datePresets: [
        for (final item in data.objList('date_presets'))
          FilterOption(
            value: item.integer('value'),
            label: 'Last ${item.integer('value')} days',
            count: item.intOrNull('count') ?? 0,
          ),
      ],
    );
  });
}

/// Device-only recent searches (max 10), cleared on sign-out.
class LocalRecentSearchStore implements RecentSearchStore {
  LocalRecentSearchStore(this._store);

  static const _key = 'recent_searches';
  static const _max = 10;

  final KeyValueStore _store;

  @override
  Future<List<String>> load() async {
    final value = await _store.read(_key);
    return value is List ? value.whereType<String>().toList() : <String>[];
  }

  @override
  Future<List<String>> add(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return load();
    final updated = [
      trimmed,
      ...(await load()).where((q) => q.toLowerCase() != trimmed.toLowerCase()),
    ].take(_max).toList();
    await _store.write(_key, updated);
    return updated;
  }

  @override
  Future<void> clear() => _store.remove(_key);
}
