import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:stashly/core/theme/app_colors.dart';

/// Fits the whole app to the device it runs on:
///
/// * text follows the screen size on top of the user's own font-size
///   setting, so compact phones stay tidy and large phones and tablets get
///   larger type;
/// * on tablets and in landscape the content keeps a readable width,
///   centred on the background, instead of stretching edge to edge.
///
/// Wraps the router's navigator, so pages, sheets and dialogs all see the
/// adjusted [MediaQuery].
class AppViewport extends StatelessWidget {
  const AppViewport({super.key, required this.child});

  final Widget child;

  /// Widest the app content gets (tablets, landscape).
  static const double maxContentWidth = 600;

  /// Width of the Figma frames the type scale was drawn for.
  static const double designWidth = 390;

  /// Largest combined text scale; layouts stay usable up to here.
  static const double maxTextScale = 2.2;

  /// Text factor for a device whose shorter side is [shortestSide] logical
  /// pixels: 0.92 on 320 px phones, 1.0 at the design width, up to 1.12 on
  /// tablets.
  static double screenTextFactor(double shortestSide) =>
      (shortestSide / designWidth).clamp(0.92, 1.12);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = math.min(media.size.width, maxContentWidth);
    final textScaler = _ScreenTextScaler(
      user: media.textScaler,
      screenFactor: screenTextFactor(media.size.shortestSide),
    );
    return ColoredBox(
      color: AppColors.background,
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: width,
          child: MediaQuery(
            data: media.copyWith(
              size: Size(width, media.size.height),
              textScaler: textScaler.clamp(maxScaleFactor: maxTextScale),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

extension TextScaledLayout on BuildContext {
  /// [designSize] for a box that needs an explicit size (horizontal list
  /// height, tile width, grid cell) but holds text: it grows with the current
  /// text scale so larger type never overflows it, and never shrinks below
  /// the design.
  double textScaled(double designSize) =>
      math.max(designSize, MediaQuery.textScalerOf(this).scale(designSize));
}

/// The user's text scaler (which may be non-linear on Android 14+) followed
/// by the screen-size factor.
@immutable
class _ScreenTextScaler extends TextScaler {
  const _ScreenTextScaler({required this.user, required this.screenFactor});

  final TextScaler user;
  final double screenFactor;

  @override
  double scale(double fontSize) => user.scale(fontSize) * screenFactor;

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => user.textScaleFactor * screenFactor;

  @override
  bool operator ==(Object other) =>
      other is _ScreenTextScaler &&
      other.user == user &&
      other.screenFactor == screenFactor;

  @override
  int get hashCode => Object.hash(user, screenFactor);
}
