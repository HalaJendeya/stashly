// Contract tests: replays every saved example of the "Stashly API v1" Postman
// collection through the real repositories and checks both directions —
// the request the app sends and how it interprets each documented response.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:stashly/core/network/api_client.dart';
import 'package:stashly/core/result/app_failure.dart';
import 'package:stashly/core/result/paging.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/features/app_config/data/http_app_config_repository.dart';
import 'package:stashly/features/app_config/domain/app_config.dart';
import 'package:stashly/features/auth/data/http_auth_repository.dart';
import 'package:stashly/features/auth/data/token_store.dart';
import 'package:stashly/features/auth/domain/auth.dart';
import 'package:stashly/features/collections/data/http_collections_repository.dart';
import 'package:stashly/features/collections/domain/collection.dart';
import 'package:stashly/features/home/data/http_home_repository.dart';
import 'package:stashly/features/home/domain/home.dart';
import 'package:stashly/features/links/data/http_links_repository.dart';
import 'package:stashly/features/links/data/link_mapper.dart';
import 'package:stashly/features/links/domain/link.dart';
import 'package:stashly/features/links/domain/links_repository.dart';
import 'package:stashly/features/profile/data/http_profile_repository.dart';
import 'package:stashly/features/profile/domain/profile.dart';
import 'package:stashly/features/search/data/search_data.dart';
import 'package:stashly/features/search/domain/search.dart';

const _base = 'https://api.stashly.test/api/v1';
const _linkId = '01jc3k9r5e8f1a2d4g6h7j9k0m';
const _collectionId = '01jc3ka0q1w2e3r4t5y6x7z8a9';

/// Error codes documented by the API and the failure each must become.
const _expectedKinds = {
  'VALIDATION_FAILED': FailureKind.validation,
  'INVALID_URL': FailureKind.invalidUrl,
  'INVALID_CURSOR': FailureKind.invalidCursor,
  'LIMIT_EXCEEDED': FailureKind.limitExceeded,
  'TOKEN_INVALID_OR_EXPIRED': FailureKind.tokenInvalidOrExpired,
  'INVALID_CREDENTIALS': FailureKind.invalidCredentials,
  'INVALID_GOOGLE_TOKEN': FailureKind.invalidGoogleToken,
  'UNAUTHENTICATED': FailureKind.unauthenticated,
  'NOT_FOUND': FailureKind.notFound,
  'DUPLICATE_LINK': FailureKind.duplicateLink,
  'RATE_LIMITED': FailureKind.rateLimited,
  'SERVICE_UNAVAILABLE': FailureKind.serviceUnavailable,
};

class _Example {
  _Example(this.folder, this.name, this.request, this.response);

  final String folder;
  final String name;
  final Map<String, dynamic> request;
  final Map<String, dynamic> response;

  int get code => response['code'] as int;
  String get body => response['body'] as String? ?? '';
  String? get originalBody => response['originalBody'] as String?;
  Map<String, String> get headers => {
    for (final h in (response['header'] as List).cast<Map<String, dynamic>>())
      (h['key'] as String).toLowerCase(): h['value'] as String,
  };

  Map<String, dynamic>? get errorJson {
    if (body.isEmpty) return null;
    final decoded = jsonDecode(body);
    return decoded is Map<String, dynamic> &&
            decoded['error'] is Map<String, dynamic>
        ? decoded['error'] as Map<String, dynamic>
        : null;
  }

  Map<String, dynamic> get dataJson =>
      (jsonDecode(body) as Map<String, dynamic>)['data']
          as Map<String, dynamic>;

  /// Documented request URL with Postman variables resolved.
  Uri get documentedUri => Uri.parse(
    (request['url'] as String)
        .replaceAll('{{base_url}}', _base)
        .replaceAll('{{link_id}}', _linkId)
        .replaceAll('{{collection_id}}', _collectionId),
  );

  Set<String> get documentedBodyKeys {
    final keys = <String>{};
    for (final raw in [request['body'] as String?, originalBody]) {
      if (raw == null) continue;
      final decoded = jsonDecode(
        raw.replaceAll(RegExp(r'"\{\{[^}]+\}\}"'), '"x"'),
      );
      if (decoded is Map<String, dynamic>) keys.addAll(decoded.keys);
    }
    return keys;
  }
}

