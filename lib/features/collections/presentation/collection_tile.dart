import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/app_icon.dart';
import 'package:stashly/features/collections/domain/collection.dart';

/// Collection card for the Collections grid (Figma 1:2566): cover mosaic of
/// up to four preview images, name and item count.
class CollectionCard extends StatelessWidget {
  const CollectionCard({
    super.key,
    required this.collection,
    required this.onTap,
  });

  final Collection collection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 105, child: _Cover(collection: collection)),
              Padding(
                padding: const EdgeInsets.fromLTRB(13, 12, 10, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            collection.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.rowTitle.copyWith(
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            collection.countLabel,
                            style: AppTextStyles.tiny,
                          ),
                        ],
                      ),
                    ),
                    const AppIcon(
                      AppIcons.cardArrow,
                      size: 17,
                      color: AppColors.textMuted,
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
}

class _Cover extends StatelessWidget {
  const _Cover({required this.collection});

  final Collection collection;

  @override
  Widget build(BuildContext context) {
    final images = collection.coverImages;
    if (images.isEmpty) return CollectionPlaceholder(seed: collection.id);
    Widget image(String url) => CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      memCacheWidth: 400,
      placeholder: (_, _) => const ColoredBox(color: AppColors.surface),
      errorWidget: (_, _, _) =>
          CollectionPlaceholder(seed: collection.id, iconSize: 18),
    );
    if (images.length == 1) return image(images.first);
    return Row(
      children: [
        Expanded(flex: 175, child: image(images[0])),
        const SizedBox(width: 2),
        Expanded(
          flex: 100,
          child: Column(
            children: [
              Expanded(child: image(images[1])),
              if (images.length > 2) ...[
                const SizedBox(height: 2),
                Expanded(child: image(images[2])),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Gradient tile with a folder glyph for collections without covers.
class CollectionPlaceholder extends StatelessWidget {
  const CollectionPlaceholder({
    super.key,
    required this.seed,
    this.iconSize = 26,
  });

  final String seed;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    // Two design variants (warm gold / cool slate), picked stably per id.
    final warm = seed.codeUnits.fold<int>(0, (sum, c) => sum + c).isEven;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: warm
              ? const [Color(0xFF25231C), Color(0xFF18181C)]
              : const [Color(0xFF202631), Color(0xFF17191D)],
        ),
      ),
      child: Center(
        child: AppIcon(
          warm ? AppIcons.folder26 : AppIcons.folder26Alt,
          size: iconSize,
          color: warm ? AppColors.gold : AppColors.textMuted,
        ),
      ),
    );
  }
}
