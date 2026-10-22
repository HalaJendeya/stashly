import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:stashly/core/l10n/l10n.dart';
import 'package:stashly/core/routing/navigation.dart';
import 'package:stashly/core/events/data_changes.dart';
import 'package:stashly/core/routing/routes.dart';
import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/app_icon.dart';
import 'package:stashly/core/widgets/brand.dart';
import 'package:stashly/core/widgets/buttons.dart';
import 'package:stashly/core/widgets/headers.dart';
import 'package:stashly/core/widgets/state_views.dart';
import 'package:stashly/features/collections/domain/collection.dart';
import 'package:stashly/features/links/domain/link.dart';
import 'package:stashly/features/links/domain/links_repository.dart';
import 'package:stashly/features/links/presentation/link_presentation.dart';

/// "You’ve saved this link before" (Figma 1:2512). Shown for
/// `409 DUPLICATE_LINK` and when the preview reports `duplicate: true`.
class DuplicateLinkScreen extends StatefulWidget {
  const DuplicateLinkScreen({
    super.key,
    required this.existing,
    required this.links,
    required this.collections,
    required this.changes,
  });

  /// The already-saved link from the API, when the server provided it.
  final Link? existing;
  final LinksRepository links;
  final CollectionsRepository collections;
  final DataChanges changes;

  @override
  State<DuplicateLinkScreen> createState() => _DuplicateLinkScreenState();
}

class _DuplicateLinkScreenState extends State<DuplicateLinkScreen> {
  late Link? _link = widget.existing;
  bool _busy = false;

  Future<void> _addToCollection(Link link) async {
    final picked = await pickCollections(
      context,
      collections: widget.collections,
      selected: link.collections,
    );
    if (picked == null || !mounted) return;
    setState(() => _busy = true);
    final result = await widget.links.setCollections(link.id, [
      for (final c in picked) c.id,
    ]);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!reportFailure(context, result)) {
      setState(() => _link = result.valueOrNull);
      widget.changes.notify({DataTopic.links, DataTopic.collections});
      showStashlySnack(context, context.l10n.collectionsUpdated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final link = _link;
    return Scaffold(
      body: StashlyBackground(
        child: SafeArea(
          child: Column(
            children: [
              CaptionTopBar(
                caption: context.l10n.incomingLink,
                leadingIcon: AppIcons.close20,
                leadingLabel: context.l10n.actionClose,
                onLeading: () => _close(context),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: context.colors.goldTint,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: AppIcon(
                          AppIcons.checkCircle28,
                          size: 28,
                          color: context.colors.gold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      context.l10n.alreadyEyebrow,
                      style: context.text.eyebrow,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      context.l10n.alreadyTitle,
                      style: context.text.heading,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.l10n.alreadyBody,
                      style: context.text.caption.copyWith(height: 1.65),
                    ),
                    const SizedBox(height: 12),
                    if (link != null)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: context.colors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: context.colors.border,
                            width: 1.36,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              link.displayTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.rowTitle.copyWith(
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              [
                                link.sourceDomain,
                                ?link.collectionLabel,
                              ].join(' · '),
                              style: context.text.tiny,
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (link != null) ...[
                      PrimaryButton(
                        label: context.l10n.openSavedItem,
                        onPressed: () =>
                            context.pushReplacement(Routes.link(link.id)),
                      ),
                      const SizedBox(height: 8),
                      SecondaryButton(
                        label: context.l10n.addToCollection,
                        icon: AppIcons.folder17,
                        loading: _busy,
                        onPressed: () => _addToCollection(link),
                      ),
                      const SizedBox(height: 8),
                      SecondaryButton(
                        label: context.l10n.editPersonalNote,
                        icon: AppIcons.file17,
                        onPressed: () => context.pushReplacement(
                          '${Routes.editLink(link.id)}?focus=note',
                        ),
                      ),
                    ] else
                      PrimaryButton(
                        label: context.l10n.openMyLibrary,
                        onPressed: () =>
                            context.pushReplacement(Routes.library),
                      ),
                    const SizedBox(height: 8),
                    TextActionButton(
                      label: context.l10n.actionCancel,
                      minHeight: 48,
                      style: context.text.buttonSecondary.copyWith(
                        color: context.colors.textPrimary,
                      ),
                      onPressed: () => _close(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _close(BuildContext context) => context.popOrHome();
}