class _Harness {
  _Harness(_Example example, {AuthToken? token}) {
    tokens = MemoryTokenStore(
      token ??
          AuthToken(
            accessToken: 'test-token',
            expiresAt: DateTime.now().toUtc().add(const Duration(days: 50)),
          ),
    );
    api = ApiClient(
      baseUri: Uri.parse(_base),
      tokens: tokens,
      httpClient: MockClient((request) async {
        sent = request;
        final headers = {
          'content-type': 'application/json',
          ...example.headers,
        };
        return http.Response(example.body, example.code, headers: headers);
      }),
    );
    api.onUnauthenticated.listen((_) => unauthenticatedEvents++);
  }

  late final MemoryTokenStore tokens;
  late final ApiClient api;
  http.Request? sent;
  int unauthenticatedEvents = 0;

  HttpLinksRepository get links => HttpLinksRepository(api);
  HttpCollectionsRepository get collections => HttpCollectionsRepository(api);
  HttpTagsRepository get tags => HttpTagsRepository(api);
  HttpAuthRepository get auth => HttpAuthRepository(api, tokens);
  HttpProfileRepository get profile => HttpProfileRepository(api);
  HttpAppConfigRepository get config => HttpAppConfigRepository(api);
  HttpSearchRepository get search => HttpSearchRepository(api);
  HttpHomeRepository get home => HttpHomeRepository(
    api,
    parseLink: LinkMapper.link,
    parseCollection: CollectionMapper.collection,
  );
}

typedef _Driver = Future<Result<Object?>> Function(_Harness h, _Example e);

/// How the app calls each documented operation.
final Map<String, _Driver> _drivers = {
  'Health check': (h, e) => h.config.checkHealth(),
  'Get app configuration': (h, e) => h.config.fetchConfig(),
  'Register': (h, e) => h.auth.register(
    const RegistrationRequest(
      displayName: 'Postman User',
      email: 'user@example.test',
      password: 'postman-initial-1',
      termsAccepted: true,
      termsVersion: '1',
    ),
  ),
  'Login': (h, e) =>
      h.auth.login(email: 'user@example.test', password: 'secret-123'),
  'Sign in with Google': (h, e) => h.auth.signInWithGoogle(
    idToken: 'google-id-token',
    termsAccepted: true,
    termsVersion: 'draft-1',
  ),
  'Get current user': (h, e) => h.auth.currentUser(),
  'Update profile': (h, e) =>
      h.auth.updateDisplayName('Postman User (updated)'),
  'Get my stats': (h, e) => h.profile.stats(),
  'Refresh token': (h, e) => h.auth.refreshIfNeeded(),
  'Change password': (h, e) => h.auth.changePassword(
    currentPassword: 'postman-initial-1',
    newPassword: 'postman-changed-2',
  ),
  'Forgot password': (h, e) => h.auth.forgotPassword('user@example.test'),
  'Reset password': (h, e) => h.auth.resetPassword(
    email: 'user@example.test',
    token: 'reset-token',
    password: 'postman-changed-2',
  ),
  'Logout': (h, e) => h.auth.logout(),
  'Delete account': (h, e) => (e.originalBody ?? '').contains('id_token')
      ? h.auth.deleteAccount(googleIdToken: 'google-id-token')
      : h.auth.deleteAccount(password: 'postman-initial-1'),
  'Get home': (h, e) => h.home.load(recentLimit: 10),
  'List links': (h, e) => h.links.list(const LinkQuery()),
  'Create link': (h, e) => h.links.create(
    const NewLink(
      url: 'https://example.com/postman-1',
      title: 'Postman test link',
      note: 'Created by the Postman collection',
    ),
    idempotencyKey: '7b0c1d9e-1d2f-4a5b-9c8d-0e1f2a3b4c5d',
  ),
  'Get link': (h, e) => h.links.get(_linkId),
  'Update link': (h, e) => h.links.update(
    _linkId,
    const LinkUpdate(
      title: FieldUpdate('Postman test link (edited)'),
      note: FieldUpdate('Edited by the Postman collection'),
      isFavorite: true,
    ),
  ),
  'Set link collections': (h, e) => h.links.setCollections(_linkId, const []),
  'Set link tags': (h, e) =>
      h.links.setTags(_linkId, const ['#Postman', 'api']),
  'Delete link': (h, e) => h.links.delete(_linkId),
  'Preview link': (h, e) => h.links.preview('https://example.com'),
  'Refresh link metadata': (h, e) => h.links.refreshMetadata(_linkId),
  'List tags': (h, e) => h.tags.list(),
  'List collections': (h, e) => h.collections.list(),
  'Create collection': (h, e) => h.collections.create(
    name: 'Postman 1',
    description: 'Created by the Postman collection',
  ),
  'Get collection': (h, e) => h.collections.get(_collectionId),
  'Update collection': (h, e) => h.collections.update(
    _collectionId,
    description: const FieldUpdate('Updated by the Postman collection'),
  ),
  'Attach / detach links': (h, e) =>
      h.collections.updateMembership(_collectionId, attach: const [_linkId]),
  'Delete collection': (h, e) => h.collections.delete(_collectionId),
  'Get filter options': (h, e) => h.search.filterOptions(),
  'Search links': (h, e) => h.links.list(const LinkQuery(text: 'postman')),
  'Export my data': (h, e) => h.profile.exportData(),
};

