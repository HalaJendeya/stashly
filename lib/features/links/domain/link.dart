/// Server-assigned content category (`content_type`).
/// Labels are localized in the UI ( message).
enum ContentType {
  video,
  article,
  product,
  social,
  other;

  String get apiValue => name;

  static ContentType fromApi(String? value) => ContentType.values.firstWhere(
    (type) => type.name == value,
    orElse: () => ContentType.other,
  );
}

/// Background metadata lookup state (`metadata.status`).
enum MetadataStatus {
  pending,
  ready,
  failed,
  blocked;

  String get apiValue => name;

  static MetadataStatus fromApi(String? value) => MetadataStatus.values
      .firstWhere((s) => s.name == value, orElse: () => MetadataStatus.pending);
}

/// Best-effort details fetched by the backend. Every field may be null.
class LinkMetadata {
  const LinkMetadata({
    required this.status,
    this.title,
    this.description,
    this.siteName,
    this.faviconUrl,
    this.previewImageUrl,
    this.fetchedAt,
    this.errorCode,
  });

  static const pending = LinkMetadata(status: MetadataStatus.pending);

  final MetadataStatus status;
  final String? title;
  final String? description;
  final String? siteName;
  final String? faviconUrl;

  /// External image URL only; Stashly never stores image bytes.
  final String? previewImageUrl;
  final DateTime? fetchedAt;
  final String? errorCode;

  bool get hasPreview => title != null || previewImageUrl != null;
}

/// A collection the link belongs to (`collections[]`).
class CollectionRef {
  const CollectionRef({required this.id, required this.name});

  final String id;
  final String name;
}

/// A saved link (`link` object of the API).
class Link {
  const Link({
    required this.id,
    required this.originalUrl,
    required this.normalizedUrl,
    required this.sourceDomain,
    required this.title,
    required this.displayTitle,
    required this.note,
    required this.isFavorite,
    required this.contentType,
    required this.metadata,
    required this.collections,
    required this.collectionsCount,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String originalUrl;
  final String normalizedUrl;
  final String sourceDomain;

  /// The user's own title; [displayTitle] falls back to the fetched title.
  final String? title;
  final String displayTitle;
  final String? note;
  final bool isFavorite;
  final ContentType contentType;
  final LinkMetadata metadata;
  final List<CollectionRef> collections;
  final int collectionsCount;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// "Travel ideas", "Learning +2", or null for unsorted links.
  String? get collectionLabel {
    if (collections.isEmpty) return null;
    final extra = collectionsCount - 1;
    return extra > 0
        ? '${collections.first.name} +$extra'
        : collections.first.name;
  }

  Link copyWith({bool? isFavorite, String? note, List<String>? tags}) => Link(
    id: id,
    originalUrl: originalUrl,
    normalizedUrl: normalizedUrl,
    sourceDomain: sourceDomain,
    title: title,
    displayTitle: displayTitle,
    note: note ?? this.note,
    isFavorite: isFavorite ?? this.isFavorite,
    contentType: contentType,
    metadata: metadata,
    collections: collections,
    collectionsCount: collectionsCount,
    tags: tags ?? this.tags,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
