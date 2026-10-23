import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:stashly/core/l10n/l10n.dart';
import 'package:stashly/core/routing/routes.dart';
import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/app_icon.dart';
import 'package:stashly/core/widgets/brand.dart';
import 'package:stashly/core/widgets/buttons.dart';
import 'package:stashly/features/auth/presentation/auth_scaffold.dart';
import 'package:stashly/features/auth/presentation/google_sign_in_button.dart';
import 'package:stashly/features/auth/presentation/session_controller.dart';

/// First screen for signed-out users (Figma 1:820).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.session,
    this.sessionExpired = false,
  });

  final SessionController session;

  final bool sessionExpired;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      padding: const EdgeInsets.fromLTRB(24, 38, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const BrandMark(size: 76, large: true),
              const SizedBox(width: 17),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stashly',
                      style: context.text.heading.copyWith(
                        fontSize: 29,
                        letterSpacing: -1.12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.tagline,
                      style: context.text.bodySmall.copyWith(
                        letterSpacing: 0.44,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),
          const Spacer(),
          if (sessionExpired) ...[
            Text(
              context.l10n.sessionEnded,
              style: context.text.caption.copyWith(
                color: context.colors.danger,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(context.l10n.welcomeEyebrow, style: context.text.eyebrow),
          const SizedBox(height: 7),
          Text(
            context.l10n.welcomeTitle,
            style: context.text.heading.copyWith(
              fontSize: 31,
              letterSpacing: -1.35,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 13),
          Text(
            context.l10n.welcomeBody,
            style: context.text.body.copyWith(height: 1.7),
          ),
          const SizedBox(height: 21),
          for (final point in [
            context.l10n.welcomePointSave,
            context.l10n.welcomePointOrganize,
            context.l10n.welcomePointSearch,
          ]) ...[
            Row(
              children: [
                AppIcon(AppIcons.check, size: 16, color: context.colors.gold),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    point,
                    style: context.text.bodySmall.copyWith(height: 1.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
          ],
          const SizedBox(height: 20),
          PrimaryButton(
            label: context.l10n.actionCreateAccount,
            authStyle: true,
            onPressed: () => context.push(Routes.register),
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: context.l10n.actionSignIn,
            onPressed: () => context.push(Routes.signIn),
          ),
          GoogleSignInSection(session: session),
          const SizedBox(height: 17),
          Text(
            context.l10n.welcomeFootnote,
            textAlign: TextAlign.center,
            style: context.text.micro,
          ),
        ],
      ),
    );
  }
}
