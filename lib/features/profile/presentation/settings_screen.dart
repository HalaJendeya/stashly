import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:stashly/core/l10n/l10n.dart';
import 'package:stashly/core/preferences/display_preferences.dart';
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
    required this.display,
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

  /// Theme and language choices.
  final DisplayPreferences display;

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
      showStashlySnack(context, context.l10n.documentUnavailable);
    }
  }

  /// `GET /me/export` → temporary JSON file → system share sheet, so the user
  /// chooses where to keep it. The temporary copy is removed afterwards.
  Future<void> _export() async {
    final subject = context.l10n.exportSubject;
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
              subject: subject,
            ),
          );
        } finally {
          if (await file.exists()) await file.delete();
        }
      case Err(:final failure):
        showStashlySnack(context, failure.describe(context.l10n), error: true);
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
            Text(context.l10n.signOutTitle, style: context.text.sectionTitle),
            const SizedBox(height: 9),
            Text(
              context.l10n.signOutBody,
              style: context.text.caption.copyWith(height: 1.65),
            ),
            const SizedBox(height: 20),
            SecondaryButton(
              label: context.l10n.signOutThisDevice,
              color: context.colors.danger,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(height: 8),
            SecondaryButton(
              label: context.l10n.signOutEverywhere,
              color: context.colors.danger,
              background: context.colors.dangerTint,
              bordered: false,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            TextActionButton(
              label: context.l10n.actionCancel,
              minHeight: 44,
              style: context.text.body,
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
            Text('Stashly', style: context.text.sectionTitle),
            const SizedBox(height: 4),
            Text(context.l10n.tagline, style: context.text.caption),
            const SizedBox(height: 12),
            Text(
              context.l10n.aboutBody,
              style: context.text.caption.copyWith(height: 1.65),
            ),
            const SizedBox(height: 16),
            SecondaryButton(
              label: context.l10n.actionClose,
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
              BackTitleHeader(
                eyebrow: context.l10n.profileEyebrow,
                title: context.l10n.settings,
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: context.colors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.colors.border, width: 1.36),
                ),
                child: Row(
                  children: [
                    InitialsAvatar(
                      name: user?.displayName ?? '',
                      size: 42,
                      radius: 14,
                      fontSize: 15,
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
                            style: context.text.rowTitle,
                          ),
                          const SizedBox(height: 4),
                          Text(user?.email ?? '', style: context.text.tiny),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _Group(
                label: context.l10n.accountEyebrow,
                rows: [
                  _Row(
                    icon: AppIcons.userGold,
                    title: context.l10n.editProfile,
                    subtitle: context.l10n.displayNameLabel,
                    onTap: () => context.push(Routes.editProfile),
                  ),
                  _Row(
                    icon: AppIcons.key,
                    title: context.l10n.changePassword,
                    subtitle: user?.passwordSet ?? true
                        ? context.l10n.changePasswordRowSubtitle
                        : context.l10n.setPasswordViaForgot,
                    onTap: user?.passwordSet ?? true
                        ? () => context.push(Routes.changePassword)
                        : null,
                  ),
                ],
              ),
              ListenableBuilder(
                listenable: widget.display,
                builder: (context, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Group(
                      label: context.l10n.appearanceGroup,
                      rows: [
                        for (final (mode, icon, title, subtitle) in [
                          (
                            ThemeMode.dark,
                            AppIcons.moon,
                            context.l10n.themeDark,
                            context.l10n.themeDarkSubtitle,
                          ),
                          (
                            ThemeMode.light,
                            AppIcons.sun,
                            context.l10n.themeLight,
                            context.l10n.themeLightSubtitle,
                          ),
                          (
                            ThemeMode.system,
                            AppIcons.settings18,
                            context.l10n.themeSystem,
                            context.l10n.themeSystemSubtitle,
                          ),
                        ])
                          _Row(
                            icon: icon,
                            title: title,
                            subtitle: subtitle,
                            selected: widget.display.themeMode == mode,
                            onTap: () => widget.display.setThemeMode(mode),
                          ),
                      ],
                    ),
                    _Group(
                      label: context.l10n.languageGroup,
                      rows: [
                        for (final (language, title, subtitle) in [
                          (
                            null,
                            context.l10n.languageDevice,
                            context.l10n.languageDeviceSubtitle,
                          ),
                          (
                            AppLanguage.english,
                            context.l10n.languageEnglish,
                            context.l10n.languageEnglishSubtitle,
                          ),
                          (
                            AppLanguage.arabic,
                            context.l10n.languageArabic,
                            context.l10n.languageArabicSubtitle,
                          ),
                        ])
                          _Row(
                            icon: AppIcons.languages,
                            title: title,
                            subtitle: subtitle,
                            selected: widget.display.language == language,
                            onTap: () => widget.display.setLanguage(language),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              _Group(
                label: context.l10n.dataGroup,
                rows: [
                  _Row(
                    icon: AppIcons.shieldGold,
                    title: context.l10n.privacyPolicy,
                    subtitle: context.l10n.privacySubtitle,
                    onTap: () => _openUrl(widget.privacyUrl),
                  ),
                  _Row(
                    icon: AppIcons.fileText,
                    title: context.l10n.termsOfUse,
                    subtitle: context.l10n.termsSubtitle,
                    onTap: () => _openUrl(widget.termsUrl),
                  ),
                  _Row(
                    icon: AppIcons.download,
                    title: context.l10n.exportData,
                    subtitle: _exporting
                        ? context.l10n.exportPreparing
                        : context.l10n.exportSubtitle,
                    onTap: _exporting ? null : _export,
                  ),
                  _Row(
                    icon: AppIcons.trash18Red,
                    title: context.l10n.deleteAccount,
                    subtitle: context.l10n.deleteAccountSubtitle,
                    danger: true,
                    onTap: _deleteAccount,
                  ),
                ],
              ),
              _Group(
                label: context.l10n.aboutGroup,
                rows: [
                  _Row(
                    icon: AppIcons.info,
                    title: context.l10n.aboutStashly,
                    subtitle: context.l10n.tagline,
                    onTap: _about,
                  ),
                  _Row(
                    icon: AppIcons.info,
                    title: context.l10n.appVersion,
                    subtitle: context.l10n.versionValue(widget.appVersion),
                    badge: GoldBadge(context.l10n.buildBadge, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SecondaryButton(
                label: context.l10n.actionSignOut,
                icon: AppIcons.logout,
                color: context.colors.danger,
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
              style: context.text.tiny.copyWith(
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
                      color: context.colors.card,
                      border: i == rows.length - 1
                          ? null
                          : Border(
                              bottom: BorderSide(
                                color: context.colors.divider,
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
    this.selected,
  });

  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? badge;
  final bool danger;

  /// Set for options in a one-of-many group (theme, language): the chosen
  /// row shows a badge instead of a chevron.
  final bool? selected;

  @override
  Widget build(BuildContext context) {
    final accent = danger ? context.colors.danger : context.colors.gold;
    final selected = this.selected;
    return Semantics(
      button: onTap != null,
      label: title,
      selected: selected,
      inMutuallyExclusiveGroup: selected != null,
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
                      color: danger
                          ? context.colors.dangerTint
                          : context.colors.goldTint,
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
                            style: context.text.micro.copyWith(
                              fontWeight: FontWeight.w700,
                              color: danger
                                  ? context.colors.danger
                                  : context.colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: context.text.tiny.copyWith(
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  badge ??
                      (selected != null
                          ? (selected
                                ? GoldBadge(context.l10n.selected, fontSize: 11)
                                : const SizedBox.shrink())
                          : onTap == null
                          ? const SizedBox.shrink()
                          : AppIcon(
                              AppIcons.chevronRightMuted,
                              size: 17,
                              color: context.colors.textMuted,
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
      setState(() => _error = context.l10n.passwordConfirmRequired);
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
              failure.describe(context.l10n),
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
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.colors.dangerTint,
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: AppIcon(
                  AppIcons.trash22,
                  size: 22,
                  color: context.colors.danger,
                ),
              ),
            ),
            const SizedBox(height: 17),
            Text(
              context.l10n.deleteAccountTitle,
              style: context.text.sectionTitle,
            ),
            const SizedBox(height: 9),
            Text(
              context.l10n.deleteAccountBody,
              style: context.text.caption.copyWith(height: 1.65),
            ),
            const SizedBox(height: 16),
            if (widget.confirmWithGoogle != null) ...[
              Text(
                context.l10n.confirmWithGoogleNotice,
                style: context.text.caption,
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: context.text.caption.copyWith(
                    color: context.colors.danger,
                  ),
                ),
              ],
            ] else
              StashlyTextField(
                controller: _password,
                hint: context.l10n.yourPasswordHint,
                icon: AppIcons.lock,
                password: true,
                errorText: _error,
                onSubmitted: (_) => _delete(),
              ),
            const SizedBox(height: 20),
            DialogActions(
              cancel: SecondaryButton(
                label: context.l10n.keepAccount,
                onPressed: () => Navigator.of(context).pop(false),
              ),
              confirm: SecondaryButton(
                label: context.l10n.actionDelete,
                color: context.colors.danger,
                background: context.colors.dangerTint,
                bordered: false,
                loading: _busy,
                onPressed: _delete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
