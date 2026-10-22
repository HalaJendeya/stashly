import 'package:stashly/core/network/json.dart';
import 'package:stashly/core/result/paging.dart';
import 'package:stashly/features/links/domain/link.dart';
import 'package:stashly/features/links/domain/links_repository.dart';

/// Wire-format mapping for links (API v1). Lives in `data` so a backend swap
/// never touches the domain.
abstract final class LinkMapper {
  static Link link(JsonMap json) => Link(
    id: json.str('id'),
    originalUrl: json.str('original_url'),
    normalizedUrl: json.strOrNull('normalized_url') ?? json.str('original_url'),
    sourceDomain: json.strOrNull('source_domain') ?? '',
    title: json.strOrNull('title'),
    displayTitle:
        json.strOrNull('display_title') ??
        json.strOrNull('title') ??
        json.strOrNull('source_domain') ??
        json.str('original_url'),
    note: json.strOrNull('note'),
    isFavorite: json.boolean('is_favorite', fallback: false),
    contentType: ContentType.fromApi(json.strOrNull('content_type')),
    metadata: metadataOrPending(json.objOrNull('metadata')),
    collections: [
      for (final ref in json.objList('collections'))
        CollectionRef(id: ref.str('id'), name: ref.str('name')),
    ],
    collectionsCount:
        json.intOrNull('collections_count') ??
        json.objList('collections').length,
    tags: json.strList('tags'),
    createdAt: json.date('created_at'),
    updatedAt: json.dateOrNull('updated_at') ?? json.date('created_at'),
  );

  static LinkMetadata metadataOrPending(JsonMap? json) =>
      json == null ? LinkMetadata.pending : metadata(json);

  static LinkMetadata metadata(JsonMap json) => LinkMetadata(
    status: MetadataStatus.fromApi(json.strOrNull('status')),
    title: json.strOrNull('title'),
    description: json.strOrNull('description'),
    siteName: json.strOrNull('site_name'),
    faviconUrl: _httpUrl(json.strOrNull('favicon_url')),
    previewImageUrl: _httpUrl(json.strOrNull('preview_image_url')),
    fetchedAt: json.dateOrNull('fetched_at'),
    errorCode: json.strOrNull('error_code'),
  );

  static LinkPreview preview(JsonMap json) {
    final existing = json.objOrNull('existing_link');
    final metadataJson = json.objOrNull('metadata');
    return LinkPreview(
      url: json.str('url'),
      normalizedUrl: json.strOrNull('normalized_url') ?? json.str('url'),
      sourceDomain: json.strOrNull('source_domain') ?? '',
      contentType: ContentType.fromApi(json.strOrNull('content_type')),
      duplicate: json.boolean('duplicate', fallback: existing != null),
      existingLink: existing == null ? null : link(existing),
      metadata: metadataJson == null ? null : metadata(metadataJson),
    );
  }

  static Paged<Link> page(List<JsonMap> data, JsonMap meta) => Paged(
    items: [for (final item in data) link(item)],
    nextCursor: meta.strOrNull('next_cursor'),
    hasMore: meta.boolean('has_more', fallback: false),
    total: meta.intOrNull('total'),
  );

  /// Only absolute http(s) image URLs are rendered; anything else falls back.
  static String? _httpUrl(String? value) =>
      value != null &&
          (value.startsWith('https://') || value.startsWith('http://'))
      ? value
      : null;
}
