import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:stashly/core/routing/navigation.dart';
import 'package:stashly/core/events/data_changes.dart';
import 'package:stashly/core/presentation/paged_controller.dart';
import 'package:stashly/core/result/app_failure.dart';
import 'package:stashly/core/result/paging.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/core/routing/routes.dart';
import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/app_icon.dart';
import 'package:stashly/core/widgets/brand.dart';
import 'package:stashly/core/widgets/buttons.dart';
import 'package:stashly/core/widgets/fields.dart';
import 'package:stashly/core/widgets/headers.dart';
import 'package:stashly/core/widgets/load_more.dart';
import 'package:stashly/core/widgets/overlays.dart';
import 'package:stashly/core/widgets/pickers.dart';
import 'package:stashly/core/widgets/saved_card.dart';
import 'package:stashly/core/widgets/saved_card_actions.dart';
import 'package:stashly/core/widgets/state_views.dart';
import 'package:stashly/features/collections/domain/collection.dart';
import 'package:stashly/features/collections/presentation/collection_form_dialog.dart';
import 'package:stashly/features/links/domain/link.dart';
import 'package:stashly/features/links/domain/links_repository.dart';

/// One collection and its links (Figma 1:2889 / 1:3047).
class CollectionDetailScreen extends StatefulWidget {
  const CollectionDetailScreen({
    super.key,
    required this.collectionId,
    required this.collections,
    required this.links,
    required this.changes,
  });

  final String collectionId;
  final CollectionsRepository collections;
  final LinksRepository links;
  final DataChanges changes;

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  Collection? _collection;
  AppFailure? _failure;
  LinkSort _sort = LinkSort.newest;
  String _search = '';
  Timer? _debounce;
  late final PagedController<Link> _links = PagedController(
    fetch: _fetch,
    idOf: (link) => link.id,
  );
  late int _seen = widget.changes.version(DataTopic.links);

  @override
  void initState() {
    super.initState();
    widget.changes.addListener(_onChanged);
    _loadCollection();
    _links.refresh();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.changes.removeListener(_onChanged);
    _links.dispose();
    super.dispose();
  }

  Future<Result<Paged<Link>>> _fetch(String? cursor) => widget.links.list(
    LinkQuery(collectionIds: {widget.collectionId}, text: _search, sort: _sort),
    cursor: cursor,
  );

  void _onChanged() {
    final version = widget.changes.version(DataTopic.links);
    if (version != _seen) {
      _seen = version;
      _loadCollection();
      _links.refresh();
    }
  }

