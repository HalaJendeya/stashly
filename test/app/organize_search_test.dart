import 'package:flutter_test/flutter_test.dart';

import '../../tool/fake_backend/fake_backend.dart';
import '../support/app_harness.dart';

void main() {
  late AppHarness app;
  late String token;

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

  group('collections', () {
    testWidgets('create: validation, duplicate name, success', (tester) async {
      await signedIn(
        tester,
        (backend) => backend.seedCollection(token, 'Travel'),
      );
      await tapLabel(tester, 'Collections');
      await tapText(tester, 'Create');
      expect(find.text('NEW COLLECTION'), findsOneWidget);

      await tapText(
        tester,
        'Create',
        index: find.text('Create').evaluate().length - 1,
      );
      expect(find.text('Give your collection a name.'), findsOneWidget);

      await enterField(tester, 'e.g. Weekend projects', 'travel');
      await tapText(
        tester,
        'Create',
        index: find.text('Create').evaluate().length - 1,
      );
      expect(
        find.textContaining('already'),
        findsOneWidget,
        reason: '422 name taken (case-insensitive)',
      );

      await enterField(tester, 'e.g. Weekend projects', 'Weekend projects');
      await enterField(tester, 'What belongs here?', 'Things to build');
      await tapText(
        tester,
        'Create',
        index: find.text('Create').evaluate().length - 1,
      );
      expect(find.text('Weekend projects'), findsOneWidget);
    });

    testWidgets('detail: add existing items, search within, delete', (
      tester,
    ) async {
      await signedIn(tester, (backend) {
        backend
          ..seedCollection(token, 'Reading')
          ..seedLink(token, 'https://example.com/one', title: 'Essay one')
          ..seedLink(token, 'https://example.com/two', title: 'Essay two');
      });
      await tapLabel(tester, 'Collections');
      await tapText(tester, 'Reading');
      expect(find.text('This collection is empty'), findsOneWidget);

      await tapText(tester, 'Add existing');
      expect(find.text('Add existing items'), findsOneWidget);
      await tapText(tester, 'Essay one');
      await tapText(tester, 'Essay two');
      await tapText(tester, 'Save membership');
      expect(find.text('Collection updated'), findsOneWidget);
      expect(find.text('Essay one'), findsOneWidget);
      expect(find.text('Essay two'), findsOneWidget);

      await enterField(tester, 'Search within this collection', 'two');
      await tester.pump(const Duration(milliseconds: 500));
      await settle(tester);
      expect(find.text('Essay one'), findsNothing);
      expect(find.text('Essay two'), findsOneWidget);

      await enterField(
        tester,
        'Search within this collection',
        'nothing-like-this',
      );
      await tester.pump(const Duration(milliseconds: 500));
      await settle(tester);
      expect(find.text('No matches in this collection'), findsOneWidget);

      await tapText(tester, 'Delete');
      expect(find.text('Delete this collection?'), findsOneWidget);
      await tapText(
        tester,
        'Delete',
        index: find.text('Delete').evaluate().length - 1,
      );
      expect(find.text('Collection deleted'), findsOneWidget);
      expect(find.text('Reading'), findsNothing);
      // Deleting a collection keeps its items.
      final remaining = app.backend.handle(
        FakeRequest(
          method: 'GET',
          path: '/links',
          headers: {'authorization': 'Bearer $token'},
        ),
      );
      expect(remaining.body, contains('Essay one'));
    });
  });

  group('search', () {
    testWidgets('query, favorites chip, no matches, recent searches', (
      tester,
    ) async {
      await signedIn(tester, (backend) {
        backend
          ..seedLink(
            token,
            'https://example.com/pasta',
            title: 'Weeknight pasta',
            favorite: true,
            tags: ['food'],
          )
          ..seedLink(
            token,
            'https://example.com/pasta-salad',
            title: 'Pasta salad',
          )
          ..seedLink(
            token,
            'https://example.com/hiking',
            title: 'Hiking in Wadi Rum',
          );
      });
      await tapLabel(tester, 'Search');
      expect(find.text('Search your stash'), findsOneWidget);
      expect(
        find.text('#food'),
        findsOneWidget,
        reason: 'suggested from top tags',
      );

      await enterField(tester, 'Title, note, description, or source…', 'pasta');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await settle(tester);
      expect(find.text('Weeknight pasta'), findsOneWidget);
      expect(find.text('Pasta salad'), findsOneWidget);
      expect(find.text('Hiking in Wadi Rum'), findsNothing);

      await tapText(tester, 'Favorites');
      expect(find.text('Weeknight pasta'), findsOneWidget);
      expect(find.text('Pasta salad'), findsNothing);
      final request = app.backend.log.lastWhere(
        (r) => r.path == '/links' && r.query.containsKey('q'),
      );
      expect(request.query, containsPair('q', 'pasta'));
      expect(request.query, containsPair('favorite', 'true'));

      await enterField(tester, 'Title, note, description, or source…', 'zzzz');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await settle(tester);
      expect(find.text('No matches found'), findsOneWidget);

      // Recent searches show only once the query and every filter are cleared.
      await tapText(tester, 'Favorites');
      await tapLabel(tester, 'Clear search');
      expect(find.text('Recent searches'), findsOneWidget);
      expect(find.text('pasta'), findsWidgets);
    });

    testWidgets('filters sheet: type, tag, reset', (tester) async {
      await signedIn(tester, (backend) {
        backend
          ..seedLink(
            token,
            'https://www.youtube.com/watch?v=abc',
            title: 'A video',
            tags: ['film'],
          )
          ..seedLink(token, 'https://example.com/article', title: 'An article');
      });
      await tapLabel(tester, 'Search');
      await tapLabel(tester, 'Filters');
      expect(find.text('Search filters'), findsOneWidget);
      await tapText(tester, 'Reset All');
      await tapText(tester, 'Apply filters');
      expect(find.text('Search filters'), findsNothing);
    });
  });
}
