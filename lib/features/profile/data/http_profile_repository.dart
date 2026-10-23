import 'package:stashly/core/network/api_client.dart';
import 'package:stashly/core/network/json.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/features/profile/domain/profile.dart';

/// [ProfileRepository] over `GET /me/stats` and `GET /me/export`.
class HttpProfileRepository implements ProfileRepository {
  HttpProfileRepository(this._api, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final ApiClient _api;
  final DateTime Function() _clock;

  @override
  Future<Result<AccountStats>> stats() => guard(() async {
    final data = (await _api.get('/me/stats')).data;
    return AccountStats(
      linksCount: data.intOrNull('links_count') ?? 0,
      collectionsCount: data.intOrNull('collections_count') ?? 0,
      favoritesCount: data.intOrNull('favorites_count') ?? 0,
    );
  });

  @override
  Future<Result<DataExport>> exportData() => guard(() async {
    final response = await _api.get(
      '/me/export',
      timeout: const Duration(seconds: 60),
    );
    return DataExport(
      filename: _filenameFrom(response.headers['content-disposition']),
      bytes: response.bytes,
    );
  });

  String _filenameFrom(String? disposition) {
    final match = RegExp(
      r'filename="?([^";]+)"?',
    ).firstMatch(disposition ?? '');
    final name = match?.group(1)?.trim();
    // Never trust a server path: keep only a safe base name.
    if (name != null && RegExp(r'^[\w.\-]+\.json$').hasMatch(name)) return name;
    final stamp = _clock().toUtc().toIso8601String().replaceAll(
      RegExp(r'[:.]'),
      '-',
    );
    return 'stashly-export-$stamp.json';
  }
}
