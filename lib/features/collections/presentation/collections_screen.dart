import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:stashly/core/l10n/l10n.dart';
import 'package:stashly/core/layout/app_viewport.dart';
import 'package:stashly/core/events/data_changes.dart';
import 'package:stashly/core/presentation/paged_controller.dart';
import 'package:stashly/core/routing/routes.dart';
import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/app_icon.dart';
import 'package:stashly/core/widgets/headers.dart';
import 'package:stashly/core/widgets/load_more.dart';
import 'package:stashly/core/widgets/state_views.dart';
import 'package:stashly/features/collections/domain/collection.dart';
import 'package:stashly/features/collections/presentation/collection_form_dialog.dart';
import 'package:stashly/features/collections/presentation/collection_tile.dart';

/// Collections tab (Figma 1:2566) over `GET /collections`.
class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({
    super.key,
    required this.collections,
    required this.changes,
    this.nameMaxLength = 60,
    this.descriptionMaxLength = 300,
  });

  final CollectionsRepository collections;
  final DataChanges changes;
  final int nameMaxLength;
  final int descriptionMaxLength;

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  late final PagedController<Collection> _list = PagedController(
    fetch: (cursor) => widget.collections.list(cursor: cursor),
    idOf: (c) => c.id,
  );
  late int _seen = widget.changes.version(DataTopic.collections);

  @override
  void initState() {
    super.initState();
    widget.changes.addListener(_onChanged);
    _list.refresh();
  }

  @override
  void dispose() {
    widget.changes.removeListener(_onChanged);
    _list.dispose();
    super.dispose();
  }

  void _onChanged() {
    final version = widget.changes.version(DataTopic.collections);
    if (version != _seen) {
      _seen = version;
      _list.refresh();
    }
  }

  Future<void> _create() async {
    final created = await showCollectionForm(
      context,
      collections: widget.collections,
      nameMaxLength: widget.nameMaxLength,
      descriptionMaxLength: widget.descriptionMaxLength,
    );
    if (created == null || !mounted) return;
    widget.changes.notify({DataTopic.collections, DataTopic.account});
    context.push(Routes.collection(created.id));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: _list,
        builder: (context, _) => RefreshIndicator(
          onRefresh: _list.refresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: BrandTopBar(
                  onLibrary: () => context.push(Routes.library),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 23, 20, 23),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TitleBlock(
                          eyebrow: context.l10n.collectionsEyebrow,
                          title: context.l10n.navCollections,
                          subtitle: context.l10n.collectionsSubtitle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _CreateButton(onTap: _create),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 118),
                sliver: _content(),
              ),
            ],
          ),
        ),
      ),
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
          icon: AppIcons.folder26,
          title: context.l10n.startOrganizing,
          message: context.l10n.startOrganizingBody,
          actionLabel: context.l10n.newCollection,
          onAction: _create,
        ),
      );
    }
    return SliverMainAxisGroup(
      slivers: [
        SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            mainAxisSpacing: 11,
            crossAxisSpacing: 11,
            // 105 px cover plus a text area that grows with the text scale.
            mainAxisExtent: 105 + context.textScaled(73),
          ),
          itemCount: _list.items.length,
          itemBuilder: (context, index) {
            final collection = _list.items[index];
            return CollectionCard(
              collection: collection,
              onTap: () => context.push(Routes.collection(collection.id)),
            );
          },
        ),
        SliverToBoxAdapter(child: LoadMoreFooter(controller: _list)),
      ],
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.createCollection,
      child: Material(
        color: context.colors.goldFill,
        borderRadius: BorderRadius.circular(13),
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
                  AppIcon(
                    AppIcons.plus18,
                    size: 18,
                    color: context.colors.onGold,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.actionCreate,
                    style: context.text.micro.copyWith(
                      color: context.colors.onGold,
                      fontWeight: FontWeight.w700,
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
