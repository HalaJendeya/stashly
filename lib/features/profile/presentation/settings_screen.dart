import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:stashly/core/result/result.dart';
import 'package:stashly/core/routing/routes.dart';
import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/app_icon.dart';
import 'package:stashly/core/widgets/brand.dart';
import 'package:stashly/core/widgets/buttons.dart';
import 'package:stashly/core/widgets/chips.dart';
import 'package:stashly/core/widgets/fields.dart';
import 'package:stashly/core/widgets/headers.dart';
import 'package:stashly/core/widgets/overlays.dart';
import 'package:stashly/core/widgets/state_views.dart';
import 'package:stashly/features/auth/domain/auth.dart';
import 'package:stashly/features/profile/domain/profile.dart';

/// Settings (Figma 1:4451): account, appearance, language, data & privacy,
/// about, sign-out.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.user,
    required this.auth,
    required this.profile,
    required this.appVersion,
    required this.termsUrl,
    required this.privacyUrl,
    required this.onSignOut,
    required this.onAccountDeleted,
    required this.confirmWithGoogle,
  });

  final User? user;
  final AuthRepository auth;
  final ProfileRepository profile;
  final String appVersion;
  final String? termsUrl;
  final String? privacyUrl;
  final Future<void> Function({bool allDevices}) onSignOut;
  final Future<void> Function() onAccountDeleted;

  /// Fresh Google ID token for Google-only accounts (`Ok(null)` if dismissed).
  final Future<Result<String?>> Function() confirmWithGoogle;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _exporting = false;

  Future<void> _openUrl(String? url) async {
    final uri = url == null ? null : Uri.tryParse(url);
    final opened =
        uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      showStashlySnack(context, 'This document isn’t available yet.');
    }
  }

  /// `GET /me/export` → temporary JSON file → system share sheet, so the user
  /// chooses where to keep it. The temporary copy is removed afterwards.
  Future<void> _export() async {
    setState(() => _exporting = true);
    final result = await widget.profile.exportData();
    if (!mounted) return;
    switch (result) {
      case Ok(:final value):
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/${value.filename}');
        await file.writeAsBytes(value.bytes, flush: true);
        try {
          await SharePlus.instance.share(
            ShareParams(
              files: [XFile(file.path, mimeType: 'application/json')],
              subject: 'My Stashly data export',
            ),
          );
        } finally {
          if (await file.exists()) await file.delete();
        }
      case Err(:final failure):
        showStashlySnack(context, failure.userMessage, error: true);
    }
    if (mounted) setState(() => _exporting = false);
  }

  Future<void> _deleteAccount() async {
    final user = widget.user;
    final deleted = await showStashlyDialog<bool>(
      context,
      builder: (context) => _DeleteAccountDialog(
        auth: widget.auth,
        // Google-only accounts confirm with a fresh Google ID token instead.
        confirmWithGoogle: user != null && !user.passwordSet
            ? widget.confirmWithGoogle
            : null,
      ),
    );
    if (deleted == true) await widget.onAccountDeleted();
  }

  Future<void> _signOut() async {
    final choice = await showStashlyDialog<bool>(
      context,
      builder: (context) => DialogCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Sign out?', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 9),
            Text(
              'You can sign out of this device only, or every device signed in to your account.',
              style: AppTextStyles.caption.copyWith(height: 1.65),
            ),
            const SizedBox(height: 20),
            SecondaryButton(
              label: 'Sign out of this device',
              color: AppColors.danger,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(height: 8),
            SecondaryButton(
              label: 'Sign out everywhere',
              color: AppColors.danger,
              background: AppColors.dangerTint,
              bordered: false,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            TextActionButton(
              label: 'Cancel',
              minHeight: 44,
              style: AppTextStyles.body,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
    if (choice != null) await widget.onSignOut(allDevices: choice);
  }

  void _about() {
    showStashlyDialog<void>(
      context,
      builder: (context) => DialogCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BrandMark(size: 48, large: true),
            const SizedBox(height: 16),
            Text('Stashly', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 4),
            Text('Everything Worth Keeping', style: AppTextStyles.caption),
            const SizedBox(height: 12),
            Text(
              'A personal wallet for links worth keeping. Stashly saves the link and '
              'its details—never a copy of the content.',
              style: AppTextStyles.caption.copyWith(height: 1.65),
            ),
            const SizedBox(height: 16),
            SecondaryButton(
              label: 'Close',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return Scaffold(
      body: StashlyBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
            children: [
              const BackTitleHeader(eyebrow: 'YOUR STASHLY', title: 'Settings'),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.36),
                ),
                child: Row(
                  children: [
                    InitialsAvatar(
                      name: user?.displayName ?? '',
                      size: 42,
                      radius: 14,
                      fontSize: 13,
                      gradient: false,
                      singleLetter: true,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? '—',
                            style: AppTextStyles.rowTitle,
                          ),
                          const SizedBox(height: 4),
                          Text(user?.email ?? '', style: AppTextStyles.tiny),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _Group(
                label: 'ACCOUNT',
                rows: [
                  _Row(
                    icon: AppIcons.userGold,
                    title: 'Edit profile',
                    subtitle: 'Display name',
                    onTap: () => context.push(Routes.editProfile),
                  ),
                  _Row(
                    icon: AppIcons.key,
                    title: 'Change password',
                    subtitle: user?.passwordSet ?? true
                        ? 'Confirm your current password to set a new one'
                        : 'Use “Forgot password” to set a password',
                    onTap: user?.passwordSet ?? true
                        ? () => context.push(Routes.changePassword)
                        : null,
                  ),
                ],
              ),
              const _Group(
                label: 'APPEARANCE',
                rows: [
                  _Row(
                    icon: AppIcons.moon,
                    title: 'Dark theme',
                    subtitle: 'Stashly’s current brand experience',
                    badge: GoldBadge('Active', fontSize: 7),
                  ),
                ],
              ),
              const _Group(
                label: 'LANGUAGE',
                rows: [
                  _Row(
                    icon: AppIcons.languages,
                    title: 'English',
                    subtitle: 'Current interface language',
                    badge: GoldBadge('Current', fontSize: 7),
                  ),
                  _Row(
                    icon: AppIcons.languages,
                    title: 'Arabic',
                    subtitle:
                        'Arabic content works today; the Arabic interface is coming later',
                    badge: GoldBadge('Future', fontSize: 7, muted: true),
                  ),
                ],
              ),
              _Group(
                label: 'DATA & PRIVACY',
                rows: [
                  _Row(
                    icon: AppIcons.shieldGold,
                    title: 'Privacy policy',
                    subtitle: 'How Stashly handles your data',
                    onTap: () => _openUrl(widget.privacyUrl),
                  ),
                  _Row(
                    icon: AppIcons.fileText,
                    title: 'Terms of use',
                    subtitle: 'The agreement for using Stashly',
                    onTap: () => _openUrl(widget.termsUrl),
                  ),
                  _Row(
                    icon: AppIcons.download,
                    title: 'Export my data',
                    subtitle: _exporting
                        ? 'Preparing your file…'
                        : 'Download everything as a JSON file',
                    onTap: _exporting ? null : _export,
                  ),
                  _Row(
                    icon: AppIcons.trash18Red,
                    title: 'Delete account',
                    subtitle:
                        'Permanently removes your account and saved items',
                    danger: true,
                    onTap: _deleteAccount,
                  ),
                ],
              ),
              _Group(
                label: 'ABOUT',
                rows: [
                  _Row(
                    icon: AppIcons.info,
                    title: 'About Stashly',
                    subtitle: 'Everything Worth Keeping',
                    onTap: _about,
                  ),
                  _Row(
                    icon: AppIcons.info,
                    title: 'App version',
                    subtitle: 'Version ${widget.appVersion}',
                    badge: const GoldBadge('Build', fontSize: 7),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SecondaryButton(
                label: 'Sign out',
                icon: AppIcons.logout,
                color: AppColors.danger,
                onPressed: _signOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.label, required this.rows});

  final String label;
  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              label,
              style: AppTextStyles.tiny.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      border: i == rows.length - 1
                          ? null
                          : const Border(
                              bottom: BorderSide(
                                color: AppColors.divider,
                                width: 1.36,
                              ),
                            ),
                    ),
                    child: rows[i],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.badge,
    this.danger = false,
  });

  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? badge;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final accent = danger ? AppColors.danger : AppColors.gold;
    return Semantics(
      button: onTap != null,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 62),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: danger ? AppColors.dangerTint : AppColors.goldTint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: AppIcon(icon, size: 18, color: accent),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ExcludeSemantics(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.micro.copyWith(
                              fontWeight: FontWeight.w700,
                              color: danger
                                  ? AppColors.danger
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: AppTextStyles.tiny.copyWith(
                              fontSize: 7,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  badge ??
                      (onTap == null
                          ? const SizedBox.shrink()
                          : const AppIcon(
                              AppIcons.chevronRightMuted,
                              size: 17,
                              color: AppColors.textMuted,
                            )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Confirmation for `DELETE /me`: the password, or for Google-only accounts
/// a fresh Google ID token.
class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({required this.auth, this.confirmWithGoogle});

  final AuthRepository auth;
  final Future<Result<String?>> Function()? confirmWithGoogle;

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    final confirmWithGoogle = widget.confirmWithGoogle;
    if (confirmWithGoogle == null && _password.text.isEmpty) {
      setState(() => _error = 'Enter your password to confirm.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final Result<void> result;
    if (confirmWithGoogle != null) {
      switch (await confirmWithGoogle()) {
        case Ok(value: null):
          if (mounted) setState(() => _busy = false);
          return;
        case Ok(:final value?):
          result = await widget.auth.deleteAccount(googleIdToken: value);
        case Err(:final failure):
          result = Err(failure);
      }
    } else {
      result = await widget.auth.deleteAccount(password: _password.text);
    }
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case Ok():
        Navigator.of(context).pop(true);
      case Err(:final failure):
        setState(
          () => _error =
              failure.fieldError('password') ??
              failure.fieldError('id_token') ??
              failure.userMessage,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogCard(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0x17FF7575),
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: const AppIcon(
                  AppIcons.trash22,
                  size: 22,
                  color: AppColors.danger,
                ),
              ),
            ),
            const SizedBox(height: 17),
            Text('Delete your account?', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 9),
            Text(
              'This permanently deletes your account, saved links, collections and tags. '
              'It can’t be undone. Export your data first if you want a copy.',
              style: AppTextStyles.caption.copyWith(height: 1.65),
            ),
            const SizedBox(height: 16),
            if (widget.confirmWithGoogle != null) ...[
              Text(
                'You’ll confirm with your Google account.',
                style: AppTextStyles.caption,
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              ],
            ] else
              StashlyTextField(
                controller: _password,
                hint: 'Your password',
                icon: AppIcons.lock,
                password: true,
                errorText: _error,
                onSubmitted: (_) => _delete(),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Keep account',
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: SecondaryButton(
                    label: 'Delete',
                    color: AppColors.danger,
                    background: AppColors.dangerTint,
                    bordered: false,
                    loading: _busy,
                    onPressed: _delete,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
