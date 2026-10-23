import 'package:flutter/material.dart';

import 'package:stashly/core/l10n/l10n.dart';
import 'package:stashly/core/result/paging.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/app_icon.dart';
import 'package:stashly/core/widgets/buttons.dart';
import 'package:stashly/core/widgets/fields.dart';
import 'package:stashly/core/widgets/overlays.dart';
import 'package:stashly/features/collections/domain/collection.dart';

/// "Create collection" dialog (Figma 1:2711); also renames when [existing]
/// is given. Resolves to the saved collection, or null when cancelled.
Future<Collection?> showCollectionForm(
  BuildContext context, {
  required CollectionsRepository collections,
  Collection? existing,
  int nameMaxLength = 60,
  int descriptionMaxLength = 300,
}) {
  return showStashlyDialog<Collection>(
    context,
    builder: (context) => _CollectionForm(
      collections: collections,
      existing: existing,
      nameMaxLength: nameMaxLength,
      descriptionMaxLength: descriptionMaxLength,
    ),
  );
}

class _CollectionForm extends StatefulWidget {
  const _CollectionForm({
    required this.collections,
    required this.existing,
    required this.nameMaxLength,
    required this.descriptionMaxLength,
  });

  final CollectionsRepository collections;
  final Collection? existing;
  final int nameMaxLength;
  final int descriptionMaxLength;

  @override
  State<_CollectionForm> createState() => _CollectionFormState();
}

class _CollectionFormState extends State<_CollectionForm> {
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _description = TextEditingController(
    text: widget.existing?.description,
  );
  bool _busy = false;
  String? _nameError;
  String? _descriptionError;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = context.l10n.collectionNameRequired);
      return;
    }
    setState(() {
      _busy = true;
      _nameError = null;
      _descriptionError = null;
    });
    final existing = widget.existing;
    final result = existing == null
        ? await widget.collections.create(
            name: name,
            description: _description.text,
          )
        : await widget.collections.update(
            existing.id,
            name: name == existing.name ? null : name,
            description:
                _description.text.trim() == (existing.description ?? '')
                ? null
                : FieldUpdate(_description.text),
          );
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case Ok(:final value):
        Navigator.of(context).pop(value);
      case Err(:final failure):
        setState(() {
          _nameError = failure.fieldError('name');
          _descriptionError = failure.fieldError('description');
          if (_nameError == null && _descriptionError == null) {
            _nameError = failure.describe(context.l10n);
          }
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return DialogCard(
      padding: 21,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        editing
                            ? context.l10n.collectionEyebrow
                            : context.l10n.newCollectionEyebrow,
                        style: context.text.eyebrow,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        editing
                            ? context.l10n.editCollection
                            : context.l10n.createCollection,
                        style: context.text.sectionTitle,
                      ),
                    ],
                  ),
                ),
                IconTapButton(
                  icon: AppIcons.close19,
                  iconSize: 19,
                  semanticLabel: context.l10n.actionClose,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StashlyTextField(
              label: context.l10n.collectionName,
              controller: _name,
              hint: context.l10n.collectionNameHint,
              maxLength: widget.nameMaxLength,
              autofocus: !editing,
              textCapitalization: TextCapitalization.sentences,
              errorText: _nameError,
            ),
            const SizedBox(height: 16),
            StashlyTextField(
              label: context.l10n.descriptionLabel,
              optional: true,
              controller: _description,
              hint: context.l10n.descriptionHint,
              multiline: true,
              maxLength: widget.descriptionMaxLength,
              textCapitalization: TextCapitalization.sentences,
              errorText: _descriptionError,
            ),
            const SizedBox(height: 16),
            DialogActions(
              cancel: SecondaryButton(
                label: context.l10n.actionCancel,
                onPressed: () => Navigator.of(context).pop(),
              ),
              confirm: PrimaryButton(
                label: editing
                    ? context.l10n.actionSave
                    : context.l10n.actionCreate,
                loading: _busy,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
