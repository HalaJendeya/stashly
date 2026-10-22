import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:stashly/core/events/data_changes.dart';
import 'package:stashly/core/network/idempotency.dart';
import 'package:stashly/core/result/app_failure.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/core/routing/routes.dart';
import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/url/url_utils.dart';
import 'package:stashly/core/widgets/app_icon.dart';
import 'package:stashly/core/widgets/buttons.dart';
import 'package:stashly/core/widgets/fields.dart';
import 'package:stashly/core/widgets/overlays.dart';
import 'package:stashly/core/widgets/state_views.dart';
import 'package:stashly/features/collections/domain/collection.dart';
import 'package:stashly/features/links/domain/link.dart';
import 'package:stashly/features/links/domain/links_repository.dart';
import 'package:stashly/features/links/presentation/link_presentation.dart';

/// Opens the manual "Save a link" sheet (Figma 1:471), the required fallback
/// when sharing from another app isn't possible.
Future<void> showSaveLinkSheet(
  BuildContext context, {
  required LinksRepository links,
  required CollectionsRepository collections,
  required DataChanges changes,
  int titleMaxLength = 300,
}) {
  // The clipboard is deliberately not read: the user pastes explicitly.
  return showStashlySheet<void>(
    context,
    builder: (context) => SaveLinkSheet(
      links: links,
      collections: collections,
      changes: changes,
      titleMaxLength: titleMaxLength,
    ),
  );
}

class SaveLinkSheet extends StatefulWidget {
  const SaveLinkSheet({
    super.key,
    required this.links,
    required this.collections,
    required this.changes,
    this.initialUrl,
    this.titleMaxLength = 300,
  });

  final LinksRepository links;
  final CollectionsRepository collections;
  final DataChanges changes;
  final String? initialUrl;
  final int titleMaxLength;

  @override
  State<SaveLinkSheet> createState() => _SaveLinkSheetState();
}

class _SaveLinkSheetState extends State<SaveLinkSheet> {
  late final _url = TextEditingController(text: widget.initialUrl);
  final _title = TextEditingController();
  List<CollectionRef> _collections = const [];
  bool _busy = false;
  String? _urlError;
  String? _titleError;

  /// One key per attempt: a retry after a timeout replays instead of duplicating.
  String _idempotencyKey = newIdempotencyKey();

  @override
  void initState() {
    super.initState();
    _url.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _url.dispose();
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickCollections() async {
    final picked = await pickCollections(
      context,
      collections: widget.collections,
      selected: _collections,
    );
    if (picked != null) setState(() => _collections = picked);
  }

  Future<void> _save() async {
    final url = UrlUtils.prepareForSave(_url.text);
    setState(() {
      _urlError = UrlUtils.validationMessage(_url.text);
      _titleError = null;
    });
    if (url == null) return;

    setState(() => _busy = true);
    final result = await widget.links.create(
      NewLink(
        url: url,
        title: _title.text,
        collectionIds: [for (final c in _collections) c.id],
      ),
      idempotencyKey: _idempotencyKey,
    );
    if (!mounted) return;
    setState(() => _busy = false);

    switch (result) {
      case Ok(:final value):
        widget.changes.notify({
          DataTopic.links,
          DataTopic.collections,
          DataTopic.account,
        });
        final router = GoRouter.of(context);
        Navigator.of(context).pop();
        showStashlySnack(context, 'Saved to Stashly');
        router.push(Routes.link(value.id));
      case Err(:final failure) when failure.kind == FailureKind.duplicateLink:
        final router = GoRouter.of(context);
        Navigator.of(context).pop();
        router.push(Routes.duplicate, extra: failure.payload);
      case Err(:final failure):
        // A rejected request can safely be retried with a fresh key.
        _idempotencyKey = newIdempotencyKey();
        setState(() {
          _urlError = failure.kind == FailureKind.invalidUrl
              ? failure.userMessage
              : failure.fieldError('url');
          _titleError = failure.fieldError('title');
        });
        if (_urlError == null && _titleError == null) {
          showStashlySnack(context, failure.userMessage, error: true);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _url.text.trim().isNotEmpty;
    return SheetFrame(
      eyebrow: 'ADD TO STASHLY',
      title: 'Save a link',
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrimaryButton(
            label: 'Save to Stashly',
            loading: _busy,
            onPressed: canSave ? _save : null,
          ),
          TextActionButton(
            label: 'Cancel',
            minHeight: 48,
            style: AppTextStyles.body,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StashlyTextField(
            label: 'URL',
            controller: _url,
            hint: 'https://example.com/article',
            icon: AppIcons.linkInput,
            fill: AppColors.card,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.next,
            maxLength: UrlUtils.maxLength,
            autofocus: widget.initialUrl == null,
            errorText: _urlError,
          ),
          const SizedBox(height: 14),
          StashlyTextField(
            label: 'Title',
            optional: true,
            controller: _title,
            hint: 'Add a memorable title',
            fill: AppColors.card,
            maxLength: widget.titleMaxLength,
            textCapitalization: TextCapitalization.sentences,
            errorText: _titleError,
          ),
          const SizedBox(height: 14),
          PickerField(
            label: 'Collection',
            optional: true,
            fill: AppColors.card,
            value: collectionsLabel(_collections),
            onTap: _pickCollections,
          ),
          const SizedBox(height: 14),
          const InfoBanner(
            icon: AppIcons.sparkles17,
            message:
                'We’ll fetch a preview when available. You can always save without one.',
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
