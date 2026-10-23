import 'dart:convert';

import 'package:flutter/material.dart';
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

  group('profile and account', () {
    testWidgets('profile shows stats from GET /me', (tester) async {
      await signedIn(tester, (backend) {
        final reading = backend.seedCollection(token, 'Reading');
        backend
          ..seedLink(
            token,
            'https://example.com/1',
            favorite: true,
            collectionIds: [reading],
          )
          ..seedLink(token, 'https://example.com/2');
      });
      await tapLabel(tester, 'Profile');
      expect(find.text('Maya Kim'), findsOneWidget);
      expect(find.text(demoEmail), findsOneWidget);
      expect(_semantics('2 Total saves'), findsOneWidget);
      expect(_semantics('1 Collections'), findsOneWidget);
      expect(_semantics('1 Favorites'), findsOneWidget);
    });

    testWidgets('edit display name', (tester) async {
      await signedIn(tester);
      await tapLabel(tester, 'Profile');
      await tapText(tester, 'Edit profile');
      final name = find.ancestor(
        of: find.text('Maya Kim'),
        matching: find.byType(TextField),
      );
      await tester.enterText(name.first, 'Maya K.');
      await tapText(tester, 'Save changes');
      expect(find.text('Profile updated'), findsOneWidget);
      expect(find.text('Maya K.'), findsWidgets);
    });

    testWidgets('change password: wrong current password, then success', (
      tester,
    ) async {
      await signedIn(tester);
      await tapLabel(tester, 'Profile');
      await tapText(tester, 'Settings');
      await tapText(tester, 'Change password');
      await enterField(tester, 'Enter current password', 'not-my-password');
      await enterField(tester, 'At least 8 characters', 'brand-new-pass-1');
      await enterField(tester, 'Enter it again', 'brand-new-pass-1');
      await tapText(tester, 'Update password');
      expect(
        find.textContaining('current password'),
        findsWidgets,
        reason: '422 on current_password',
      );

      await enterField(tester, 'Enter current password', demoPassword);
      await tapText(tester, 'Update password');
      expect(
        find.text('Password updated. Other devices were signed out.'),
        findsOneWidget,
      );
      expect(
        app.tokens.token,
        isNotNull,
        reason: 'the response carries a fresh token',
      );
    });

    testWidgets('sign out of this device revokes the token', (tester) async {
      await signedIn(tester);
      await tapLabel(tester, 'Profile');
      await tapText(tester, 'Sign out');
      expect(find.text('Save anything worth keeping.'), findsOneWidget);
      expect(app.tokens.token, isNull);
      final logout = app.backend.log.lastWhere((r) => r.path == '/auth/logout');
      expect(jsonDecode(logout.body), {'all_devices': false});
    });

    testWidgets('delete account requires the password', (tester) async {
      await signedIn(tester);
      await tapLabel(tester, 'Profile');
      await tapText(tester, 'Settings');
      await tapText(tester, 'Delete account');
      expect(find.text('Delete your account?'), findsOneWidget);

      await enterField(tester, 'Your password', 'wrong-password');
      await tapText(
        tester,
        'Delete',
        index: find.text('Delete').evaluate().length - 1,
      );
      expect(
        find.text('Delete your account?'),
        findsOneWidget,
        reason: 'stays open on 422',
      );

      await enterField(tester, 'Your password', demoPassword);
      await tapText(
        tester,
        'Delete',
        index: find.text('Delete').evaluate().length - 1,
      );
      expect(find.text('Save anything worth keeping.'), findsOneWidget);
      expect(app.tokens.token, isNull);
      final login = app.backend.handle(
        FakeRequest(
          method: 'POST',
          path: '/auth/login',
          body: jsonEncode({
            'email': demoEmail,
            'password': demoPassword,
            'device_name': 'test',
          }),
        ),
      );
      expect(login.status, 401, reason: 'the account is gone');
    });
  });

  group('share intake', () {
    testWidgets('signed in: a shared URL opens the save screen', (
      tester,
    ) async {
      await signedIn(tester);
      app.shares.share(
        'Look at this https://example.com/shared-article via a friend',
      );
      await settle(tester);
      expect(find.text('Shared to Stashly'), findsOneWidget);
      await tapText(tester, 'Save now');
      expect(find.text('Saved item'), findsOneWidget);
      final create = app.backend.log.lastWhere(
        (r) => r.path == '/links' && r.method == 'POST',
      );
      expect(
        jsonDecode(create.body)['url'],
        'https://example.com/shared-article',
      );
    });

    testWidgets('a share without a web link explains why', (tester) async {
      await signedIn(tester);
      app.shares.share('just some text, intent://evil and file:///etc/passwd');
      await settle(tester);
      expect(
        find.text('This share doesn’t contain a web link Stashly can save.'),
        findsOneWidget,
      );
    });

    testWidgets('signed out: the share waits for sign-in', (tester) async {
      app = AppHarness();
      app.seedAccount();
      app.shares.initial = 'https://example.com/cold-start';
      await app.pumpApp(tester);
      expect(find.text('Save anything worth keeping.'), findsOneWidget);

      await tapText(tester, 'Sign In');
      await enterField(tester, 'you@example.com', demoEmail);
      await enterField(tester, 'Enter your password', demoPassword);
      await tapText(tester, 'Sign In');
      expect(find.text('Shared to Stashly'), findsOneWidget);
    });
  });
}

Finder _semantics(String label) => find.byWidgetPredicate(
  (widget) => widget is Semantics && widget.properties.label == label,
);
