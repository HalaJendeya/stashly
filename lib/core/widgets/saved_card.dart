import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:stashly/core/format/date_labels.dart';
import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/app_icon.dart';
import 'package:stashly/core/widgets/preview_image.dart';

/// Everything a saved-item card displays. Features map their own link model
/// to this so the card stays free of feature imports.
class SavedCardData {
  const SavedCardData({
    required this.id,
    required this.title,
    required this.domain,
    required this.imageUrl,
    required this.isFavorite,
    required this.dateLabel,
    required this.typeLabel,
    this.collectionLabel,
    this.previewState = PreviewState.ready,
    this.placeholderIcon = AppIcons.typeArticle,
  });

  /// Builds a card from the API's link fields (`content_type` and
  /// `metadata.status` as sent by the server). Every list goes through this,
  /// so a link looks the same on Home, Library, Search and in a collection.
  factory SavedCardData.fromApiFields({
    required String id,
    required String title,
    required String sourceDomain,
    required String originalUrl,
    required String? previewImageUrl,
    required bool isFavorite,
    required DateTime createdAt,
    required String contentType,
    required String contentTypeLabel,
    required String metadataStatus,
    String? collectionLabel,
  }) => SavedCardData(
    id: id,
    title: title,
    // Links whose domain couldn't be derived still show where they point.
    domain: sourceDomain.isEmpty ? originalUrl : sourceDomain,
    imageUrl: previewImageUrl,
    isFavorite: isFavorite,
    dateLabel: DateLabels.relativeDay(createdAt),
    typeLabel: contentTypeLabel,
    collectionLabel: collectionLabel,
    previewState: previewStateForMetadataStatus(metadataStatus),
    placeholderIcon: placeholderIconForContentType(contentType),
  );

  final String id;
  final String title;
  final String domain;
  final String? imageUrl;
  final bool isFavorite;
  final String dateLabel;
  final String typeLabel;

  /// "Travel ideas" or "Learning +2"; null when the item is unsorted.
  final String? collectionLabel;
  final PreviewState previewState;
  final String placeholderIcon;
}

enum SavedCardAction { viewDetails, copyLink, delete }

/// Placeholder glyph for a link without a preview image, by API
/// `content_type`.
String placeholderIconForContentType(String contentType) =>
    switch (contentType) {
      'article' => AppIcons.typeArticle,
      'video' => AppIcons.external,
      'product' => AppIcons.tag15,
      'social' => AppIcons.share,
      _ => AppIcons.link,
    };

/// Preview treatment for an API `metadata.status`.
PreviewState previewStateForMetadataStatus(String status) => switch (status) {
  'pending' => PreviewState.pending,
  'ready' => PreviewState.ready,
  _ => PreviewState.unavailable,
};

/// Horizontal saved-item card (Home, Library list, Search, Collection).
class SavedCard extends StatelessWidget {
  const SavedCard({
    super.key,
    required this.data,
    required this.onOpen,
    required this.onToggleFavorite,
    required this.onAction,
  });

  final SavedCardData data;
  final VoidCallback onOpen;
  final VoidCallback onToggleFavorite;
  final ValueChanged<SavedCardAction> onAction;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      onTap: onOpen,
      semanticLabel: '${data.title}, ${data.domain}',
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 112,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 126),
                child: _Thumbnail(
                  data: data,
                  onToggleFavorite: onToggleFavorite,
                  favoriteLeft: 62,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 15, 10, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.domain.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.cardDomain,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            data.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.cardTitle,
                          ),
                          const SizedBox(height: 10),
                          _MetaLine(data: data),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _MoreButton(onAction: onAction),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vertical card for the Library grid layout.
class SavedGridCard extends StatelessWidget {
  const SavedGridCard({
    super.key,
    required this.data,
    required this.onOpen,
    required this.onToggleFavorite,
    required this.onAction,
  });

