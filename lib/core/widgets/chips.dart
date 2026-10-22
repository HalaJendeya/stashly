import 'package:flutter/material.dart';

import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/app_icon.dart';

enum PillSize {
  /// Filter rows on Home / Library / Search (38 px, 11 pt).
  regular,

  /// Filter sheet options (35 px, 8 pt).
  compact,
}

/// Rounded filter chip; gold when [selected].
class PillChip extends StatelessWidget {
  const PillChip({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.icon,
    this.size = PillSize.regular,
  });

  final String label;
  final VoidCallback? onTap;
  final bool selected;
  final String? icon;
  final PillSize size;

  @override
  Widget build(BuildContext context) {
    final compact = size == PillSize.compact;
    final foreground = selected
        ? context.colors.onGold
        : context.colors.textSecondary;
    final textStyle = compact
        ? context.text.chip.copyWith(fontSize: 11.5, color: foreground)
        : context.text.chip.copyWith(color: foreground);
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? context.colors.goldFill : context.colors.surface,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? context.colors.goldFill : context.colors.border,
            width: 1.36,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: compact ? 35 : 38),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: compact ? 11 : 15),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    AppIcon(icon!, size: 14, color: foreground),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small static tag pill (`#travel`) used on details.
class TagPill extends StatelessWidget {
  const TagPill(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: ShapeDecoration(
        color: context.colors.surface,
        shape: StadiumBorder(
          side: BorderSide(color: context.colors.border, width: 1.36),
        ),
      ),
      child: Text(
        label,
        style: context.text.tiny.copyWith(color: context.colors.textSecondary),
      ),
    );
  }
}

/// Gold-tinted label ("Videos", "Active").
class GoldBadge extends StatelessWidget {
  const GoldBadge(
    this.label, {
    super.key,
    this.fontSize = 11.5,
    this.muted = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
  });

  final String label;
  final double fontSize;
  final bool muted;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: ShapeDecoration(
        color: muted ? context.colors.subtleFill : context.colors.goldTint,
        shape: const StadiumBorder(),
      ),
      child: Text(
        label,
        style: context.text.tiny.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: muted ? context.colors.textMuted : context.colors.gold,
        ),
      ),
    );
  }
}

/// 23 px rounded checkbox square used in pickers and filters.
class CheckSquare extends StatelessWidget {
  const CheckSquare({super.key, required this.checked, this.size = 23});

  final bool checked;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: checked ? context.colors.goldFill : context.colors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: checked
              ? context.colors.goldFill
              : context.colors.checkboxBorder,
          width: 1.36,
        ),
      ),
      child: checked
          ? Center(
              child: AppIcon(
                AppIcons.checkDark,
                size: 14,
                color: context.colors.onGold,
              ),
            )
          : null,
    );
  }
}

/// Selectable row with a checkbox, a bold title and a small subtitle.
class SelectionRow extends StatelessWidget {
  const SelectionRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: selected,
      button: true,
      child: Material(
        color: selected ? context.colors.goldTint : context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? context.colors.goldBorder : context.colors.border,
            width: 1.36,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 54),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              child: Row(
                children: [
                  CheckSquare(checked: selected),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.rowTitle,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.tiny,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
