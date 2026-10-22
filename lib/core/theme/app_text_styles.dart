import 'package:flutter/material.dart';

import 'package:stashly/core/theme/app_colors.dart';

/// Text styles from the Stashly Figma type scale (Plus Jakarta Sans), built
/// for one colour palette so each theme gets matching text colours.
///
/// Heights are expressed as Figma line-height / font-size so text keeps the
/// design rhythm; colours default to the most common usage of each style.
/// Widgets read the active set with `context.text`.
@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  AppTextStyles._(AppColors c)
    : eyebrow = _base(c).copyWith(
        fontSize: 13,
        height: 1.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: c.gold,
      ),
      heading = _base(
        c,
      ).copyWith(fontSize: 30, height: 1.2, letterSpacing: -1.17),
      headingCompact = _base(
        c,
      ).copyWith(fontSize: 23, height: 1.2, letterSpacing: -0.88),
      sectionTitle = _base(
        c,
      ).copyWith(fontSize: 21, height: 1.5, letterSpacing: -0.6),
      sheetTitle = _base(
        c,
      ).copyWith(fontSize: 24, height: 1.5, letterSpacing: -0.69),
      detailTitle = _base(
        c,
      ).copyWith(fontSize: 26, height: 1.3, letterSpacing: -1),
      subtitle = _base(
        c,
      ).copyWith(fontSize: 15, height: 1.55, color: c.textSecondary),
      body = _base(
        c,
      ).copyWith(fontSize: 14, height: 1.55, color: c.textSecondary),
      bodySmall = _base(
        c,
      ).copyWith(fontSize: 13.5, height: 1.7, color: c.textSecondary),
      caption = _base(
        c,
      ).copyWith(fontSize: 13, height: 1.55, color: c.textSecondary),
      micro = _base(c).copyWith(fontSize: 12, height: 1.5, color: c.textMuted),
      tiny = _base(c).copyWith(fontSize: 11.5, height: 1.5, color: c.textMuted),
      fieldLabel = _base(c).copyWith(
        fontSize: 13.5,
        height: 1.5,
        fontWeight: FontWeight.w600,
        color: c.textSecondary,
      ),
      input = _base(c).copyWith(fontSize: 15, height: 1.5),
      button = _base(c).copyWith(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w700,
        color: c.onGold,
      ),
      buttonSecondary = _base(
        c,
      ).copyWith(fontSize: 16, height: 1.5, color: c.textSecondary),
      linkButton = _base(c).copyWith(
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w700,
        color: c.gold,
      ),
      chip = _base(c).copyWith(
        fontSize: 13.5,
        height: 1.5,
        fontWeight: FontWeight.w600,
        color: c.textSecondary,
      ),
      cardTitle = _base(c).copyWith(
        fontSize: 16,
        height: 1.45,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      cardDomain = _base(c).copyWith(
        fontSize: 13,
        height: 1.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: c.textMuted,
      ),
      cardMeta = _base(
        c,
      ).copyWith(fontSize: 13, height: 1.5, color: c.textMuted),
      rowTitle = _base(
        c,
      ).copyWith(fontSize: 13, height: 1.5, fontWeight: FontWeight.w700),
      navLabel = _base(
        c,
      ).copyWith(fontSize: 12, height: 1.5, color: c.textMuted);

  factory AppTextStyles.of(AppColors colors) => colors.isDark ? _dark : _light;

  static final _dark = AppTextStyles._(AppColors.dark);
  static final _light = AppTextStyles._(AppColors.light);

  static const String fontFamily = 'Plus Jakarta Sans';

  static TextStyle _base(AppColors c) => TextStyle(
    fontFamily: fontFamily,
    color: c.textPrimary,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Gold all-caps label above titles ("YOUR SPACE").
  final TextStyle eyebrow;

  /// Screen title (29.36 px in the design).
  final TextStyle heading;

  final TextStyle headingCompact;

  final TextStyle sectionTitle;

  final TextStyle sheetTitle;

  final TextStyle detailTitle;

  final TextStyle subtitle;

  final TextStyle body;

  final TextStyle bodySmall;

  final TextStyle caption;

  final TextStyle micro;

  final TextStyle tiny;

  final TextStyle fieldLabel;

  final TextStyle input;

  final TextStyle button;

  final TextStyle buttonSecondary;

  final TextStyle linkButton;

  final TextStyle chip;

  final TextStyle cardTitle;

  final TextStyle cardDomain;

  final TextStyle cardMeta;

  final TextStyle rowTitle;

  final TextStyle navLabel;

  @override
  AppTextStyles copyWith() => this;

  @override
  AppTextStyles lerp(AppTextStyles? other, double t) =>
      other == null || t < 0.5 ? this : other;
}

extension AppTextStylesContext on BuildContext {
  /// The active theme's text styles.
  AppTextStyles get text => Theme.of(this).extension<AppTextStyles>()!;
}
