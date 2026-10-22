import 'package:flutter/material.dart';

import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';

/// Stashly's dark (primary) and light themes, built from one palette each.
/// Widgets read tokens through `context.colors` / `context.text`, never from
/// ad-hoc literals.
abstract final class AppTheme {
  static ThemeData dark() => _build(AppColors.dark);

  static ThemeData light() => _build(AppColors.light);

  static ThemeData _build(AppColors c) {
    final text = AppTextStyles.of(c);
    final scheme = ColorScheme(
      brightness: c.brightness,
      primary: c.goldFill,
      onPrimary: c.onGold,
      secondary: c.gold,
      onSecondary: c.onGold,
      error: c.danger,
      onError: c.isDark ? c.onGold : Colors.white,
      surface: c.background,
      onSurface: c.textPrimary,
      surfaceContainerHighest: c.surface,
      outline: c.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: c.brightness,
      colorScheme: scheme,
      fontFamily: AppTextStyles.fontFamily,
      scaffoldBackgroundColor: c.background,
      splashFactory: InkSparkle.splashFactory,
      extensions: [c, text],
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.gold,
        selectionColor: c.goldTint,
        selectionHandleColor: c.gold,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.menu,
        contentTextStyle: text.caption.copyWith(color: c.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: c.border),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.gold),
      dividerTheme: DividerThemeData(color: c.divider, thickness: 1),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
