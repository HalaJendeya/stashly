import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stashly/core/l10n/l10n.dart';

import '../support/app_harness.dart';

/// A device, text scale, language and theme the layout must survive without
/// overflowing. Any RenderFlex overflow is reported as a test failure.
typedef _Setup = ({Size size, double scale, String language, String theme});

const _setups = <String, _Setup>{
  'small phone (320x568)': (
    size: Size(320, 568),
    scale: 1,
    language: 'en',
    theme: 'dark',
  ),
  'standard phone, large text (390x844 @1.3)': (
    size: Size(390, 844),
    scale: 1.3,
    language: 'en',
    theme: 'dark',
  ),
  'large phone, largest text (430x932 @2.0)': (
    size: Size(430, 932),
    scale: 2,
    language: 'en',
    theme: 'dark',
  ),
  'tablet portrait (800x1280)': (
    size: Size(800, 1280),
    scale: 1,
    language: 'en',
    theme: 'dark',
  ),
  'phone landscape (844x390)': (
    size: Size(844, 390),
    scale: 1,
    language: 'en',
    theme: 'dark',
  ),
  'Arabic RTL, small phone (320x568)': (
    size: Size(320, 568),
    scale: 1,
    language: 'ar',
    theme: 'dark',
  ),
  'Arabic RTL, largest text (430x932 @2.0)': (
    size: Size(430, 932),
    scale: 2,
    language: 'ar',
    theme: 'light',
  ),
  'light theme, standard phone (390x844)': (
    size: Size(390, 844),
    scale: 1,
    language: 'en',
    theme: 'light',
  ),
};

/// Lets a confirmation snackbar time out so it no longer covers the bottom
/// of the screen.
Future<void> waitForSnackbar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 4));
  await settle(tester);
}

void main() {
  for (final MapEntry(key: name, value: setup) in _setups.entries) {
    final t = lookupAppLocalizations(Locale(setup.language));

    Future<void> pump(
      AppHarness app,
      WidgetTester tester, {
      bool onboarded = true,
    }) => app.pumpApp(
      tester,
      onboardingSeen: onboarded,
      size: setup.size,
      textScale: setup.scale,
      language: setup.language,
      themeMode: setup.theme,
    );

    void expectDirectionAndTheme(WidgetTester tester) {
      final context = tester.element(find.byType(Scaffold).first);
      expect(
        Directionality.of(context),
        setup.language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      );
      expect(
        Theme.of(context).brightness,
        setup.theme == 'light' ? Brightness.light : Brightness.dark,
      );
    }

    group(name, () {
      testWidgets('signed-out screens', (tester) async {
        final app = AppHarness();
        await pump(app, tester, onboarded: false);
        expectDirectionAndTheme(tester);
        await tapText(tester, t.actionNext);
        await tapText(tester, t.actionNext);
        await tapText(tester, t.actionGetStarted);
        expect(find.text(t.welcomeTitle), findsOneWidget);
        await tapText(tester, t.actionCreateAccount);
        await tapText(tester, t.actionCreateAccount); // shows every error
        await tapLabel(tester, t.actionBack);
        await tapText(tester, t.actionSignIn);
        await tapText(tester, t.forgotPassword);
        await enterField(tester, t.emailHint, 'a@stashly.test');
        await tapText(tester, t.actionContinue);
        expect(find.text(t.checkInboxTitle), findsOneWidget);
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
        await pump(app, tester);
        expectDirectionAndTheme(tester);

        expect(find.textContaining('Maya'), findsOneWidget);
        await tapText(tester, t.saveLink);
        await tapText(tester, t.actionCancel);
        await tapText(tester, t.viewAll);
        await tapLabel(tester, t.gridLayout);
        await tapLabel(tester, t.actionBack);

        await tapText(tester, 'Plain');
        expect(find.text(t.savedItemTitle), findsOneWidget);
        await tapText(tester, t.actionEdit);
        await tapLabel(tester, t.actionBack);
        await tapLabel(tester, t.actionBack);

        await tapTab(tester, t.navCollections);
        await tapText(
          tester,
          'Travel ideas with a rather long collection name',
        );
        await tapLabel(tester, t.actionBack);

        await tapTab(tester, t.navSearch);
        await enterField(tester, t.searchHint, 'dolomites');
        await tester.pump(const Duration(milliseconds: 500));
        await settle(tester);
        await tapLabel(tester, t.filters);
        await tapText(tester, t.applyFilters);

        await tapTab(tester, t.navProfile);
        await tapText(tester, t.settings);
        await tapText(tester, t.aboutStashly);
        await tapText(tester, t.actionClose);
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
        await pump(app, tester);

        await tapText(
          tester,
          'An item with a long enough title to need wrapping',
        );
        await tapText(tester, t.editTags);
        await tapText(tester, t.saveTags);
        await tapText(tester, t.organizeIntoCollections);
        await tapText(tester, t.actionSaveChanges);
        await waitForSnackbar(tester);
        await tapText(tester, t.deleteSavedItem);
        expect(find.text(t.deleteItemTitle), findsOneWidget);
        await tapText(tester, t.keepItem);
        await tapLabel(tester, t.actionBack);

        await tapTab(tester, t.navCollections);
        await tapText(tester, 'Reading');
        await tapText(tester, t.addExisting);
        await tapText(tester, t.saveMembership);
        await waitForSnackbar(tester);
        await tapLabel(tester, t.editCollection);
        await tapText(tester, t.actionCancel);
        await tapLabel(tester, t.actionBack);

        await tapTab(tester, t.navProfile);
        await tapText(tester, t.editProfile);
        await tapLabel(tester, t.actionBack);
        await tapText(tester, t.settings);
        await tapText(tester, t.changePassword);
        await tapText(tester, t.updatePassword); // shows errors
        await systemBack(tester);
        await tapText(tester, t.deleteAccount);
        await tapText(tester, t.keepAccount);
        await systemBack(tester);

        app.shares.share('https://example.com/long');
        await settle(tester);
        // The share's preview spots the duplicate straight away.
        expect(find.text(t.alreadyTitle), findsOneWidget);
      });
    });
  }
}
