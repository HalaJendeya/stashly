// Drives the app's real repositories against a deployed Stashly API.
// Opt-in, because it creates (and finally deletes) a throwaway account:
//
//   STASHLY_LIVE_API=https://stashly.labbaass.com/api/v1 flutter test test/live
@Tags(['live'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:stashly/app/dependencies.dart';
import 'package:stashly/core/network/idempotency.dart';
import 'package:stashly/core/result/app_failure.dart';
import 'package:stashly/core/result/paging.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/core/storage/key_value_store.dart';
import 'package:stashly/features/auth/data/token_store.dart';
import 'package:stashly/features/auth/domain/auth.dart';
import 'package:stashly/features/auth/domain/google_identity.dart';
import 'package:stashly/features/links/domain/link.dart';
import 'package:stashly/features/links/domain/links_repository.dart';
import 'package:stashly/features/share_intake/domain/shared_link_source.dart';

final _baseUrl = Platform.environment['STASHLY_LIVE_API'];

class _NoShares implements SharedTextSource {
  @override
  Future<String?> takeInitialShare() async => null;

  @override
  Stream<String> get shares => const Stream.empty();
}

T ok<T>(Result<T> result, String step) => switch (result) {
  Ok(:final value) => value,
  Err(:final failure) => fail(
    '$step failed: $failure ${failure.fieldErrors} ${failure.message ?? ''}',
  ),
};

AppFailure err<T>(Result<T> result, String step) => switch (result) {
  Ok() => fail('$step unexpectedly succeeded'),
  Err(:final failure) => failure,
};

void main() {
  late AppDependencies deps;
  final tokens = MemoryTokenStore();
  final stamp = DateTime.now().millisecondsSinceEpoch;
  final email = 'app-live+$stamp@example.test';
  const password = 'live-check-pass-1';
  var accountCreated = false;

  setUpAll(() {
    deps = AppDependencies.create(
      tokenStore: tokens,
      preferences: MemoryKeyValueStore(),
      sharedText: _NoShares(),
      google: const UnavailableGoogleIdentity(),
      baseUrl: _baseUrl ?? 'https://invalid.test/api/v1',
    );
  });

  tearDownAll(() async {
    // Never leave the throwaway account behind, even after a failure.
    if (accountCreated && await tokens.read() != null) {
      await deps.auth.deleteAccount(password: password);
    }
    deps.dispose();
  });

  test(
    'the app works end to end against the deployed API',
    () async {
      // ---- public
      final health = ok(await deps.config.checkHealth(), 'GET /health');
      expect(health.healthy, isTrue);
      final config = ok(await deps.config.fetchConfig(), 'GET /config');
      expect(config.termsVersion, isNotNull);

      // ---- account
      final registerError = err(
        await deps.auth.register(
          RegistrationRequest(
            displayName: 'Live check',
            email: email,
            password: password,
            termsAccepted: false,
          ),
        ),
        'register without terms',
      );
      expect(registerError.fieldError('terms_accepted'), isNotNull);

      final user = ok(
        await deps.auth.register(
          RegistrationRequest(
            displayName: 'Live check',
            email: email,
            password: password,
            termsAccepted: true,
            termsVersion: config.termsVersion,
          ),
        ),
        'POST /auth/register',
      );
      accountCreated = true;
      expect(user.email, email);
      expect(user.passwordSet, isTrue);

      final badLogin = err(
        await deps.auth.login(email: email, password: 'not-the-password'),
        'login with a wrong password',
      );
      expect(badLogin.kind, FailureKind.invalidCredentials);
      ok(
        await deps.auth.login(email: email, password: password),
        'POST /auth/login',
      );
      expect(
        ok(await deps.auth.currentUser(), 'GET /me').displayName,
        'Live check',
      );
      expect(
        ok(
          await deps.auth.updateDisplayName('Live check 2'),
          'PATCH /me',
        ).displayName,
        'Live check 2',
      );
      ok(
        await deps.auth.refreshIfNeeded(),
        'refresh check (no-op while fresh)',
      );

      // ---- links
      final created = ok(
        await deps.links.create(
          NewLink(
            url: 'https://example.com/stashly-live-check-$stamp?utm_source=app',
            title: 'Live check link',
            tags: const ['Live Check'],
          ),
          idempotencyKey: newIdempotencyKey(),
        ),
        'POST /links',
      );
      expect(created.displayTitle, 'Live check link');
      expect(created.tags, contains('live check'));

      final duplicate = err(
        await deps.links.create(
          NewLink(url: 'https://EXAMPLE.com/stashly-live-check-$stamp'),
          idempotencyKey: newIdempotencyKey(),
        ),
        'duplicate POST /links',
      );
      expect(duplicate.kind, FailureKind.duplicateLink);
      expect((duplicate.payload! as Link).id, created.id);

      final invalid = err(
        await deps.links.create(
          const NewLink(url: 'javascript:alert(1)'),
          idempotencyKey: newIdempotencyKey(),
        ),
        'invalid URL',
      );
      expect(
        invalid.kind,
        anyOf(FailureKind.invalidUrl, FailureKind.validation),
      );

      ok(await deps.links.get(created.id), 'GET /links/{id}');
      final updated = ok(
        await deps.links.update(
          created.id,
          const LinkUpdate(
            note: FieldUpdate('Checked by the app'),
            isFavorite: true,
          ),
        ),
        'PATCH /links/{id}',
      );
      expect(updated.isFavorite, isTrue);
      expect(updated.note, 'Checked by the app');
      final tagged = ok(
        await deps.links.setTags(created.id, ['live', 'app']),
        'PUT /links/{id}/tags',
      );
      expect(tagged.tags.toSet(), {'live', 'app'});
      ok(
        await deps.links.preview('https://example.com/'),
        'POST /links/preview',
      );
      final refresh = await deps.links.refreshMetadata(created.id);
      if (refresh case Err(:final failure)) {
        // Refreshing again within the cooldown is a documented 429.
        expect(failure.kind, FailureKind.rateLimited);
      }

      final page = ok(
        await deps.links.list(const LinkQuery(limit: 1)),
        'GET /links',
      );
      expect(page.items, hasLength(1));
      final search = ok(
        await deps.links.list(
          const LinkQuery(text: 'live check', favoritesOnly: true),
        ),
        'GET /links?q',
      );
      expect(search.items.map((l) => l.id), contains(created.id));
      ok(await deps.search.filterOptions(), 'GET /search/filters');
      ok(await deps.tags.list(), 'GET /tags');

      // ---- collections
      final collection = ok(
        await deps.collections.create(
          name: 'Live check $stamp',
          description: 'Temporary',
        ),
        'POST /collections',
      );
      final nameTaken = err(
        await deps.collections.create(name: 'live check $stamp'),
        'duplicate collection name',
      );
      expect(nameTaken.fieldError('name'), isNotNull);
      ok(
        await deps.collections.updateMembership(
          collection.id,
          attach: [created.id],
        ),
        'PATCH /collections/{id}/links',
      );
      expect(
        ok(
          await deps.collections.get(collection.id),
          'GET /collections/{id}',
        ).linksCount,
        1,
      );
      final inCollection = ok(
        await deps.links.list(LinkQuery(collectionIds: {collection.id})),
        'GET /links?collection_id',
      );
      expect(inCollection.items.single.id, created.id);
      ok(
        await deps.links.setCollections(created.id, const []),
        'PUT /links/{id}/collections',
      );
      ok(
        await deps.collections.update(
          collection.id,
          name: 'Live renamed $stamp',
        ),
        'PATCH /collections/{id}',
      );
      ok(await deps.collections.list(), 'GET /collections');
      ok(
        await deps.collections.delete(collection.id),
        'DELETE /collections/{id}',
      );

      // ---- home, profile, export
      final home = ok(await deps.home.load(), 'GET /home');
      expect(home.linksCount, 1);
      final stats = ok(await deps.profile.stats(), 'GET /me/stats');
      expect(stats.linksCount, 1);
      final export = ok(await deps.profile.exportData(), 'GET /me/export');
      expect(
        (jsonDecode(utf8.decode(export.bytes)) as Map).keys,
        containsAll(['user', 'links', 'collections']),
      );

      // ---- password, delete, logout, account deletion
      final wrongCurrent = err(
        await deps.auth.changePassword(
          currentPassword: 'not-the-password',
          newPassword: 'live-check-pass-2',
        ),
        'change password with a wrong current password',
      );
      expect(wrongCurrent.fieldError('current_password'), isNotNull);
      ok(await deps.links.delete(created.id), 'DELETE /links/{id}');
      expect(
        err(await deps.links.get(created.id), 'GET deleted link').kind,
        FailureKind.notFound,
      );
      ok(await deps.auth.forgotPassword(email), 'POST /auth/forgot-password');
      ok(await deps.auth.logout(), 'POST /auth/logout');
      ok(
        await deps.auth.login(email: email, password: password),
        'login again',
      );
      final wrongDelete = err(
        await deps.auth.deleteAccount(password: 'not-the-password'),
        'delete account with a wrong password',
      );
      expect(wrongDelete.fieldError('password'), isNotNull);
      ok(await deps.auth.deleteAccount(password: password), 'DELETE /me');
      accountCreated = false;
      expect(
        err(
          await deps.auth.login(email: email, password: password),
          'login after deletion',
        ).kind,
        FailureKind.invalidCredentials,
      );
    },
    skip: _baseUrl == null ? 'set STASHLY_LIVE_API to run' : false,
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
