import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stashly/core/l10n/l10n.dart';

import '../support/app_harness.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final ar = lookupAppLocalizations(const Locale('ar'));

  BuildContext pageContext(WidgetTester tester) =>
      tester.element(find.byType(Scaffold).first);

  Future<AppHarness> openSettings(WidgetTester tester) async {
    final app = AppHarness();
    await app.storeSession(app.seedAccount());
    await app.pumpApp(tester, language: 'en');
    await tapTab(tester, en.navProfile);
    await tapText(tester, en.settings);
    return app;
  }

  testWidgets('dark is the default; Light and Match device are saved', (
    tester,
  ) async {
    final app = await openSettings(tester);
    expect(Theme.of(pageContext(tester)).brightness, Brightness.dark);

    await tapText(tester, en.themeLight);
    expect(Theme.of(pageContext(tester)).brightness, Brightness.light);
    expect(await app.prefs.read('theme_mode'), 'light');

    // The test device reports light, so "Match device" stays light.
    await tapText(tester, en.themeSystem);
    expect(await app.prefs.read('theme_mode'), 'system');
    expect(Theme.of(pageContext(tester)).brightness, Brightness.light);

    await tapText(tester, en.themeDark);
    expect(Theme.of(pageContext(tester)).brightness, Brightness.dark);
  });

  testWidgets('choosing Arabic switches the whole app to right-to-left', (
    tester,
  ) async {
    final app = await openSettings(tester);
    expect(Directionality.of(pageContext(tester)), TextDirection.ltr);

    await tapText(tester, en.languageArabic);
    expect(await app.prefs.read('language'), 'ar');
    expect(Directionality.of(pageContext(tester)), TextDirection.rtl);
    expect(find.text(ar.appearanceGroup), findsOneWidget);

    await tapText(tester, ar.languageEnglish);
    expect(Directionality.of(pageContext(tester)), TextDirection.ltr);
    expect(find.text(en.appearanceGroup), findsOneWidget);
  });

  testWidgets('the saved language is used on the next launch', (tester) async {
    final app = AppHarness();
    await app.storeSession(app.seedAccount());
    await app.pumpApp(tester, language: 'ar', themeMode: 'light');
    expect(Directionality.of(pageContext(tester)), TextDirection.rtl);
    expect(Theme.of(pageContext(tester)).brightness, Brightness.light);
    expect(find.text(ar.recentlySaved), findsOneWidget);
    // Back arrows point the other way in RTL.
    await tapText(tester, ar.viewAll);
    expect(find.bySemanticsLabel(ar.actionBack), findsOneWidget);
  });

  testWidgets('Arabic errors and counts use Arabic grammar', (tester) async {
    final app = AppHarness();
    await app.storeSession(app.seedAccount());
    await app.pumpApp(tester, language: 'ar');
    await tapText(tester, ar.saveLink);
    await enterField(
      tester,
      'https://example.com/article',
      'ftp://example.com',
    );
    await tapText(tester, ar.saveToStashly);
    expect(find.text(ar.urlScheme), findsOneWidget);
    expect(ar.itemCount(2), 'عنصران');
    expect(ar.itemCount(5), '5 عناصر');
    expect(ar.itemCount(11), '11 عنصرًا');
  });
}