/// Extra checks on a parsed success, per operation.
void _verifySuccess(_Example e, Object? value, _Harness h) {
  switch (e.name) {
    case 'Health check':
      expect((value! as ServiceHealth).healthy, e.code == 200);
    case 'Get app configuration':
      final config = value! as AppConfig;
      final data = e.dataJson;
      expect(config.termsVersion, (data['terms'] as Map)['version']);
      expect(config.googleEnabled, (data['auth'] as Map)['google_enabled']);
      expect(
        config.tagsPerLinkMax,
        (data['limits'] as Map)['tags_per_link_max'],
      );
    case 'Register' || 'Login' || 'Sign in with Google':
      final user = value! as User;
      final data = e.dataJson;
      expect(user.email, (data['user'] as Map)['email']);
      expect(user.passwordSet, (data['user'] as Map)['password_set']);
      expect(
        h.tokens.token?.accessToken,
        (data['token'] as Map)['access_token'],
      );
    case 'Get current user' || 'Update profile':
      expect(
        (value! as User).displayName,
        (e.dataJson['user'] as Map)['display_name'],
      );
    case 'Refresh token':
      expect(
        h.tokens.token?.accessToken,
        (e.dataJson['token'] as Map)['access_token'],
      );
    case 'Get my stats':
      expect((value! as AccountStats).linksCount, e.dataJson['links_count']);
    case 'Get home':
      final home = value! as HomeSummary;
      expect(
        home.recentLinks,
        hasLength((e.dataJson['recent_links'] as List).length),
      );
      expect(
        home.quickAccess,
        hasLength((e.dataJson['quick_access'] as List).length),
      );
    case 'List links' || 'Search links':
      final page = value! as Paged<Link>;
      final decoded = jsonDecode(e.body) as Map<String, dynamic>;
      expect(page.items, hasLength((decoded['data'] as List).length));
      expect(page.total, (decoded['meta'] as Map)['total']);
    case 'Create link' ||
        'Get link' ||
        'Update link' ||
        'Set link collections' ||
        'Set link tags' ||
        'Refresh link metadata':
      final link = value! as Link;
      final json = e.dataJson['link'] as Map<String, dynamic>;
      expect(link.id, json['id']);
      expect(link.tags, json['tags']);
      expect(link.metadata.status.name, (json['metadata'] as Map)['status']);
    case 'Preview link':
      final preview = value! as LinkPreview;
      expect(preview.duplicate, e.dataJson['duplicate']);
    case 'List tags':
      expect(value, isA<List<TagCount>>());
    case 'List collections':
      expect((value! as Paged<Collection>).items, isNotEmpty);
    case 'Create collection' ||
        'Get collection' ||
        'Update collection' ||
        'Attach / detach links':
      expect(
        (value! as Collection).id,
        (e.dataJson['collection'] as Map)['id'],
      );
    case 'Get filter options':
      final options = value! as FilterOptions;
      expect(options.contentTypes, hasLength(5));
      expect(options.datePresets.map((p) => p.value), [7, 30]);
    case 'Export my data':
      final export = value! as DataExport;
      expect(export.filename, 'stashly-export-20261020-093012.json');
      expect(
        jsonDecode(utf8.decode(export.bytes)),
        containsPair('schema_version', 1),
      );
  }
}

