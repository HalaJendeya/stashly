import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:stashly/core/result/result.dart';
import 'package:stashly/core/widgets/overlays.dart';
import 'package:stashly/core/widgets/saved_card.dart';
import 'package:stashly/core/widgets/state_views.dart';

/// Asks before deleting the saved item called [title] (Figma delete dialog).
Future<bool> confirmDeleteSavedItem(BuildContext context, String title) =>
    confirmDestructive(
      context,
      title: 'Delete this saved item?',
      message:
          '“$title” will be removed from your library. The original content '
          'won’t be affected.',
      confirmLabel: 'Delete',
      cancelLabel: 'Keep item',
    );

/// Copies a saved item's original [url] and confirms with a snackbar.
Future<void> copySavedItemUrl(BuildContext context, String url) async {
  await Clipboard.setData(ClipboardData(text: url));
  if (context.mounted) showStashlySnack(context, 'Link copied');
}

/// The ⋯ menu of a saved-item card, shared by every list that shows cards.
/// Screens supply only what differs: how to open the item and how to delete
/// it (the repository call plus their own list bookkeeping on success).
Future<void> handleSavedCardAction(
  BuildContext context,
  SavedCardAction action, {
  required String title,
  required String url,
  required VoidCallback onOpen,
  required Future<Result<void>> Function() onDelete,
}) async {
  switch (action) {
    case SavedCardAction.viewDetails:
      onOpen();
    case SavedCardAction.copyLink:
      await copySavedItemUrl(context, url);
    case SavedCardAction.delete:
      if (!await confirmDeleteSavedItem(context, title) || !context.mounted) {
        return;
      }
      final result = await onDelete();
      if (!context.mounted) return;
      switch (result) {
        case Ok():
          showStashlySnack(context, 'Item deleted');
        case Err(:final failure):
          showStashlySnack(context, failure.userMessage, error: true);
      }
  }
}
