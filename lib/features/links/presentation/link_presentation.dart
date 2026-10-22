import 'package:flutter/material.dart';

import 'package:stashly/core/l10n/l10n.dart';
import 'package:stashly/core/result/paging.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/core/widgets/overlays.dart';
import 'package:stashly/core/widgets/pickers.dart';
import 'package:stashly/core/widgets/saved_card.dart';
import 'package:stashly/core/widgets/state_views.dart';
import 'package:stashly/features/collections/domain/collection.dart';
import 'package:stashly/features/links/domain/link.dart';

/// Maps a [Link] to the shared card component.
SavedCardData linkCardData(Link link, AppLocalizations l10n) =>
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

/// "Add to collections" sheet; resolves to the chosen collections (null if
/// dismissed).
Future<List<CollectionRef>?> pickCollections(
  BuildContext context, {
  required CollectionsRepository collections,
  required List<CollectionRef> selected,
}) async {
  // Read before awaiting: the sheet closes before the result is mapped.
  final l10n = context.l10n;
  final names = {for (final ref in selected) ref.id: ref.name};
  final ids = await showStashlySheet<Set<String>>(
    context,
    builder: (context) => MultiSelectSheet(
      eyebrow: context.l10n.organizeEyebrow,
      title: context.l10n.addToCollections,
      helper: context.l10n.organizeHelper,
      initialSelection: {for (final ref in selected) ref.id},
      selectedSubtitle: context.l10n.selected,
      saveLabel: context.l10n.actionSaveChanges,
      emptyMessage: context.l10n.noCollectionsYet,
      loadPage: (cursor) async {
        final result = await collections.list(
          sort: CollectionSort.name,
          cursor: cursor,
          limit: 100,
        );
        if (result case Ok(:final value)) {
          names.addAll({for (final c in value.items) c.id: c.name});
        }
        return result.map(
          (Paged<Collection> page) => PickerPage([
            for (final c in page.items)
              PickerOption(
                id: c.id,
                title: c.name,
                subtitle: c.description ?? l10n.itemCount(c.linksCount),
              ),
          ], nextCursor: page.hasMore ? page.nextCursor : null),
        );
      },
      onCreate: (name) async {
        final result = await collections.create(name: name);
        if (result case Ok(:final value)) names[value.id] = value.name;
        return result.map(
          (c) => PickerOption(
            id: c.id,
            title: c.name,
            subtitle: l10n.newCollection,
          ),
        );
      },
    ),
  );
  if (ids == null) return null;
  return [
    for (final id in ids)
      CollectionRef(id: id, name: names[id] ?? l10n.collectionLabel),
  ];
}

/// "Edit tags" sheet with suggestions from the user's tags.
Future<List<String>?> editTags(
  BuildContext context, {
  required TagsRepository tags,
  required List<String> current,
}) {
  return showStashlySheet<List<String>>(
    context,
    builder: (context) => TagEditorSheet(
      initialTags: current,
      loadSuggestions: () async {
        final result = await tags.list(limit: 40);
        return result.map((list) => [for (final t in list) t.name]);
      },
    ),
  );
}

/// Parses "travel, italy, film" into tag names (the server normalizes too).
List<String> parseTagInput(String input) {
  final seen = <String>{};
  return [
    for (final raw in input.split(','))
      if (TagEditorSheet.normalize(raw) case final tag
          when tag.isNotEmpty && seen.add(tag))
        tag,
  ];
}

/// Names of the selected collections for a picker field ("Unsorted" if none).
String collectionsLabel(AppLocalizations l10n, List<CollectionRef> refs) =>
    refs.isEmpty ? l10n.unsorted : refs.map((c) => c.name).join(', ');

/// Unwraps a result for fire-and-forget UI actions, surfacing failures.
bool reportFailure<T>(BuildContext context, Result<T> result) {
  if (result case Err(:final failure)) {
    if (context.mounted) {
      showStashlySnack(context, failure.describe(context.l10n), error: true);
    }
    return true;
  }
  return false;
}
