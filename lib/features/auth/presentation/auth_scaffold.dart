import 'package:flutter/material.dart';

import 'package:stashly/core/l10n/l10n.dart';
import 'package:stashly/core/widgets/brand.dart';

/// Shared frame for auth screens: glow backdrop, safe area, scrollable body
/// with the design's 20 px gutters.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 7, 20, 28),
    this.scrollable = true,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StashlyBackground(
        secondGlow: true,
        child: SafeArea(
          child: scrollable
              ? LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    padding: padding,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - padding.vertical,
                      ),
                      // Lets screens use Spacer to pin actions to the bottom.
                      child: IntrinsicHeight(child: child),
                    ),
                  ),
                )
              : Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Basic client-side checks for UX; the server is authoritative.
abstract final class AuthValidators {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(AppLocalizations l10n, String value) {
    final text = value.trim();
    if (text.isEmpty) return l10n.emailRequired;
    if (text.length > 255 || !_email.hasMatch(text)) {
      return l10n.emailInvalid;
    }
    return null;
  }

  static String? newPassword(AppLocalizations l10n, String value) {
    if (value.length < 8) return l10n.passwordTooShort;
    if (value.length > 128) return l10n.passwordTooLong;
    return null;
  }

  static String? displayName(AppLocalizations l10n, String value) {
    final text = value.trim();
    if (text.isEmpty) return l10n.nameRequired;
    if (text.length > 100) return l10n.nameTooLong;
    return null;
  }
}
