import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:stashly/core/widgets/chips.dart';

import '../../tool/fake_backend/fake_backend.dart';
import '../support/app_harness.dart';

void main() {
  testWidgets('first launch: onboarding → welcome → register with validation', (
    tester,
  ) async {
    final app = AppHarness();
    await app.pumpApp(tester, onboardingSeen: false);

    expect(find.text('Save what matters'), findsOneWidget);
    await tapText(tester, 'Next');
    expect(find.text('Organize your world'), findsOneWidget);
    await tapText(tester, 'Next');
    expect(find.text('Find it when you need it'), findsOneWidget);
    await tapText(tester, 'Get Started');

    expect(find.text('Save anything worth keeping.'), findsOneWidget);
    await tapText(tester, 'Create Account');
    expect(find.text('Create your account'), findsOneWidget);

    // Empty submit shows every client-side error.
    await tapText(tester, 'Create Account');
    expect(find.text('Tell us what to call you.'), findsOneWidget);
    expect(find.text('Enter your email.'), findsOneWidget);
    expect(find.text('Use at least 8 characters.'), findsOneWidget);
    expect(find.text('Please accept the Terms to continue.'), findsOneWidget);

    await enterField(tester, 'How should we address you?', 'Lina Haddad');
    await enterField(tester, 'you@example.com', 'lina@stashly.test');
    await enterField(tester, 'At least 8 characters', 'lina-pass-123');
    await enterField(tester, 'Enter it once more', 'lina-pass-999');
    await tapText(tester, 'Create Account');
    expect(find.text('Passwords don’t match.'), findsOneWidget);

    await enterField(tester, 'Enter it once more', 'lina-pass-123');
    await tester.tap(find.byType(CheckSquare));
    await tapText(tester, 'Create Account');

    expect(
      find.textContaining(', Lina'),
      findsOneWidget,
      reason: 'greeting on Home',
    );
    expect(find.text('Nothing saved yet'), findsOneWidget);

    final register = app.backend.log.firstWhere(
      (r) => r.path == '/auth/register',
    );
    final body = jsonDecode(register.body) as Map<String, dynamic>;
    expect(body['terms_accepted'], isTrue);
    expect(body['terms_version'], '2026-10-01', reason: 'from GET /config');
    expect(app.tokens.token, isNotNull, reason: 'token stored securely');
  });

  testWidgets('register: server validation is shown next to the field', (
    tester,
  ) async {
    final app = AppHarness();
    app.seedAccount();
    await app.pumpApp(tester);
    await tapText(tester, 'Create Account');
    await enterField(tester, 'How should we address you?', 'Someone');
    await enterField(tester, 'you@example.com', demoEmail);
    await enterField(tester, 'At least 8 characters', 'some-pass-123');
    await enterField(tester, 'Enter it once more', 'some-pass-123');
    await tester.tap(find.byType(CheckSquare));
    await tapText(tester, 'Create Account');
    expect(find.text('The email has already been taken.'), findsOneWidget);
  });

  testWidgets('sign in: wrong password, then success', (tester) async {
    final app = AppHarness();
    app.seedAccount();
    await app.pumpApp(tester);

    await tapText(tester, 'Sign In');
    expect(find.text('Welcome back'), findsOneWidget);
    await enterField(tester, 'you@example.com', demoEmail);
    await enterField(tester, 'Enter your password', 'wrong-password');
    await tapText(tester, 'Sign In');
    expect(find.text('The email or password is incorrect.'), findsOneWidget);

    await enterField(tester, 'Enter your password', demoPassword);
    await tapText(tester, 'Sign In');
    expect(find.textContaining(', Maya'), findsOneWidget);
  });

  testWidgets('forgot password always confirms without revealing accounts', (
    tester,
  ) async {
    final app = AppHarness();
    await app.pumpApp(tester);
    await tapText(tester, 'Sign In');
    await tapText(tester, 'Forgot password?');
    await enterField(tester, 'you@example.com', 'nobody@stashly.test');
    await tapText(tester, 'Continue');
    expect(find.text('Next, check your inbox'), findsOneWidget);
    expect(find.textContaining('nobody@stashly.test'), findsOneWidget);
    await tapText(tester, 'Return to Sign In');
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('a revoked token signs the user out with an explanation', (
    tester,
  ) async {
    final app = AppHarness();
    final token = app.seedAccount();
    await app.storeSession(token);
    await app.pumpApp(tester);
    expect(find.textContaining(', Maya'), findsOneWidget);

    // Revoke every token server-side (e.g. password reset on another device).
    app.backend.handle(
      FakeRequest(
        method: 'POST',
        path: '/auth/logout',
        headers: {'authorization': 'Bearer $token'},
        body: jsonEncode({'all_devices': true}),
      ),
    );
    await tapLabel(tester, 'Profile');
    expect(
      find.text('Your session ended. Please sign in again.'),
      findsOneWidget,
    );
    expect(app.tokens.token, isNull);
  });
}
