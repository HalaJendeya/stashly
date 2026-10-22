import 'package:flutter/material.dart';

import 'package:stashly/core/result/app_failure.dart';
import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/app_icon.dart';
import 'package:stashly/core/widgets/buttons.dart';

/// Centered gold spinner for loading states.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.padding = const EdgeInsets.all(32)});

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: const Center(
        child: SizedBox.square(
          dimension: 26,
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      ),
    );
  }
}

/// Dashed card for empty, offline and error states (search "No matches found").
class MessageCard extends StatelessWidget {
  const MessageCard({
    super.key,
    required this.title,
    required this.message,
    this.icon = AppIcons.search28,
    this.actionLabel,
    this.onAction,
    this.glow = false,
  });

  final String title;
  final String message;
  final String icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// The search hint card has a faint gold glow in the corner.
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedBorderPainter(radius: 22, color: AppColors.border),
      child: Container(
        constraints: const BoxConstraints(minHeight: 200),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: glow
              ? const RadialGradient(
                  center: Alignment(0.7, -0.7),
                  radius: 1.1,
                  colors: [Color(0x17D4AF37), AppColors.card],
                  stops: [0, 0.35],
                )
              : null,
          color: glow ? null : Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(icon, size: 28, color: AppColors.textMuted),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.cardTitle.copyWith(
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              SecondaryButton(
                label: actionLabel!,
                onPressed: onAction,
                height: 42,
                textStyle: AppTextStyles.caption,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Failure card with a retry button; wording adapts to offline/server errors.
class FailureView extends StatelessWidget {
  const FailureView({super.key, required this.failure, required this.onRetry});

  final AppFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final offline = failure.kind == FailureKind.offline;
    return MessageCard(
      icon: offline ? AppIcons.info : AppIcons.shield,
      title: offline ? 'You’re offline' : 'Couldn’t load this',
      message: failure.userMessage,
      actionLabel: 'Try again',
      onAction: onRetry,
    );
  }
}

/// Paints a rounded dashed outline (Flutter has no built-in dashed border).
class DashedBorderPainter extends CustomPainter {
  DashedBorderPainter({required this.radius, required this.color});

  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.36;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    paintDashedPath(canvas, path, paint);
  }

  /// Strokes [path] as 4 px dashes with 3 px gaps.
  static void paintDashedPath(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 4), paint);
        distance += 7;
      }
    }
  }

  @override
  bool shouldRepaint(DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

/// Shows a floating snackbar; errors are tinted red.
void showStashlySnack(
  BuildContext context,
  String message, {
  bool error = false,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  messenger
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.caption.copyWith(
            color: error ? AppColors.danger : AppColors.textPrimary,
          ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
}
