import 'package:flutter_test/flutter_test.dart';

import 'package:stashly/core/presentation/paged_controller.dart';
import 'package:stashly/core/result/app_failure.dart';
import 'package:stashly/core/result/paging.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/core/widgets/app_icon.dart';
import 'package:stashly/core/widgets/preview_image.dart';
import 'package:stashly/core/widgets/saved_card.dart';

typedef _Item = ({String id, bool favorite});

void main() {
  group('PagedController.replaceOptimistically', () {
    Future<PagedController<_Item>> loaded() async {
      final controller = PagedController<_Item>(
        fetch: (_) async => const Ok(
          Paged(
            items: [(id: 'a', favorite: false)],
            nextCursor: null,
            hasMore: false,
          ),
        ),
        idOf: (item) => item.id,
      );
      await controller.refresh();
      return controller;
    }

    test('shows the change at once, then the server version', () async {
      final controller = await loaded();
      final shownWhileSaving = <bool>[];
      final result = await controller.replaceOptimistically(
        (id: 'a', favorite: true),
        original: (id: 'a', favorite: false),
        commit: () async {
          shownWhileSaving.add(controller.items.single.favorite);
          return const Ok((id: 'a', favorite: true));
        },
      );
      expect(shownWhileSaving, [true]);
      expect(result, isA<Ok<_Item>>());
      expect(controller.items.single.favorite, isTrue);
    });

    test('rolls back when the server refuses', () async {
      final controller = await loaded();
      final result = await controller.replaceOptimistically(
        (id: 'a', favorite: true),
        original: (id: 'a', favorite: false),
        commit: () async => const Err(AppFailure(FailureKind.offline)),
      );
      expect(result, isA<Err<_Item>>());
      expect(controller.items.single.favorite, isFalse);
    });
  });

  group('SavedCardData.fromApiFields', () {
    SavedCardData card({
      String sourceDomain = 'example.com',
      String contentType = 'article',
      String metadataStatus = 'ready',
    }) => SavedCardData.fromApiFields(
      id: '01',
      title: 'Title',
      sourceDomain: sourceDomain,
      originalUrl: 'https://example.com/a',
      previewImageUrl: null,
      isFavorite: false,
      createdAt: DateTime.now().toUtc(),
      contentType: contentType,
      contentTypeLabel: 'Articles',
      metadataStatus: metadataStatus,
    );

    test('falls back to the URL when the server gave no domain', () {
      expect(card().domain, 'example.com');
      expect(card(sourceDomain: '').domain, 'https://example.com/a');
    });

    test('maps every metadata status and content type', () {
      expect(
        card(metadataStatus: 'pending').previewState,
        PreviewState.pending,
      );
      expect(card().previewState, PreviewState.ready);
      for (final status in ['failed', 'blocked', 'something-new']) {
        expect(
          card(metadataStatus: status).previewState,
          PreviewState.unavailable,
        );
      }
      expect(card().placeholderIcon, AppIcons.typeArticle);
      expect(card(contentType: 'video').placeholderIcon, AppIcons.external);
      expect(card(contentType: 'unknown').placeholderIcon, AppIcons.link);
    });
  });
}
