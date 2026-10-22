import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:stashly/core/result/result.dart';
import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/buttons.dart';
import 'package:stashly/core/widgets/overlays.dart';
import 'package:stashly/features/auth/presentation/session_controller.dart';

/// "or" divider plus "Continue with Google" (`POST /auth/google`, DEC-035).
/// Renders nothing unless the server supports Google (`auth.google_enabled`).
///
/// Not in the Figma file; styled as the design's secondary auth button.
class GoogleSignInSection extends StatefulWidget {
  const GoogleSignInSection({
    super.key,
    required this.session,
    this.termsAccepted,
    this.onTermsMissing,
  });

  final SessionController session;

  /// Register passes its Terms checkbox; elsewhere a dialog asks a new
  /// Google user to accept the Terms.
  final bool? termsAccepted;

  /// Called on Register when a new Google account needs the Terms checkbox.
  final VoidCallback? onTermsMissing;

  @override
  State<GoogleSignInSection> createState() => _GoogleSignInSectionState();
}

class _GoogleSignInSectionState extends State<GoogleSignInSection> {
  bool _busy = false;
  String? _error;

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    var result = await widget.session.signInWithGoogle(
      termsAccepted: widget.termsAccepted ?? false,
    );
    if (result case Err(
      :final failure,
    ) when SessionController.needsTerms(failure)) {
      if (widget.termsAccepted != null) {
        widget.onTermsMissing?.call();
        result = const Ok(null);
      } else if (mounted && await _askForTerms()) {
        result = await widget.session.signInWithGoogle(termsAccepted: true);
      } else {
        widget.session.discardPendingGoogleSignIn();
        result = const Ok(null);
      }
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (result case Err(:final failure)) _error = failure.userMessage;
    });
    // On success the router redirects to Home.
  }

  Future<bool> _askForTerms() async {
    final termsUrl = widget.session.config.termsUrl;
    final accepted = await showStashlyDialog<bool>(
      context,
      builder: (context) => DialogCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create your Stashly account',
              style: AppTextStyles.sectionTitle,
            ),
            const SizedBox(height: 9),
            Text(
              'This Google account is new to Stashly. Accept the Terms to '
              'create your account.',
              style: AppTextStyles.caption.copyWith(height: 1.65),
            ),
            if (termsUrl != null)
              TextActionButton(
                label: 'Read the Terms',
                minHeight: 38,
                style: AppTextStyles.linkButton.copyWith(fontSize: 13.5),
                onPressed: () => launchUrl(
                  Uri.parse(termsUrl),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            const SizedBox(height: 14),
            DialogActions(
              cancel: SecondaryButton(
                label: 'Cancel',
                onPressed: () => Navigator.of(context).pop(false),
              ),
              confirm: PrimaryButton(
                label: 'Accept',
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ),
          ],
        ),
      ),
    );
    return accepted ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      // Visibility follows `GET /config`, which may arrive after first paint.
      listenable: widget.session,
      builder: (context, _) {
        if (!widget.session.googleAvailable) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(child: Divider(color: AppColors.divider)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or', style: AppTextStyles.micro),
                ),
                const Expanded(child: Divider(color: AppColors.divider)),
              ],
            ),
            const SizedBox(height: 16),
            SecondaryButton(
              label: 'Continue with Google',
              color: AppColors.textPrimary,
              loading: _busy,
              leading: SvgPicture.asset(
                'assets/icons/google_g.svg',
                width: 18,
                height: 18,
              ),
              onPressed: _continue,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: AppTextStyles.caption.copyWith(color: AppColors.danger),
              ),
            ],
          ],
        );
      },
    );
  }
}
