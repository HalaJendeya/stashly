import 'package:flutter/material.dart';

import 'package:stashly/core/l10n/l10n.dart';
import 'package:stashly/core/routing/navigation.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/widgets/app_icon.dart';
import 'package:stashly/core/widgets/brand.dart';
import 'package:stashly/core/widgets/buttons.dart';
import 'package:stashly/core/widgets/fields.dart';
import 'package:stashly/core/widgets/headers.dart';
import 'package:stashly/core/widgets/state_views.dart';
import 'package:stashly/features/auth/domain/auth.dart';

/// "Edit profile" (Figma 1:4391) → `PATCH /me`. The e-mail is shown read-only
/// because the API does not support changing it in v1 (DEC-022).
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.user,
    required this.auth,
    required this.onUpdated,
  });

  final User? user;
  final AuthRepository auth;
  final ValueChanged<User> onUpdated;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final _name = TextEditingController(text: widget.user?.displayName);
  late final _email = TextEditingController(text: widget.user?.email);
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty || name.length > 100) {
      setState(() => _error = context.l10n.nameLength);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await widget.auth.updateDisplayName(name);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case Ok(:final value):
        widget.onUpdated(value);
        showStashlySnack(context, context.l10n.profileUpdated);
        context.popOrHome();
      case Err(:final failure):
        setState(
          () => _error =
              failure.fieldError('display_name') ??
              failure.describe(context.l10n),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StashlyBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 30),
            children: [
              BackTitleHeader(
                eyebrow: context.l10n.accountEyebrow,
                title: context.l10n.editProfile,
              ),
              const SizedBox(height: 20),
              Center(
                child: InitialsAvatar(
                  name: _name.text,
                  size: 72,
                  radius: 22,
                  fontSize: 19,
                ),
              ),
              const SizedBox(height: 20),
              StashlyTextField(
                label: context.l10n.displayNameLabel,
                controller: _name,
                icon: AppIcons.user,
                maxLength: 100,
                textCapitalization: TextCapitalization.words,
                errorText: _error,
              ),
              const SizedBox(height: 15),
              StashlyTextField(
                label: context.l10n.emailAddress,
                controller: _email,
                icon: AppIcons.mail,
                readOnly: true,
              ),
              const SizedBox(height: 26),
              InfoBanner(message: context.l10n.emailLocked),
              const SizedBox(height: 18),
              PrimaryButton(
                label: context.l10n.actionSaveChanges,
                icon: AppIcons.save,
                loading: _busy,
                onPressed: _name.text.trim() == widget.user?.displayName
                    ? null
                    : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Change password" (Figma 1:4657) → `PUT /me/password`.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key, required this.auth});

  final AuthRepository auth;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  final Map<String, String?> _errors = {};

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _errors
        ..clear()
        ..['current_password'] = _current.text.isEmpty
            ? context.l10n.currentPasswordRequired
            : null
        ..['password'] = _new.text.length < 8
            ? context.l10n.passwordTooShort
            : _new.text == _current.text
            ? context.l10n.choosePasswordNew
            : null
        ..['password_confirmation'] = _confirm.text != _new.text
            ? context.l10n.passwordsDontMatch
            : null;
    });
    if (_errors.values.any((e) => e != null)) return;

    setState(() => _busy = true);
    final result = await widget.auth.changePassword(
      currentPassword: _current.text,
      newPassword: _new.text,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case Ok():
        showStashlySnack(context, context.l10n.passwordUpdated);
        context.popOrHome();
      case Err(:final failure):
        setState(() {
          _errors['current_password'] = failure.fieldError('current_password');
          _errors['password'] = failure.fieldError('password');
        });
        if (_errors.values.every((e) => e == null)) {
          showStashlySnack(
            context,
            failure.describe(context.l10n),
            error: true,
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StashlyBackground(
        secondGlow: true,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
            children: [
              AuthHeader(
                title: context.l10n.changePassword,
                subtitle: context.l10n.changePasswordSubtitle,
              ),
              const SizedBox(height: 24),
              StashlyTextField(
                label: context.l10n.currentPassword,
                controller: _current,
                hint: context.l10n.currentPasswordHint,
                icon: AppIcons.lock,
                password: true,
                autofillHints: const [AutofillHints.password],
                errorText: _errors['current_password'],
              ),
              const SizedBox(height: 16),
              StashlyTextField(
                label: context.l10n.newPassword,
                controller: _new,
                hint: context.l10n.newPasswordHint,
                icon: AppIcons.lock,
                password: true,
                maxLength: 128,
                autofillHints: const [AutofillHints.newPassword],
                errorText: _errors['password'],
              ),
              const SizedBox(height: 16),
              StashlyTextField(
                label: context.l10n.confirmNewPassword,
                controller: _confirm,
                hint: context.l10n.confirmNewPasswordHint,
                icon: AppIcons.lock,
                password: true,
                maxLength: 128,
                errorText: _errors['password_confirmation'],
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: context.l10n.updatePassword,
                icon: AppIcons.keyDark,
                loading: _busy,
                onPressed: _submit,
              ),
              const SizedBox(height: 18),
              InfoBanner(
                icon: AppIcons.shield,
                message: context.l10n.otherDevicesNotice,
                iconColor: context.colors.gold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
