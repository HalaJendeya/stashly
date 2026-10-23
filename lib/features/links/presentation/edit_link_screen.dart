import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:stashly/core/l10n/l10n.dart';
import 'package:stashly/core/routing/navigation.dart';
import 'package:stashly/core/events/data_changes.dart';
import 'package:stashly/core/result/app_failure.dart';
import 'package:stashly/core/result/paging.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/core/widgets/app_icon.dart';
import 'package:stashly/core/widgets/brand.dart';
import 'package:stashly/core/widgets/buttons.dart';
import 'package:stashly/core/widgets/fields.dart';
import 'package:stashly/core/widgets/headers.dart';
import 'package:stashly/core/widgets/state_views.dart';
import 'package:stashly/features/collections/domain/collection.dart';
import 'package:stashly/features/links/domain/link.dart';
import 'package:stashly/features/links/domain/links_repository.dart';
import 'package:stashly/features/links/presentation/link_presentation.dart';

/// "Edit details" (Figma 1:2027): title, note, tags and collections.
///
/// The original URL is shown read-only because the API does not allow
/// changing it (API-LINK-005); collections are multi-select (API-LINK-007).
class EditLinkScreen extends StatefulWidget {
  const EditLinkScreen({
    super.key,
    required this.linkId,
    required this.links,
    required this.collections,
    required this.changes,
    this.noteMaxLength = 2000,
    this.titleMaxLength = 300,
    this.focusNote = false,
  });

  final String linkId;
  final LinksRepository links;
  final CollectionsRepository collections;
  final DataChanges changes;
  final int noteMaxLength;
  final int titleMaxLength;

  /// Opened from "Edit personal note": focus the note field.
  final bool focusNote;

  @override
  State<EditLinkScreen> createState() => _EditLinkScreenState();
}

