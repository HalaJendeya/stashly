import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      _emailError = AuthValidators.email(_email.text);
      _passwordError = _password.text.isEmpty ? 'Enter your password.' : null;
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
            ? failure.userMessage
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
            const AuthHeader(
              title: 'Welcome back',
              subtitle: 'Sign in to return to everything you’ve kept.',
            ),
            const SizedBox(height: 24),
            StashlyTextField(
              label: 'Email',
              controller: _email,
              hint: 'you@example.com',
              icon: AppIcons.mail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              errorText: _emailError,
            ),
            const SizedBox(height: 15),
            StashlyTextField(
              label: 'Password',
              controller: _password,
              hint: 'Enter your password',
              icon: AppIcons.lock,
              password: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              errorText: _passwordError,
              onSubmitted: (_) => _submit(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextActionButton(
                label: 'Forgot password?',
                minHeight: 34,
                style: AppTextStyles.linkButton.copyWith(fontSize: 10),
                onPressed: () => context.push(Routes.forgotPassword),
              ),
            ),
            if (_formError != null) ...[
              const SizedBox(height: 6),
              Text(
                _formError!,
                style: AppTextStyles.caption.copyWith(color: AppColors.danger),
              ),
            ],
            const SizedBox(height: 14),
            PrimaryButton(
              label: 'Sign In',
              authStyle: true,
              loading: _busy,
              onPressed: _submit,
            ),
            GoogleSignInSection(session: widget.session),
            const SizedBox(height: 18),
            AuthFooterPrompt(
              prompt: 'New to Stashly?',
              action: 'Create account',
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(prompt, style: AppTextStyles.cardMeta),
        const SizedBox(width: 4),
        TextActionButton(
          label: action,
          minHeight: 38,
          style: AppTextStyles.linkButton.copyWith(fontSize: 10),
          onPressed: onTap,
        ),
      ],
    );
  }
}