  Future<void> _loadCollection() async {
    final result = await widget.collections.get(widget.collectionId);
    if (!mounted) return;
    setState(() {
      _collection = result.valueOrNull ?? _collection;
      _failure = result.failureOrNull;
    });
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _search = value;
      _links.refresh();
    });
  }

  Future<void> _edit(Collection collection) async {
    final updated = await showCollectionForm(
      context,
      collections: widget.collections,
      existing: collection,
    );
    if (updated == null || !mounted) return;
    setState(() => _collection = updated);
    widget.changes.notify({DataTopic.collections, DataTopic.links});
  }

  Future<void> _delete(Collection collection) async {
    final confirmed = await confirmDestructive(
      context,
      title: 'Delete this collection?',
      message:
          '“${collection.name}” will be removed. The links inside stay in your library.',
      confirmLabel: 'Delete',
      cancelLabel: 'Keep it',
    );
    if (!confirmed || !mounted) return;
    final result = await widget.collections.delete(collection.id);
    if (!mounted) return;
    if (result case Err(:final failure)) {
      showStashlySnack(context, failure.userMessage, error: true);
      return;
    }
    widget.changes.notify({
      DataTopic.collections,
      DataTopic.links,
      DataTopic.account,
    });
    showStashlySnack(context, 'Collection deleted');
    context.popOrHome();
  }

  /// "Add existing items": select library links; the diff becomes one
  /// attach/detach call per 100 ids (API-COLL-006).
  Future<void> _manageMembership(Collection collection) async {
    final originalMembers = <String>{};
    final selection = await showStashlySheet<Set<String>>(
      context,
      builder: (context) => MultiSelectSheet(
        eyebrow: 'COLLECTION MEMBERSHIP',
        title: 'Add existing items',
        helper:
            'Select links for ${collection.name}. Removing one here keeps it in your library.',
        initialSelection: const {},
        saveLabel: 'Save membership',
        showClear: false,
        emptyMessage: 'Your library is empty.',
        loadPage: (cursor) async {
          final result = await widget.links.list(
            const LinkQuery(limit: 50),
            cursor: cursor,
          );
          return result.map((page) {
            final options = <PickerOption>[];
            for (final link in page.items) {
              final member = link.collections.any((c) => c.id == collection.id);
              if (member) originalMembers.add(link.id);
              options.add(
                PickerOption(
                  id: link.id,
                  title: link.displayTitle,
                  subtitle: link.sourceDomain,
                  preselected: member,
                ),
              );
            }
            return PickerPage(
              options,
              nextCursor: page.hasMore ? page.nextCursor : null,
            );
          });
        },
      ),
    );
    if (selection == null || !mounted) return;
    final attach = selection.difference(originalMembers).toList();
    final detach = originalMembers.difference(selection).toList();
    if (attach.isEmpty && detach.isEmpty) return;

    Result<Collection> result = Ok(collection);
    for (var i = 0; i < attach.length || i < detach.length; i += 100) {
      result = await widget.collections.updateMembership(
        collection.id,
        attach: attach.skip(i).take(100).toList(),
        detach: detach.skip(i).take(100).toList(),
      );
      if (!result.isOk) break;
    }
    if (!mounted) return;
    switch (result) {
      case Ok(:final value):
        setState(() => _collection = value);
        _seen = widget.changes.version(DataTopic.links) + 1;
        widget.changes.notify({DataTopic.links, DataTopic.collections});
        _links.refresh();
        showStashlySnack(context, 'Collection updated');
      case Err(:final failure):
        showStashlySnack(context, failure.userMessage, error: true);
    }
  }

  Future<void> _toggleFavorite(Link link) async {
    final result = await _links.replaceOptimistically(
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
        showStashlySnack(context, failure.userMessage, error: true);
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
            _links.remove(link.id);
            _seen = widget.changes.version(DataTopic.links) + 1;
            widget.changes.notify({
              DataTopic.links,
              DataTopic.collections,
              DataTopic.account,
            });
            _loadCollection();
          }
          return result;
        },
      );

  @override
  Widget build(BuildContext context) {
    final collection = _collection;
    return Scaffold(
      body: StashlyBackground(
        child: SafeArea(
          bottom: false,
          child: ListenableBuilder(
            listenable: _links,
            builder: (context, _) => RefreshIndicator(
              onRefresh: () async {
                await Future.wait([_loadCollection(), _links.refresh()]);
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: BrandTopBar(
                      onLibrary: () => context.push(Routes.library),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: collection == null
                          ? (_failure == null
                                ? const LoadingView()
                                : FailureView(
                                    failure: _failure!,
                                    onRetry: _loadCollection,
                                  ))
                          : _header(collection),
                    ),
                  ),
                  if (collection != null)
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        0,
                        20,
                        32 + MediaQuery.paddingOf(context).bottom,
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

  Widget _header(Collection collection) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BackTitleHeader(
          eyebrow: 'COLLECTION',
          title: collection.name,
          trailing: IconTapButton(
            icon: AppIcons.edit18,
            iconSize: 18,
            semanticLabel: 'Edit collection',
            onPressed: () => _edit(collection),
          ),
        ),
        if ((collection.description ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 56, top: 3),
            child: Text(
              collection.description!,
              style: AppTextStyles.micro.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 200,
              child: PrimaryButton(
                label: 'Add existing',
                icon: AppIcons.addExisting,
                height: 44,
                labelStyle: AppTextStyles.micro.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                onPressed: () => _manageMembership(collection),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 170,
              child: SecondaryButton(
                label: 'Delete',
                icon: AppIcons.trash17Red,
                color: AppColors.danger,
                height: 44,
                textStyle: AppTextStyles.micro,
                onPressed: () => _delete(collection),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        StashlyTextField(
          hint: 'Search within this collection',
          icon: AppIcons.searchInput,
          textInputAction: TextInputAction.search,
          onChanged: _onSearch,
        ),
        SizedBox(
          height: 51,
          child: Row(
            children: [
              Text(
                _links.total == null
                    ? ''
                    : (_links.total == 1 ? '1 item' : '${_links.total} items'),
                style: AppTextStyles.micro,
              ),
              const Spacer(),
              _SortControl(
                label: _sort.label,
                onTap: () {
                  setState(() => _sort = _sort.toggled);
                  _links.refresh();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _content() {
    if (_links.loading && !_links.loadedOnce) {
      return const SliverToBoxAdapter(child: LoadingView());
    }
    if (_links.failure != null && _links.items.isEmpty) {
      return SliverToBoxAdapter(
        child: FailureView(failure: _links.failure!, onRetry: _links.refresh),
      );
    }
    if (_links.isEmpty) {
      return SliverToBoxAdapter(
        child: MessageCard(
          icon: AppIcons.folder26,
          title: _search.isEmpty
              ? 'This collection is empty'
              : 'No matches in this collection',
          message: _search.isEmpty
              ? 'Use “Add existing” to bring links in, or organize from any item.'
              : 'Try a broader word.',
        ),
      );
    }
    return SliverMainAxisGroup(
      slivers: [
        SliverList.separated(
          itemCount: _links.items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final link = _links.items[index];
            return SavedCard(
              data: _cardData(link),
              onOpen: () => context.push(Routes.link(link.id)),
              onToggleFavorite: () => _toggleFavorite(link),
              onAction: (action) => _onAction(link, action),
            );
          },
        ),
        SliverToBoxAdapter(child: LoadMoreFooter(controller: _links)),
      ],
    );
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

/// Small "⇅ Newest" control next to the item count.
class _SortControl extends StatelessWidget {
  const _SortControl({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Sort: $label',
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 38),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppIcon(
                AppIcons.sort15,
                size: 15,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.micro.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
