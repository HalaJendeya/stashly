import 'dart:ui';

import 'package:flutter/material.dart';

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
    barrierColor: AppColors.scrim,
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
      decoration: const BoxDecoration(
        color: AppColors.sheet,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1.36),
          left: BorderSide(color: AppColors.border, width: 1.36),
          right: BorderSide(color: AppColors.border, width: 1.36),
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
                color: AppColors.handle,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(eyebrow, style: AppTextStyles.eyebrow),
                      const SizedBox(height: 7),
                      Text(title, style: AppTextStyles.sheetTitle),
                    ],
                  ),
                ),
              ),
              IconTapButton(
                icon: AppIcons.close,
                iconSize: 20,
                semanticLabel: 'Close',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          if (helper != null) ...[
            const SizedBox(height: 8),
            Text(helper!, style: AppTextStyles.caption),
          ],
          const SizedBox(height: 14),
          if (scrollable)
            Flexible(child: SingleChildScrollView(child: child))
          else
            Flexible(child: child),
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
    barrierLabel: 'Dismiss',
    barrierColor: AppColors.scrim,
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
        color: AppColors.dialog,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: 1.36),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
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
  String cancelLabel = 'Cancel',
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
              color: const Color(0x17FF7575),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(
              child: AppIcon(
                AppIcons.trash22,
                size: 22,
                color: AppColors.danger,
              ),
            ),
          ),
          const SizedBox(height: 17),
          Text(title, style: AppTextStyles.sectionTitle),
          const SizedBox(height: 9),
          Text(message, style: AppTextStyles.caption.copyWith(height: 1.65)),
          const SizedBox(height: 20),
          DialogActions(
            cancel: SecondaryButton(
              label: cancelLabel,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            confirm: SecondaryButton(
              label: confirmLabel,
              color: AppColors.danger,
              background: AppColors.dangerTint,
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
