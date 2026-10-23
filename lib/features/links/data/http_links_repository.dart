import 'package:stashly/core/network/api_client.dart';
import 'package:stashly/core/network/json.dart';
import 'package:stashly/core/result/app_failure.dart';
import 'package:stashly/core/result/paging.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/features/links/data/link_mapper.dart';
import 'package:stashly/features/links/domain/link.dart';
import 'package:stashly/features/links/domain/links_repository.dart';

/// [LinksRepository] over the Stashly REST API (API-LINK-001..009).
class HttpLinksRepository implements LinksRepository {
  HttpLinksRepository(this._api);

  final ApiClient _api;

  @override
  Future<Result<Paged<Link>>> list(LinkQuery query, {String? cursor}) =>
      guard(() async {
        final text = query.text?.trim();
        final response = await _api.get(
          '/links',
          query: {
            'q': text == null || text.isEmpty ? null : text,
            'favorite': query.favoritesOnly ? 'true' : null,
            'content_type': query.contentTypes.map((t) => t.apiValue).toList(),
            'source': query.sources.toList(),
            'collection_id': query.collectionIds.toList(),
            'tags': query.tags.toList(),
            'saved_within_days': query.savedWithinDays,
            'sort': query.sort.name,
            'limit': query.limit,
            'cursor': cursor,
          },
        );
        return LinkMapper.page(response.dataList, response.meta);
      });

  @override
  Future<Result<Link>> get(String id) => guard(() async {
    final response = await _api.get('/links/${Uri.encodeComponent(id)}');
    return LinkMapper.link(response.data.obj('link'));
  });

  @override
  Future<Result<LinkPreview>> preview(String url) => guard(() async {
    // The server answers within ~4 s; allow some network headroom.
    final response = await _api.post(
      '/links/preview',
      body: {'url': url},
      timeout: const Duration(seconds: 12),
    );
    return LinkMapper.preview(response.data);
  });

  @override
  Future<Result<Link>> create(
    NewLink link, {
    required String idempotencyKey,
  }) async {
    final result = await guard(() async {
      final response = await _api.post(
        '/links',
        headers: {'Idempotency-Key': idempotencyKey},
        body: {
          'url': link.url,
          if (_hasText(link.title)) 'title': link.title!.trim(),
          if (_hasText(link.note)) 'note': link.note!.trim(),
          'collection_ids': link.collectionIds,
          'tags': link.tags,
          'is_favorite': link.isFavorite,
        },
      );
      return LinkMapper.link(response.data.obj('link'));
    });
    return _attachExistingLink(result);
  }

  @override
  Future<Result<Link>> update(String id, LinkUpdate update) => guard(() async {
    final response = await _api.patch(
      '/links/${Uri.encodeComponent(id)}',
      body: {
        if (update.title != null) 'title': _blankToNull(update.title!.value),
        if (update.note != null) 'note': _blankToNull(update.note!.value),
        if (update.isFavorite != null) 'is_favorite': update.isFavorite,
      },
    );
    return LinkMapper.link(response.data.obj('link'));
  });

  @override
  Future<Result<void>> delete(String id) => guard(() async {
    await _api.delete('/links/${Uri.encodeComponent(id)}');
  });

  @override
  Future<Result<Link>> setCollections(String id, List<String> collectionIds) =>
      guard(() async {
        final response = await _api.put(
          '/links/${Uri.encodeComponent(id)}/collections',
          body: {'collection_ids': collectionIds},
        );
        return LinkMapper.link(response.data.obj('link'));
      });

  @override
  Future<Result<Link>> setTags(String id, List<String> tags) => guard(() async {
    final response = await _api.put(
      '/links/${Uri.encodeComponent(id)}/tags',
      body: {'tags': tags},
    );
    return LinkMapper.link(response.data.obj('link'));
  });

  @override
  Future<Result<Link>> refreshMetadata(String id) => guard(() async {
    final response = await _api.post(
      '/links/${Uri.encodeComponent(id)}/metadata/refresh',
    );
    return LinkMapper.link(response.data.obj('link'));
  });

  /// Converts `details.existing_link` of a 409 into a domain [Link] so the UI
  /// can offer "Open saved item".
  Result<Link> _attachExistingLink(Result<Link> result) {
    if (result case Err(
      :final failure,
    ) when failure.kind == FailureKind.duplicateLink) {
      final details = failure.payload;
      Link? existing;
      if (details is JsonMap && details['existing_link'] is JsonMap) {
        try {
          existing = LinkMapper.link(details['existing_link'] as JsonMap);
        } on FormatException {
          existing = null;
        }
      }
      return Err(
        AppFailure(
          FailureKind.duplicateLink,
          code: failure.code,
          message: failure.message,
          requestId: failure.requestId,
          payload: existing,
        ),
      );
    }
    return result;
  }

  static bool _hasText(String? value) =>
      value != null && value.trim().isNotEmpty;

  static String? _blankToNull(String? value) =>
      value == null || value.trim().isEmpty ? null : value.trim();
}
