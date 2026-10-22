import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:stashly/core/l10n/l10n.dart';
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
        showStashlySnack(context, context.l10n.documentUnavailable);
      }
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _formError = null;
      _errors
        ..clear()
        ..['display_name'] = AuthValidators.displayName(
          context.l10n,
          _name.text,
        )
        ..['email'] = AuthValidators.email(context.l10n, _email.text)
        ..['password'] = AuthValidators.newPassword(
          context.l10n,
          _password.text,
        )
        ..['password_confirmation'] = _confirm.text != _password.text
            ? context.l10n.passwordsDontMatch
            : null
        ..['terms_accepted'] = _accepted
            ? null
            : context.l10n.acceptTermsRequired;
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
          _formError = failure.describe(context.l10n);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final linkStyle = context.text.micro.copyWith(
      color: context.colors.textSecondary,
      fontWeight: FontWeight.w500,
      height: 1.65,
    );
    return AuthScaffold(
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthHeader(
              title: context.l10n.registerTitle,
              subtitle: context.l10n.registerSubtitle,
            ),
            const SizedBox(height: 24),
            StashlyTextField(
              label: context.l10n.displayNameLabel,
              controller: _name,
              hint: context.l10n.displayNameHint,
              icon: AppIcons.user,
              maxLength: 100,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              errorText: _errors['display_name'],
            ),
            const SizedBox(height: 15),
            StashlyTextField(
              label: context.l10n.emailLabel,
              controller: _email,
              hint: context.l10n.emailHint,
              icon: AppIcons.mail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              errorText: _errors['email'],
            ),
            const SizedBox(height: 15),
            StashlyTextField(
              label: context.l10n.passwordLabel,
              controller: _password,
              hint: context.l10n.newPasswordHint,
              icon: AppIcons.lock,
              password: true,
              maxLength: 128,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              errorText: _errors['password'],
            ),
            const SizedBox(height: 15),
            StashlyTextField(
              label: context.l10n.confirmPasswordLabel,
              controller: _confirm,
              hint: context.l10n.confirmPasswordHint,
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
                          style: context.text.micro.copyWith(height: 1.65),
                          children: [
                            TextSpan(text: context.l10n.termsPrefix),
                            TextSpan(
                              text: context.l10n.termsLink,
                              style: linkStyle,
                              recognizer: _termsTap,
                            ),
                            TextSpan(text: context.l10n.termsAnd),
                            TextSpan(
                              text: context.l10n.privacyLink,
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
                style: context.text.micro.copyWith(
                  color: context.colors.danger,
                ),
              ),
            ],
            if (_formError != null) ...[
              const SizedBox(height: 10),
              Text(
                _formError!,
                style: context.text.caption.copyWith(
                  color: context.colors.danger,
                ),
              ),
            ],
            const SizedBox(height: 20),
            PrimaryButton(
              label: context.l10n.actionCreateAccount,
              authStyle: true,
              loading: _busy,
              onPressed: _submit,
            ),
            GoogleSignInSection(
              session: widget.session,
              termsAccepted: _accepted,
              onTermsMissing: () => setState(
                () => _errors['terms_accepted'] =
                    context.l10n.acceptTermsRequired,
              ),
            ),
            const SizedBox(height: 18),
            AuthFooterPrompt(
              prompt: context.l10n.haveAccount,
              action: context.l10n.actionSignIn,
              onTap: () => context.pushReplacement(Routes.signIn),
            ),
          ],
        ),
      ),
    );
  }
}
