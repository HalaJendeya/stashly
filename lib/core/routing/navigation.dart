import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:stashly/core/routing/routes.dart';
import 'package:stashly/core/widgets/overlays.dart';

extension SafeNavigation on BuildContext {
  /// Goes back one page, or to Home when there is nothing to go back to (the
  /// page was opened directly, e.g. from the share sheet). Signed-out users
  /// are redirected from Home to Welcome by the router.
  void popOrHome() {
    if (canPop()) {
      pop();
    } else {
      go(Routes.home);
    }
  }
}

/// Asks before leaving a form with unsaved edits, whether the user taps the
/// back arrow or uses the system back gesture.
class UnsavedChangesGuard extends StatelessWidget {
  const UnsavedChangesGuard({
    super.key,
    required this.hasChanges,
    required this.child,
  });

  /// Read on every back attempt, so it can depend on live controllers.
  final bool Function() hasChanges;
  final Widget child;

  /// Leave the page, asking first when there are unsaved edits. Use for the
  /// page's own back or close button.
  static Future<void> leave(
    BuildContext context,
    bool Function() hasChanges,
  ) async {
    if (!hasChanges() || await confirmDiscard(context)) {
      if (context.mounted) context.popOrHome();
    }
  }

  static Future<bool> confirmDiscard(BuildContext context) =>
      confirmDestructive(
        context,
        title: 'Discard your changes?',
        message: 'You have edits that haven’t been saved yet.',
        confirmLabel: 'Discard',
        cancelLabel: 'Keep editing',
      );

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) leave(context, hasChanges);
      },
      child: child,
    );
  }
}