List<_Example> _loadExamples() {
  final file = File('test/fixtures/stashly_api_v1_examples.json');
  final root = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final examples = <_Example>[];
  for (final folder in (root['item'] as List).cast<Map<String, dynamic>>()) {
    for (final item in (folder['item'] as List).cast<Map<String, dynamic>>()) {
      for (final response
          in (item['response'] as List).cast<Map<String, dynamic>>()) {
        examples.add(
          _Example(
            folder['name'] as String,
            item['name'] as String,
            item['request'] as Map<String, dynamic>,
            response,
          ),
        );
      }
    }
  }
  return examples;
}

void main() {
  final examples = _loadExamples();

  test('every documented operation has a client implementation', () {
    final names = examples.map((e) => e.name).toSet();
    expect(names.difference(_drivers.keys.toSet()), isEmpty);
    expect(examples.length, greaterThanOrEqualTo(99));
  });

  for (final example in examples) {
    test(
      '${example.folder} › ${example.name} › ${example.response['name']}',
      () async {
        // "Refresh token" only calls the server when the token is > 30 days old.
        final harness = _Harness(
          example,
          token: example.name == 'Refresh token'
              ? AuthToken(
                  accessToken: 'old-token',
                  expiresAt: DateTime.now().toUtc().add(
                    const Duration(days: 10),
                  ),
                )
              : null,
        );

        final result = await _drivers[example.name]!(harness, example);
        final request = harness.sent;
        expect(request, isNotNull, reason: 'no HTTP request was sent');

        // --- Request side -----------------------------------------------------
        final documented = example.documentedUri;
        expect(request!.method, example.request['method']);
        expect(request.url.path, documented.path);
        documented.queryParameters.forEach((key, value) {
          expect(
            request.url.queryParameters[key],
            value,
            reason: 'query "$key"',
          );
        });
        expect(request.headers['Accept'], 'application/json');
        if (example.request['auth'] == 'noauth') {
          expect(request.headers.containsKey('Authorization'), isFalse);
        } else {
          expect(request.headers['Authorization'], startsWith('Bearer '));
        }
        if (example.name == 'Create link') {
          expect(
            request.headers['Idempotency-Key'],
            matches(RegExp(r'^[0-9a-f-]{36}$')),
          );
        }
        if (request.body.isNotEmpty) {
          expect(
            request.headers['Content-Type'],
            startsWith('application/json'),
          );
          final sentKeys = (jsonDecode(request.body) as Map<String, dynamic>)
              .keys
              .toSet();
          expect(
            sentKeys.difference(example.documentedBodyKeys),
            isEmpty,
            reason: 'body fields not in the contract',
          );
        }

        // --- Response side ----------------------------------------------------
        final error = example.errorJson;
        final healthReport =
            example.name == 'Health check' && example.code == 503;
        if (example.code < 300 || healthReport) {
          expect(result, isA<Ok<Object?>>(), reason: '${result.failureOrNull}');
          _verifySuccess(example, result.valueOrNull, harness);
        } else {
          expect(result, isA<Err<Object?>>());
          final failure = result.failureOrNull!;
          final code = error?['code'] as String?;
          expect(
            failure.kind,
            _expectedKinds[code],
            reason: 'error.code $code',
          );
          expect(failure.code, code);
          if (code == 'VALIDATION_FAILED') {
            expect(failure.fieldErrors, isNotEmpty);
          }
          if (code == 'RATE_LIMITED' &&
              example.headers['retry-after'] != null) {
            expect(
              failure.retryAfter?.inSeconds,
              int.parse(example.headers['retry-after']!),
            );
          }
          if (code == 'DUPLICATE_LINK') {
            expect(
              failure.payload,
              isA<Link>(),
              reason: 'existing link attached',
            );
          }
          if (code == 'UNAUTHENTICATED') {
            await Future<void>.delayed(Duration.zero);
            expect(harness.unauthenticatedEvents, 1);
          }
        }

        // Sessions end locally after logout and account deletion.
        if ((example.name == 'Logout' || example.name == 'Delete account') &&
            example.code == 204) {
          expect(harness.tokens.token, isNull);
        }
      },
    );
  }
}
