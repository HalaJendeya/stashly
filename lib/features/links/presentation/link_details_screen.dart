import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:stashly/core/l10n/l10n.dart';
import 'package:stashly/core/routing/navigation.dart';
import 'package:stashly/core/events/data_changes.dart';
import 'package:stashly/core/format/date_labels.dart';
import 'package:stashly/core/routing/routes.dart';
import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/app_icon.dart';
import 'package:stashly/core/widgets/brand.dart';
import 'package:stashly/core/widgets/buttons.dart';
import 'package:stashly/core/widgets/chips.dart';
import 'package:stashly/core/widgets/headers.dart';
import 'package:stashly/core/widgets/preview_image.dart';
import 'package:stashly/core/widgets/saved_card.dart';
import 'package:stashly/core/widgets/saved_card_actions.dart';
import 'package:stashly/core/widgets/state_views.dart';
import 'package:stashly/features/collections/domain/collection.dart';
import 'package:stashly/features/links/domain/link.dart';
import 'package:stashly/features/links/domain/links_repository.dart';
import 'package:stashly/features/links/presentation/link_details_view_model.dart';
import 'package:stashly/features/links/presentation/link_presentation.dart';

/// "Saved item" details (Figma 1:2110 / 1:3715).
class LinkDetailsScreen extends StatefulWidget {
  const LinkDetailsScreen({
    super.key,
    required this.linkId,
    required this.links,
    required this.collections,
    required this.tags,
    required this.changes,
  });

  final String linkId;
  final LinksRepository links;
  final CollectionsRepository collections;
  final TagsRepository tags;
  final DataChanges changes;

  @override
  State<LinkDetailsScreen> createState() => _LinkDetailsScreenState();
}

class _LinkDetailsScreenState extends State<LinkDetailsScreen> {
  late final _vm = LinkDetailsViewModel(
    linkId: widget.linkId,
    links: widget.links,
    changes: widget.changes,
  );
  int _seenVersion = 0;

  @override
  void initState() {
    super.initState();
    _seenVersion = widget.changes.version(DataTopic.links);
    widget.changes.addListener(_onDataChanged);
    _vm.load();
  }

  @override
  void dispose() {
    widget.changes.removeListener(_onDataChanged);
    _vm.dispose();
    super.dispose();
  }

  /// Reload after edits made on the Edit screen.
  void _onDataChanged() {
    final version = widget.changes.version(DataTopic.links);
    if (version != _seenVersion && !_vm.busy) {
      _seenVersion = version;
      _vm.load();
    }
  }

