import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:stashly/core/l10n/l10n.dart';
import 'package:stashly/core/events/data_changes.dart';
import 'package:stashly/core/format/date_labels.dart';
import 'package:stashly/core/result/app_failure.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/core/routing/routes.dart';
import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/app_icon.dart';
import 'package:stashly/core/widgets/brand.dart';
import 'package:stashly/core/widgets/buttons.dart';
import 'package:stashly/core/widgets/headers.dart';
import 'package:stashly/core/widgets/state_views.dart';
import 'package:stashly/features/auth/domain/auth.dart';
import 'package:stashly/features/profile/domain/profile.dart';

/// Profile tab (Figma 1:4257): account card, counts and account shortcuts.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.user,
    required this.profile,
    required this.changes,
    required this.onRefreshUser,
    required this.onSignOut,
  });

  final User? user;
  final ProfileRepository profile;
  final DataChanges changes;
  final Future<void> Function() onRefreshUser;
  final Future<void> Function() onSignOut;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AccountStats? _stats;
  AppFailure? _failure;
  bool _signingOut = false;
  late int _seen = _versions();

  int _versions() =>
      widget.changes.version(DataTopic.links) +
      widget.changes.version(DataTopic.collections) +
      widget.changes.version(DataTopic.account);

  @override
  void initState() {
    super.initState();
    widget.changes.addListener(_onChanged);
    _load();
  }

  @override
  void dispose() {
    widget.changes.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    final versions = _versions();
    if (versions != _seen) {
      _seen = versions;
      _load();
    }
  }

  Future<void> _load() async {
    final results = await Future.wait([widget.profile.stats(), _refreshUser()]);
    if (!mounted) return;
    final stats = results.first as Result<AccountStats>;
    setState(() {
      _stats = stats.valueOrNull ?? _stats;
      _failure = stats.failureOrNull;
    });
  }

  Future<Result<void>> _refreshUser() async {
    await widget.onRefreshUser();
    return const Ok(null);
  }

  Future<void> _signOut() async {
    setState(() => _signingOut = true);
    await widget.onSignOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 118),
          children: [
            BrandTopBar(onLibrary: () => context.push(Routes.library)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 23, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TitleBlock(
                          eyebrow: context.l10n.profileEyebrow,
                          title: context.l10n.navProfile,
                        ),
                      ),
                      IconTapButton(
                        icon: AppIcons.settings20,
                        iconSize: 20,
                        color: context.colors.textSecondary,
                        semanticLabel: context.l10n.settings,
                        onPressed: () => context.push(Routes.settings),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _AccountCard(
                    user: user,
                    onEdit: () => context.push(Routes.editProfile),
                  ),
                  const SizedBox(height: 11),
                  if (_stats == null && _failure != null)
                    FailureView(failure: _failure!, onRetry: _load)
                  else
                    Row(
                      children: [
                        _StatTile(
                          value: _stats?.linksCount,
                          label: context.l10n.totalSaves,
                        ),
                        const SizedBox(width: 9),
                        _StatTile(
                          value: _stats?.collectionsCount,
                          label: context.l10n.navCollections,
                        ),
                        const SizedBox(width: 9),
                        _StatTile(
                          value: _stats?.favoritesCount,
                          label: context.l10n.favorites,
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.colors.goldTint,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0x26D4AF37),
                        width: 1.36,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppIcon(
                          AppIcons.shield18,
                          size: 18,
                          color: context.colors.gold,
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.walletTitle,
                                style: context.text.micro.copyWith(
                                  color: context.colors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                context.l10n.walletBody,
                                style: context.text.tiny.copyWith(
                                  color: context.colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 17),
                  _NavRow(
                    icon: AppIcons.userGold,
                    title: context.l10n.editProfile,
                    subtitle: context.l10n.displayNameLabel,
                    onTap: () => context.push(Routes.editProfile),
                  ),
                  const SizedBox(height: 8),
                  _NavRow(
                    icon: AppIcons.settings18,
                    title: context.l10n.settings,
                    subtitle: context.l10n.settingsRowSubtitle,
                    onTap: () => context.push(Routes.settings),
                  ),
                  const SizedBox(height: 15),
                  SecondaryButton(
                    label: context.l10n.actionSignOut,
                    icon: AppIcons.logout,
                    color: context.colors.danger,
                    loading: _signingOut,
                    onPressed: _signOut,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.user, required this.onEdit});

  final User? user;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final user = this.user;
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.colors.border, width: 1.36),
        gradient: RadialGradient(
          center: Alignment(0.85, -1),
          radius: 1.4,
          colors: [Color(0x1AD4AF37), context.colors.card],
          stops: [0, 0.35],
        ),
      ),
      child: Row(
        children: [
          InitialsAvatar(
            name: user?.displayName ?? '',
            size: 64,
            radius: 20,
            fontSize: 16,
            gradient: false,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.rowTitle.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.micro.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                if (user != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.memberSince(
                      DateLabels(context.l10n).monthYear(user.createdAt),
                    ),
                    style: context.text.tiny.copyWith(fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 13),
          Semantics(
            button: true,
            label: context.l10n.editProfile,
            child: Material(
              color: context.colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: context.colors.border, width: 1.36),
              ),
              child: InkWell(
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onTap: onEdit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: Column(
                    children: [
                      AppIcon(
                        AppIcons.edit16,
                        size: 16,
                        color: context.colors.textSecondary,
                      ),
                      ExcludeSemantics(
                        child: Text(
                          context.l10n.actionEdit,
                          style: context.text.tiny.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final int? value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        label: context.l10n.statLabel(value ?? 0, label),
        child: ExcludeSemantics(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            decoration: BoxDecoration(
              color: context.colors.cardRaised,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colors.border, width: 1.36),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value == null ? '—' : '$value',
                  style: context.text.sectionTitle.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.goldActive,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(label, style: context.text.micro),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: context.colors.border, width: 1.36),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 61),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              child: Row(
                children: [
                  AppIcon(icon, size: 18, color: context.colors.gold),
                  const SizedBox(width: 19),
                  Expanded(
                    child: ExcludeSemantics(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: context.text.rowTitle),
                          const SizedBox(height: 4),
                          Text(subtitle, style: context.text.tiny),
                        ],
                      ),
                    ),
                  ),
                  AppIcon(
                    AppIcons.chevronRight,
                    size: 17,
                    color: context.colors.gold,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
