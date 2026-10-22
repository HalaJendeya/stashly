import 'package:flutter/painting.dart';

/// Colour tokens from the Stashly Figma foundations (single source of truth).
abstract final class AppColors {
  static const Color background = Color(0xFF0B0B0F);
  static const Color backgroundDeep = Color(0xFF08080A);
  static const Color surface = Color(0xFF1F1F23);
  static const Color card = Color(0xFF141418);
  static const Color cardRaised = Color(0xFF19191D);
  static const Color menu = Color(0xFF252529);
  static const Color sheet = Color(0xFF17171B);
  static const Color dialog = Color(0xFF1B1B1F);
  static const Color floatingCard = Color(0xFF202024);
  static const Color brandMarkBackground = Color(0xFF080808);

  static const Color gold = Color(0xFFD4AF37);
  static const Color goldActive = Color(0xFFE2BF50);
  static const Color goldLight = Color(0xFFF1D477);
  static const Color goldDeep = Color(0xFFB99527);
  static const Color onGold = Color(0xFF17130A);
  static const Color onGoldAuth = Color(0xFF08080A);

  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFAAA9B0);
  static const Color textMuted = Color(0xFF74737B);
  static const Color placeholder = Color(0xFF6F6E75);

  static const Color danger = Color(0xFFFF7575);
  static const Color success = Color(0xFF67D69F);

  static const Color disabled = Color(0xFF55545B);
  static const Color onDisabled = Color(0xFF85848A);
  static const Color checkboxBorder = Color(0xFF4B4A50);
  static const Color handle = Color(0xFF4B4A51);
  static const Color dotInactive = Color(0xFF3D3C42);

  static const Color border = Color(0x17FFFFFF); // white 9%
  static const Color borderStrong = Color(0x1FFFFFFF); // white 12%
  static const Color divider = Color(0x0FFFFFFF); // white 6%
  static const Color subtleFill = Color(0x0DFFFFFF); // white 5%

  static const Color goldTint = Color(0x21D4AF37); // gold 13%
  static const Color goldBorder = Color(0x57D4AF37); // gold 34%
  static const Color goldBorderSoft = Color(0x38D4AF37); // gold 22%
  static const Color goldBorderFaint = Color(0x24D4AF37); // gold 14%
  static const Color dangerTint = Color(0x14FF7575); // danger 8%

  static const Color navBar = Color(0xF018181C); // rgba(24,24,28,.94)
  static const Color topBar = Color(0xEB0B0B0F); // rgba(11,11,15,.92)
  static const Color glass = Color(0xB80A0A0D); // rgba(10,10,13,.72)
  static const Color scrim = Color(0xB3000000); // black 70%
}
