import 'package:flutter/painting.dart';

import 'package:stashly/core/theme/app_colors.dart';

/// Text styles from the Stashly Figma type scale (Plus Jakarta Sans).
///
/// Heights are expressed as Figma line-height / font-size so text keeps the
/// design rhythm; colours default to the most common usage of each style.
abstract final class AppTextStyles {
  static const String fontFamily = 'Plus Jakarta Sans';

  static const TextStyle _base = TextStyle(
    fontFamily: fontFamily,
    color: AppColors.textPrimary,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Gold all-caps label above titles ("YOUR SPACE").
  static final TextStyle eyebrow = _base.copyWith(
    fontSize: 13,
    height: 1.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: AppColors.gold,
  );

  /// Screen title (29.36 px in the design).
  static final TextStyle heading = _base.copyWith(
    fontSize: 30,
    height: 1.2,
    letterSpacing: -1.17,
  );

  static final TextStyle headingCompact = _base.copyWith(
    fontSize: 23,
    height: 1.2,
    letterSpacing: -0.88,
  );

  static final TextStyle sectionTitle = _base.copyWith(
    fontSize: 21,
    height: 1.5,
    letterSpacing: -0.6,
  );

  static final TextStyle sheetTitle = _base.copyWith(
    fontSize: 24,
    height: 1.5,
    letterSpacing: -0.69,
  );

  static final TextStyle detailTitle = _base.copyWith(
    fontSize: 26,
    height: 1.3,
    letterSpacing: -1,
  );

  static final TextStyle subtitle = _base.copyWith(
    fontSize: 15,
    height: 1.55,
    color: AppColors.textSecondary,
  );

  static final TextStyle body = _base.copyWith(
    fontSize: 14,
    height: 1.55,
    color: AppColors.textSecondary,
  );

  static final TextStyle bodySmall = _base.copyWith(
    fontSize: 13.5,
    height: 1.7,
    color: AppColors.textSecondary,
  );

  static final TextStyle caption = _base.copyWith(
    fontSize: 13,
    height: 1.55,
    color: AppColors.textSecondary,
  );

  static final TextStyle micro = _base.copyWith(
    fontSize: 12,
    height: 1.5,
    color: AppColors.textMuted,
  );

  static final TextStyle tiny = _base.copyWith(
    fontSize: 11.5,
    height: 1.5,
    color: AppColors.textMuted,
  );

  static final TextStyle fieldLabel = _base.copyWith(
    fontSize: 13.5,
    height: 1.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static final TextStyle input = _base.copyWith(fontSize: 15, height: 1.5);

  static final TextStyle button = _base.copyWith(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w700,
    color: AppColors.onGold,
  );

  static final TextStyle buttonSecondary = _base.copyWith(
    fontSize: 16,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static final TextStyle linkButton = _base.copyWith(
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w700,
    color: AppColors.gold,
  );

  static final TextStyle chip = _base.copyWith(
    fontSize: 13.5,
    height: 1.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static final TextStyle cardTitle = _base.copyWith(
    fontSize: 16,
    height: 1.45,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );

  static final TextStyle cardDomain = _base.copyWith(
    fontSize: 13,
    height: 1.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    color: AppColors.textMuted,
  );

  static final TextStyle cardMeta = _base.copyWith(
    fontSize: 13,
    height: 1.5,
    color: AppColors.textMuted,
  );

  static final TextStyle rowTitle = _base.copyWith(
    fontSize: 13,
    height: 1.5,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle navLabel = _base.copyWith(
    fontSize: 12,
    height: 1.5,
    color: AppColors.textMuted,
  );
}
