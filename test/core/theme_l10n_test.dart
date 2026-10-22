import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stashly/core/theme/app_colors.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  group('palette contrast (WCAG 4.5:1 for text, CLAUDE.md §4)', () {
    for (final (name, c) in [
      ('dark', AppColors.dark),
      ('light', AppColors.light),
    ]) {
      test(name, () {
        final pairs = <String, (Color, Color)>{
          for (final (bgName, bg) in [
            ('background', c.background),
            ('card', c.card),
            ('surface', c.surface),
          ]) ...{
            'textPrimary on $bgName': (c.textPrimary, bg),
            'textSecondary on $bgName': (c.textSecondary, bg),
            'textMuted on $bgName': (c.textMuted, bg),
            'gold on $bgName': (c.gold, bg),
            'danger on $bgName': (c.danger, bg),
          },
          'onGold on goldFill': (c.onGold, c.goldFill),
        };
        for (final MapEntry(key: label, value: (fg, bg)) in pairs.entries) {
          expect(_contrast(fg, bg), greaterThanOrEqualTo(4.5), reason: label);
        }
      });
    }
  });

  test('English and Arabic define exactly the same messages', () {
    Map<String, dynamic> load(String lang) =>
        jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync())
            as Map<String, dynamic>;
    Set<String> keys(Map<String, dynamic> arb) =>
        arb.keys.where((k) => !k.startsWith('@')).toSet();
    final en = load('en'), ar = load('ar');
    expect(keys(ar), keys(en));
    // Spot-check that Arabic is really translated, not copied.
    final translated = keys(en).where((k) => en[k] != ar[k]).length;
    expect(translated / keys(en).length, greaterThan(0.85));
  });
}
