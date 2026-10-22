import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:stashly/core/l10n/l10n.dart';
import 'package:stashly/core/result/app_failure.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/core/routing/routes.dart';
import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/app_icon.dart';
import 'package:stashly/core/widgets/buttons.dart';
import 'package:stashly/core/widgets/fields.dart';
import 'package:stashly/core/widgets/headers.dart';
import 'package:stashly/features/auth/presentation/auth_scaffold.dart';
import 'package:stashly/features/auth/presentation/google_sign_in_button.dart';
import 'package:stashly/features/auth/presentation/session_controller.dart';

/// "Welcome back" (Figma 1:869) → `POST /auth/login`.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, required this.session});

  final SessionController session;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _emailError;
  String? _passwordError;
  String? _formError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _emailError = AuthValidators.email(context.l10n, _email.text);
      _passwordError = _password.text.isEmpty
          ? context.l10n.passwordRequired
          : null;
      _formError = null;
    });
    if (_emailError != null || _passwordError != null) return;

    setState(() => _busy = true);
    final result = await widget.session.signIn(
      email: _email.text,
      password: _password.text,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (result case Err(:final failure)) {
        _emailError = failure.fieldError('email');
        _passwordError = failure.fieldError('password');
        _formError = _emailError == null && _passwordError == null
            ? failure.describe(context.l10n)
            : null;
        if (failure.kind == FailureKind.invalidCredentials) _password.clear();
      }
    });
    // On success the router redirects to Home.
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthHeader(
              title: context.l10n.signInTitle,
              subtitle: context.l10n.signInSubtitle,
            ),
            const SizedBox(height: 24),
            StashlyTextField(
              label: context.l10n.emailLabel,
              controller: _email,
              hint: context.l10n.emailHint,
              icon: AppIcons.mail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              errorText: _emailError,
            ),
            const SizedBox(height: 15),
            StashlyTextField(
              label: context.l10n.passwordLabel,
              controller: _password,
              hint: context.l10n.passwordHint,
              icon: AppIcons.lock,
              password: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              errorText: _passwordError,
              onSubmitted: (_) => _submit(),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextActionButton(
                label: context.l10n.forgotPassword,
                minHeight: 34,
                style: context.text.linkButton.copyWith(fontSize: 13),
                onPressed: () => context.push(Routes.forgotPassword),
              ),
            ),
            if (_formError != null) ...[
              const SizedBox(height: 6),
              Text(
                _formError!,
                style: context.text.caption.copyWith(
                  color: context.colors.danger,
                ),
              ),
            ],
            const SizedBox(height: 14),
            PrimaryButton(
              label: context.l10n.actionSignIn,
              authStyle: true,
              loading: _busy,
              onPressed: _submit,
            ),
            GoogleSignInSection(session: widget.session),
            const SizedBox(height: 18),
            AuthFooterPrompt(
              prompt: context.l10n.newToStashly,
              action: context.l10n.createAccountLink,
              onTap: () => context.pushReplacement(Routes.register),
            ),
          ],
        ),
      ),
    );
  }
}

/// "New to Stashly? Create account" footer, shared with Register.
class AuthFooterPrompt extends StatelessWidget {
  const AuthFooterPrompt({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
  });

  final String prompt;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Wraps onto two lines when large text or a narrow screen needs it.
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        Text(prompt, style: context.text.cardMeta),
        TextActionButton(
          label: action,
          minHeight: 38,
          style: context.text.linkButton.copyWith(fontSize: 13),
          onPressed: onTap,
        ),
      ],
    );
  }
}
