// In-memory implementation of the Stashly REST API v1 contract (Postman
// collection "Stashly API v1"). Dev/test tooling only: it never ships in the
// app. Used by widget/scenario tests and by tool/fake_api_server.dart so the
// app can be exercised on an emulator before the Laravel backend is running.
import 'dart:convert';
import 'dart:math';

class FakeRequest {
  FakeRequest({
    required this.method,
    required this.path,
    this.query = const {},
    this.headers = const {},
    this.body = '',
  });

  final String method;

  /// Path relative to `/api/v1`, e.g. `/links/01J…`.
  final String path;
  final Map<String, String> query;

  /// Lower-case header names.
  final Map<String, String> headers;
  final String body;
}

class FakeResponse {
  FakeResponse(
    this.status, {
    Object? json,
    this.headers = const {},
    String? raw,
  }) : body = raw ?? (json == null ? '' : jsonEncode(json));

  final int status;
  final String body;
  final Map<String, String> headers;
}

/// Resolves best-effort metadata for a URL once the "background job" runs.
typedef MetadataResolver = Map<String, Object?> Function(String url);

class _User {
  _User(this.id, this.name, this.email, this.password, this.createdAt);

  final String id;
  String name;
  final String email;
  String? password;
  final DateTime createdAt;
  String termsVersion = '1';
  String? googleSubject;
}

class _Link {
  _Link({
    required this.id,
    required this.ownerId,
    required this.url,
    required this.normalized,
    required this.domain,
    required this.createdAt,
  }) : updatedAt = createdAt;

  final String id;
  final String ownerId;
  final String url;
  final String normalized;
  final String domain;
  final DateTime createdAt;
  DateTime updatedAt;
  String? title;
  String? note;
  bool favorite = false;
  String contentType = 'other';
  Map<String, Object?> metadata = {
    'status': 'pending',
    'title': null,
    'description': null,
    'site_name': null,
    'favicon_url': null,
    'preview_image_url': null,
    'fetched_at': null,
    'error_code': null,
  };
  int pendingReads = 0;
  DateTime? lastRefresh;
  final List<String> collectionIds = [];
  final List<String> tags = [];
}

class _Collection {
  _Collection(
    this.id,
    this.ownerId,
    this.name,
    this.description,
    this.createdAt,
  ) : updatedAt = createdAt;

  final String id;
  final String ownerId;
  String name;
  String? description;
  final DateTime createdAt;
  DateTime updatedAt;
}

class FakeStashlyBackend {
  FakeStashlyBackend({
    DateTime Function()? clock,
    MetadataResolver? metadataResolver,
    this.readsUntilMetadataReady = 1,
    this.googleEnabled = false,
  }) : _clock = clock ?? DateTime.now,
       _resolveMetadata = metadataResolver ?? _defaultMetadata;

  final DateTime Function() _clock;
  final MetadataResolver _resolveMetadata;

  /// How many `GET /links/{id}` reads a pending link needs before its
  /// metadata "arrives" (simulates the queue worker).
  final int readsUntilMetadataReady;
  final bool googleEnabled;

  final _random = Random(7);
  int _idCounter = 0;
  final Map<String, _User> _usersByEmail = {};
  final Map<String, String> _tokens = {};
  final Map<String, DateTime> _tokenExpiry = {};
  final List<_Link> _links = [];
  final List<_Collection> _collections = [];
  final Map<String, FakeResponse> _idempotency = {};

  /// Every request handled, for assertions in tests.
  final List<FakeRequest> log = [];

  /// When set, every request fails with this status (e.g. 503 or a fake
  /// transport failure in tests).
  int? forcedStatus;

  // ------------------------------------------------------------------ seed

  /// Creates an account directly (test/demo seeding) and returns its token.
  String seedUser({
    required String name,
    required String email,
    required String password,
    DateTime? createdAt,
  }) {
    final user = _User(
      _id(),
      name,
      email.toLowerCase(),
      password,
      createdAt ?? _clock(),
    );
    _usersByEmail[user.email] = user;
    return _issueToken(user);
  }

  String seedCollection(String token, String name, {String? description}) {
    final user = _userForToken(token)!;
    final collection = _Collection(_id(), user.id, name, description, _clock());
    _collections.add(collection);
    return collection.id;
  }

  String seedLink(
    String token,
    String url, {
    String? title,
    String? note,
    bool favorite = false,
    List<String> collectionIds = const [],
    List<String> tags = const [],
    DateTime? createdAt,
    bool metadataReady = true,
  }) {
    final user = _userForToken(token)!;
    final normalized = normalizeUrl(url)!;
    final link =
        _Link(
            id: _id(),
            ownerId: user.id,
            url: url,
            normalized: normalized,
            domain: _domainOf(normalized),
            createdAt: createdAt ?? _clock(),
          )
          ..title = title
          ..note = note
          ..favorite = favorite;
    link.contentType = _contentTypeFor(link.domain, normalized);
    link.collectionIds.addAll(collectionIds);
    link.tags.addAll(tags.map(_normalizeTag));
    if (metadataReady) _completeMetadata(link);
    _links.add(link);
    return link.id;
  }

  // --------------------------------------------------------------- dispatch

