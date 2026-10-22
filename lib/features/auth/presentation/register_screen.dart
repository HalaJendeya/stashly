import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:stashly/core/result/result.dart';
import 'package:stashly/core/routing/routes.dart';
import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/app_icon.dart';
import 'package:stashly/core/widgets/buttons.dart';
import 'package:stashly/core/widgets/chips.dart';
import 'package:stashly/core/widgets/fields.dart';
import 'package:stashly/core/widgets/headers.dart';
import 'package:stashly/core/widgets/state_views.dart';
import 'package:stashly/features/auth/domain/auth.dart';
import 'package:stashly/features/auth/presentation/auth_scaffold.dart';
import 'package:stashly/features/auth/presentation/google_sign_in_button.dart';
import 'package:stashly/features/auth/presentation/session_controller.dart';
import 'package:stashly/features/auth/presentation/sign_in_screen.dart';

/// "Create your account" (Figma 1:1020) → `POST /auth/register`.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.session});

  final SessionController session;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  late final TapGestureRecognizer _termsTap = TapGestureRecognizer()
    ..onTap = () => _openLegal(widget.session.config.termsUrl);
  late final TapGestureRecognizer _privacyTap = TapGestureRecognizer()
    ..onTap = () => _openLegal(widget.session.config.privacyUrl);

  bool _accepted = false;
  bool _busy = false;
  final Map<String, String?> _errors = {};
  String? _formError;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm]) {
      c.dispose();
    }
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  Future<void> _openLegal(String? url) async {
    final uri = url == null ? null : Uri.tryParse(url);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        showStashlySnack(context, 'This document isn’t available yet.');
      }
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _formError = null;
      _errors
        ..clear()
        ..['display_name'] = AuthValidators.displayName(_name.text)
        ..['email'] = AuthValidators.email(_email.text)
        ..['password'] = AuthValidators.newPassword(_password.text)
        ..['password_confirmation'] = _confirm.text != _password.text
            ? 'Passwords don’t match.'
            : null
        ..['terms_accepted'] = _accepted
            ? null
            : 'Please accept the Terms to continue.';
    });
    if (_errors.values.any((e) => e != null)) return;

    setState(() => _busy = true);
    final result = await widget.session.register(
      RegistrationRequest(
        displayName: _name.text,
        email: _email.text,
        password: _password.text,
        termsAccepted: _accepted,
        termsVersion: widget.session.config.termsVersion,
      ),
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (result case Err(:final failure)) {
        for (final field in [
          'display_name',
          'email',
          'password',
          'terms_accepted',
        ]) {
          _errors[field] = failure.fieldError(field);
        }
        if (_errors.values.every((e) => e == null)) {
          _formError = failure.userMessage;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final linkStyle = AppTextStyles.micro.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w500,
      height: 1.65,
    );
    return AuthScaffold(
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeader(
              title: 'Create your account',
              subtitle: 'Start building a stash that’s easy to return to.',
            ),
            const SizedBox(height: 24),
            StashlyTextField(
              label: 'Display name',
              controller: _name,
              hint: 'How should we address you?',
              icon: AppIcons.user,
              maxLength: 100,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              errorText: _errors['display_name'],
            ),
            const SizedBox(height: 15),
            StashlyTextField(
              label: 'Email',
              controller: _email,
              hint: 'you@example.com',
              icon: AppIcons.mail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              errorText: _errors['email'],
            ),
            const SizedBox(height: 15),
            StashlyTextField(
              label: 'Password',
              controller: _password,
              hint: 'At least 8 characters',
              icon: AppIcons.lock,
              password: true,
              maxLength: 128,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              errorText: _errors['password'],
            ),
            const SizedBox(height: 15),
            StashlyTextField(
              label: 'Confirm password',
              controller: _confirm,
              hint: 'Enter it once more',
              icon: AppIcons.lock,
              password: true,
              maxLength: 128,
              textInputAction: TextInputAction.done,
              errorText: _errors['password_confirmation'],
            ),
            const SizedBox(height: 15),
            MergeSemantics(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _accepted = !_accepted),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      checked: _accepted,
                      child: CheckSquare(checked: _accepted, size: 21),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: AppTextStyles.micro.copyWith(height: 1.65),
                          children: [
                            const TextSpan(text: 'I agree to the Stashly '),
                            TextSpan(
                              text: 'Terms',
                              style: linkStyle,
                              recognizer: _termsTap,
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: linkStyle,
                              recognizer: _privacyTap,
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_errors['terms_accepted'] != null) ...[
              const SizedBox(height: 6),
              Text(
                _errors['terms_accepted']!,
                style: AppTextStyles.micro.copyWith(color: AppColors.danger),
              ),
            ],
            if (_formError != null) ...[
              const SizedBox(height: 10),
              Text(
                _formError!,
                style: AppTextStyles.caption.copyWith(color: AppColors.danger),
              ),
            ],
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Create Account',
              authStyle: true,
              loading: _busy,
              onPressed: _submit,
            ),
            GoogleSignInSection(
              session: widget.session,
              termsAccepted: _accepted,
              onTermsMissing: () => setState(
                () => _errors['terms_accepted'] =
                    'Please accept the Terms to continue.',
              ),
            ),
            const SizedBox(height: 18),
            AuthFooterPrompt(
              prompt: 'Already have an account?',
              action: 'Sign In',
              onTap: () => context.pushReplacement(Routes.signIn),
            ),
          ],
        ),
      ),
    );
  }
}