class _EditLinkScreenState extends State<EditLinkScreen> {
  final _title = TextEditingController();
  final _note = TextEditingController();
  final _tags = TextEditingController();
  final _url = TextEditingController();
  final _noteFocus = FocusNode();
  Link? _link;
  AppFailure? _loadFailure;
  List<CollectionRef> _collections = const [];
  bool _saving = false;
  final Map<String, String?> _errors = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    _tags.dispose();
    _url.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loadFailure = null);
    final result = await widget.links.get(widget.linkId);
    if (!mounted) return;
    setState(() {
      switch (result) {
        case Ok(:final value):
          _link = value;
          _title.text = value.title ?? value.displayTitle;
          _note.text = value.note ?? '';
          _tags.text = value.tags.join(', ');
          _url.text = value.originalUrl;
          _collections = value.collections;
        case Err(:final failure):
          _loadFailure = failure;
      }
    });
    if (widget.focusNote && _link != null) _noteFocus.requestFocus();
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
    final link = _link;
    if (link == null) return;
    FocusScope.of(context).unfocus();
    final tags = parseTagInput(_tags.text);
    setState(() {
      _errors.clear();
      if (tags.length > 20) {
        _errors['tags'] = context.l10n.tooManyTags(20);
      }
      if (tags.any((t) => t.length > 40)) {
        _errors['tags'] = context.l10n.tagTooLong(40);
      }
    });
    if (_errors.values.any((e) => e != null)) return;

    final newTitle = _title.text.trim();
    final newNote = _note.text.trim();
    final update = LinkUpdate(
      title: newTitle != (link.title ?? link.displayTitle)
          ? FieldUpdate(newTitle)
          : null,
      note: newNote != (link.note ?? '') ? FieldUpdate(newNote) : null,
    );
    final collectionIds = [for (final c in _collections) c.id];
    final collectionsChanged = !setEquals(collectionIds.toSet(), {
      for (final c in link.collections) c.id,
    });
    final tagsChanged = !listEquals(tags, link.tags);

    setState(() => _saving = true);
    final failures = <AppFailure>[];
    if (!update.isEmpty) {
      final result = await widget.links.update(link.id, update);
      if (result case Err(:final failure)) failures.add(failure);
    }
    if (tagsChanged && failures.isEmpty) {
      final result = await widget.links.setTags(link.id, tags);
      if (result case Err(:final failure)) failures.add(failure);
    }
    if (collectionsChanged && failures.isEmpty) {
      final result = await widget.links.setCollections(link.id, collectionIds);
      if (result case Err(:final failure)) failures.add(failure);
    }
    if (!mounted) return;
    setState(() => _saving = false);

    if (failures.isEmpty) {
      widget.changes.notify({DataTopic.links, DataTopic.collections});
      showStashlySnack(context, context.l10n.changesSaved);
      context.popOrHome();
      return;
    }
    final failure = failures.first;
    setState(() {
      _errors['title'] = failure.fieldError('title');
      _errors['note'] = failure.fieldError('note');
      _errors['tags'] =
          failure.fieldError('tags') ??
          (failure.kind == FailureKind.limitExceeded
              ? failure.describe(context.l10n)
              : null);
    });
    if (_errors.values.every((e) => e == null)) {
      showStashlySnack(context, failure.describe(context.l10n), error: true);
    }
  }

  /// True when the form differs from the item as loaded.
  bool _hasEdits() {
    final link = _link;
    if (link == null || _saving) return false;
    String ids(List<CollectionRef> refs) =>
        (refs.map((c) => c.id).toList()..sort()).join(',');
    return _title.text.trim() != (link.title ?? link.displayTitle).trim() ||
        _note.text.trim() != (link.note ?? '').trim() ||
        _tags.text.trim() != link.tags.join(', ') ||
        ids(_collections) != ids(link.collections);
  }

  @override
  Widget build(BuildContext context) {
    return UnsavedChangesGuard(
      hasChanges: _hasEdits,
      child: Scaffold(
        body: StashlyBackground(
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 30),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                BackTitleHeader(
                  eyebrow: context.l10n.savedItemEyebrow,
                  title: context.l10n.editDetails,
                  onBack: () => UnsavedChangesGuard.leave(context, _hasEdits),
                ),
                const SizedBox(height: 15),
                if (_loadFailure != null)
                  FailureView(failure: _loadFailure!, onRetry: _load)
                else if (_link == null)
                  const LoadingView()
                else ...[
                  StashlyTextField(
                    label: context.l10n.titleLabel,
                    controller: _title,
                    hint: _link!.metadata.title ?? context.l10n.titleHint,
                    maxLength: widget.titleMaxLength,
                    textCapitalization: TextCapitalization.sentences,
                    errorText: _errors['title'],
                  ),
                  const SizedBox(height: 15),
                  StashlyTextField(
                    label: context.l10n.originalUrl,
                    controller: _url,
                    icon: AppIcons.linkInput,
                    keyboardType: TextInputType.url,
                    readOnly: true,
                  ),
                  const SizedBox(height: 15),
                  StashlyTextField(
                    label: context.l10n.personalNote,
                    optional: true,
                    controller: _note,
                    focusNode: _noteFocus,
                    hint: context.l10n.noteHint,
                    multiline: true,
                    maxLength: widget.noteMaxLength,
                    textCapitalization: TextCapitalization.sentences,
                    errorText: _errors['note'],
                  ),
                  const SizedBox(height: 15),
                  StashlyTextField(
                    label: context.l10n.tagsLabel,
                    optional: true,
                    controller: _tags,
                    hint: context.l10n.tagsHint,
                    icon: AppIcons.tagInput,
                    errorText: _errors['tags'],
                  ),
                  const SizedBox(height: 15),
                  PickerField(
                    label: context.l10n.collectionLabel,
                    value: collectionsLabel(context.l10n, _collections),
                    onTap: _pickCollections,
                  ),
                  const SizedBox(height: 26),
                  PrimaryButton(
                    label: context.l10n.actionSaveChanges,
                    icon: AppIcons.save,
                    loading: _saving,
                    onPressed: _save,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
