import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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

  testWidgets('Android is told the app handles back on tabs other than Home', (
    tester,
  ) async {
    // With predictive back (Android 14+, default on 16) Android only sends
    // back to Flutter when the app says it handles it; otherwise it closes
    // the app.
    bool? frameworkHandlesBack;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'SystemNavigator.setFrameworkHandlesBack') {
          frameworkHandlesBack = call.arguments as bool;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    // Flutter only reports to Android once the app is in the foreground.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await signedIn(tester);
    expect(
      frameworkHandlesBack ?? false,
      isFalse,
      reason: 'Home: back leaves the app',
    );

    for (final tab in ['Search', 'Collections', 'Profile']) {
      await tapTab(tester, tab);
      expect(frameworkHandlesBack, isTrue, reason: '$tab: back goes Home');
    }
    await tapTab(tester, 'Home');
    expect(frameworkHandlesBack, isFalse);
  });

  testWidgets('system back on another tab returns to Home', (tester) async {
    await signedIn(tester);
    await tapLabel(tester, 'Search');
    expect(find.text('Search your stash'), findsOneWidget);
    await systemBack(tester);
    expect(find.textContaining(', Maya'), findsOneWidget);
  });

  testWidgets('pages opened from a tab go back to that tab', (tester) async {
    await signedIn(
      tester,
      (backend) => backend.seedLink(token, 'https://example.com/a', title: 'A'),
    );
    await tapText(tester, 'A');
    expect(find.text('Saved item'), findsOneWidget);
    await tapLabel(tester, 'Back');
    expect(find.textContaining(', Maya'), findsOneWidget);

    await tapText(tester, 'A');
    await systemBack(tester);
    expect(find.textContaining(', Maya'), findsOneWidget);
  });

  testWidgets('a share at cold start opens on top of Home', (tester) async {
    app = AppHarness();
    token = app.seedAccount();
    await app.storeSession(token);
    app.shares.initial = 'https://example.com/cold-start';
    await app.pumpApp(tester);
    expect(find.text('Shared to Stashly'), findsOneWidget);

    await tapText(tester, 'Save now');
    expect(find.text('Saved item'), findsOneWidget);
    // Previously the item page was alone in the history here.
    await tapLabel(tester, 'Back');
    expect(find.textContaining(', Maya'), findsOneWidget);
  });

  testWidgets('leaving a share with typed details asks first', (tester) async {
    await signedIn(tester);
    app.shares.share('https://example.com/shared');
    await settle(tester);
    await enterField(tester, 'Why is this worth keeping?', 'For later');

    await systemBack(tester);
    expect(find.text('Discard your changes?'), findsOneWidget);
    await tapText(tester, 'Keep editing');
    expect(find.text('Shared to Stashly'), findsOneWidget);

    await tapLabel(tester, 'Close');
    await tapText(tester, 'Discard');
    expect(find.textContaining(', Maya'), findsOneWidget);
    expect(
      app.backend.log.where((r) => r.path == '/links' && r.method == 'POST'),
      isEmpty,
    );
  });

  testWidgets('edit: back asks before discarding, not when unchanged', (
    tester,
  ) async {
    await signedIn(
      tester,
      (backend) => backend.seedLink(token, 'https://example.com/b', title: 'B'),
    );
    await tapText(tester, 'B');
    await tapText(tester, 'Edit');
    await tapLabel(tester, 'Back');
    expect(find.text('Saved item'), findsOneWidget, reason: 'nothing changed');

    await tapText(tester, 'Edit');
    await enterField(tester, 'Why is this worth keeping?', 'A note');
    await tapLabel(tester, 'Back');
    expect(find.text('Discard your changes?'), findsOneWidget);
    await tapText(tester, 'Keep editing');
    expect(find.text('Edit details'), findsOneWidget);

    await systemBack(tester);
    await tapText(tester, 'Discard');
    expect(find.text('Saved item'), findsOneWidget);
    expect(find.text('A note'), findsNothing);
  });

  testWidgets('password reset returns to Sign In, then back to Welcome', (
    tester,
  ) async {
    app = AppHarness();
    await app.pumpApp(tester);
    await tapText(tester, 'Sign In');
    await tapText(tester, 'Forgot password?');
    await enterField(tester, 'you@example.com', 'someone@stashly.test');
    await tapText(tester, 'Continue');
    await tapText(tester, 'Return to Sign In');
    expect(find.text('Welcome back'), findsOneWidget);
    await systemBack(tester);
    expect(find.text('Save anything worth keeping.'), findsOneWidget);
  });
}