  FakeResponse handle(FakeRequest request) {
    log.add(request);
    if (forcedStatus != null) {
      return _error(
        forcedStatus!,
        forcedStatus == 503 ? 'SERVICE_UNAVAILABLE' : 'SERVER_ERROR',
        'Forced failure.',
      );
    }
    final segments = request.path
        .split('/')
        .where((s) => s.isNotEmpty)
        .toList();
    final m = request.method.toUpperCase();
    final body = _decodeBody(request.body);

    // Public endpoints.
    switch ((m, segments)) {
      case ('GET', ['health']):
        return FakeResponse(
          200,
          json: {
            'data': {
              'status': 'ok',
              'time': _iso(_clock()),
              'checks': {'database': 'ok', 'cache': 'ok', 'queue': 'ok'},
            },
          },
        );
      case ('GET', ['config']):
        return FakeResponse(
          200,
          headers: {'cache-control': 'public, max-age=300'},
          json: {
            'data': {
              'api_version': '1.0',
              'min_supported_app_version': '1.0.0',
              'latest_app_version': '1.0.0',
              'terms': {
                'version': '2026-10-01',
                'url': 'https://stashly.example/terms',
              },
              'privacy': {'url': 'https://stashly.example/privacy'},
              'auth': {'google_enabled': googleEnabled},
              'limits': {
                'url_max_length': 2048,
                'title_max_length': 300,
                'note_max_length': 2000,
                'collection_name_max_length': 60,
                'collection_description_max_length': 300,
                'tag_max_length': 40,
                'tags_per_link_max': 20,
                'collections_per_user_max': 100,
                'page_size_max': 50,
              },
            },
          },
        );
      case ('POST', ['auth', 'register']):
        return _register(body);
      case ('POST', ['auth', 'login']):
        return _login(body);
      case ('POST', ['auth', 'google']):
        return _google(body);
      case ('POST', ['auth', 'forgot-password']):
        final email = body['email'];
        if (email is! String || !email.contains('@')) {
          return _validation({
            'email': ['The email field must be a valid email address.'],
          });
        }
        return FakeResponse(
          200,
          json: {
            'data': {
              'message':
                  'If an account exists for this email, a password reset link has been sent.',
            },
          },
        );
      case ('POST', ['auth', 'reset-password']):
        if (body['token'] != 'valid-reset-token') {
          return _error(
            422,
            'TOKEN_INVALID_OR_EXPIRED',
            'This password reset link is invalid or has expired.',
          );
        }
        final user =
            _usersByEmail[(body['email'] as String? ?? '').toLowerCase()];
        if (user == null) {
          return _error(
            422,
            'TOKEN_INVALID_OR_EXPIRED',
            'This password reset link is invalid or has expired.',
          );
        }
        user.password = body['password'] as String?;
        _tokens.removeWhere((_, id) => id == user.id);
        return FakeResponse(
          200,
          json: {
            'data': {'message': 'Your password has been reset.'},
          },
        );
    }

    // Authenticated endpoints.
    final token = (request.headers['authorization'] ?? '').replaceFirst(
      'Bearer ',
      '',
    );
    final user = _userForToken(token);
    if (user == null) return _error(401, 'UNAUTHENTICATED', 'Unauthenticated.');

    return switch ((m, segments)) {
      ('GET', ['me']) => FakeResponse(
        200,
        json: {
          'data': {'user': _userJson(user)},
        },
      ),
      ('PATCH', ['me']) => _updateMe(user, body),
      ('GET', ['me', 'stats']) => _stats(user),
      ('GET', ['me', 'export']) => _export(user),
      ('PUT', ['me', 'password']) => _changePassword(user, token, body),
      ('DELETE', ['me']) => _deleteMe(user, body),
      ('POST', ['auth', 'refresh']) => _refresh(user, token),
      ('POST', ['auth', 'logout']) => _logout(user, token, body),
      ('GET', ['home']) => _home(user, request.query),
      ('GET', ['links']) => _listLinks(user, request.query),
      ('POST', ['links']) => _createLink(user, body, request),
      ('POST', ['links', 'preview']) => _preview(user, body),
      ('GET', ['links', final id]) => _withLink(
        user,
        id,
        (l) => _linkResponse(l, read: true),
      ),
      ('PATCH', ['links', final id]) => _withLink(
        user,
        id,
        (l) => _updateLink(l, body),
      ),
      ('DELETE', ['links', final id]) => _withLink(user, id, (l) {
        _links.remove(l);
        return FakeResponse(204);
      }),
      ('PUT', ['links', final id, 'collections']) => _withLink(
        user,
        id,
        (l) => _setLinkCollections(user, l, body),
      ),
      ('PUT', ['links', final id, 'tags']) => _withLink(
        user,
        id,
        (l) => _setLinkTags(l, body),
      ),
      ('POST', ['links', final id, 'metadata', 'refresh']) => _withLink(
        user,
        id,
        _refreshMetadata,
      ),
      ('GET', ['tags']) => _listTags(user, request.query),
      ('GET', ['collections']) => _listCollections(user, request.query),
      ('POST', ['collections']) => _createCollection(user, body),
      ('GET', ['collections', final id]) => _withCollection(
        user,
        id,
        (c) => _collectionResponse(c, 200),
      ),
      ('PATCH', ['collections', final id]) => _withCollection(
        user,
        id,
        (c) => _updateCollection(user, c, body),
      ),
      ('DELETE', ['collections', final id]) => _withCollection(user, id, (c) {
        _collections.remove(c);
        for (final link in _links) {
          link.collectionIds.remove(c.id);
        }
        return FakeResponse(204);
      }),
      ('PATCH', ['collections', final id, 'links']) => _withCollection(
        user,
        id,
        (c) => _membership(user, c, body),
      ),
      ('GET', ['search', 'filters']) => _filters(user),
      _ => _error(404, 'NOT_FOUND', 'Resource not found.'),
    };
  }

  // ------------------------------------------------------------------- auth

