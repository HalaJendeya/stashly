import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
      showStashlySnack(context, 'Couldn’t open this link.', error: true);
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
      showStashlySnack(context, 'Collections updated');
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
      showStashlySnack(context, 'Item deleted');
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
                    caption: 'Saved item',
                    trailing: link == null
                        ? null
                        : IconTapButton(
                            icon: link.isFavorite
                                ? AppIcons.heartHeader
                                : AppIcons.heart17Outline,
                            iconSize: 20,
                            color: link.isFavorite
                                ? AppColors.gold
                                : AppColors.textPrimary,
                            semanticLabel: link.isFavorite
                                ? 'Remove from favorites'
                                : 'Add to favorites',
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
              color: AppColors.card,
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
                    GoldBadge(link.contentType.label),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        link.sourceDomain,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.micro,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Semantics(
                  header: true,
                  child: Text(
                    link.displayTitle,
                    style: AppTextStyles.detailTitle,
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Open Original',
                  icon: AppIcons.externalDark,
                  onPressed: () => _open(link),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _ActionTile(
                      icon: AppIcons.edit,
                      label: 'Edit',
                      onTap: () => context.push(Routes.editLink(link.id)),
                    ),
                    const SizedBox(width: 8),
                    _ActionTile(
                      icon: AppIcons.copy17,
                      label: 'Copy Link',
                      onTap: () => copySavedItemUrl(context, link.originalUrl),
                    ),
                    const SizedBox(width: 8),
                    _ActionTile(
                      icon: AppIcons.share,
                      label: 'Share',
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
                      Text('DESCRIPTION', style: _sectionLabel),
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
                        label: 'Original URL',
                        value: link.originalUrl,
                      ),
                      const SizedBox(height: 17),
                      _InfoRow(
                        icon: AppIcons.calendar,
                        label: 'Saved',
                        value: DateLabels.relativeDay(link.createdAt),
                      ),
                      const SizedBox(height: 17),
                      _InfoRow(
                        icon: AppIcons.folder16,
                        label: 'Collection',
                        value: collectionsLabel(link.collections),
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
                          Expanded(child: Text('TAGS', style: _sectionLabel)),
                          TextActionButton(
                            label: link.tags.isEmpty ? 'Add tags' : 'Edit tags',
                            minHeight: 34,
                            style: AppTextStyles.tiny.copyWith(
                              color: AppColors.gold,
                            ),
                            onPressed: () => _editTags(link),
                          ),
                        ],
                      ),
                      if (link.tags.isEmpty)
                        Text('No tags yet.', style: AppTextStyles.micro)
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
                      ? 'Remove from Favorites'
                      : 'Add to Favorites',
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
                  label: 'Organize into Collections',
                  icon: AppIcons.folderPlus,
                  loading: _vm.busy,
                  onPressed: () => _organize(link),
                ),
                const SizedBox(height: 8),
                SecondaryButton(
                  label: 'Delete saved item',
                  icon: AppIcons.trash17,
                  color: AppColors.danger,
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

  TextStyle get _sectionLabel => AppTextStyles.micro.copyWith(
    fontWeight: FontWeight.w700,
    letterSpacing: 0.63,
  );

  Widget _descriptionFor(Link link) {
    final style = AppTextStyles.bodySmall;
    final description = link.metadata.description;
    if (description != null && description.trim().isNotEmpty) {
      return Text(description, style: style);
    }
    return switch (link.metadata.status) {
      MetadataStatus.pending => Text('Fetching details…', style: style),
      MetadataStatus.ready => Text('No description available.', style: style),
      MetadataStatus.failed || MetadataStatus.blocked => Row(
        children: [
          Expanded(
            child: Text(
              link.metadata.status == MetadataStatus.blocked
                  ? 'This page can’t be previewed.'
                  : 'We couldn’t load a preview.',
              style: style,
            ),
          ),
          TextActionButton(
            label: 'Refresh preview',
            minHeight: 34,
            style: AppTextStyles.tiny.copyWith(color: AppColors.gold),
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
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border, width: 1.36),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 64),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppIcon(icon, size: 17, color: AppColors.textSecondary),
                  const SizedBox(height: 6),
                  ExcludeSemantics(
                    child: Text(
                      label,
                      style: AppTextStyles.tiny.copyWith(
                        color: AppColors.textSecondary,
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
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1.36),
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
  });

  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppIcon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 7),
        SizedBox(width: 105, child: Text(label, style: AppTextStyles.micro)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.micro.copyWith(color: AppColors.textSecondary),
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
        color: AppColors.goldTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldBorderFaint, width: 1.36),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIcon(AppIcons.note, size: 17, color: AppColors.gold),
              const SizedBox(width: 7),
              Text(
                'Personal note',
                style: AppTextStyles.micro.copyWith(color: AppColors.gold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(note, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
