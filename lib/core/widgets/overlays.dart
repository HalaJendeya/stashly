import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:stashly/core/l10n/l10n.dart';
import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/app_icon.dart';
import 'package:stashly/core/widgets/buttons.dart';

/// Opens a Stashly bottom sheet (dark sheet, 28 px top radius, drag handle).
Future<T?> showStashlySheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    // Above the shell, so the floating bottom navigation can't cover the
    // sheet's footer actions.
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: context.colors.scrim,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: builder(context),
    ),
  );
}

/// Sheet body: handle, eyebrow + title, close button, then [child].
class SheetFrame extends StatelessWidget {
  const SheetFrame({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.child,
    this.helper,
    this.footer,
    this.scrollable = true,
  });

  final String eyebrow;
  final String title;
  final String? helper;
  final Widget child;
  final Widget? footer;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: context.colors.sheet,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: context.colors.border, width: 1.36),
          left: BorderSide(color: context.colors.border, width: 1.36),
          right: BorderSide(color: context.colors.border, width: 1.36),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 9, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.handle,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Header and helper scroll with the content, so large text never
          // pushes the footer actions off-screen.
          Flexible(
            child: SingleChildScrollView(
              physics: scrollable ? null : const NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(eyebrow, style: context.text.eyebrow),
                              const SizedBox(height: 7),
                              Text(title, style: context.text.sheetTitle),
                            ],
                          ),
                        ),
                      ),
                      IconTapButton(
                        icon: AppIcons.close,
                        iconSize: 20,
                        semanticLabel: context.l10n.actionClose,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  if (helper != null) ...[
                    const SizedBox(height: 8),
                    Text(helper!, style: context.text.caption),
                  ],
                  const SizedBox(height: 14),
                  child,
                ],
              ),
            ),
          ),
          if (footer != null) ...[const SizedBox(height: 12), footer!],
        ],
      ),
    );
  }
}

/// Centered dialog card (#1B1B1F, radius 22) over a blurred scrim.
Future<T?> showStashlyDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: context.l10n.actionDismiss,
    barrierColor: context.colors.scrim,
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (context, animation, secondaryAnimation) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              22,
              0,
              22,
              MediaQuery.viewInsetsOf(context).bottom,
            ),
            // Scrolls when large text makes the dialog taller than the screen.
            child: SingleChildScrollView(
              child: Material(
                color: Colors.transparent,
                child: builder(context),
              ),
            ),
          ),
        ),
      ),
    ),
    transitionBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

/// A dialog's cancel and confirm buttons: side by side as designed, stacked
/// (confirm on top) when large text would not fit them on one row.
class DialogActions extends StatelessWidget {
  const DialogActions({super.key, required this.cancel, required this.confirm});

  final Widget cancel;
  final Widget confirm;

  /// Above this text scale two half-width button labels stop fitting.
  static const double stackAboveTextScale = 1.35;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
    if (scale > stackAboveTextScale) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [confirm, const SizedBox(height: 9), cancel],
      );
    }
    return Row(
      children: [
        Expanded(child: cancel),
        const SizedBox(width: 9),
        Expanded(child: confirm),
      ],
    );
  }
}

/// The dialog card itself.
class DialogCard extends StatelessWidget {
  const DialogCard({super.key, required this.child, this.padding = 22});

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 440),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: context.colors.dialog,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.colors.border, width: 1.36),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow,
            blurRadius: 35,
            offset: Offset(0, 24),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Destructive confirmation ("Delete this saved item?").
Future<bool> confirmDestructive(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String? cancelLabel,
}) async {
  final confirmed = await showStashlyDialog<bool>(
    context,
    builder: (context) => DialogCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.colors.dangerTint,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: AppIcon(
                AppIcons.trash22,
                size: 22,
                color: context.colors.danger,
              ),
            ),
          ),
          const SizedBox(height: 17),
          Text(title, style: context.text.sectionTitle),
          const SizedBox(height: 9),
          Text(message, style: context.text.caption.copyWith(height: 1.65)),
          const SizedBox(height: 20),
          DialogActions(
            cancel: SecondaryButton(
              label: cancelLabel ?? context.l10n.actionCancel,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            confirm: SecondaryButton(
              label: confirmLabel,
              color: context.colors.danger,
              background: context.colors.dangerTint,
              bordered: false,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ),
        ],
      ),
    ),
  );
  return confirmed ?? false;
}