  final SavedCardData data;
  final VoidCallback onOpen;
  final VoidCallback onToggleFavorite;
  final ValueChanged<SavedCardAction> onAction;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      onTap: onOpen,
      semanticLabel: '${data.title}, ${data.domain}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 122,
            child: _Thumbnail(
              data: data,
              onToggleFavorite: onToggleFavorite,
              favoriteRight: 8,
              showTypeBadge: true,
              compactPlaceholder: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.domain.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.cardDomain,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        data.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.cardTitle.copyWith(
                          fontSize: 11,
                          height: 1.45,
                          letterSpacing: -0.22,
                        ),
                      ),
                    ],
                  ),
                ),
                _MoreButton(onAction: onAction, size: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.child,
    required this.onTap,
    required this.semanticLabel,
  });

  final Widget child;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3D000000),
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.border, width: 1.36),
        ),
        clipBehavior: Clip.antiAlias,
        child: Semantics(
          label: semanticLabel,
          button: true,
          child: InkWell(onTap: onTap, child: child),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.data,
    required this.onToggleFavorite,
    this.favoriteLeft,
    this.favoriteRight,
    this.showTypeBadge = false,
    this.compactPlaceholder = false,
  });

  final SavedCardData data;
  final VoidCallback onToggleFavorite;
  final double? favoriteLeft;
  final double? favoriteRight;
  final bool showTypeBadge;
  final bool compactPlaceholder;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: AppColors.surface,
          child: PreviewImage(
            imageUrl: data.imageUrl,
            domain: data.domain,
            state: data.previewState,
            placeholderIcon: data.placeholderIcon,
            compact: compactPlaceholder,
          ),
        ),
        const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0x80050507), Color(0x00050507)],
                stops: [0, 0.55],
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          left: favoriteLeft,
          right: favoriteRight,
          child: FavoriteBubble(
            isFavorite: data.isFavorite,
            onPressed: onToggleFavorite,
          ),
        ),
        if (showTypeBadge)
          Positioned(
            left: 10,
            bottom: 9,
            child: _GlassBadge(label: data.typeLabel),
          ),
      ],
    );
  }
}

/// Round frosted favourite toggle shown on thumbnails.
class FavoriteBubble extends StatelessWidget {
  const FavoriteBubble({
    super.key,
    required this.isFavorite,
    required this.onPressed,
  });

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: isFavorite,
      label: isFavorite ? 'Remove from favorites' : 'Add to favorites',
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: AppColors.glass,
            shape: const CircleBorder(
              side: BorderSide(color: AppColors.borderStrong, width: 1.36),
            ),
            child: InkWell(
              onTap: onPressed,
              child: SizedBox.square(
                dimension: 42,
                child: Center(
                  child: AppIcon(
                    isFavorite
                        ? AppIcons.heartFilledCard
                        : AppIcons.heartOutlineCard,
                    size: 18,
                    color: isFavorite ? AppColors.gold : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassBadge extends StatelessWidget {
  const _GlassBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: ShapeDecoration(
            color: const Color(0xBD0A0A0D),
            shape: const StadiumBorder(
              side: BorderSide(color: AppColors.borderStrong, width: 1.36),
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.micro.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.data});

  final SavedCardData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (data.collectionLabel != null) ...[
          const AppIcon(
            AppIcons.folderSmall,
            size: 14,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              data.collectionLabel!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.cardMeta,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 3,
            height: 3,
            decoration: const BoxDecoration(
              color: AppColors.textMuted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Text(data.dateLabel, style: AppTextStyles.cardMeta),
      ],
    );
  }
}

class _MoreButton extends StatelessWidget {
  const _MoreButton({required this.onAction, this.size = 42});

  final ValueChanged<SavedCardAction> onAction;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: PopupMenuButton<SavedCardAction>(
        tooltip: 'More actions',
        padding: EdgeInsets.zero,
        color: AppColors.menu,
        elevation: 0,
        menuPadding: const EdgeInsets.all(6),
        position: PopupMenuPosition.under,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border, width: 1.36),
        ),
        constraints: const BoxConstraints(minWidth: 154, maxWidth: 154),
        onSelected: onAction,
        icon: const AppIcon(
          AppIcons.more,
          size: 20,
          color: AppColors.textSecondary,
        ),
        itemBuilder: (context) => [
          _item(SavedCardAction.viewDetails, AppIcons.external, 'View details'),
          _item(SavedCardAction.copyLink, AppIcons.copy, 'Copy link'),
          _item(
            SavedCardAction.delete,
            AppIcons.trashRed,
            'Delete',
            danger: true,
          ),
        ],
      ),
    );
  }

  PopupMenuItem<SavedCardAction> _item(
    SavedCardAction value,
    String icon,
    String label, {
    bool danger = false,
  }) {
    final color = danger ? AppColors.danger : AppColors.textPrimary;
    return PopupMenuItem(
      value: value,
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      child: Row(
        children: [
          AppIcon(
            icon,
            size: 15,
            color: danger ? AppColors.danger : AppColors.textPrimary,
          ),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.micro.copyWith(color: color)),
        ],
      ),
    );
  }
}
