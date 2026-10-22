import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:stashly/core/layout/app_viewport.dart';
import 'package:stashly/core/events/data_changes.dart';
import 'package:stashly/core/presentation/paged_controller.dart';
import 'package:stashly/core/result/paging.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/core/routing/routes.dart';
import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/app_icon.dart';
import 'package:stashly/core/widgets/brand.dart';
import 'package:stashly/core/widgets/chips.dart';
import 'package:stashly/core/widgets/headers.dart';
import 'package:stashly/core/widgets/load_more.dart';
import 'package:stashly/core/widgets/saved_card.dart';
import 'package:stashly/core/widgets/saved_card_actions.dart';
import 'package:stashly/core/widgets/state_views.dart';
import 'package:stashly/features/links/domain/link.dart';
import 'package:stashly/features/links/domain/links_repository.dart';
import 'package:stashly/features/links/presentation/link_presentation.dart';

/// "All saved items" (Figma 1:1375 list, 1:1560 grid) over `GET /links`.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({
    super.key,
    required this.links,
    required this.changes,
    this.favoritesOnly = false,
  });

  final LinksRepository links;
  final DataChanges changes;
  final bool favoritesOnly;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late LinkQuery _query = LinkQuery(favoritesOnly: widget.favoritesOnly);
  late final PagedController<Link> _list = PagedController(
    fetch: _fetch,
    idOf: (link) => link.id,
  );
  bool _grid = false;
  late int _seenVersion = widget.changes.version(DataTopic.links);

  @override
  void initState() {
    super.initState();
    widget.changes.addListener(_onDataChanged);
    _list.refresh();
  }

  @override
  void dispose() {
    widget.changes.removeListener(_onDataChanged);
    _list.dispose();
    super.dispose();
  }

  Future<Result<Paged<Link>>> _fetch(String? cursor) =>
      widget.links.list(_query, cursor: cursor);

  void _onDataChanged() {
    final version = widget.changes.version(DataTopic.links);
    if (version != _seenVersion) {
      _seenVersion = version;
      _list.refresh();
    }
  }

  void _setQuery(LinkQuery query) {
    setState(() => _query = query);
    _list.refresh();
  }

  Future<void> _toggleFavorite(Link link) async {
    final result = await _list.replaceOptimistically(
      link.copyWith(isFavorite: !link.isFavorite),
      original: link,
      commit: () => widget.links.update(
        link.id,
        LinkUpdate(isFavorite: !link.isFavorite),
      ),
    );
    if (!mounted) return;
    switch (result) {
      case Ok(:final value):
        // An un-favorited item leaves the Favorites view.
        if (_query.favoritesOnly && !value.isFavorite) _list.remove(value.id);
        _seenVersion = widget.changes.version(DataTopic.links) + 1;
        widget.changes.notify({DataTopic.links, DataTopic.account});
      case Err():
        reportFailure(context, result);
    }
  }

  Future<void> _onAction(Link link, SavedCardAction action) =>
      handleSavedCardAction(
        context,
        action,
        title: link.displayTitle,
        url: link.originalUrl,
        onOpen: () => context.push(Routes.link(link.id)),
        onDelete: () async {
          final result = await widget.links.delete(link.id);
          if (result is Ok) {
            _list.remove(link.id);
            _seenVersion = widget.changes.version(DataTopic.links) + 1;
            widget.changes.notify({
              DataTopic.links,
              DataTopic.collections,
              DataTopic.account,
            });
          }
          return result;
        },
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StashlyBackground(
        child: SafeArea(
          bottom: false,
          child: ListenableBuilder(
            listenable: _list,
            builder: (context, _) => RefreshIndicator(
              onRefresh: _list.refresh,
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                    sliver: SliverToBoxAdapter(child: _header()),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      30 + MediaQuery.paddingOf(context).bottom,
                    ),
                    sliver: _content(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BackTitleHeader(
          eyebrow: 'YOUR CONTENT LIBRARY',
          title: _query.favoritesOnly ? 'Favorites' : 'All saved items',
          trailing: _list.total == null
              ? null
              : Semantics(
                  label: '${_list.total} items',
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.goldTint,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${_list.total}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _SortButton(
              sort: _query.sort,
              onTap: () =>
                  _setQuery(_query.copyWith(sort: _query.sort.toggled)),
            ),
            const Spacer(),
            _LayoutToggle(
              grid: _grid,
              onChanged: (grid) => setState(() => _grid = grid),
            ),
          ],
        ),
        SizedBox(
          height: context.textScaled(70),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(top: 15, bottom: 17),
            children: [
              PillChip(
                label: 'Favorites',
                icon: AppIcons.heartChip,
                selected: _query.favoritesOnly,
                onTap: () => _setQuery(
                  _query.copyWith(favoritesOnly: !_query.favoritesOnly),
                ),
              ),
              const SizedBox(width: 8),
              PillChip(
                label: 'All',
                selected: _query.contentTypes.isEmpty,
                onTap: () => _setQuery(_query.copyWith(contentTypes: const {})),
              ),
              for (final type in ContentType.values) ...[
                const SizedBox(width: 8),
                PillChip(
                  label: type.label,
                  selected: _query.contentTypes.contains(type),
                  onTap: () => _setQuery(_query.copyWith(contentTypes: {type})),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _content() {
    if (_list.loading && !_list.loadedOnce) {
      return const SliverToBoxAdapter(child: LoadingView());
    }
    if (_list.failure != null && _list.items.isEmpty) {
      return SliverToBoxAdapter(
        child: FailureView(failure: _list.failure!, onRetry: _list.refresh),
      );
    }
    if (_list.isEmpty) {
      return SliverToBoxAdapter(
        child: MessageCard(
          icon: AppIcons.bookmark,
          title: _query.hasFilters
              ? 'Nothing matches these filters'
              : 'Nothing saved yet',
          message: _query.hasFilters
              ? 'Try another type or turn off Favorites.'
              : 'Share a link to Stashly or tap + to save your first one.',
        ),
      );
    }
    final footer = SliverToBoxAdapter(child: LoadMoreFooter(controller: _list));
    if (_grid) {
      return SliverMainAxisGroup(
        slivers: [
          SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              // 122 px thumbnail plus a text area that grows with the text scale.
              mainAxisExtent: 122 + context.textScaled(90),
            ),
            itemCount: _list.items.length,
            itemBuilder: (context, index) {
              final link = _list.items[index];
              return SavedGridCard(
                data: linkCardData(link),
                onOpen: () => context.push(Routes.link(link.id)),
                onToggleFavorite: () => _toggleFavorite(link),
                onAction: (action) => _onAction(link, action),
              );
            },
          ),
          footer,
        ],
      );
    }
    return SliverMainAxisGroup(
      slivers: [
        SliverList.separated(
          itemCount: _list.items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 13),
          itemBuilder: (context, index) {
            final link = _list.items[index];
            return SavedCard(
              data: linkCardData(link),
              onOpen: () => context.push(Routes.link(link.id)),
              onToggleFavorite: () => _toggleFavorite(link),
              onAction: (action) => _onAction(link, action),
            );
          },
        ),
        footer,
      ],
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({required this.sort, required this.onTap});

  final LinkSort sort;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Sort: ${sort.label}',
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
            constraints: const BoxConstraints(minHeight: 42),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppIcon(
                    AppIcons.sort,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 7),
                  Text(sort.label, style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LayoutToggle extends StatelessWidget {
  const _LayoutToggle({required this.grid, required this.onChanged});

  final bool grid;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget segment(bool isGrid, String icon, String label) {
      final selected = grid == isGrid;
      return Semantics(
        button: true,
        selected: selected,
        label: label,
        child: GestureDetector(
          onTap: () => onChanged(isGrid),
          child: Container(
            width: 36,
            height: 34,
            decoration: BoxDecoration(
              color: selected ? AppColors.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: AppIcon(
              icon,
              size: 18,
              color: selected ? AppColors.gold : AppColors.textMuted,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border, width: 1.36),
      ),
      child: Row(
        children: [
          segment(false, AppIcons.layoutList, 'List layout'),
          segment(true, AppIcons.layoutGrid, 'Grid layout'),
        ],
      ),
    );
  }
}
