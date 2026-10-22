import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 28,
                        letterSpacing: -1.12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Everything Worth Keeping',
                      style: AppTextStyles.bodySmall.copyWith(
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
              'Your session ended. Please sign in again.',
              style: AppTextStyles.caption.copyWith(color: AppColors.danger),
            ),
            const SizedBox(height: 16),
          ],
          Text('YOUR DIGITAL-CONTENT WALLET', style: AppTextStyles.eyebrow),
          const SizedBox(height: 7),
          // Align loosens the Column's stretch so the 330 px measure applies.
          Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 330),
              child: Text(
                'Save anything worth keeping.',
                style: AppTextStyles.heading.copyWith(
                  fontSize: 30,
                  letterSpacing: -1.35,
                  height: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 13),
          // Align loosens the Column's stretch so the 330 px measure applies.
          Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 330),
              child: Text(
                'Collect useful links from anywhere, organize them your way, and '
                'find them when they matter.',
                style: AppTextStyles.body.copyWith(height: 1.7),
              ),
            ),
          ),
          const SizedBox(height: 21),
          for (final point in const [
            'Save links in seconds',
            'Organize when you’re ready',
            'Search your whole stash',
          ]) ...[
            Row(
              children: [
                const AppIcon(AppIcons.check, size: 16, color: AppColors.gold),
                const SizedBox(width: 9),
                Text(
                  point,
                  style: AppTextStyles.bodySmall.copyWith(height: 1.5),
                ),
              ],
            ),
            const SizedBox(height: 11),
          ],
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Create Account',
            authStyle: true,
            onPressed: () => context.push(Routes.register),
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Sign In',
            onPressed: () => context.push(Routes.signIn),
          ),
          GoogleSignInSection(session: session),
          const SizedBox(height: 17),
          Text(
            'Stashly keeps the link and its details — never a copy of the content.',
            textAlign: TextAlign.center,
            style: AppTextStyles.micro,
          ),
        ],
      ),
    );
  }
}
