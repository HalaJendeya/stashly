import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:stashly/core/l10n/l10n.dart';
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
      showStashlySnack(context, failure.describe(context.l10n), error: true);
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
          eyebrow: context.l10n.quickAccess,
          title: context.l10n.navCollections,
          actionLabel: context.l10n.browseAll,
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
        eyebrow: context.l10n.yourSpace,
        title: context.l10n.recentlySaved,
        actionLabel: context.l10n.viewAll,
        onAction: () => context.push(Routes.library),
      ),
      SizedBox(
        height: context.textScaled(69),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(top: 16, bottom: 15),
          children: [
            PillChip(
              label: context.l10n.filterAll,
              selected: _vm.type == null,
              onTap: () => _vm.selectType(null),
            ),
            for (final type in ContentType.values) ...[
              const SizedBox(width: 8),
              PillChip(
                label: context.l10n.contentType(type.apiValue),
                selected: _vm.type == type,
                onTap: () => _vm.selectType(type),
              ),
            ],
            const SizedBox(width: 8),
            Semantics(
              button: true,
              label: context.l10n.moreFilters,
              child: Material(
                color: context.colors.surface,
                shape: StadiumBorder(
                  side: BorderSide(color: context.colors.border, width: 1.36),
                ),
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: () => context.go('${Routes.search}?filters=1'),
                  child: SizedBox(
                    width: 40,
                    height: 38,
                    child: Center(
                      child: AppIcon(
                        AppIcons.chipSliders,
                        size: 16,
                        color: context.colors.textSecondary,
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
              ? context.l10n.nothingSavedYet
              : context.l10n.noItemsOfType(_vm.type!.apiValue),
          message: totalLinks == 0
              ? context.l10n.homeEmptyBody
              : context.l10n.homeEmptyTypeBody,
        ),
      ];
    }
    return [
      for (final link in links) ...[
        SavedCard(
          data: _cardData(link, context.l10n),
          onOpen: () => context.push(Routes.link(link.id)),
          onToggleFavorite: () => _toggleFavorite(link),
          onAction: (action) => _onAction(link, action),
        ),
        const SizedBox(height: 14),
      ],
    ];
  }
}

SavedCardData _cardData(Link link, AppLocalizations l10n) =>
    SavedCardData.fromApiFields(
      id: link.id,
      title: link.displayTitle,
      sourceDomain: link.sourceDomain,
      originalUrl: link.originalUrl,
      previewImageUrl: link.metadata.previewImageUrl,
      isFavorite: link.isFavorite,
      createdAt: link.createdAt,
      contentType: link.contentType.apiValue,
      metadataStatus: link.metadata.status.apiValue,
      l10n: l10n,
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
              eyebrow: DateLabels(context.l10n).eyebrowDate(now),
              title: DateLabels(context.l10n).greeting(now, name: first),
              subtitle: context.l10n.homeSubtitle,
              subtitleStyle: context.text.subtitle,
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
      color: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.colors.border, width: 1.36),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onSearch,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            children: [
              const SizedBox(width: 14),
              AppIcon(
                AppIcons.search,
                size: 19,
                color: context.colors.textMuted,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Semantics(
                  button: true,
                  label: context.l10n.navSearch,
                  child: Text(
                    context.l10n.homeSearchHint,
                    style: context.text.bodySmall.copyWith(
                      color: context.colors.textMuted,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              IconTapButton(
                icon: AppIcons.sliders,
                iconSize: 17,
                size: 44,
                color: context.colors.textMuted,
                semanticLabel: context.l10n.searchFilters,
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
        color: context.colors.goldFill,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 58),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcon(AppIcons.plus, size: 20, color: context.colors.onGold),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    context.l10n.saveLink,
                    textAlign: TextAlign.center,
                    style: context.text.button,
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
      label: context.l10n.favoritesTileLabel(
        context.l10n.savedCount(count ?? 0),
      ),
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
            constraints: const BoxConstraints(minHeight: 58),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  AppIcon(
                    AppIcons.heartGold,
                    size: 19,
                    color: context.colors.gold,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: ExcludeSemantics(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.favorites,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.rowTitle,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            count == null
                                ? '—'
                                : context.l10n.savedCount(count!),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.tiny,
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
      label: context.l10n.cardLabel(
        collection.name,
        context.l10n.itemCount(collection.linksCount),
      ),
      child: Material(
        color: context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: context.colors.border, width: 1.36),
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
                    color: context.colors.goldTint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: AppIcon(icon, size: 17, color: context.colors.gold),
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
                          style: context.text.rowTitle.copyWith(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10n.itemCount(collection.linksCount),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.tiny.copyWith(fontSize: 11),
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
