import 'package:stashly/core/result/paging.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/features/links/domain/link.dart';

enum LinkSort {
  newest('Newest'),
  oldest('Oldest');

  const LinkSort(this.label);

  final String label;

  LinkSort get toggled => this == newest ? oldest : newest;
}

/// Filters for `GET /links` (library, favorites, search, collection items).
class LinkQuery {
  const LinkQuery({
    this.text,
    this.favoritesOnly = false,
    this.contentTypes = const {},
    this.sources = const {},
    this.collectionIds = const {},
    this.tags = const {},
    this.savedWithinDays,
    this.sort = LinkSort.newest,
    this.limit = 20,
  });

  final String? text;
  final bool favoritesOnly;
  final Set<ContentType> contentTypes;
  final Set<String> sources;
  final Set<String> collectionIds;

  /// A link must carry all of these tags.
  final Set<String> tags;

  /// 7 or 30.
  final int? savedWithinDays;
  final LinkSort sort;
  final int limit;

  bool get hasFilters =>
      favoritesOnly ||
      contentTypes.isNotEmpty ||
      sources.isNotEmpty ||
      collectionIds.isNotEmpty ||
      tags.isNotEmpty ||
      savedWithinDays != null;

  LinkQuery copyWith({
    String? text,
    bool clearText = false,
    bool? favoritesOnly,
    Set<ContentType>? contentTypes,
    Set<String>? sources,
    Set<String>? collectionIds,
    Set<String>? tags,
    int? savedWithinDays,
    bool clearSavedWithin = false,
    LinkSort? sort,
    int? limit,
  }) => LinkQuery(
    text: clearText ? null : (text ?? this.text),
    favoritesOnly: favoritesOnly ?? this.favoritesOnly,
    contentTypes: contentTypes ?? this.contentTypes,
    sources: sources ?? this.sources,
    collectionIds: collectionIds ?? this.collectionIds,
    tags: tags ?? this.tags,
    savedWithinDays: clearSavedWithin
        ? null
        : (savedWithinDays ?? this.savedWithinDays),
    sort: sort ?? this.sort,
    limit: limit ?? this.limit,
  );
}

/// Result of the optional pre-save lookup (`POST /links/preview`).
class LinkPreview {
  const LinkPreview({
    required this.url,
    required this.normalizedUrl,
    required this.sourceDomain,
    required this.contentType,
    required this.duplicate,
    this.existingLink,
    this.metadata,
  });

  final String url;
  final String normalizedUrl;
  final String sourceDomain;
  final ContentType contentType;
  final bool duplicate;
  final Link? existingLink;

  /// Null when nothing was found within the server's time budget.
  final LinkMetadata? metadata;
}

/// Fields for `POST /links`.
class NewLink {
  const NewLink({
    required this.url,
    this.title,
    this.note,
    this.collectionIds = const [],
    this.tags = const [],
    this.isFavorite = false,
  });

  final String url;
  final String? title;
  final String? note;
  final List<String> collectionIds;
  final List<String> tags;
  final bool isFavorite;
}

/// Fields for `PATCH /links/{id}`; null members are left unchanged.
class LinkUpdate {
  const LinkUpdate({this.title, this.note, this.isFavorite});

  final FieldUpdate<String>? title;
  final FieldUpdate<String>? note;
  final bool? isFavorite;

  bool get isEmpty => title == null && note == null && isFavorite == null;
}

/// Saved-link operations. Implementations own transport and parsing; a
/// `409 DUPLICATE_LINK` from [create] is an `Err` whose `payload` is the
/// existing [Link].
abstract interface class LinksRepository {
  Future<Result<Paged<Link>>> list(LinkQuery query, {String? cursor});
  Future<Result<Link>> get(String id);
  Future<Result<LinkPreview>> preview(String url);
  Future<Result<Link>> create(NewLink link, {required String idempotencyKey});
  Future<Result<Link>> update(String id, LinkUpdate update);
  Future<Result<void>> delete(String id);
  Future<Result<Link>> setCollections(String id, List<String> collectionIds);
  Future<Result<Link>> setTags(String id, List<String> tags);
  Future<Result<Link>> refreshMetadata(String id);
}