  FakeResponse _register(Map<String, dynamic> body) {
    final errors = <String, List<String>>{};
    final name = (body['display_name'] as String? ?? '').trim();
    final email = (body['email'] as String? ?? '').trim().toLowerCase();
    final password = body['password'] as String? ?? '';
    if (name.isEmpty || name.length > 100) {
      errors['display_name'] = ['The display name field is required.'];
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      errors['email'] = ['The email field must be a valid email address.'];
    } else if (_usersByEmail.containsKey(email)) {
      errors['email'] = ['The email has already been taken.'];
    }
    if (password.length < 8) {
      errors['password'] = [
        'The password field must be at least 8 characters.',
      ];
    }
    if (body['password_confirmation'] != password) {
      (errors['password'] ??= []).add(
        'The password field confirmation does not match.',
      );
    }
    if (body['terms_accepted'] != true) {
      errors['terms_accepted'] = ['You must accept the terms.'];
    }
    if (errors.isNotEmpty) return _validation(errors);
    final user = _User(_id(), name, email, password, _clock());
    _usersByEmail[email] = user;
    return FakeResponse(
      201,
      json: {
        'data': {
          'user': _userJson(user),
          'token': _tokenJson(_issueToken(user)),
        },
      },
    );
  }

  FakeResponse _login(Map<String, dynamic> body) {
    final email = (body['email'] as String? ?? '').trim().toLowerCase();
    final password = body['password'] as String?;
    if (email.isEmpty || password == null || password.isEmpty) {
      return _validation({
        if (email.isEmpty) 'email': ['The email field is required.'],
        if (password == null || password.isEmpty)
          'password': ['The password field is required.'],
      });
    }
    final user = _usersByEmail[email];
    if (user == null || user.password != password) {
      return _error(
        401,
        'INVALID_CREDENTIALS',
        'The email or password is incorrect.',
      );
    }
    return FakeResponse(
      200,
      json: {
        'data': {
          'user': _userJson(user),
          'token': _tokenJson(_issueToken(user)),
        },
      },
    );
  }

  FakeResponse _updateMe(_User user, Map<String, dynamic> body) {
    if (body.containsKey('email')) {
      return _validation({
        'email': ['The email field is prohibited.'],
      });
    }
    final name = (body['display_name'] as String? ?? '').trim();
    if (name.isEmpty || name.length > 100) {
      return _validation({
        'display_name': [
          'The display name field must be between 1 and 100 characters.',
        ],
      });
    }
    user.name = name;
    return FakeResponse(
      200,
      json: {
        'data': {'user': _userJson(user)},
      },
    );
  }

  FakeResponse _changePassword(
    _User user,
    String token,
    Map<String, dynamic> body,
  ) {
    if (body['current_password'] != user.password) {
      return _validation({
        'current_password': ['The password is incorrect.'],
      });
    }
    final password = body['password'] as String? ?? '';
    if (password.length < 8 || password == user.password) {
      return _validation({
        'password': [
          'The password field and current password must be different.',
        ],
      });
    }
    user.password = password;
    _tokens.removeWhere((t, id) => id == user.id && t != token);
    return FakeResponse(
      200,
      json: {
        'data': {'message': 'Your password has been changed.'},
      },
    );
  }

  /// Stand-in for a Google ID token, which the fake "verifies" by parsing.
  /// Real tokens are signed JWTs checked against Google's keys.
  static String googleIdToken({
    required String email,
    String name = 'Google User',
    bool emailVerified = true,
  }) => 'fake-google|${email.toLowerCase()}|$name|${emailVerified ? 1 : 0}';

  /// `(subject, email, name)` of a valid token, or null (→ 401).
  static (String, String, String)? _verifyGoogleToken(Object? token) {
    if (token is! String) return null;
    final parts = token.split('|');
    if (parts.length != 4 || parts[0] != 'fake-google' || parts[3] != '1') {
      return null;
    }
    return ('sub-${parts[1]}', parts[1], parts[2]);
  }

  FakeResponse _invalidGoogleToken() => _error(
    401,
    'INVALID_GOOGLE_TOKEN',
    'The Google sign-in token is invalid or has expired.',
  );

  /// API-AUTH-008: sign in, link by verified e-mail, or register.
  FakeResponse _google(Map<String, dynamic> body) {
    if (!googleEnabled) {
      return _error(
        503,
        'SERVICE_UNAVAILABLE',
        'Google sign-in is not configured.',
      );
    }
    final errors = <String, List<String>>{
      if (body['id_token'] is! String)
        'id_token': ['The id token field is required.'],
      if (body['device_name'] is! String)
        'device_name': ['The device name field is required.'],
    };
    if (errors.isNotEmpty) return _validation(errors);
    final identity = _verifyGoogleToken(body['id_token']);
    if (identity == null) return _invalidGoogleToken();
    final (subject, email, name) = identity;

    var user = _usersByEmail.values
        .where((u) => u.googleSubject == subject)
        .firstOrNull;
    var status = 200;
    if (user == null) {
      user = _usersByEmail[email];
      if (user != null) {
        // DEC-037: linking revokes older tokens and clears the password.
        user
          ..googleSubject = subject
          ..password = null;
        final linkedId = user.id;
        _tokens.removeWhere((_, id) => id == linkedId);
      } else {
        if (body['terms_accepted'] != true) {
          return _validation({
            'terms_accepted': [
              'You must accept the terms to create an account.',
            ],
          });
        }
        user = _User(_id(), name, email, null, _clock())
          ..googleSubject = subject;
        _usersByEmail[email] = user;
        status = 201;
      }
    }
    return FakeResponse(
      status,
      json: {
        'data': {
          'user': _userJson(user),
          'token': _tokenJson(_issueToken(user)),
        },
      },
    );
  }

