import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stashly/app/app.dart';
import 'package:stashly/app/dependencies.dart';
import 'package:stashly/core/storage/key_value_store.dart';
import 'package:stashly/features/auth/data/token_store.dart';
import 'package:stashly/core/result/app_failure.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/features/auth/domain/auth.dart';
import 'package:stashly/features/auth/domain/google_identity.dart';
import 'package:stashly/features/share_intake/domain/shared_link_source.dart';

import '../../tool/fake_backend/fake_backend.dart';
import 'fake_http.dart';

const demoEmail = 'maya@stashly.test';
const demoPassword = 'stashly-test-1';

class FakeShares implements SharedTextSource {
  String? initial;
  final _controller = StreamController<String>.broadcast();

  void share(String text) => _controller.add(text);

  @override
  Future<String?> takeInitialShare() async {
    final value = initial;
    initial = null;
    return value;
  }

  @override
  Stream<String> get shares => _controller.stream;
}

/// Boots the real app against the in-memory fake backend.
class AppHarness {
  AppHarness({FakeStashlyBackend? backend})
    : backend = backend ?? FakeStashlyBackend(readsUntilMetadataReady: 1);

  final FakeStashlyBackend backend;
  final tokens = MemoryTokenStore();
  final prefs = MemoryKeyValueStore();
  final shares = FakeShares();
  final google = FakeGoogle();
  late final AppDependencies deps;

  /// Seeds the demo account and returns its server token.
  String seedAccount() => backend.seedUser(
    name: 'Maya Kim',
    email: demoEmail,
    password: demoPassword,
    createdAt: DateTime.utc(2025, 10, 2),
  );

  /// Signs the device in as [token] (as if the user had logged in before).
  Future<void> storeSession(String token) => tokens.save(
    AuthToken(
      accessToken: token,
      expiresAt: DateTime.now().toUtc().add(const Duration(days: 59)),
    ),
  );

  /// Boots the app on a [size] logical-pixel screen with the system font
  /// size set to [textScale]. [language] (`en`/`ar`) and [themeMode]
  /// (`dark`/`light`/`system`) are stored as the user's choices.
  Future<void> pumpApp(
    WidgetTester tester, {
    bool onboardingSeen = true,
    Size size = const Size(419, 912),
    double textScale = 1,
    String? language,
    String? themeMode,
  }) async {
    tester.view.physicalSize = size * 3;
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    if (onboardingSeen) await prefs.write('onboarding_seen', true);
    if (language != null) await prefs.write('language', language);
    if (themeMode != null) await prefs.write('theme_mode', themeMode);
    deps = AppDependencies.create(
      httpClient: fakeHttpClient(backend),
      tokenStore: tokens,
      preferences: prefs,
      sharedText: shares,
      google: google,
      baseUrl: 'https://api.stashly.test/api/v1',
    );
    await tester.pumpWidget(StashlyApp(deps: deps));
    await settle(tester);
  }
}

/// Pumps frames until the UI is idle. Unlike `pumpAndSettle`, it tolerates
/// endless animations such as progress spinners.
Future<void> settle(WidgetTester tester, {int frames = 20}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 60));
  }
}

/// Scrolls [finder] to the middle of its scroll view, clear of the floating
/// bottom navigation that would otherwise swallow the tap.
Future<void> _reveal(WidgetTester tester, Finder finder) async {
  final element = tester.element(finder);
  if (Scrollable.maybeOf(element) != null) {
    await Scrollable.ensureVisible(element, alignment: 0.5);
  }
  await tester.pump();
}

/// Taps a bottom-navigation tab. Its label is the last matching text, since
/// the bar is built after the page (whose headings may share the name).
Future<void> tapTab(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).last);
  await settle(tester);
}

/// Scrolls the page down until [finder] is built (lazy lists only build
/// what is on screen).
Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isNotEmpty) return;
  final vertical = find.byWidgetPredicate(
    (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
  );
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: vertical.hitTestable().first,
  );
}

Future<void> tapText(WidgetTester tester, String text, {int index = 0}) async {
  await _scrollTo(tester, find.text(text));
  final finder = find.text(text).at(index);
  await _reveal(tester, finder);
  await tester.tap(finder);
  await settle(tester);
}

Future<void> tapLabel(WidgetTester tester, String semanticsLabel) async {
  final finder = find.bySemanticsLabel(semanticsLabel).first;
  await _reveal(tester, finder);
  await tester.tap(finder);
  await settle(tester);
}

Future<void> enterField(WidgetTester tester, String hint, String value) async {
  final field = find.ancestor(
    of: find.text(hint),
    matching: find.byType(TextField),
  );
  await tester.ensureVisible(field.first);
  await tester.enterText(field.first, value);
  await tester.pump();
}

/// Scripted Google account picker.
class FakeGoogle implements GoogleIdentity {
  /// What the next picker shows: an ID token, null (dismissed) or a failure.
  Result<String?> next = const Ok(null);
  int requests = 0;
  int signOuts = 0;

  /// Picks the Google account [email] (a token the fake backend accepts).
  void pick(String email, {String name = 'Google User'}) =>
      next = Ok(FakeStashlyBackend.googleIdToken(email: email, name: name));

  void fail() => next = const Err(AppFailure(FailureKind.googleUnavailable));

  @override
  bool get isConfigured => true;

  @override
  Future<Result<String?>> requestIdToken() async {
    requests++;
    return next;
  }

  @override
  Future<void> signOut() async => signOuts++;
}

/// Sends Android's system back (the gesture or the back key).
Future<void> systemBack(WidgetTester tester) async {
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    'flutter/navigation',
    const JSONMethodCodec().encodeMethodCall(const MethodCall('popRoute')),
    (_) {},
  );
  await settle(tester);
}
