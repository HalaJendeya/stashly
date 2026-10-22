import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';

/// Screens and text scales the layout must survive without overflowing.
/// Any RenderFlex overflow is reported as a test failure.
const _devices = <String, (Size, double)>{
  'small phone (320x568)': (Size(320, 568), 1),
  'standard phone, large text (390x844 @1.3)': (Size(390, 844), 1.3),
  'large phone, largest text (430x932 @2.0)': (Size(430, 932), 2),
  'tablet portrait (800x1280)': (Size(800, 1280), 1),
  'phone landscape (844x390)': (Size(844, 390), 1),
};

/// Lets a confirmation snackbar time out so it no longer covers the bottom
/// of the screen.
Future<void> waitForSnackbar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 4));
  await settle(tester);
}

void main() {
  for (final MapEntry(key: name, value: (size, scale)) in _devices.entries) {
    group(name, () {
      testWidgets('signed-out screens', (tester) async {
        final app = AppHarness();
        await app.pumpApp(
          tester,
          onboardingSeen: false,
          size: size,
          textScale: scale,
        );
        await tapText(tester, 'Next');
        await tapText(tester, 'Next');
        await tapText(tester, 'Get Started');
        expect(find.text('Save anything worth keeping.'), findsOneWidget);
        await tapText(tester, 'Create Account');
        await tapText(tester, 'Create Account'); // shows every error
        await tapLabel(tester, 'Back');
        await tapText(tester, 'Sign In');
        await tapText(tester, 'Forgot password?');
        await enterField(tester, 'you@example.com', 'a@stashly.test');
        await tapText(tester, 'Continue');
        expect(find.text('Next, check your inbox'), findsOneWidget);
      });

      testWidgets('signed-in screens', (tester) async {
        final app = AppHarness();
        final token = app.seedAccount();
        final travel = app.backend.seedCollection(
          token,
          'Travel ideas with a rather long collection name',
          description: 'Places, maps and itineraries worth keeping',
        );
        app.backend
          ..seedLink(
            token,
            'https://www.youtube.com/watch?v=dolomites',
            title:
                'A cinematic guide to the Italian Dolomites, with a title '
                'long enough to wrap',
            note: 'Revisit when planning the autumn trip.',
            favorite: true,
            collectionIds: [travel],
            tags: ['travel', 'italy', 'film'],
          )
          ..seedLink(token, 'https://example.com/plain', title: 'Plain');
        await app.storeSession(token);
        await app.pumpApp(tester, size: size, textScale: scale);

        expect(find.textContaining(', Maya'), findsOneWidget);
        await tapText(tester, 'Save Link');
        await tapText(tester, 'Cancel');
        await tapText(tester, 'View all');
        await tapLabel(tester, 'Grid layout');
        await tapLabel(tester, 'Back');

        await tapText(tester, 'Plain');
        expect(find.text('Saved item'), findsOneWidget);
        await tapText(tester, 'Edit');
        await tapLabel(tester, 'Back');
        await tapLabel(tester, 'Back');

        await tapTab(tester, 'Collections');
        await tapText(
          tester,
          'Travel ideas with a rather long collection name',
        );
        await tapLabel(tester, 'Back');

        await tapTab(tester, 'Search');
        await enterField(
          tester,
          'Title, note, description, or source…',
          'dolomites',
        );
        await tester.pump(const Duration(milliseconds: 500));
        await settle(tester);
        await tapLabel(tester, 'Filters');
        await tapText(tester, 'Apply filters');

        await tapTab(tester, 'Profile');
        await tapText(tester, 'Settings');
        await tapText(tester, 'About Stashly');
        await tapText(tester, 'Close');
      });

      testWidgets('sheets, dialogs and secondary screens', (tester) async {
        final app = AppHarness();
        final token = app.seedAccount();
        final reading = app.backend.seedCollection(token, 'Reading');
        app.backend.seedLink(
          token,
          'https://example.com/long',
          title: 'An item with a long enough title to need wrapping',
          tags: ['one', 'two'],
          collectionIds: [reading],
        );
        await app.storeSession(token);
        await app.pumpApp(tester, size: size, textScale: scale);

        await tapText(
          tester,
          'An item with a long enough title to need wrapping',
        );
        await tapText(tester, 'Edit tags');
        await tapText(tester, 'Save tags');
        await tapText(tester, 'Organize into Collections');
        await tapText(tester, 'Save changes');
        await waitForSnackbar(tester);
        await tapText(tester, 'Delete saved item');
        expect(find.text('Delete this saved item?'), findsOneWidget);
        await tapText(tester, 'Keep item');
        await tapLabel(tester, 'Back');

        await tapTab(tester, 'Collections');
        await tapText(tester, 'Reading');
        await tapText(tester, 'Add existing');
        await tapText(tester, 'Save membership');
        await waitForSnackbar(tester);
        await tapLabel(tester, 'Edit collection');
        await tapText(tester, 'Cancel');
        await tapLabel(tester, 'Back');

        await tapTab(tester, 'Profile');
        await tapText(tester, 'Edit profile');
        await tapLabel(tester, 'Back');
        await tapText(tester, 'Settings');
        await tapText(tester, 'Change password');
        await tapText(tester, 'Update password'); // shows errors
        await systemBack(tester);
        await tapText(tester, 'Delete account');
        await tapText(tester, 'Keep account');
        await systemBack(tester);

        app.shares.share('https://example.com/long');
        await settle(tester);
        // The share's preview spots the duplicate straight away.
        expect(find.text('You’ve saved this link before'), findsOneWidget);
      });
    });
  }
}
