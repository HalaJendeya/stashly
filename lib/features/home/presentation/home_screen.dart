import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:stashly/core/layout/app_viewport.dart';
import 'package:stashly/core/format/date_labels.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/core/routing/routes.dart';
import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/app_icon.dart';
import 'package:stashly/core/widgets/brand.dart';
import 'package:stashly/core/widgets/buttons.dart';
import 'package:stashly/core/widgets/chips.dart';
import 'package:stashly/core/widgets/headers.dart';
import 'package:stashly/core/widgets/saved_card.dart';
import 'package:stashly/core/widgets/saved_card_actions.dart';
import 'package:stashly/core/widgets/state_views.dart';
import 'package:stashly/features/collections/domain/collection.dart';
import 'package:stashly/features/home/presentation/home_view_model.dart';
import 'package:stashly/features/links/domain/link.dart';

/// Home tab (Figma 1:1113).
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.viewModel,
    required this.displayName,
    required this.onSaveLink,
  });

  final HomeViewModel viewModel;

  /// Fallback name from the session while Home loads.
  final String displayName;
  final VoidCallback onSaveLink;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeViewModel get _vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _vm.load();
  }

  Future<void> _onAction(Link link, SavedCardAction action) =>
      handleSavedCardAction(
        context,
        action,
        title: link.displayTitle,
        url: link.originalUrl,
        onOpen: () => context.push(Routes.link(link.id)),
        onDelete: () => _vm.delete(link),
      );

  Future<void> _toggleFavorite(Link link) async {
    final result = await _vm.toggleFavorite(link);
    if (!mounted) return;
    if (result case Err(:final failure)) {
      showStashlySnack(context, failure.userMessage, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) {
          final summary = _vm.summary;
          final name = (summary?.displayName.isNotEmpty ?? false)
              ? summary!.displayName
              : widget.displayName;
          return RefreshIndicator(
            onRefresh: _vm.load,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 118),
              children: [
                BrandTopBar(onLibrary: () => context.push(Routes.library)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Greeting(
                        name: name,
                        onProfile: () => context.go(Routes.profile),
                      ),
                      const SizedBox(height: 22),
                      _SearchEntry(
                        onSearch: () => context.go(Routes.search),
                        onFilters: () =>
                            context.go('${Routes.search}?filters=1'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 194,
                            child: _SaveLinkButton(onTap: widget.onSaveLink),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 175,
                            child: _FavoritesTile(
                              count: summary?.favoritesCount,
                              onTap: () => context.push(Routes.favorites),
                            ),
                          ),
                        ],
                      ),
                      ..._body(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _body() {
    final summary = _vm.summary;
    if (_vm.loading) return const [LoadingView(padding: EdgeInsets.all(48))];
    if (summary == null) {
      return [
        const SizedBox(height: 27),
        FailureView(failure: _vm.failure!, onRetry: _vm.load),
      ];
    }
    return [
      if (summary.quickAccess.isNotEmpty) ...[
        const SizedBox(height: 27),
        SectionHeader(
          eyebrow: 'QUICK ACCESS',
          title: 'Collections',
          actionLabel: 'Browse all',
          onAction: () => context.go(Routes.collections),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: context.textScaled(67),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: summary.quickAccess.length,
            separatorBuilder: (_, _) => const SizedBox(width: 9),
            itemBuilder: (context, index) {
              final collection = summary.quickAccess[index];
              return SizedBox(
                width: context.textScaled(132),
                child: _QuickAccessTile(
                  collection: collection,
                  index: index,
                  onTap: () => context.push(Routes.collection(collection.id)),
                ),
              );
            },
          ),
        ),
      ],
      const SizedBox(height: 27),
      SectionHeader(
        eyebrow: 'YOUR SPACE',
        title: 'Recently saved',
        actionLabel: 'View all',
        onAction: () => context.push(Routes.library),
      ),
      SizedBox(
        height: context.textScaled(69),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(top: 16, bottom: 15),
          children: [
            PillChip(
              label: 'All',
              selected: _vm.type == null,
              onTap: () => _vm.selectType(null),
            ),
            for (final type in ContentType.values) ...[
              const SizedBox(width: 8),
              PillChip(
                label: type.label,
                selected: _vm.type == type,
                onTap: () => _vm.selectType(type),
              ),
            ],
            const SizedBox(width: 8),
            Semantics(
              button: true,
              label: 'More filters',
              child: Material(
                color: AppColors.surface,
                shape: const StadiumBorder(
                  side: BorderSide(color: AppColors.border, width: 1.36),
                ),
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: () => context.go('${Routes.search}?filters=1'),
                  child: const SizedBox(
                    width: 40,
                    height: 38,
                    child: Center(
                      child: AppIcon(
                        AppIcons.chipSliders,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ..._recent(summary.linksCount),
    ];
  }

  List<Widget> _recent(int totalLinks) {
    if (_vm.type != null && _vm.typedLoading) {
      return const [LoadingView()];
    }
    if (_vm.type != null && _vm.typedFailure != null) {
      return [
        FailureView(
          failure: _vm.typedFailure!,
          onRetry: () => _vm.selectType(_vm.type),
        ),
      ];
    }
    final links = _vm.recentLinks;
    if (links.isEmpty) {
      return [
        MessageCard(
          icon: AppIcons.bookmark,
          title: totalLinks == 0
              ? 'Nothing saved yet'
              : 'No ${_vm.type?.label.toLowerCase()} yet',
          message: totalLinks == 0
              ? 'Share a link from any app, or tap Save Link to add one.'
              : 'Items of this type will show up here.',
        ),
      ];
    }
    return [
      for (final link in links) ...[
        SavedCard(
          data: _cardData(link),
          onOpen: () => context.push(Routes.link(link.id)),
          onToggleFavorite: () => _toggleFavorite(link),
          onAction: (action) => _onAction(link, action),
        ),
        const SizedBox(height: 14),
      ],
    ];
  }
}

SavedCardData _cardData(Link link) => SavedCardData.fromApiFields(
  id: link.id,
  title: link.displayTitle,
  sourceDomain: link.sourceDomain,
  originalUrl: link.originalUrl,
  previewImageUrl: link.metadata.previewImageUrl,
  isFavorite: link.isFavorite,
  createdAt: link.createdAt,
  contentType: link.contentType.apiValue,
  contentTypeLabel: link.contentType.label,
  metadataStatus: link.metadata.status.apiValue,
  collectionLabel: link.collectionLabel,
);

class _Greeting extends StatelessWidget {
  const _Greeting({required this.name, required this.onProfile});

  final String name;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final first = name.trim().split(RegExp(r'\s+')).first;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TitleBlock(
              eyebrow: DateLabels.eyebrowDate(now),
              title: first.isEmpty
                  ? DateLabels.greeting(now)
                  : '${DateLabels.greeting(now)}, $first',
              subtitle: 'Everything worth keeping, right where you left it.',
              subtitleStyle: AppTextStyles.subtitle,
            ),
          ),
        ),
        const SizedBox(width: 12),
        InitialsAvatar(name: name, onTap: onProfile),
      ],
    );
  }
}

class _SearchEntry extends StatelessWidget {
  const _SearchEntry({required this.onSearch, required this.onFilters});

  final VoidCallback onSearch;
  final VoidCallback onFilters;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 1.36),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onSearch,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            children: [
              const SizedBox(width: 14),
              const AppIcon(
                AppIcons.search,
                size: 19,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Semantics(
                  button: true,
                  label: 'Search',
                  child: Text(
                    'Search titles, sources, collections…',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              IconTapButton(
                icon: AppIcons.sliders,
                iconSize: 17,
                size: 44,
                color: AppColors.textMuted,
                semanticLabel: 'Search filters',
                onPressed: onFilters,
              ),
              const SizedBox(width: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaveLinkButton extends StatelessWidget {
  const _SaveLinkButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Material(
        color: AppColors.gold,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 58),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppIcon(AppIcons.plus, size: 20, color: AppColors.onGold),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    'Save Link',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.button,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoritesTile extends StatelessWidget {
  const _FavoritesTile({required this.count, required this.onTap});

  final int? count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Favorites, ${count ?? 0} saved',
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
            constraints: const BoxConstraints(minHeight: 58),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const AppIcon(
                    AppIcons.heartGold,
                    size: 19,
                    color: AppColors.gold,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: ExcludeSemantics(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Favorites',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.rowTitle,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            count == null ? '—' : '$count saved',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.tiny,
                          ),
                        ],
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

/// Quick-access collection tile (icon, name, item count).
class _QuickAccessTile extends StatelessWidget {
  const _QuickAccessTile({
    required this.collection,
    required this.index,
    required this.onTap,
  });

  final Collection collection;
  final int index;
  final VoidCallback onTap;

  // The API has no per-collection icon; cycle the design's glyphs by position.
  static const _icons = [
    AppIcons.collSparkles,
    AppIcons.collBook,
    AppIcons.collCompass,
  ];

  @override
  Widget build(BuildContext context) {
    final icon = _icons[index % _icons.length];
    return Semantics(
      button: true,
      label: '${collection.name}, ${collection.countLabel}',
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1.36),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.goldTint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: AppIcon(icon, size: 17, color: AppColors.gold),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ExcludeSemantics(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          collection.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.rowTitle.copyWith(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          collection.countLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.tiny.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
