import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/app_icon.dart';

enum PreviewState {
  /// Metadata lookup finished (image may still be absent).
  ready,

  /// Lookup queued or running: show the "Preview pending" shimmer.
  pending,

  /// Lookup failed or blocked: show the branded fallback.
  unavailable,
}

/// External preview image with graceful fallbacks. Images are cached on
/// device but never re-hosted; expired or hotlink-blocked URLs fall back to a
/// domain placeholder instead of a broken image (CLAUDE.md §6).
class PreviewImage extends StatelessWidget {
  const PreviewImage({
    super.key,
    required this.imageUrl,
    required this.domain,
    this.state = PreviewState.ready,
    this.placeholderIcon = AppIcons.typeArticle,
    this.compact = false,
  });

  final String? imageUrl;
  final String domain;
  final PreviewState state;
  final String placeholderIcon;

  /// Smaller placeholder tile for narrow thumbnails.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || !url.startsWith('http')) {
      return state == PreviewState.pending
          ? const _PendingPreview()
          : _FallbackPreview(
              domain: domain,
              icon: placeholderIcon,
              compact: compact,
            );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 180),
      // Decode at display size to keep memory bounded on long lists.
      memCacheWidth: 600,
      placeholder: (context, _) => const ColoredBox(color: AppColors.surface),
      errorWidget: (context, _, _) => _FallbackPreview(
        domain: domain,
        icon: placeholderIcon,
        compact: compact,
      ),
    );
  }
}

class _FallbackPreview extends StatelessWidget {
  const _FallbackPreview({
    required this.domain,
    required this.icon,
    required this.compact,
  });

  final String domain;
  final String icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final label = domain.split('.').first;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF242015), AppColors.card],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned(
            right: -20,
            top: 0,
            child: SizedBox.square(
              dimension: 90,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x33D4AF37), Color(0x00D4AF37)],
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: compact ? 40 : 54,
                  height: compact ? 40 : 54,
                  decoration: BoxDecoration(
                    color: const Color(0x17D4AF37),
                    borderRadius: BorderRadius.circular(compact ? 13 : 17),
                    border: Border.all(
                      color: const Color(0x47D4AF37),
                      width: 1.36,
                    ),
                  ),
                  child: Center(
                    child: AppIcon(
                      icon,
                      size: compact ? 20 : 26,
                      color: AppColors.gold,
                    ),
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(height: 12),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(height: 1.5),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingPreview extends StatelessWidget {
  const _PendingPreview();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-1, -0.4),
          end: Alignment(1, 0.4),
          colors: [AppColors.surface, Color(0xFF252529), AppColors.surface],
          stops: [0.37, 0.5, 0.63],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppIcon(
              AppIcons.loader,
              size: 23,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 10),
            Text('Preview pending', style: AppTextStyles.micro),
          ],
        ),
      ),
    );
  }
}
