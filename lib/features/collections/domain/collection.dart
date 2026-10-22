import 'package:stashly/core/result/paging.dart';
import 'package:stashly/core/result/result.dart';

/// A user collection (`collection` object of the API).
class Collection {
  const Collection({
    required this.id,
    required this.name,
    required this.description,
    required this.linksCount,
    required this.coverImages,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? description;
  final int linksCount;

  /// Up to four external preview-image URLs of member links.
  final List<String> coverImages;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// "1 item" / "12 items".
}

/// A tag with its usage count (`GET /tags`). Tags are identified by name.
class TagCount {
  const TagCount({required this.name, required this.linksCount});

  final String name;
  final int linksCount;
}

enum CollectionSort {
  recent('recent'),
  name('name');

  const CollectionSort(this.apiValue);

  final String apiValue;
}

enum TagSort {
  usage('usage'),
  name('name');

  const TagSort(this.apiValue);

  final String apiValue;
}

abstract interface class CollectionsRepository {
  Future<Result<Paged<Collection>>> list({
    CollectionSort sort = CollectionSort.recent,
    String? cursor,
    int limit = 50,
  });
  Future<Result<Collection>> get(String id);
  Future<Result<Collection>> create({
    required String name,
    String? description,
  });
  Future<Result<Collection>> update(
    String id, {
    String? name,
    FieldUpdate<String>? description,
  });
  Future<Result<void>> delete(String id);

  /// Adds and/or removes member links atomically.
  Future<Result<Collection>> updateMembership(
    String id, {
    List<String> attach = const [],
    List<String> detach = const [],
  });
}

abstract interface class TagsRepository {
  Future<Result<List<TagCount>>> list({
    String? prefix,
    TagSort sort = TagSort.usage,
    int limit = 100,
  });
}
