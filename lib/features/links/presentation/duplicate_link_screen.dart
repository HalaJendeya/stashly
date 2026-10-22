import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      showStashlySnack(context, 'Collections updated');
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
                caption: 'Incoming link',
                leadingIcon: AppIcons.close20,
                leadingLabel: 'Close',
                onLeading: () => _close(context),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: AppColors.goldTint,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: const AppIcon(
                          AppIcons.checkCircle28,
                          size: 28,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text('ALREADY IN STASHLY', style: AppTextStyles.eyebrow),
                    const SizedBox(height: 7),
                    Text(
                      'You’ve saved this link before',
                      style: AppTextStyles.heading,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No duplicate was created. You can open the existing item or add more organization.',
                      style: AppTextStyles.caption.copyWith(height: 1.65),
                    ),
                    const SizedBox(height: 12),
                    if (link != null)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.border,
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
                              style: AppTextStyles.rowTitle.copyWith(
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              [
                                link.sourceDomain,
                                ?link.collectionLabel,
                              ].join(' · '),
                              style: AppTextStyles.tiny,
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (link != null) ...[
                      PrimaryButton(
                        label: 'Open saved item',
                        onPressed: () =>
                            context.pushReplacement(Routes.link(link.id)),
                      ),
                      const SizedBox(height: 8),
                      SecondaryButton(
                        label: 'Add to a collection',
                        icon: AppIcons.folder17,
                        loading: _busy,
                        onPressed: () => _addToCollection(link),
                      ),
                      const SizedBox(height: 8),
                      SecondaryButton(
                        label: 'Edit personal note',
                        icon: AppIcons.file17,
                        onPressed: () => context.pushReplacement(
                          '${Routes.editLink(link.id)}?focus=note',
                        ),
                      ),
                    ] else
                      PrimaryButton(
                        label: 'Open my library',
                        onPressed: () =>
                            context.pushReplacement(Routes.library),
                      ),
                    const SizedBox(height: 8),
                    TextActionButton(
                      label: 'Cancel',
                      minHeight: 48,
                      style: AppTextStyles.buttonSecondary.copyWith(
                        color: AppColors.textPrimary,
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

  void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.home);
    }
  }
}
