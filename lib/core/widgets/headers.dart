import 'package:flutter/material.dart';

import 'package:stashly/core/l10n/l10n.dart';
import 'package:stashly/core/routing/navigation.dart';
import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/app_icon.dart';
import 'package:stashly/core/widgets/brand.dart';
import 'package:stashly/core/widgets/buttons.dart';

/// Tab-screen top bar: brand mark + "Stashly" on the left, action on the right.
class BrandTopBar extends StatelessWidget {
  const BrandTopBar({super.key, this.onLibrary});

  /// The bookmark button opens the full library.
  final VoidCallback? onLibrary;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 58),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Row(
          children: [
            const BrandMark(),
            const SizedBox(width: 9),
            Text(
              'Stashly',
              style: context.text.button.copyWith(
                color: context.colors.textPrimary,
                letterSpacing: -0.32,
              ),
            ),
            const Spacer(),
            IconTapButton(
              icon: AppIcons.bookmark,
              iconSize: 19,
              semanticLabel: context.l10n.allSavedItems,
              onPressed: onLibrary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Eyebrow + large title block ("YOUR SPACE / Recently saved").
class TitleBlock extends StatelessWidget {
  const TitleBlock({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(eyebrow, style: context.text.eyebrow),
          const SizedBox(height: 7),
          Text(title, style: titleStyle ?? context.text.heading),
          if (subtitle != null) ...[
            const SizedBox(height: 7),
            Text(subtitle!, style: subtitleStyle ?? context.text.body),
          ],
        ],
      ),
    );
  }
}

/// Section header with an optional trailing gold action ("Browse all").
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String eyebrow;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TitleBlock(
            eyebrow: eyebrow,
            title: title,
            titleStyle: context.text.sectionTitle,
          ),
        ),
        if (actionLabel != null)
          TextActionButton(label: actionLabel!, onPressed: onAction),
      ],
    );
  }
}

/// Inner-page header: back button, eyebrow + compact title, optional trailing.
class BackTitleHeader extends StatelessWidget {
  const BackTitleHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.trailing,
    this.onBack,
  });

  final String eyebrow;
  final String title;
  final Widget? trailing;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 72),
      child: Row(
        children: [
          IconTapButton(
            icon: AppIcons.arrowLeft,
            semanticLabel: context.l10n.actionBack,
            onPressed: onBack ?? context.popOrHome,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TitleBlock(
              eyebrow: eyebrow,
              title: title,
              titleStyle: context.text.headingCompact,
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

/// Auth-style header: back button + small brand mark, then a big title.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showBack = true,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final bool showBack;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (showBack)
              IconTapButton(
                icon: AppIcons.arrowLeft,
                semanticLabel: context.l10n.actionBack,
                onPressed: onBack ?? context.popOrHome,
              )
            else
              const SizedBox(height: 48),
            const Spacer(),
            const BrandMark(),
          ],
        ),
        const SizedBox(height: 23),
        Semantics(
          header: true,
          child: Text(title, style: context.text.heading),
        ),
        const SizedBox(height: 7),
        Text(subtitle, style: context.text.body.copyWith(height: 1.55)),
      ],
    );
  }
}

/// Translucent bar with back, centred caption and optional action
/// (item details, shared link).
class CaptionTopBar extends StatelessWidget {
  const CaptionTopBar({
    super.key,
    required this.caption,
    this.leadingIcon = AppIcons.arrowLeft,
    this.leadingLabel,
    this.onLeading,
    this.trailing,
  });

  final String caption;
  final String leadingIcon;

  /// Defaults to "Back".
  final String? leadingLabel;
  final VoidCallback? onLeading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.topBar,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Row(
        children: [
          IconTapButton(
            icon: leadingIcon,
            iconSize: 20,
            semanticLabel: leadingLabel ?? context.l10n.actionBack,
            onPressed: onLeading ?? context.popOrHome,
          ),
          Expanded(
            child: Text(
              caption,
              textAlign: TextAlign.center,
              style: context.text.caption.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          trailing ?? const SizedBox(width: 48),
        ],
      ),
    );
  }
}
