import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:stashly/core/l10n/l10n.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/core/widgets/overlays.dart';
import 'package:stashly/core/widgets/saved_card.dart';
import 'package:stashly/core/widgets/state_views.dart';

/// Asks before deleting the saved item called [title] (Figma delete dialog).
Future<bool> confirmDeleteSavedItem(BuildContext context, String title) =>
    confirmDestructive(
      context,
      title: context.l10n.deleteItemTitle,
      message: context.l10n.deleteItemMessage(title),
      confirmLabel: context.l10n.actionDelete,
      cancelLabel: context.l10n.keepItem,
    );

/// Copies a saved item's original [url] and confirms with a snackbar.
Future<void> copySavedItemUrl(BuildContext context, String url) async {
  await Clipboard.setData(ClipboardData(text: url));
  if (context.mounted) showStashlySnack(context, context.l10n.linkCopied);
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
          showStashlySnack(context, context.l10n.itemDeleted);
        case Err(:final failure):
          showStashlySnack(
            context,
            failure.describe(context.l10n),
            error: true,
          );
      }
  }
}
