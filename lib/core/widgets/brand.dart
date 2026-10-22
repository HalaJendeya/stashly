import 'package:flutter/material.dart';

import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';

/// The Stashly logo tile. The source artwork is a large canvas; the design
/// shows a fixed crop of it, reproduced here at any [size].
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 30, this.large = false});

  final double size;

  /// Large variant (welcome screen) has a gold hairline and drop shadow.
  final bool large;

  static const String asset = 'assets/images/brand_mark.png';

  @override
  Widget build(BuildContext context) {
    final radius = large ? 22.0 : 8.0;
    return Semantics(
      label: 'Stashly',
      image: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.brandMarkBackground,
          borderRadius: BorderRadius.circular(radius),
          border: large
              ? Border.all(color: const Color(0x2ED4AF37), width: 1.36)
              : null,
          boxShadow: large
              ? const [
                  BoxShadow(
                    color: Color(0x73000000),
                    blurRadius: 46,
                    offset: Offset(0, 16),
                  ),
                ]
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: OverflowBox(
          alignment: Alignment.topLeft,
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          child: Transform.translate(
            offset: Offset(-3.134 * size, -0.2998 * size),
            child: Image.asset(
              asset,
              width: 7.136 * size,
              height: 7.136 * size,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
      ),
    );
  }
}

/// Dark page backdrop with the faint gold glows used on every screen.
class StashlyBackground extends StatelessWidget {
  const StashlyBackground({
    super.key,
    required this.child,
    this.secondGlow = false,
  });

  final Widget child;

  /// Auth and onboarding screens add a second glow at the top right.
  final bool secondGlow;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.background),
      child: Stack(
        children: [
          const Positioned(
            left: -50,
            top: -45,
            child: _Glow(size: 240, opacity: 0.08),
          ),
          if (secondGlow)
            const Positioned(
              right: -45,
              top: 25,
              child: _Glow(size: 170, opacity: 0.06),
            ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.gold.withValues(alpha: opacity),
              AppColors.gold.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

/// Initials avatar ("MK"): gold gradient tile or flat gold tile.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.name,
    this.size = 48,
    this.radius = 16,
    this.fontSize = 12,
    this.gradient = true,
    this.singleLetter = false,
    this.onTap,
  });

  final String name;
  final double size;
  final double radius;
  final double fontSize;
  final bool gradient;
  final bool singleLetter;
  final VoidCallback? onTap;

  static String initialsOf(String name, {bool single = false}) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (single) return parts.first.characters.first.toUpperCase();
    final letters = parts.take(2).map((p) => p.characters.first.toUpperCase());
    return letters.join();
  }

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: gradient ? null : AppColors.gold,
        gradient: gradient
            ? const LinearGradient(
                begin: Alignment(-0.6, -1),
                end: Alignment(0.6, 1),
                colors: [AppColors.goldLight, AppColors.goldDeep],
              )
            : null,
        borderRadius: BorderRadius.circular(radius),
        border: gradient
            ? Border.all(color: AppColors.borderStrong, width: 1.36)
            : null,
      ),
      child: Text(
        initialsOf(name, single: singleLetter),
        style: AppTextStyles.button.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
    if (onTap == null) return tile;
    return Semantics(
      button: true,
      label: 'Profile',
      child: GestureDetector(onTap: onTap, child: tile),
    );
  }
}
