import 'package:flutter/material.dart';

import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/app_icon.dart';

/// Gold call-to-action (48 px, radius 16). Shows a spinner while [loading].
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.height = 48,
    this.authStyle = false,
    this.trailingIcon,
    this.labelStyle,
    this.horizontalPadding = 16,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? icon;
  final String? trailingIcon;
  final bool loading;
  final double height;

  /// Auth screens use a near-black label (#08080A) instead of #17130A.
  final bool authStyle;

  /// Overrides the label style (e.g. small sheet buttons).
  final TextStyle? labelStyle;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final foreground = !enabled && !loading
        ? AppColors.onDisabled
        : (authStyle ? AppColors.onGoldAuth : AppColors.onGold);
    return _ButtonFrame(
      height: height,
      horizontalPadding: horizontalPadding,
      color: enabled || loading ? AppColors.gold : AppColors.disabled,
      onTap: enabled ? onPressed : null,
      child: loading
          ? SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: foreground,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  AppIcon(icon!, size: 18, color: foreground),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: (labelStyle ?? AppTextStyles.button).copyWith(
                      color: foreground,
                    ),
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: 8),
                  AppIcon(trailingIcon!, size: 18, color: foreground),
                ],
              ],
            ),
    );
  }
}

/// Surface button with hairline border (e.g. "Sign In", "Keep item").
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.leading,
    this.color = AppColors.textSecondary,
    this.background = AppColors.surface,
    this.bordered = true,
    this.height = 48,
    this.loading = false,
    this.textStyle,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? icon;

  /// Shown instead of [icon] when the mark must keep its own colours (e.g.
  /// the Google logo).
  final Widget? leading;
  final Color color;
  final Color background;
  final bool bordered;
  final double height;
  final bool loading;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final style = (textStyle ?? AppTextStyles.buttonSecondary).copyWith(
      color: color,
    );
    return _ButtonFrame(
      height: height,
      color: background,
      bordered: bordered,
      onTap: loading ? null : onPressed,
      child: loading
          ? SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2.2, color: color),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 10),
                ] else if (icon != null) ...[
                  AppIcon(icon!, size: 17, color: color),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: style,
                  ),
                ),
              ],
            ),
    );
  }
}

/// Borderless text button (e.g. "Cancel", "Browse all").
class TextActionButton extends StatelessWidget {
  const TextActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style,
    this.minHeight = 42,
    this.padding = const EdgeInsets.symmetric(horizontal: 4),
  });

  final String label;
  final VoidCallback? onPressed;
  final TextStyle? style;
  final double minHeight;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Padding(
            padding: padding,
            child: Center(
              widthFactor: 1,
              child: Text(label, style: style ?? AppTextStyles.linkButton),
            ),
          ),
        ),
      ),
    );
  }
}

/// 48 px square tap target holding a single icon.
class IconTapButton extends StatelessWidget {
  const IconTapButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.iconSize = 21,
    this.color = AppColors.textPrimary,
    this.size = 48,
    this.background,
    this.bordered = false,
    this.radius = 16,
  });

  final String icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final double iconSize;
  final Color? color;
  final double size;
  final Color? background;
  final bool bordered;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      label: semanticLabel,
      child: Material(
        color: background ?? Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: bordered
              ? const BorderSide(color: AppColors.border, width: 1.36)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox.square(
            dimension: size,
            child: Center(
              child: AppIcon(icon, size: iconSize, color: color),
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonFrame extends StatelessWidget {
  const _ButtonFrame({
    required this.height,
    required this.color,
    required this.onTap,
    required this.child,
    this.bordered = false,
    this.horizontalPadding = 16,
  });

  final double height;
  final Color color;
  final VoidCallback? onTap;
  final Widget child;
  final bool bordered;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      child: Material(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: bordered
              ? const BorderSide(color: AppColors.border, width: 1.36)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: height),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
