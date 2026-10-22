import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:stashly/core/result/app_failure.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/core/widgets/chips.dart';

import '../../tool/fake_backend/fake_backend.dart';
import '../support/app_harness.dart';

void main() {
  AppHarness googleApp() =>
      AppHarness(backend: FakeStashlyBackend(googleEnabled: true));

  Map<String, dynamic> lastGoogleBody(AppHarness app) =>
      jsonDecode(
            app.backend.log.lastWhere((r) => r.path == '/auth/google').body,
          )
          as Map<String, dynamic>;

  testWidgets('hidden when the server has Google sign-in turned off', (
    tester,
  ) async {
    final app = AppHarness();
    await app.pumpApp(tester);
    expect(find.text('Continue with Google'), findsNothing);
    await tapText(tester, 'Sign In');
    expect(find.text('Continue with Google'), findsNothing);
  });

  testWidgets('a build without a Google client ID still shows the button '
      'and explains why it can’t continue', (tester) async {
    final app = googleApp();
    app.google.next = const Err(AppFailure(FailureKind.googleNotConfigured));
    await app.pumpApp(tester);
    await tapText(tester, 'Continue with Google');
    expect(
      find.text('Google sign-in isn’t set up in this version of the app yet.'),
      findsOneWidget,
    );
    expect(app.backend.log.where((r) => r.path == '/auth/google'), isEmpty);
  });

  testWidgets('existing e-mail account is linked and signed in', (
    tester,
  ) async {
    final app = googleApp();
    app.seedAccount();
    await app.pumpApp(tester);
    app.google.pick(demoEmail, name: 'Maya Kim');

    await tapText(tester, 'Sign In');
    await tapText(tester, 'Continue with Google');
    expect(find.textContaining(', Maya'), findsOneWidget);
    expect(lastGoogleBody(app).containsKey('terms_accepted'), isFalse);
    expect(app.tokens.token, isNotNull);

    // DEC-037: the linked account's password is cleared.
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
    expect(login.status, 401);
  });

  testWidgets('a new Google user accepts the Terms once, without re-picking', (
    tester,
  ) async {
    final app = googleApp();
    await app.pumpApp(tester);
    app.google.pick('lina@gmail.test', name: 'Lina Haddad');

    await tapText(tester, 'Continue with Google');
    expect(find.text('Create your Stashly account'), findsOneWidget);
    await tapText(tester, 'Accept');

    expect(find.textContaining(', Lina'), findsOneWidget);
    expect(app.google.requests, 1, reason: 'the ID token is reused');
    final body = lastGoogleBody(app);
    expect(body['terms_accepted'], isTrue);
    expect(body['terms_version'], '2026-10-01');
  });

  testWidgets('declining the Terms creates nothing', (tester) async {
    final app = googleApp();
    await app.pumpApp(tester);
    app.google.pick('new@gmail.test');

    await tapText(tester, 'Continue with Google');
    await tapText(tester, 'Cancel');
    expect(find.text('Save anything worth keeping.'), findsOneWidget);
    expect(app.tokens.token, isNull);

    // The next attempt asks Google again rather than reusing a stale token.
    await tapText(tester, 'Continue with Google');
    expect(app.google.requests, 2);
  });

  testWidgets('dismissing the picker sends nothing', (tester) async {
    final app = googleApp();
    await app.pumpApp(tester);
    await tapText(tester, 'Continue with Google');
    expect(app.backend.log.where((r) => r.path == '/auth/google'), isEmpty);
    expect(find.text('Save anything worth keeping.'), findsOneWidget);
  });

  testWidgets('device and server failures are explained', (tester) async {
    final app = googleApp();
    await app.pumpApp(tester);

    app.google.fail();
    await tapText(tester, 'Continue with Google');
    expect(
      find.text('Google sign-in isn’t available on this device right now.'),
      findsOneWidget,
    );

    app.google.next = const Ok('expired-or-forged-token');
    await tapText(tester, 'Continue with Google');
    expect(
      find.text('Google sign-in failed. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('register: a new Google user must tick the Terms box', (
    tester,
  ) async {
    final app = googleApp();
    await app.pumpApp(tester);
    app.google.pick('sam@gmail.test', name: 'Sam');

    await tapText(tester, 'Create Account');
    await tapText(tester, 'Continue with Google');
    expect(find.text('Please accept the Terms to continue.'), findsOneWidget);

    await tester.tap(find.byType(CheckSquare));
    await tapText(tester, 'Continue with Google');
    expect(find.textContaining(', Sam'), findsOneWidget);
    expect(app.google.requests, 1, reason: 'token kept for the retry');
  });

  testWidgets('Google-only account: delete confirms with Google, sign-out '
      'forgets the Google account', (tester) async {
    final app = googleApp();
    await app.pumpApp(tester);
    app.google.pick('gia@gmail.test', name: 'Gia');
    await tapText(tester, 'Continue with Google');
    await tapText(tester, 'Accept');

    await tapLabel(tester, 'Profile');
    await tapText(tester, 'Settings');
    expect(
      find.text('Use “Forgot password” to set a password'),
      findsOneWidget,
    );
    await tapText(tester, 'Delete account');
    expect(
      find.text('You’ll confirm with your Google account.'),
      findsOneWidget,
    );
    expect(find.text('Your password'), findsNothing);

    // Another Google account can't confirm.
    app.google.pick('someone-else@gmail.test');
    await tapText(
      tester,
      'Delete',
      index: find.text('Delete').evaluate().length - 1,
    );
    expect(
      find.text('Google sign-in failed. Please try again.'),
      findsOneWidget,
    );
    expect(app.tokens.token, isNotNull, reason: 'not a session expiry');

    app.google.pick('gia@gmail.test');
    await tapText(
      tester,
      'Delete',
      index: find.text('Delete').evaluate().length - 1,
    );
    expect(find.text('Save anything worth keeping.'), findsOneWidget);
    expect(app.tokens.token, isNull);
    expect(app.google.signOuts, greaterThan(0));
    final delete = app.backend.log.lastWhere((r) => r.method == 'DELETE');
    expect(jsonDecode(delete.body), {
      'id_token': FakeStashlyBackend.googleIdToken(email: 'gia@gmail.test'),
    });
  });
}
