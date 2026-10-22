import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:stashly/core/result/result.dart';
import 'package:stashly/core/routing/routes.dart';
import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/app_icon.dart';
import 'package:stashly/core/widgets/buttons.dart';
import 'package:stashly/core/widgets/fields.dart';
import 'package:stashly/core/widgets/headers.dart';
import 'package:stashly/features/auth/domain/auth.dart';
import 'package:stashly/features/auth/presentation/auth_scaffold.dart';

/// "Reset your password" (Figma 1:934) → `POST /auth/forgot-password`.
///
/// The reset itself happens on the backend's web page from the e-mailed link.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    required this.auth,
    this.initialEmail,
  });

  final AuthRepository auth;
  final String? initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final _email = TextEditingController(text: widget.initialEmail);
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final validation = AuthValidators.email(_email.text);
    setState(() => _error = validation);
    if (validation != null) return;

    setState(() => _busy = true);
    final result = await widget.auth.forgotPassword(_email.text);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case Ok():
        // Passed in memory, not in the route string, to keep the address out of logs.
        context.pushReplacement(Routes.checkInbox, extra: _email.text.trim());
      case Err(:final failure):
        setState(
          () => _error = failure.fieldError('email') ?? failure.userMessage,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeader(
            title: 'Reset your password',
            subtitle: 'Enter the email associated with your account.',
          ),
          const SizedBox(height: 24),
          StashlyTextField(
            label: 'Email',
            controller: _email,
            hint: 'you@example.com',
            icon: AppIcons.mail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            errorText: _error,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Continue',
            authStyle: true,
            loading: _busy,
            onPressed: _submit,
          ),
          const SizedBox(height: 18),
          const InfoBanner(
            message:
                'We’ll email a secure reset link if an account exists. It expires in 60 minutes.',
          ),
        ],
      ),
    );
  }
}

/// "Next, check your inbox" (Figma 1:980).
class CheckInboxScreen extends StatelessWidget {
  const CheckInboxScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      padding: const EdgeInsets.fromLTRB(24, 34, 24, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox.square(
              dimension: 74,
              child: Stack(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: AppColors.goldTint,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: const Color(0x3DD4AF37),
                        width: 1.36,
                      ),
                    ),
                    child: const Center(
                      child: AppIcon(
                        AppIcons.mailLarge,
                        size: 28,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 43,
                    top: 43,
                    child: Container(
                      width: 27,
                      height: 27,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.background,
                          width: 2.7,
                        ),
                      ),
                      child: const Center(
                        child: AppIcon(
                          AppIcons.checkBadge,
                          size: 15,
                          color: AppColors.background,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text('RESET LINK SENT', style: AppTextStyles.eyebrow),
          const SizedBox(height: 7),
          Text('Next, check your inbox', style: AppTextStyles.heading),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              style: AppTextStyles.body.copyWith(height: 1.7),
              children: [
                const TextSpan(text: 'If an account exists for '),
                TextSpan(
                  text: email,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: ', a password reset link is on its way.'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1.36),
            ),
            child: Column(
              children: [
                _Step(number: '1', text: 'Open the secure link in the email.'),
                const SizedBox(height: 13),
                _Step(
                  number: '2',
                  text: 'Choose a new password, then return to sign in.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 35),
          PrimaryButton(
            label: 'Return to Sign In',
            authStyle: true,
            // Back to the Sign In page underneath, keeping Welcome below it.
            onPressed: () =>
                context.canPop() ? context.pop() : context.go(Routes.signIn),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            color: AppColors.goldTint,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: AppTextStyles.micro.copyWith(
              color: AppColors.gold,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: AppTextStyles.caption)),
      ],
    );
  }
}
