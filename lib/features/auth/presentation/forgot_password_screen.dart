import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:stashly/core/l10n/l10n.dart';
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
    final validation = AuthValidators.email(context.l10n, _email.text);
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
          () => _error =
              failure.fieldError('email') ?? failure.describe(context.l10n),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthHeader(
            title: context.l10n.resetTitle,
            subtitle: context.l10n.resetSubtitle,
          ),
          const SizedBox(height: 24),
          StashlyTextField(
            label: context.l10n.emailLabel,
            controller: _email,
            hint: context.l10n.emailHint,
            icon: AppIcons.mail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            errorText: _error,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: context.l10n.actionContinue,
            authStyle: true,
            loading: _busy,
            onPressed: _submit,
          ),
          const SizedBox(height: 18),
          InfoBanner(message: context.l10n.resetNotice),
        ],
      ),
    );
  }
}

/// "Next, check your inbox" (Figma 1:980).
class CheckInboxScreen extends StatelessWidget {
  const CheckInboxScreen({super.key, required this.email});

  /// The address the link was sent to; "your email" when unknown.
  final String? email;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      padding: const EdgeInsets.fromLTRB(24, 34, 24, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: SizedBox.square(
              dimension: 74,
              child: Stack(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: context.colors.goldTint,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: const Color(0x3DD4AF37),
                        width: 1.36,
                      ),
                    ),
                    child: Center(
                      child: AppIcon(
                        AppIcons.mailLarge,
                        size: 28,
                        color: context.colors.gold,
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
                        color: context.colors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.colors.background,
                          width: 2.7,
                        ),
                      ),
                      child: Center(
                        child: AppIcon(
                          AppIcons.checkBadge,
                          size: 15,
                          color: context.colors.background,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(context.l10n.resetSentEyebrow, style: context.text.eyebrow),
          const SizedBox(height: 7),
          Text(context.l10n.checkInboxTitle, style: context.text.heading),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              style: context.text.body.copyWith(height: 1.7),
              children: [
                TextSpan(text: context.l10n.checkInboxBefore),
                TextSpan(
                  text: email ?? context.l10n.yourEmailFallback,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: context.l10n.checkInboxAfter),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colors.border, width: 1.36),
            ),
            child: Column(
              children: [
                _Step(number: '1', text: context.l10n.checkInboxStepOpen),
                const SizedBox(height: 13),
                _Step(number: '2', text: context.l10n.checkInboxStepChoose),
              ],
            ),
          ),
          const SizedBox(height: 35),
          PrimaryButton(
            label: context.l10n.returnToSignIn,
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
            color: context.colors.goldTint,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: context.text.micro.copyWith(
              color: context.colors.gold,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: context.text.caption)),
      ],
    );
  }
}