  Future<void> _open(Link link) async {
    final uri = Uri.tryParse(link.originalUrl);
    final opened =
        uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      showStashlySnack(context, context.l10n.openFailed, error: true);
    }
  }

  Future<void> _organize(Link link) async {
    final picked = await pickCollections(
      context,
      collections: widget.collections,
      selected: link.collections,
    );
    if (picked == null || !mounted) return;
    final result = await _vm.setCollections([for (final c in picked) c.id]);
    if (mounted && !reportFailure(context, result)) {
      showStashlySnack(context, context.l10n.collectionsUpdated);
    }
  }

  Future<void> _editTags(Link link) async {
    final tags = await editTags(context, tags: widget.tags, current: link.tags);
    if (tags == null || !mounted) return;
    final result = await _vm.setTags(tags);
    if (mounted) reportFailure(context, result);
  }

  Future<void> _delete(Link link) async {
    if (!await confirmDeleteSavedItem(context, link.displayTitle) || !mounted) {
      return;
    }
    final result = await _vm.delete();
    if (!mounted) return;
    if (!reportFailure(context, result)) {
      showStashlySnack(context, context.l10n.itemDeleted);
      context.popOrHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StashlyBackground(
        child: SafeArea(
          bottom: false,
          child: ListenableBuilder(
            listenable: _vm,
            builder: (context, _) {
              final link = _vm.link;
              return Column(
                children: [
                  CaptionTopBar(
                    caption: context.l10n.savedItemTitle,
                    trailing: link == null
                        ? null
                        : IconTapButton(
                            icon: link.isFavorite
                                ? AppIcons.heartHeader
                                : AppIcons.heart17Outline,
                            iconSize: 20,
                            color: link.isFavorite
                                ? context.colors.gold
                                : context.colors.textPrimary,
                            semanticLabel: link.isFavorite
                                ? context.l10n.removeFromFavorites
                                : context.l10n.addToFavorites,
                            onPressed: () async {
                              final result = await _vm.toggleFavorite();
                              if (context.mounted) {
                                reportFailure(context, result);
                              }
                            },
                          ),
                  ),
                  Expanded(child: _body(link)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _body(Link? link) {
    if (_vm.loading) return const LoadingView();
    if (link == null) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [FailureView(failure: _vm.failure!, onRetry: _vm.load)],
      );
    }
    return RefreshIndicator(
      onRefresh: _vm.load,
      child: ListView(
        padding: EdgeInsets.only(
          bottom: 32 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          SizedBox(
            height: 245,
            child: ColoredBox(
              color: context.colors.card,
              child: PreviewImage(
                imageUrl: link.metadata.previewImageUrl,
                domain: link.sourceDomain,
                state: previewStateForMetadataStatus(
                  link.metadata.status.apiValue,
                ),
                placeholderIcon: placeholderIconForContentType(
                  link.contentType.apiValue,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 21, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    GoldBadge(
                      context.l10n.contentType(link.contentType.apiValue),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        link.sourceDomain,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.micro,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Semantics(
                  header: true,
                  child: Text(
                    link.displayTitle,
                    style: context.text.detailTitle,
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: context.l10n.openOriginal,
                  icon: AppIcons.externalDark,
                  onPressed: () => _open(link),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _ActionTile(
                      icon: AppIcons.edit,
                      label: context.l10n.actionEdit,
                      onTap: () => context.push(Routes.editLink(link.id)),
                    ),
                    const SizedBox(width: 8),
                    _ActionTile(
                      icon: AppIcons.copy17,
                      label: context.l10n.copyLinkButton,
                      onTap: () => copySavedItemUrl(context, link.originalUrl),
                    ),
                    const SizedBox(width: 8),
                    _ActionTile(
                      icon: AppIcons.share,
                      label: context.l10n.actionShare,
                      onTap: () => SharePlus.instance.share(
                        ShareParams(
                          uri: Uri.tryParse(link.originalUrl),
                          subject: link.displayTitle,
                        ),
                      ),
                    ),
                  ],
                ),
                _Section(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.descriptionEyebrow,
                        style: _sectionLabel,
                      ),
                      const SizedBox(height: 9),
                      _descriptionFor(link),
                    ],
                  ),
                ),
                _Section(
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: AppIcons.link,
                        label: context.l10n.originalUrl,
                        value: link.originalUrl,
                        ltr: true,
                      ),
                      const SizedBox(height: 17),
                      _InfoRow(
                        icon: AppIcons.calendar,
                        label: context.l10n.savedLabel,
                        value: DateLabels(
                          context.l10n,
                        ).relativeDay(link.createdAt),
                      ),
                      const SizedBox(height: 17),
                      _InfoRow(
                        icon: AppIcons.folder16,
                        label: context.l10n.collectionLabel,
                        value: collectionsLabel(context.l10n, link.collections),
                      ),
                    ],
                  ),
                ),
                _Section(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              context.l10n.tagsEyebrow,
                              style: _sectionLabel,
                            ),
                          ),
                          TextActionButton(
                            label: link.tags.isEmpty
                                ? context.l10n.addTags
                                : context.l10n.editTags,
                            minHeight: 34,
                            style: context.text.tiny.copyWith(
                              color: context.colors.gold,
                            ),
                            onPressed: () => _editTags(link),
                          ),
                        ],
                      ),
                      if (link.tags.isEmpty)
                        Text(context.l10n.noTagsYet, style: context.text.micro)
                      else
                        Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: [
                            for (final tag in link.tags) TagPill('#$tag'),
                          ],
                        ),
                    ],
                  ),
                ),
                if ((link.note ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _NoteCard(note: link.note!),
                ],
                const SizedBox(height: 20),
                SecondaryButton(
                  label: link.isFavorite
                      ? context.l10n.removeFromFavoritesButton
                      : context.l10n.addToFavoritesButton,
                  icon: link.isFavorite
                      ? AppIcons.heart17
                      : AppIcons.heart17Outline,
                  onPressed: () async {
                    final result = await _vm.toggleFavorite();
                    if (mounted) reportFailure(context, result);
                  },
                ),
                const SizedBox(height: 8),
                SecondaryButton(
                  label: context.l10n.organizeIntoCollections,
                  icon: AppIcons.folderPlus,
                  loading: _vm.busy,
                  onPressed: () => _organize(link),
                ),
                const SizedBox(height: 8),
                SecondaryButton(
                  label: context.l10n.deleteSavedItem,
                  icon: AppIcons.trash17,
                  color: context.colors.danger,
                  background: Colors.transparent,
                  bordered: false,
                  onPressed: () => _delete(link),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle get _sectionLabel => context.text.micro.copyWith(
    fontWeight: FontWeight.w700,
    letterSpacing: 0.63,
  );

  Widget _descriptionFor(Link link) {
    final style = context.text.bodySmall;
    final description = link.metadata.description;
    if (description != null && description.trim().isNotEmpty) {
      return Text(description, style: style);
    }
    return switch (link.metadata.status) {
      MetadataStatus.pending => Text(
        context.l10n.fetchingDetails,
        style: style,
      ),
      MetadataStatus.ready => Text(context.l10n.noDescription, style: style),
      MetadataStatus.failed || MetadataStatus.blocked => Row(
        children: [
          Expanded(
            child: Text(
              link.metadata.status == MetadataStatus.blocked
                  ? context.l10n.previewBlocked
                  : context.l10n.previewFailed,
              style: style,
            ),
          ),
          TextActionButton(
            label: context.l10n.refreshPreview,
            minHeight: 34,
            style: context.text.tiny.copyWith(color: context.colors.gold),
            onPressed: () async {
              final result = await _vm.refreshPreview();
              if (mounted) reportFailure(context, result);
            },
          ),
        ],
      ),
    };
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: label,
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
              constraints: const BoxConstraints(minHeight: 64),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppIcon(icon, size: 17, color: context.colors.textSecondary),
                  const SizedBox(height: 6),
                  ExcludeSemantics(
                    child: Text(
                      label,
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
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.colors.divider, width: 1.36),
        ),
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.ltr = false,
  });

  final String icon;
  final String label;
  final String value;

  /// Keeps URLs left-to-right inside Arabic layouts.
  final bool ltr;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppIcon(icon, size: 16, color: context.colors.textMuted),
        const SizedBox(width: 7),
        SizedBox(width: 105, child: Text(label, style: context.text.micro)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textDirection: ltr ? TextDirection.ltr : null,
            textAlign: ltr
                ? (Directionality.of(context) == TextDirection.rtl
                      ? TextAlign.left
                      : TextAlign.right)
                : TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.micro.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.goldTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.goldBorderFaint, width: 1.36),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIcon(AppIcons.note, size: 17, color: context.colors.gold),
              const SizedBox(width: 7),
              Text(
                context.l10n.personalNote,
                style: context.text.micro.copyWith(color: context.colors.gold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(note, style: context.text.bodySmall),
        ],
      ),
    );
  }
}
