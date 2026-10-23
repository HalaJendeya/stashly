import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:stashly/core/l10n/l10n.dart';
import 'package:stashly/core/events/data_changes.dart';
import 'package:stashly/core/presentation/paged_controller.dart';
import 'package:stashly/core/result/paging.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/core/routing/routes.dart';
import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/app_icon.dart';
import 'package:stashly/core/widgets/buttons.dart';
import 'package:stashly/core/widgets/chips.dart';
import 'package:stashly/core/widgets/fields.dart';
import 'package:stashly/core/widgets/headers.dart';
import 'package:stashly/core/widgets/load_more.dart';
import 'package:stashly/core/widgets/saved_card.dart';
import 'package:stashly/core/widgets/saved_card_actions.dart';
import 'package:stashly/core/widgets/state_views.dart';
import 'package:stashly/features/collections/domain/collection.dart';
import 'package:stashly/features/links/domain/link.dart';
import 'package:stashly/features/links/domain/links_repository.dart';
import 'package:stashly/features/search/domain/search.dart';
import 'package:stashly/features/search/presentation/filters_sheet.dart';

/// Search tab (Figma 1:3846 idle, 1:2330 results/no matches). Searching is
/// `GET /links?q=…` with the filters from the sheet (API-LINK-003).
class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.links,
    required this.search,
    required this.tags,
    required this.recentSearches,
    required this.changes,
    this.openFiltersOnStart = false,
  });

  final LinksRepository links;
  final SearchRepository search;
  final TagsRepository tags;
  final RecentSearchStore recentSearches;
  final DataChanges changes;
  final bool openFiltersOnStart;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _input = TextEditingController();
  final _focus = FocusNode();
  LinkQuery _query = const LinkQuery();
  List<String> _recent = const [];
  List<TagCount> _suggestedTags = const [];
  Timer? _debounce;
  late final PagedController<Link> _results = PagedController(
    fetch: _fetch,
    idOf: (link) => link.id,
  );
  late int _seen = widget.changes.version(DataTopic.links);

  bool get _active =>
      (_query.text ?? '').trim().isNotEmpty || _query.hasFilters;

  @override
  void initState() {
    super.initState();
    widget.changes.addListener(_onChanged);
    _input.addListener(() => setState(() {}));
    _loadIdleContent();
    if (widget.openFiltersOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openFilters());
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.changes.removeListener(_onChanged);
    _input.dispose();
    _focus.dispose();
    _results.dispose();
    super.dispose();
  }

  Future<Result<Paged<Link>>> _fetch(String? cursor) =>
      widget.links.list(_query, cursor: cursor);

  Future<void> _loadIdleContent() async {
    final recent = await widget.recentSearches.load();
    final tags = await widget.tags.list(limit: 6);
    if (!mounted) return;
    setState(() {
      _recent = recent;
      _suggestedTags = tags.valueOrNull ?? const [];
    });
  }

  void _onChanged() {
    final version = widget.changes.version(DataTopic.links);
    if (version != _seen) {
      _seen = version;
      if (_active) _results.refresh();
    }
  }

  void _onTyped(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => _run(value, remember: false),
    );
  }

  Future<void> _run(String text, {bool remember = true}) async {
    setState(() => _query = _query.copyWith(text: text.trim()));
    if (!_active) return;
    if (remember && text.trim().isNotEmpty) {
      final recent = await widget.recentSearches.add(text);
      if (mounted) setState(() => _recent = recent);
    }
    await _results.refresh();
  }

  void _useSuggestion(String text) {
    _input.text = text;
    _input.selection = TextSelection.collapsed(offset: text.length);
    _run(text);
  }

  Future<void> _openFilters() async {
    final updated = await showFiltersSheet(
      context,
      search: widget.search,
      query: _query,
    );
    if (updated == null || !mounted) return;
    setState(() => _query = updated.copyWith(text: _input.text.trim()));
    if (_active) await _results.refresh();
  }

  void _setQuery(LinkQuery query) {
    setState(() => _query = query);
    if (_active) _results.refresh();
  }

  void _clearText() {
    _input.clear();
    _run('', remember: false);
  }

  Future<void> _toggleFavorite(Link link) async {
    final result = await _results.replaceOptimistically(
      link.copyWith(isFavorite: !link.isFavorite),
      original: link,
      commit: () => widget.links.update(
        link.id,
        LinkUpdate(isFavorite: !link.isFavorite),
      ),
    );
    if (!mounted) return;
    switch (result) {
      case Ok():
        _seen = widget.changes.version(DataTopic.links) + 1;
        widget.changes.notify({DataTopic.links, DataTopic.account});
      case Err(:final failure):
        showStashlySnack(context, failure.describe(context.l10n), error: true);
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
            _results.remove(link.id);
            _seen = widget.changes.version(DataTopic.links) + 1;
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
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: _results,
        builder: (context, _) => CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: BrandTopBar(onLibrary: () => context.push(Routes.library)),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 23, 20, 0),
              sliver: SliverToBoxAdapter(child: _header()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 118),
              sliver: _active
                  ? _resultsSliver()
                  : SliverToBoxAdapter(child: _idle()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TitleBlock(
          eyebrow: context.l10n.searchEyebrow,
          title: context.l10n.searchTitle,
          subtitle: _active ? null : context.l10n.searchSubtitle,
          subtitleStyle: context.text.micro.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: 17),
        Row(
          children: [
            Expanded(
              child: StashlyTextField(
                controller: _input,
                focusNode: _focus,
                hint: context.l10n.searchHint,
                icon: AppIcons.searchInput,
                maxLength: 100,
                textInputAction: TextInputAction.search,
                onChanged: _onTyped,
                onSubmitted: _run,
                trailing: _input.text.isEmpty
                    ? null
                    : IconTapButton(
                        icon: AppIcons.xInput,
                        iconSize: 15,
                        size: 36,
                        color: context.colors.textMuted,
                        semanticLabel: context.l10n.clearSearch,
                        onPressed: _clearText,
                      ),
              ),
            ),
            const SizedBox(width: 8),
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconTapButton(
                  icon: AppIcons.sliders18,
                  iconSize: 18,
                  size: 52,
                  background: context.colors.surface,
                  bordered: true,
                  color: _query.hasFilters
                      ? context.colors.gold
                      : context.colors.textMuted,
                  semanticLabel: context.l10n.filters,
                  onPressed: _openFilters,
                ),
                if (_query.hasFilters)
                  PositionedDirectional(
                    end: 10,
                    top: 10,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: context.colors.gold,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        if (_active) _quickChips(),
      ],
    );
  }

  Widget _quickChips() {
    return SizedBox(
      height: 76,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(top: 16, bottom: 22),
        children: [
          PillChip(
            label: context.l10n.favorites,
            selected: _query.favoritesOnly,
            onTap: () => _setQuery(
              _query.copyWith(favoritesOnly: !_query.favoritesOnly),
            ),
          ),
          const SizedBox(width: 8),
          PillChip(
            label: context.l10n.lastDays(30),
            selected: _query.savedWithinDays == 30,
            onTap: () => _setQuery(
              _query.savedWithinDays == 30
                  ? _query.copyWith(clearSavedWithin: true)
                  : _query.copyWith(savedWithinDays: 30),
            ),
          ),
          for (final type in ContentType.values) ...[
            const SizedBox(width: 8),
            PillChip(
              label: context.l10n.contentType(type.apiValue),
              selected: _query.contentTypes.contains(type),
              onTap: () => _setQuery(
                _query.copyWith(
                  contentTypes: _query.contentTypes.contains(type)
                      ? ({..._query.contentTypes}..remove(type))
                      : {..._query.contentTypes, type},
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _idle() {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_recent.isNotEmpty) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.recentSearches,
                    style: _sectionStyle,
                  ),
                ),
                TextActionButton(
                  label: context.l10n.actionClear,
                  minHeight: 34,
                  style: context.text.tiny.copyWith(color: context.colors.gold),
                  onPressed: () async {
                    await widget.recentSearches.clear();
                    if (mounted) setState(() => _recent = const []);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final query in _recent.take(5))
              _RecentRow(query: query, onTap: () => _useSuggestion(query)),
            const SizedBox(height: 25),
          ],
          if (_suggestedTags.isNotEmpty) ...[
            Text(context.l10n.suggestedSearches, style: _sectionStyle),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in _suggestedTags)
                  PillChip(
                    label: '#${tag.name}',
                    size: PillSize.compact,
                    onTap: () => _setQuery(_query.copyWith(tags: {tag.name})),
                  ),
                PillChip(
                  label: context.l10n.favorites,
                  size: PillSize.compact,
                  onTap: () => _setQuery(_query.copyWith(favoritesOnly: true)),
                ),
              ],
            ),
            const SizedBox(height: 25),
          ],
          const _HintCard(),
        ],
      ),
    );
  }

  TextStyle get _sectionStyle => context.text.subtitle.copyWith(
    color: context.colors.textPrimary,
    letterSpacing: -0.39,
    height: 1.5,
  );

  Widget _resultsSliver() {
    if (_results.loading && _results.items.isEmpty) {
      return const SliverToBoxAdapter(child: LoadingView());
    }
    if (_results.failure != null && _results.items.isEmpty) {
      return SliverToBoxAdapter(
        child: FailureView(
          failure: _results.failure!,
          onRetry: _results.refresh,
        ),
      );
    }
    if (_results.isEmpty) {
      return SliverToBoxAdapter(
        child: MessageCard(
          title: context.l10n.noMatches,
          message: context.l10n.noMatchesBody,
        ),
      );
    }
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              context.l10n.resultCount(_results.total ?? _results.items.length),
              style: context.text.micro,
            ),
          ),
        ),
        SliverList.separated(
          itemCount: _results.items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final link = _results.items[index];
            return SavedCard(
              data: _cardData(link, context.l10n),
              onOpen: () => context.push(Routes.link(link.id)),
              onToggleFavorite: () => _toggleFavorite(link),
              onAction: (action) => _onAction(link, action),
            );
          },
        ),
        SliverToBoxAdapter(child: LoadMoreFooter(controller: _results)),
      ],
    );
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

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.query, required this.onTap});

  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.searchFor(query),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 45),
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: context.colors.divider, width: 1.36),
            ),
          ),
          child: Row(
            children: [
              AppIcon(
                AppIcons.clock,
                size: 16,
                color: context.colors.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  query,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.caption,
                ),
              ),
              AppIcon(
                AppIcons.arrowRight15,
                size: 15,
                color: context.colors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedBorderPainter(radius: 22, color: context.colors.border),
      child: Container(
        constraints: const BoxConstraints(minHeight: 155),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: RadialGradient(
            center: Alignment(0.7, -0.7),
            radius: 1.2,
            colors: [Color(0x17D4AF37), context.colors.card],
            stops: [0, 0.35],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIcon(AppIcons.search25, size: 25, color: context.colors.gold),
            const SizedBox(height: 32),
            Text(
              context.l10n.searchEmptyTitle,
              style: context.text.subtitle.copyWith(
                color: context.colors.textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 7),
            Text(context.l10n.searchEmptyBody, style: context.text.micro),
          ],
        ),
      ),
    );
  }
}
