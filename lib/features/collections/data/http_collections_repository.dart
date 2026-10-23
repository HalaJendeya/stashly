import 'package:stashly/core/network/api_client.dart';
import 'package:stashly/core/network/json.dart';
import 'package:stashly/core/result/paging.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/features/collections/domain/collection.dart';

/// Wire-format mapping for collections and tags (API v1).
abstract final class CollectionMapper {
  static Collection collection(JsonMap json) => Collection(
    id: json.str('id'),
    name: json.str('name'),
    description: json.strOrNull('description'),
    linksCount: json.intOrNull('links_count') ?? 0,
    coverImages: [
      for (final url in json.strList('cover_images'))
        if (url.startsWith('http')) url,
    ],
    createdAt: json.date('created_at'),
    updatedAt: json.dateOrNull('updated_at') ?? json.date('created_at'),
  );

  static TagCount tag(JsonMap json) => TagCount(
    name: json.str('name'),
    linksCount: json.intOrNull('links_count') ?? 0,
  );
}

/// [CollectionsRepository] over the REST API (API-COLL-001..006).
class HttpCollectionsRepository implements CollectionsRepository {
  HttpCollectionsRepository(this._api);

  final ApiClient _api;

  @override
  Future<Result<Paged<Collection>>> list({
    CollectionSort sort = CollectionSort.recent,
    String? cursor,
    int limit = 50,
  }) => guard(() async {
    final response = await _api.get(
      '/collections',
      query: {'sort': sort.apiValue, 'limit': limit, 'cursor': cursor},
    );
    final meta = response.meta;
    return Paged(
      items: [
        for (final item in response.dataList) CollectionMapper.collection(item),
      ],
      nextCursor: meta.strOrNull('next_cursor'),
      hasMore: meta.boolean('has_more', fallback: false),
      total: meta.intOrNull('total'),
    );
  });

  @override
  Future<Result<Collection>> get(String id) => guard(() async {
    final response = await _api.get('/collections/${Uri.encodeComponent(id)}');
    return CollectionMapper.collection(response.data.obj('collection'));
  });

  @override
  Future<Result<Collection>> create({
    required String name,
    String? description,
  }) => guard(() async {
    final response = await _api.post(
      '/collections',
      body: {
        'name': name.trim(),
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
      },
    );
    return CollectionMapper.collection(response.data.obj('collection'));
  });

  @override
  Future<Result<Collection>> update(
    String id, {
    String? name,
    FieldUpdate<String>? description,
  }) => guard(() async {
    final descriptionValue = description?.value?.trim();
    final response = await _api.patch(
      '/collections/${Uri.encodeComponent(id)}',
      body: {
        if (name != null) 'name': name.trim(),
        if (description != null)
          'description': descriptionValue == null || descriptionValue.isEmpty
              ? null
              : descriptionValue,
      },
    );
    return CollectionMapper.collection(response.data.obj('collection'));
  });

  @override
  Future<Result<void>> delete(String id) => guard(() async {
    await _api.delete('/collections/${Uri.encodeComponent(id)}');
  });

  @override
  Future<Result<Collection>> updateMembership(
    String id, {
    List<String> attach = const [],
    List<String> detach = const [],
  }) => guard(() async {
    final response = await _api.patch(
      '/collections/${Uri.encodeComponent(id)}/links',
      body: {'attach': attach, 'detach': detach},
    );
    return CollectionMapper.collection(response.data.obj('collection'));
  });
}

/// [TagsRepository] over `GET /tags` (API-TAG-001).
class HttpTagsRepository implements TagsRepository {
  HttpTagsRepository(this._api);

  final ApiClient _api;

  @override
  Future<Result<List<TagCount>>> list({
    String? prefix,
    TagSort sort = TagSort.usage,
    int limit = 100,
  }) => guard(() async {
    final response = await _api.get(
      '/tags',
      query: {
        'q': prefix == null || prefix.trim().isEmpty ? null : prefix.trim(),
        'sort': sort.apiValue,
        'limit': limit,
      },
    );
    return [for (final item in response.dataList) CollectionMapper.tag(item)];
  });
}
