import 'package:stashly/core/network/api_client.dart';
import 'package:stashly/core/network/json.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/features/collections/domain/collection.dart';
import 'package:stashly/features/home/domain/home.dart';
import 'package:stashly/features/links/domain/link.dart';

/// [HomeRepository] over `GET /home` (API-HOME-001).
///
/// The link and collection parsers are injected by the app layer so this
/// feature never imports another feature's `data` package (CLAUDE.md §3).
class HttpHomeRepository implements HomeRepository {
  HttpHomeRepository(
    this._api, {
    required this._parseLink,
    required this._parseCollection,
  });

  final ApiClient _api;
  final Link Function(JsonMap) _parseLink;
  final Collection Function(JsonMap) _parseCollection;

  @override
  Future<Result<HomeSummary>> load({int recentLimit = 10}) => guard(() async {
    final data = (await _api.get(
      '/home',
      query: {'recent_limit': recentLimit},
    )).data;
    return HomeSummary(
      displayName: data.objOrNull('user')?.strOrNull('display_name') ?? '',
      linksCount: data.intOrNull('links_count') ?? 0,
      favoritesCount: data.intOrNull('favorites_count') ?? 0,
      quickAccess: [
        for (final item in data.objList('quick_access')) _parseCollection(item),
      ],
      recentLinks: [
        for (final item in data.objList('recent_links')) _parseLink(item),
      ],
    );
  });
}