  FakeResponse _deleteMe(_User user, Map<String, dynamic> body) {
    if (user.password == null) {
      // Google-only accounts confirm with a fresh ID token for this account.
      final identity = _verifyGoogleToken(body['id_token']);
      if (body['id_token'] is! String) {
        return _validation({
          'id_token': ['The id token field is required.'],
        });
      }
      if (identity == null || identity.$1 != user.googleSubject) {
        return _invalidGoogleToken();
      }
    } else if (body['password'] != user.password) {
      return _validation({
        'password': ['The password is incorrect.'],
      });
    }
    _usersByEmail.remove(user.email);
    _tokens.removeWhere((_, id) => id == user.id);
    _links.removeWhere((l) => l.ownerId == user.id);
    _collections.removeWhere((c) => c.ownerId == user.id);
    return FakeResponse(204);
  }

  FakeResponse _refresh(_User user, String token) {
    _tokens.remove(token);
    return FakeResponse(
      200,
      json: {
        'data': {'token': _tokenJson(_issueToken(user))},
      },
    );
  }

  FakeResponse _logout(_User user, String token, Map<String, dynamic> body) {
    if (body['all_devices'] == true) {
      _tokens.removeWhere((_, id) => id == user.id);
    } else {
      _tokens.remove(token);
    }
    return FakeResponse(204);
  }

  // ---------------------------------------------------------------- profile

  FakeResponse _stats(_User user) {
    final links = _linksOf(user);
    return FakeResponse(
      200,
      json: {
        'data': {
          'links_count': links.length,
          'collections_count': _collectionsOf(user).length,
          'favorites_count': links.where((l) => l.favorite).length,
        },
      },
    );
  }

  FakeResponse _export(_User user) {
    final links = _linksOf(user);
    final stamp = _clock()
        .toUtc()
        .toIso8601String()
        .replaceAll(RegExp(r'[-:]'), '')
        .split('.')
        .first;
    return FakeResponse(
      200,
      headers: {
        'content-disposition':
            'attachment; filename=stashly-export-$stamp.json',
      },
      json: {
        'schema_version': 1,
        'exported_at': _iso(_clock()),
        'user': {
          ..._userJson(user)..remove('password_set'),
          'terms_version': user.termsVersion,
          'terms_accepted_at': _iso(user.createdAt),
        },
        'collections': [
          for (final c in _collectionsOf(user))
            {
              'id': c.id,
              'name': c.name,
              'description': c.description,
              'created_at': _iso(c.createdAt),
              'updated_at': _iso(c.updatedAt),
              'link_ids': [
                for (final l in links)
                  if (l.collectionIds.contains(c.id)) l.id,
              ],
            },
        ],
        'tags': _tagCounts(user).keys.toList(),
        'links': [for (final l in links) _linkJson(l)],
      },
    );
  }

  FakeResponse _home(_User user, Map<String, String> query) {
    final limit = int.tryParse(query['recent_limit'] ?? '10') ?? 10;
    if (limit < 1 || limit > 20) {
      return _validation({
        'recent_limit': ['The recent limit field must not be greater than 20.'],
      });
    }
    final links = _linksOf(user)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final collections = _collectionsOf(user)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return FakeResponse(
      200,
      json: {
        'data': {
          'user': {'display_name': user.name},
          'links_count': links.length,
          'favorites_count': links.where((l) => l.favorite).length,
          'quick_access': [
            for (final c in collections.take(4)) _collectionJson(c),
          ],
          'recent_links': [for (final l in links.take(limit)) _linkJson(l)],
        },
      },
    );
  }

  // ------------------------------------------------------------------ links

