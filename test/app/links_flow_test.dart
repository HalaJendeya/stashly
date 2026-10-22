import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tool/fake_backend/fake_backend.dart';
import '../support/app_harness.dart';

void main() {
  late AppHarness app;
  late String token;

  /// Signs in as the demo user; [seed] runs before the app first loads.
  Future<void> signedIn(
    WidgetTester tester, [
    void Function(FakeStashlyBackend backend)? seed,
  ]) async {
    app = AppHarness();
    token = app.seedAccount();
    seed?.call(app.backend);
    await app.storeSession(token);
    await app.pumpApp(tester);
  }

  Future<void> openLibrary(WidgetTester tester) => tapText(tester, 'View all');

  testWidgets('save sheet: client validation, then save with idempotency key', (
    tester,
  ) async {
    await signedIn(tester);
    await tapText(tester, 'Save Link');
    expect(find.text('Save a link'), findsOneWidget);

    await enterField(
      tester,
      'https://example.com/article',
      'javascript:alert(1)',
    );
    await tapText(tester, 'Save to Stashly');
    expect(
      find.text('Only http and https links can be saved.'),
      findsOneWidget,
    );
    expect(
      app.backend.log.where((r) => r.path == '/links' && r.method == 'POST'),
      isEmpty,
    );

    await enterField(
      tester,
      'https://example.com/article',
      'example.com/read-later',
    );
    await enterField(tester, 'Add a memorable title', 'Read later');
    await tapText(tester, 'Save to Stashly');

    final create = app.backend.log.lastWhere(
      (r) => r.path == '/links' && r.method == 'POST',
    );
    expect(create.headers['idempotency-key'], isNotEmpty);
    final body = jsonDecode(create.body) as Map<String, dynamic>;
    expect(
      body['url'],
      'https://example.com/read-later',
      reason: 'scheme added on the client',
    );
    expect(
      find.text('Saved item'),
      findsOneWidget,
      reason: 'opens the new item',
    );
    expect(find.text('Read later'), findsWidgets);
  });

  testWidgets('saving a duplicate opens the existing item instead', (
    tester,
  ) async {
    await signedIn(tester);
    app.backend.seedLink(
      token,
      'https://example.com/guide',
      title: 'The original guide',
    );
    await tapText(tester, 'Save Link');
    await enterField(
      tester,
      'https://example.com/article',
      'https://EXAMPLE.com/guide?utm_source=x',
    );
    await tapText(tester, 'Save to Stashly');

    expect(find.text('You’ve saved this link before'), findsOneWidget);
    expect(find.text('The original guide'), findsOneWidget);
    await tapText(tester, 'Open saved item');
    expect(find.text('Saved item'), findsOneWidget);
  });

  testWidgets('details: pending metadata resolves, favorite, tags, delete', (
    tester,
  ) async {
    await signedIn(
      tester,
      (backend) => backend.seedLink(
        token,
        'https://example.com/slow-page',
        title: 'Slow page',
        metadataReady: false,
      ),
    );
    await openLibrary(tester);
    await tapText(tester, 'Slow page');
    expect(find.text('Saved item'), findsOneWidget);

    // The view model polls GET /links/{id} until metadata is no longer pending.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(seconds: 3));
    }
    await settle(tester);
    expect(find.text('Fetching details…'), findsNothing);

    await tapText(tester, 'Add to Favorites');
    expect(find.text('Remove from Favorites'), findsOneWidget);
    final patch = app.backend.log.lastWhere((r) => r.method == 'PATCH');
    expect(jsonDecode(patch.body), {'is_favorite': true});

    await tapText(tester, 'Add tags');
    expect(find.text('ITEM TAGS'), findsOneWidget);
    await enterField(tester, 'Find or create a tag', 'Reading List');
    await tapText(tester, 'Add');
    await tapText(tester, 'Save tags');
    expect(
      find.text('#reading list'),
      findsOneWidget,
      reason: 'server-normalized tag',
    );

    await tapText(tester, 'Delete saved item');
    expect(find.text('Delete this saved item?'), findsOneWidget);
    await tapText(
      tester,
      'Delete',
      index: find.text('Delete').evaluate().length - 1,
    );
    expect(find.text('Item deleted'), findsOneWidget);
    expect(
      app.backend.log.last.method,
      'GET',
      reason: 'list refreshed after delete',
    );
    expect(find.text('Slow page'), findsNothing);
  });

  testWidgets('organize: add the item to a collection', (tester) async {
    await signedIn(tester, (backend) {
      backend
        ..seedCollection(token, 'Reading')
        ..seedLink(token, 'https://example.com/a', title: 'Item A');
    });
    await openLibrary(tester);
    await tapText(tester, 'Item A');
    await tapText(tester, 'Organize into Collections');
    expect(find.text('Add to collections'), findsOneWidget);
    await tapText(tester, 'Reading');
    await tapText(tester, 'Save changes');
    expect(find.text('Collections updated'), findsOneWidget);
    final put = app.backend.log.lastWhere((r) => r.method == 'PUT');
    expect(put.path, endsWith('/collections'));
  });

  testWidgets('edit: title, note and server validation', (tester) async {
    await signedIn(
      tester,
      (backend) =>
          backend.seedLink(token, 'https://example.com/b', title: 'Item B'),
    );
    await openLibrary(tester);
    await tapText(tester, 'Item B');
    await tapText(tester, 'Edit');
    expect(find.text('Edit details'), findsOneWidget);

    final title = find.ancestor(
      of: find.text('Item B'),
      matching: find.byType(TextField),
    );
    await tester.enterText(title.first, 'Item B, renamed');
    await enterField(tester, 'Why is this worth keeping?', 'For the weekend.');
    await tapText(tester, 'Save changes');
    expect(find.text('Changes saved'), findsOneWidget);
    expect(find.text('Item B, renamed'), findsWidgets);
    expect(find.text('For the weekend.'), findsOneWidget);
  });

  testWidgets('library: favorites filter and empty filtered state', (
    tester,
  ) async {
    await signedIn(tester, (backend) {
      backend
        ..seedLink(
          token,
          'https://example.com/fav',
          title: 'Loved',
          favorite: true,
        )
        ..seedLink(token, 'https://example.com/plain', title: 'Plain');
    });
    await openLibrary(tester);
    expect(find.text('Loved'), findsOneWidget);
    expect(find.text('Plain'), findsOneWidget);

    await tapText(tester, 'Favorites');
    expect(find.text('Loved'), findsOneWidget);
    expect(find.text('Plain'), findsNothing);
    final list = app.backend.log.lastWhere(
      (r) => r.path == '/links' && r.method == 'GET',
    );
    expect(list.query['favorite'], anyOf('1', 'true'));
  });

  testWidgets('a server outage shows a retryable error', (tester) async {
    app = AppHarness();
    token = app.seedAccount();
    await app.storeSession(token);
    app.backend.forcedStatus = 503;
    await app.pumpApp(tester);
    expect(find.text('Try again'), findsWidgets);

    app.backend.forcedStatus = null;
    await tapText(tester, 'Try again');
    expect(find.textContaining(', Maya'), findsOneWidget);
  });

  testWidgets('another user’s item is reported as missing', (tester) async {
    await signedIn(tester);
    final other = app.backend.seedUser(
      name: 'Other',
      email: 'other@stashly.test',
      password: 'x-pass-123',
    );
    final foreign = app.backend.seedLink(
      other,
      'https://example.com/private',
      title: 'Private',
    );
    final response = app.backend.handle(
      FakeRequest(
        method: 'GET',
        path: '/links/$foreign',
        headers: {'authorization': 'Bearer $token'},
      ),
    );
    expect(response.status, 404, reason: 'ownership is enforced by the server');
  });
}
