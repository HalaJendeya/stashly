import 'package:flutter/material.dart';

/// Colour tokens (single source of truth), one palette per theme.
///
/// Dark is the Figma palette. Light is derived from the same brand: ivory
/// backgrounds, white surfaces, and a deeper gold for text so every text
/// pairing keeps WCAG 4.5:1 contrast. Widgets read the active palette with
/// `context.colors`; never hard-code colours in widgets.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.brightness,
    required this.background,
    required this.backgroundDeep,
    required this.surface,
    required this.card,
    required this.cardRaised,
    required this.menu,
    required this.sheet,
    required this.dialog,
    required this.floatingCard,
    required this.brandMarkBackground,
    required this.gold,
    required this.goldFill,
    required this.goldActive,
    required this.goldLight,
    required this.goldDeep,
    required this.onGold,
    required this.onGoldAuth,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.placeholder,
    required this.danger,
    required this.success,
    required this.disabled,
    required this.onDisabled,
    required this.checkboxBorder,
    required this.handle,
    required this.dotInactive,
    required this.border,
    required this.borderStrong,
    required this.divider,
    required this.subtleFill,
    required this.goldTint,
    required this.goldBorder,
    required this.goldBorderSoft,
    required this.goldBorderFaint,
    required this.dangerTint,
    required this.navBar,
    required this.topBar,
    required this.glass,
    required this.scrim,
    required this.glow,
    required this.shadow,
    required this.coverCoolEnd,
    required this.coverCoolStart,
    required this.coverWarmEnd,
    required this.coverWarmStart,
    required this.shimmer,
    required this.previewPlaceholder,
  });

  static const dark = AppColors(
    brightness: Brightness.dark,
    background: Color(0xFF0B0B0F),
    backgroundDeep: Color(0xFF08080A),
    surface: Color(0xFF1F1F23),
    card: Color(0xFF141418),
    cardRaised: Color(0xFF19191D),
    menu: Color(0xFF252529),
    sheet: Color(0xFF17171B),
    dialog: Color(0xFF1B1B1F),
    floatingCard: Color(0xFF202024),
    brandMarkBackground: Color(0xFF080808),
    gold: Color(0xFFD4AF37),
    goldFill: Color(0xFFD4AF37),
    goldActive: Color(0xFFE2BF50),
    goldLight: Color(0xFFF1D477),
    goldDeep: Color(0xFFB99527),
    onGold: Color(0xFF17130A),
    onGoldAuth: Color(0xFF08080A),
    textPrimary: Color(0xFFF5F5F5),
    textSecondary: Color(0xFFAAA9B0),
    // Raised from the Figma #74737B so muted text keeps 4.5:1 on cards.
    textMuted: Color(0xFF8A8990),
    placeholder: Color(0xFF86858C),
    danger: Color(0xFFFF7575),
    success: Color(0xFF67D69F),
    disabled: Color(0xFF55545B),
    onDisabled: Color(0xFF85848A),
    checkboxBorder: Color(0xFF4B4A50),
    handle: Color(0xFF4B4A51),
    dotInactive: Color(0xFF3D3C42),
    border: Color(0x17FFFFFF), // white 9%
    borderStrong: Color(0x1FFFFFFF), // white 12%
    divider: Color(0x0FFFFFFF), // white 6%
    subtleFill: Color(0x0DFFFFFF), // white 5%
    goldTint: Color(0x21D4AF37), // gold 13%
    goldBorder: Color(0x57D4AF37), // gold 34%
    goldBorderSoft: Color(0x38D4AF37), // gold 22%
    goldBorderFaint: Color(0x24D4AF37), // gold 14%
    dangerTint: Color(0x14FF7575), // danger 8%
    navBar: Color(0xF018181C), // rgba(24,24,28,.94)
    topBar: Color(0xEB0B0B0F), // rgba(11,11,15,.92)
    glass: Color(0xB80A0A0D), // rgba(10,10,13,.72)
    scrim: Color(0xB3000000), // black 70%
    glow: Color(0x2ED4AF37), // gold 18%
    shadow: Color(0x99000000),
    coverCoolEnd: Color(0xFF17191D),
    coverCoolStart: Color(0xFF202631),
    coverWarmEnd: Color(0xFF18181C),
    coverWarmStart: Color(0xFF25231C),
    shimmer: Color(0xFF252529),
    previewPlaceholder: Color(0xFF242015),
  );

  static const light = AppColors(
    brightness: Brightness.light,
    background: Color(0xFFF7F5F0),
    backgroundDeep: Color(0xFFEFECE5),
    surface: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    cardRaised: Color(0xFFFBFAF7),
    menu: Color(0xFFFFFFFF),
    sheet: Color(0xFFFFFFFF),
    dialog: Color(0xFFFFFFFF),
    floatingCard: Color(0xFFFFFFFF),
    // The brand mark tile stays dark in both themes.
    brandMarkBackground: Color(0xFF080808),
    // Brand gold is too light for text on ivory (1.9:1); this deeper gold
    // reaches 5.4:1. Filled gold surfaces keep the brand colour.
    gold: Color(0xFF7D6110),
    goldFill: Color(0xFFD4AF37),
    // Text use (selected tab, stats): deep gold for contrast.
    goldActive: Color(0xFF7D6110),
    // Avatar gradient (a fill under dark initials): brand-bright as in dark.
    goldLight: Color(0xFFF1D477),
    goldDeep: Color(0xFFB99527),
    onGold: Color(0xFF17130A),
    onGoldAuth: Color(0xFF08080A),
    textPrimary: Color(0xFF17171C),
    textSecondary: Color(0xFF55545C),
    textMuted: Color(0xFF6B6A72),
    placeholder: Color(0xFF76757D),
    danger: Color(0xFFC62828),
    success: Color(0xFF1B7F47),
    disabled: Color(0xFFD9D8DC),
    onDisabled: Color(0xFF76757D),
    checkboxBorder: Color(0xFFB9B8BE),
    handle: Color(0xFFCFCED3),
    dotInactive: Color(0xFFD6D5DA),
    border: Color(0x1A17171C), // ink 10%
    borderStrong: Color(0x2617171C), // ink 15%
    divider: Color(0x1217171C), // ink 7%
    subtleFill: Color(0x0A17171C), // ink 4%
    goldTint: Color(0x26D4AF37), // brand gold 15%
    goldBorder: Color(0x807D6110), // deep gold 50%
    goldBorderSoft: Color(0x4D7D6110), // deep gold 30%
    goldBorderFaint: Color(0x337D6110), // deep gold 20%
    dangerTint: Color(0x14C62828), // danger 8%
    navBar: Color(0xF5FFFFFF), // white 96%
    topBar: Color(0xEBF7F5F0), // ivory 92%
    glass: Color(0xD9FFFFFF), // white 85%
    scrim: Color(0x73000000), // black 45%
    glow: Color(0x24D4AF37), // brand gold 14%
    shadow: Color(0x2617171C), // ink 15%
    coverCoolEnd: Color(0xFFF4F6F9),
    coverCoolStart: Color(0xFFE3E8F0),
    coverWarmEnd: Color(0xFFFBF8F0),
    coverWarmStart: Color(0xFFF6EDD3),
    shimmer: Color(0xFFEDECE7),
    previewPlaceholder: Color(0xFFF5EBCF),
  );

  final Brightness brightness;
  final Color background;
  final Color backgroundDeep;
  final Color surface;
  final Color card;
  final Color cardRaised;
  final Color menu;
  final Color sheet;
  final Color dialog;
  final Color floatingCard;
  final Color brandMarkBackground;

  /// Gold for text, icons and outlines (passes contrast on the background).
  final Color gold;

  /// Brand gold for filled surfaces (buttons, badges, the "+" button), always
  /// paired with [onGold] content.
  final Color goldFill;

  /// Highlighted gold text and icons (selected tab, stats).
  final Color goldActive;

  /// Avatar gradient stops (fills under [onGold] text).
  final Color goldLight;
  final Color goldDeep;
  final Color onGold;
  final Color onGoldAuth;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color placeholder;
  final Color danger;
  final Color success;
  final Color disabled;
  final Color onDisabled;
  final Color checkboxBorder;
  final Color handle;
  final Color dotInactive;
  final Color border;
  final Color borderStrong;
  final Color divider;
  final Color subtleFill;
  final Color goldTint;
  final Color goldBorder;
  final Color goldBorderSoft;
  final Color goldBorderFaint;
  final Color dangerTint;
  final Color navBar;
  final Color topBar;
  final Color glass;
  final Color scrim;

  /// Soft gold light behind headers and empty states.
  final Color glow;
  final Color shadow;

  /// Collection cover gradient, cool variant.
  final Color coverCoolEnd;

  /// Collection cover gradient, cool variant.
  final Color coverCoolStart;

  /// Collection cover gradient, warm variant.
  final Color coverWarmEnd;

  /// Collection cover gradient, warm variant.
  final Color coverWarmStart;

  /// Highlight band of loading shimmers.
  final Color shimmer;

  /// Warm start of the no-image preview placeholder.
  final Color previewPlaceholder;

  bool get isDark => brightness == Brightness.dark;

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(AppColors? other, double t) =>
      other == null || t < 0.5 ? this : other;
}

extension AppColorsContext on BuildContext {
  /// The active theme's colour tokens.
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