  FakeResponse _listLinks(_User user, Map<String, String> query) {
    final limit = int.tryParse(query['limit'] ?? '20') ?? 20;
    if (limit < 1 || limit > 50) {
      return _validation({
        'limit': ['The limit field must be between 1 and 50.'],
      });
    }
    final fingerprint =
        (Map.of(query)
              ..remove('cursor')
              ..remove('limit'))
            .entries
            .map((e) => '${e.key}=${e.value}')
            .join('&');
    var offset = 0;
    final cursor = query['cursor'];
    if (cursor != null) {
      try {
        final decoded =
            jsonDecode(utf8.decode(base64Url.decode(cursor)))
                as Map<String, dynamic>;
        if (decoded['f'] != fingerprint) throw const FormatException();
        offset = decoded['o'] as int;
      } on Object {
        return _error(
          422,
          'INVALID_CURSOR',
          'The cursor is invalid or does not match these filters.',
        );
      }
    }

    Iterable<_Link> links = _linksOf(user);
    final terms = _searchTerms(query['q'] ?? '');
    if (terms.isNotEmpty) {
      links = links.where((l) {
        final haystack = _searchable([
          l.title,
          l.metadata['title'] as String?,
          l.metadata['description'] as String?,
          l.note,
          l.domain,
          l.metadata['site_name'] as String?,
        ]);
        return terms.every(haystack.contains);
      });
    }
    if (query['favorite'] == 'true') links = links.where((l) => l.favorite);
    final types = _csv(query['content_type']);
    if (types.isNotEmpty) {
      links = links.where((l) => types.contains(l.contentType));
    }
    final sources = _csv(query['source']);
    if (sources.isNotEmpty) {
      links = links.where((l) => sources.contains(l.domain));
    }
    final collectionIds = _csv(query['collection_id']);
    if (collectionIds.isNotEmpty) {
      links = links.where((l) => l.collectionIds.any(collectionIds.contains));
    }
    final tags = _csv(query['tags']).map(_normalizeTag).toSet();
    if (tags.isNotEmpty) {
      links = links.where((l) => tags.every(l.tags.contains));
    }
    final days = int.tryParse(query['saved_within_days'] ?? '');
    if (days != null) {
      final since = _clock().subtract(Duration(days: days));
      links = links.where((l) => l.createdAt.isAfter(since));
    }
    final sorted = links.toList()
      ..sort(
        (a, b) => query['sort'] == 'oldest'
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt),
      );
    final page = sorted.skip(offset).take(limit).toList();
    final hasMore = offset + limit < sorted.length;
    return FakeResponse(
      200,
      json: {
        'data': [for (final l in page) _linkJson(l)],
        'meta': {
          'per_page': limit,
          'has_more': hasMore,
          'next_cursor': hasMore
              ? base64Url.encode(
                  utf8.encode(
                    jsonEncode({'o': offset + limit, 'f': fingerprint}),
                  ),
                )
              : null,
          if (cursor == null) 'total': sorted.length,
        },
      },
    );
  }

  FakeResponse _createLink(
    _User user,
    Map<String, dynamic> body,
    FakeRequest request,
  ) {
    final key = request.headers['idempotency-key'];
    if (key != null && _idempotency.containsKey('${user.id}:$key')) {
      final stored = _idempotency['${user.id}:$key']!;
      return FakeResponse(
        stored.status,
        raw: stored.body,
        headers: {'idempotent-replayed': 'true'},
      );
    }
    final url = body['url'];
    final normalized = url is String && url.length <= 2048
        ? normalizeUrl(url)
        : null;
    if (normalized == null) {
      return _error(422, 'INVALID_URL', 'This URL cannot be saved.');
    }
    final title = body['title'] as String?;
    final note = body['note'] as String?;
    final errors = <String, List<String>>{};
    if (title != null && title.length > 300) {
      errors['title'] = [
        'The title field must not be greater than 300 characters.',
      ];
    }
    if (note != null && note.length > 2000) {
      errors['note'] = [
        'The note field must not be greater than 2000 characters.',
      ];
    }
    final collectionIds = (body['collection_ids'] as List? ?? const [])
        .cast<String>();
    for (var i = 0; i < collectionIds.length; i++) {
      if (!_collectionsOf(user).any((c) => c.id == collectionIds[i])) {
        errors['collection_ids.$i'] = ['The selected collection is invalid.'];
      }
    }
    final tags = (body['tags'] as List? ?? const [])
        .cast<String>()
        .map(_normalizeTag)
        .toSet()
        .toList();
    if (tags.length > 20) {
      return _error(422, 'LIMIT_EXCEEDED', 'A link can have at most 20 tags.');
    }
    if (errors.isNotEmpty) return _validation(errors);

    final existing = _linksOf(
      user,
    ).where((l) => l.normalized == normalized).firstOrNull;
    if (existing != null) {
      return _error(
        409,
        'DUPLICATE_LINK',
        'This link is already saved.',
        details: {'existing_link': _linkJson(existing)},
      );
    }
    final link =
        _Link(
            id: _id(),
            ownerId: user.id,
            url: (url as String).trim(),
            normalized: normalized,
            domain: _domainOf(normalized),
            createdAt: _clock(),
          )
          ..title = (title?.trim().isEmpty ?? true) ? null : title!.trim()
          ..note = (note?.trim().isEmpty ?? true) ? null : note!.trim()
          ..favorite = body['is_favorite'] == true;
    link.contentType = _contentTypeFor(link.domain, normalized);
    link.collectionIds.addAll(collectionIds);
    link.tags.addAll(tags);
    _links.add(link);
    final response = _linkResponse(link, status: 201);
    if (key != null) _idempotency['${user.id}:$key'] = response;
    return response;
  }

  FakeResponse _preview(_User user, Map<String, dynamic> body) {
    final url = body['url'];
    final normalized = url is String ? normalizeUrl(url) : null;
    if (normalized == null) {
      return _error(422, 'INVALID_URL', 'This URL cannot be saved.');
    }
    final existing = _linksOf(
      user,
    ).where((l) => l.normalized == normalized).firstOrNull;
    final metadata = existing == null
        ? {
            'fetched_at': _iso(_clock()),
            'error_code': null,
            ..._resolveMetadata(url as String),
          }
        : existing.metadata;
    return FakeResponse(
      200,
      json: {
        'data': {
          'url': url.trim(),
          'normalized_url': normalized,
          'source_domain': _domainOf(normalized),
          'content_type': _contentTypeFor(_domainOf(normalized), normalized),
          'duplicate': existing != null,
          'existing_link': existing == null ? null : _linkJson(existing),
          'metadata': metadata['status'] == null ? null : metadata,
        },
      },
    );
  }

  FakeResponse _updateLink(_Link link, Map<String, dynamic> body) {
    const allowed = {'title', 'note', 'is_favorite'};
    final readOnly = body.keys.where((k) => !allowed.contains(k)).toList();
    if (readOnly.isNotEmpty) {
      return _validation({
        for (final key in readOnly) key: ['This field is read-only.'],
      });
    }
    if (body.containsKey('title')) {
      final title = body['title'] as String?;
      if (title != null && title.length > 300) {
        return _validation({
          'title': ['The title field must not be greater than 300 characters.'],
        });
      }
      link.title = (title?.trim().isEmpty ?? true) ? null : title!.trim();
    }
    if (body.containsKey('note')) {
      final note = body['note'] as String?;
      link.note = (note?.trim().isEmpty ?? true) ? null : note!.trim();
    }
    if (body.containsKey('is_favorite')) {
      link.favorite = body['is_favorite'] == true;
    }
    link.updatedAt = _clock();
    return _linkResponse(link);
  }

  FakeResponse _setLinkCollections(
    _User user,
    _Link link,
    Map<String, dynamic> body,
  ) {
    final ids = (body['collection_ids'] as List? ?? const []).cast<String>();
    final errors = <String, List<String>>{};
    for (var i = 0; i < ids.length; i++) {
      if (!_collectionsOf(user).any((c) => c.id == ids[i])) {
        errors['collection_ids.$i'] = ['The selected collection is invalid.'];
      }
    }
    if (errors.isNotEmpty) return _validation(errors);
    link.collectionIds
      ..clear()
      ..addAll(ids.toSet());
    for (final c in _collectionsOf(user).where((c) => ids.contains(c.id))) {
      c.updatedAt = _clock();
    }
    return _linkResponse(link);
  }

  FakeResponse _setLinkTags(_Link link, Map<String, dynamic> body) {
    final tags = (body['tags'] as List? ?? const [])
        .cast<String>()
        .map(_normalizeTag)
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList();
    if (tags.length > 20) {
      return _error(422, 'LIMIT_EXCEEDED', 'A link can have at most 20 tags.');
    }
    if (tags.any((t) => t.length > 40)) {
      return _validation({
        'tags.0': ['The tag must not be greater than 40 characters.'],
      });
    }
    link.tags
      ..clear()
      ..addAll(tags..sort());
    return _linkResponse(link);
  }

  FakeResponse _refreshMetadata(_Link link) {
    final last = link.lastRefresh;
    if (last != null &&
        _clock().difference(last) < const Duration(minutes: 1)) {
      return _error(
        429,
        'RATE_LIMITED',
        'Too many requests.',
        headers: {'retry-after': '42'},
      );
    }
    link
      ..lastRefresh = _clock()
      ..pendingReads = 0
      ..metadata = {...link.metadata, 'status': 'pending', 'error_code': null};
    return _linkResponse(link, status: 202);
  }

  // ------------------------------------------------------------ collections

  FakeResponse _listCollections(_User user, Map<String, String> query) {
    final limit = int.tryParse(query['limit'] ?? '50') ?? 50;
    final offset = int.tryParse(query['cursor'] ?? '0') ?? 0;
    final all = _collectionsOf(user)
      ..sort(
        (a, b) => query['sort'] == 'name'
            ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
            : b.createdAt.compareTo(a.createdAt),
      );
    final page = all.skip(offset).take(limit).toList();
    final hasMore = offset + limit < all.length;
    return FakeResponse(
      200,
      json: {
        'data': [for (final c in page) _collectionJson(c)],
        'meta': {
          'per_page': limit,
          'has_more': hasMore,
          'next_cursor': hasMore ? '${offset + limit}' : null,
          if (query['cursor'] == null) 'total': all.length,
        },
      },
    );
  }

  FakeResponse _createCollection(_User user, Map<String, dynamic> body) {
    final name = (body['name'] as String? ?? '').trim();
    if (name.isEmpty || name.length > 60) {
      return _validation({
        'name': ['The name field must be between 1 and 60 characters.'],
      });
    }
    if (_collectionsOf(
      user,
    ).any((c) => c.name.toLowerCase() == name.toLowerCase())) {
      return _validation({
        'name': ['A collection with this name already exists.'],
      });
    }
    if (_collectionsOf(user).length >= 100) {
      return _error(
        422,
        'LIMIT_EXCEEDED',
        'You can have at most 100 collections.',
      );
    }
    final description = (body['description'] as String?)?.trim();
    final collection = _Collection(
      _id(),
      user.id,
      name,
      description == null || description.isEmpty ? null : description,
      _clock(),
    );
    _collections.add(collection);
    return _collectionResponse(collection, 201);
  }

  FakeResponse _updateCollection(
    _User user,
    _Collection collection,
    Map<String, dynamic> body,
  ) {
    if (body.containsKey('name')) {
      final name = (body['name'] as String? ?? '').trim();
      if (name.isEmpty || name.length > 60) {
        return _validation({
          'name': ['The name field must be between 1 and 60 characters.'],
        });
      }
      if (_collectionsOf(user).any(
        (c) =>
            c.id != collection.id && c.name.toLowerCase() == name.toLowerCase(),
      )) {
        return _validation({
          'name': ['A collection with this name already exists.'],
        });
      }
      collection.name = name;
    }
    if (body.containsKey('description')) {
      final description = (body['description'] as String?)?.trim();
      collection.description = description == null || description.isEmpty
          ? null
          : description;
    }
    collection.updatedAt = _clock();
    return _collectionResponse(collection, 200);
  }

  FakeResponse _membership(
    _User user,
    _Collection collection,
    Map<String, dynamic> body,
  ) {
    final attach = (body['attach'] as List? ?? const []).cast<String>();
    final detach = (body['detach'] as List? ?? const []).cast<String>();
    if (attach.isEmpty && detach.isEmpty) {
      return _validation({
        'attach': ['At least one of attach or detach is required.'],
      });
    }
    final errors = <String, List<String>>{};
    for (var i = 0; i < attach.length; i++) {
      if (!_linksOf(user).any((l) => l.id == attach[i])) {
        errors['attach.$i'] = ['The selected link is invalid.'];
      }
    }
    if (errors.isNotEmpty) return _validation(errors);
    for (final link in _linksOf(user)) {
      if (attach.contains(link.id) &&
          !link.collectionIds.contains(collection.id)) {
        link.collectionIds.add(collection.id);
      }
      if (detach.contains(link.id)) link.collectionIds.remove(collection.id);
    }
    collection.updatedAt = _clock();
    return _collectionResponse(collection, 200);
  }

  // ------------------------------------------------------------ tags/search

  FakeResponse _listTags(_User user, Map<String, String> query) {
    final prefix = _normalizeTag(query['q'] ?? '');
    final counts =
        _tagCounts(user).entries.where((e) => e.key.startsWith(prefix)).toList()
          ..sort(
            (a, b) => query['sort'] == 'name'
                ? a.key.compareTo(b.key)
                : b.value.compareTo(a.value),
          );
    final limit = int.tryParse(query['limit'] ?? '100') ?? 100;
    return FakeResponse(
      200,
      json: {
        'data': [
          for (final e in counts.take(limit))
            {'name': e.key, 'links_count': e.value},
        ],
      },
    );
  }

  FakeResponse _filters(_User user) {
    final links = _linksOf(user);
    final sources = <String, int>{};
    for (final l in links) {
      sources[l.domain] = (sources[l.domain] ?? 0) + 1;
    }
    final now = _clock();
    return FakeResponse(
      200,
      json: {
        'data': {
          'content_types': [
            for (final type in [
              'video',
              'article',
              'product',
              'social',
              'other',
            ])
              {
                'value': type,
                'count': links.where((l) => l.contentType == type).length,
              },
          ],
          'sources': [
            for (final e in sources.entries) {'value': e.key, 'count': e.value},
          ],
          'collections': [
            for (final c in _collectionsOf(user))
              {
                'id': c.id,
                'name': c.name,
                'count': links
                    .where((l) => l.collectionIds.contains(c.id))
                    .length,
              },
          ],
          'tags': [
            for (final e in _tagCounts(user).entries)
              {'name': e.key, 'count': e.value},
          ],
          'date_presets': [
            for (final days in [7, 30])
              {
                'value': days,
                'count': links
                    .where(
                      (l) => l.createdAt.isAfter(
                        now.subtract(Duration(days: days)),
                      ),
                    )
                    .length,
              },
          ],
        },
      },
    );
  }

  // ---------------------------------------------------------------- helpers

  FakeResponse _withLink(
    _User user,
    String id,
    FakeResponse Function(_Link) action,
  ) {
    final link = _links
        .where((l) => l.id == id && l.ownerId == user.id)
        .firstOrNull;
    // Another user's link is indistinguishable from a missing one.
    return link == null
        ? _error(404, 'NOT_FOUND', 'Resource not found.')
        : action(link);
  }

  FakeResponse _withCollection(
    _User user,
    String id,
    FakeResponse Function(_Collection) action,
  ) {
    final collection = _collections
        .where((c) => c.id == id && c.ownerId == user.id)
        .firstOrNull;
    return collection == null
        ? _error(404, 'NOT_FOUND', 'Resource not found.')
        : action(collection);
  }

  FakeResponse _linkResponse(
    _Link link, {
    int status = 200,
    bool read = false,
  }) {
    if (read && link.metadata['status'] == 'pending') {
      link.pendingReads++;
      if (link.pendingReads >= readsUntilMetadataReady) _completeMetadata(link);
    }
    return FakeResponse(
      status,
      json: {
        'data': {'link': _linkJson(link)},
      },
    );
  }

  FakeResponse _collectionResponse(_Collection collection, int status) =>
      FakeResponse(
        status,
        json: {
          'data': {'collection': _collectionJson(collection)},
        },
      );

  void _completeMetadata(_Link link) {
    final resolved = _resolveMetadata(link.url);
    link.metadata = {
      'status': 'ready',
      'title': null,
      'description': null,
      'site_name': null,
      'favicon_url': null,
      'preview_image_url': null,
      ...resolved,
      'fetched_at': _iso(_clock()),
      'error_code': null,
    };
    if (resolved['status'] == 'failed' || resolved['status'] == 'blocked') {
      link.metadata['fetched_at'] = null;
    }
  }

  Map<String, Object?> _linkJson(_Link l) {
    final ownCollections = _collections
        .where((c) => l.collectionIds.contains(c.id))
        .toList();
    final metadataTitle = l.metadata['title'] as String?;
    return {
      'id': l.id,
      'original_url': l.url,
      'normalized_url': l.normalized,
      'source_domain': l.domain,
      'title': l.title,
      'display_title': l.title ?? metadataTitle ?? l.domain,
      'note': l.note,
      'is_favorite': l.favorite,
      'content_type': l.contentType,
      'metadata': Map.of(l.metadata),
      'collections': [
        for (final c in ownCollections) {'id': c.id, 'name': c.name},
      ],
      'collections_count': ownCollections.length,
      'tags': List.of(l.tags),
      'created_at': _iso(l.createdAt),
      'updated_at': _iso(l.updatedAt),
    };
  }

  Map<String, Object?> _collectionJson(_Collection c) {
    final members = _links.where((l) => l.collectionIds.contains(c.id)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return {
      'id': c.id,
      'name': c.name,
      'description': c.description,
      'links_count': members.length,
      'cover_images': [
        for (final l in members)
          if (l.metadata['preview_image_url'] case final String url) url,
      ].take(4).toList(),
      'created_at': _iso(c.createdAt),
      'updated_at': _iso(c.updatedAt),
    };
  }

  Map<String, Object?> _userJson(_User user) => {
    'id': user.id,
    'display_name': user.name,
    'email': user.email,
    'created_at': _iso(user.createdAt),
    'password_set': user.password != null,
  };

  Map<String, Object?> _tokenJson(String token) => {
    'access_token': token,
    'token_type': 'Bearer',
    'expires_at': _iso(_tokenExpiry[token]!),
  };

  String _issueToken(_User user) {
    final token =
        '${_id()}|${List.generate(24, (_) => _random.nextInt(36).toRadixString(36)).join()}';
    _tokens[token] = user.id;
    _tokenExpiry[token] = _clock().add(const Duration(days: 60));
    return token;
  }

  _User? _userForToken(String token) {
    final id = _tokens[token];
    if (id == null) return null;
    return _usersByEmail.values.where((u) => u.id == id).firstOrNull;
  }

  List<_Link> _linksOf(_User user) =>
      _links.where((l) => l.ownerId == user.id).toList();

  List<_Collection> _collectionsOf(_User user) =>
      _collections.where((c) => c.ownerId == user.id).toList();

  Map<String, int> _tagCounts(_User user) {
    final counts = <String, int>{};
    for (final link in _linksOf(user)) {
      for (final tag in link.tags) {
        counts[tag] = (counts[tag] ?? 0) + 1;
      }
    }
    return counts;
  }

  String _id() {
    // Time-sortable, ULID-shaped (26 chars, Crockford alphabet).
    const alphabet = '0123456789abcdefghjkmnpqrstvwxyz';
    final time = (_clock().millisecondsSinceEpoch + _idCounter++)
        .toRadixString(32)
        .padLeft(10, '0');
    final rand = List.generate(16, (_) => alphabet[_random.nextInt(32)]).join();
    return '$time$rand'.substring(0, 26);
  }

  static Map<String, dynamic> _decodeBody(String body) {
    if (body.isEmpty) return const {};
    final decoded = jsonDecode(body);
    return decoded is Map<String, dynamic> ? decoded : const {};
  }

  static FakeResponse _validation(Map<String, List<String>> details) => _error(
    422,
    'VALIDATION_FAILED',
    'The given data was invalid.',
    details: details,
  );

  static FakeResponse _error(
    int status,
    String code,
    String message, {
    Map<String, Object?> details = const {},
    Map<String, String> headers = const {},
  }) => FakeResponse(
    status,
    headers: headers,
    json: {
      'error': {
        'code': code,
        'message': message,
        'details': details,
        'request_id': 'fake-request',
      },
    },
  );

  static String _iso(DateTime value) =>
      '${value.toUtc().toIso8601String().split('.').first}Z';

  static List<String> _csv(String? value) => (value ?? '')
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  static String _normalizeTag(String raw) => raw
      .trim()
      .replaceFirst(RegExp(r'^#+'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .toLowerCase();

  static String _arabicFold(String text) => text
      .toLowerCase()
      .replaceAll(RegExp('[ً-ٰٟـ]'), '')
      .replaceAll(RegExp('[أإآٱ]'), 'ا')
      .replaceAll('ى', 'ي');

  static String _searchable(List<String?> parts) =>
      _arabicFold(parts.whereType<String>().join(' '));

  static List<String> _searchTerms(String q) => _arabicFold(
    q,
  ).split(RegExp(r'\s+')).where((t) => t.isNotEmpty).take(6).toList();

  static String _domainOf(String normalized) => Uri.parse(normalized).host;

  static String _contentTypeFor(String domain, String normalized) {
    if (RegExp(
      r'(^|\.)(youtube\.com|youtu\.be|vimeo\.com)$',
    ).hasMatch(domain)) {
      return 'video';
    }
    if (RegExp(
      r'(^|\.)(instagram\.com|tiktok\.com|x\.com|twitter\.com|threads\.net|facebook\.com)$',
    ).hasMatch(domain)) {
      return 'social';
    }
    if (RegExp(
      r'(^|\.)(amazon\.[a-z.]+|muji\.com|etsy\.com|ikea\.com)$',
    ).hasMatch(domain)) {
      return 'product';
    }
    return Uri.parse(
              normalized,
            ).pathSegments.where((s) => s.isNotEmpty).length >
            1
        ? 'article'
        : 'other';
  }

  /// One normalization for duplicate detection (BR-URL-002).
  static String? normalizeUrl(String input) {
    var text = input.trim();
    if (text.isEmpty) return null;
    if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9+.\-]*://').hasMatch(text)) {
      text = 'https://$text';
    }
    final uri = Uri.tryParse(text);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }
    if (uri.host.isEmpty || uri.userInfo.isNotEmpty) return null;
    var host = uri.host.toLowerCase();
    for (final prefix in ['www.', 'm.']) {
      if (host.startsWith(prefix)) host = host.substring(prefix.length);
    }
    final params = Map.of(uri.queryParameters)
      ..removeWhere(
        (k, _) =>
            k.startsWith('utm_') ||
            const {'fbclid', 'gclid', 'feature', 'si'}.contains(k),
      );
    final sortedKeys = params.keys.toList()..sort();
    var path = uri.path;
    if (path.endsWith('/')) path = path.substring(0, path.length - 1);
    if (host == 'youtu.be' && path.length > 1) {
      return 'https://youtube.com/watch?v=${path.substring(1)}';
    }
    final query = sortedKeys.map((k) => '$k=${params[k]}').join('&');
    return 'https://$host$path${query.isEmpty ? '' : '?$query'}';
  }

  static Map<String, Object?> _defaultMetadata(String url) {
    final normalized = normalizeUrl(url) ?? url;
    final segments = Uri.parse(
      normalized,
    ).pathSegments.where((s) => s.isNotEmpty).toList();
    final words =
        (segments.isEmpty ? Uri.parse(normalized).host : segments.last)
            .replaceAll(RegExp(r'[-_]+'), ' ')
            .replaceAll(RegExp(r'\.\w+$'), '');
    final title = words.isEmpty
        ? null
        : '${words[0].toUpperCase()}${words.substring(1)}';
    return {
      'status': 'ready',
      'title': title,
      'description': title == null
          ? null
          : 'Saved from ${Uri.parse(normalized).host}.',
      'site_name': Uri.parse(normalized).host,
      'favicon_url': null,
      'preview_image_url': null,
    };
  }
}
