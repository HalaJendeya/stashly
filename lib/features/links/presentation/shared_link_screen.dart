import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:stashly/core/l10n/l10n.dart';
import 'package:stashly/core/routing/navigation.dart';
import 'package:stashly/core/events/data_changes.dart';
import 'package:stashly/core/network/idempotency.dart';
import 'package:stashly/core/result/app_failure.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/core/routing/routes.dart';
import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/url/url_utils.dart';
import 'package:stashly/core/widgets/app_icon.dart';
import 'package:stashly/core/widgets/brand.dart';
import 'package:stashly/core/widgets/buttons.dart';
import 'package:stashly/core/widgets/chips.dart';
import 'package:stashly/core/widgets/fields.dart';
import 'package:stashly/core/widgets/headers.dart';
import 'package:stashly/core/widgets/preview_image.dart';
import 'package:stashly/core/widgets/saved_card.dart';
import 'package:stashly/core/widgets/state_views.dart';
import 'package:stashly/features/collections/domain/collection.dart';
import 'package:stashly/features/links/domain/link.dart';
import 'package:stashly/features/links/domain/links_repository.dart';
import 'package:stashly/features/links/presentation/link_presentation.dart';

enum _PreviewPhase { checking, ready, partial, none, blocked, offline }

/// "Shared to Stashly" (Figma 1:2406): preview, then save with optional
/// title, collections, tags and note. The preview is best-effort; saving
/// never depends on it (CLAUDE.md §6).
class SharedLinkScreen extends StatefulWidget {
  const SharedLinkScreen({
    super.key,
    required this.sharedText,
    required this.links,
    required this.collections,
    required this.changes,
    this.noteMaxLength = 2000,
    this.titleMaxLength = 300,
  });

  /// Raw text from the share intent (untrusted).
  final String sharedText;
  final LinksRepository links;
  final CollectionsRepository collections;
  final DataChanges changes;
  final int noteMaxLength;
  final int titleMaxLength;

  @override
  State<SharedLinkScreen> createState() => _SharedLinkScreenState();
}

class _SharedLinkScreenState extends State<SharedLinkScreen> {
  late final String? _url = UrlUtils.extractFromSharedText(widget.sharedText);
  final _title = TextEditingController();
  final _tags = TextEditingController();
  final _note = TextEditingController();
  _PreviewPhase _phase = _PreviewPhase.checking;
  LinkPreview? _preview;
  List<CollectionRef> _collections = const [];
  bool _saving = false;
  String? _urlError;
  final Map<String, String?> _errors = {};
  String _idempotencyKey = newIdempotencyKey();

  @override
  void initState() {
    super.initState();
    // Without a link there is nothing to preview; build() explains why.
    if (_url != null) _loadPreview();
  }

  @override
  void dispose() {
    _title.dispose();
    _tags.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _loadPreview() async {
    setState(() => _phase = _PreviewPhase.checking);
    final result = await widget.links.preview(_url!);
    if (!mounted) return;
    switch (result) {
      case Ok(:final value) when value.duplicate:
        context.pushReplacement(Routes.duplicate, extra: value.existingLink);
      case Ok(:final value):
        final metadata = value.metadata;
        setState(() {
          _preview = value;
          _phase = switch (metadata?.status) {
            MetadataStatus.blocked => _PreviewPhase.blocked,
            _ when metadata == null || !metadata.hasPreview =>
              _PreviewPhase.none,
            _ when metadata.title != null && metadata.previewImageUrl != null =>
              _PreviewPhase.ready,
            _ => _PreviewPhase.partial,
          };
          if (_title.text.isEmpty && metadata?.title != null) {
            _title.text = metadata!.title!;
          }
        });
      case Err(:final failure) when failure.kind == FailureKind.invalidUrl:
        setState(() {
          _phase = _PreviewPhase.none;
          _urlError = context.l10n.linkCantBeSaved;
        });
      case Err(:final failure):
        setState(() {
          _phase = failure.kind == FailureKind.offline
              ? _PreviewPhase.offline
              : _PreviewPhase.none;
        });
    }
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
    final url = _url;
    if (url == null || _urlError != null) return;
    final tags = parseTagInput(_tags.text);
    setState(() {
      _errors.clear();
      if (tags.length > 20) {
        _errors['tags'] = context.l10n.tooManyTags(20);
      }
    });
    if (_errors['tags'] != null) return;

    setState(() => _saving = true);
    final result = await widget.links.create(
      NewLink(
        url: url,
        title: _title.text,
        note: _note.text,
        tags: tags,
        collectionIds: [for (final c in _collections) c.id],
      ),
      idempotencyKey: _idempotencyKey,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    switch (result) {
      case Ok(:final value):
        widget.changes.notify({
          DataTopic.links,
          DataTopic.collections,
          DataTopic.account,
        });
        showStashlySnack(context, context.l10n.savedToStashly);
        context.pushReplacement(Routes.link(value.id));
      case Err(:final failure) when failure.kind == FailureKind.duplicateLink:
        context.pushReplacement(Routes.duplicate, extra: failure.payload);
      case Err(:final failure):
        _idempotencyKey = newIdempotencyKey();
        setState(() {
          for (final field in ['title', 'note', 'tags']) {
            _errors[field] = failure.fieldError(field);
          }
          if (failure.kind == FailureKind.invalidUrl) {
            _urlError = failure.describe(context.l10n);
          }
        });
        if (_errors.values.every((e) => e == null) && _urlError == null) {
          showStashlySnack(
            context,
            failure.describe(context.l10n),
            error: true,
          );
        }
    }
  }

  /// Typed details that leaving would throw away.
  bool _hasEdits() =>
      !_saving && [_title, _tags, _note].any((c) => c.text.trim().isNotEmpty);

  void _close() => UnsavedChangesGuard.leave(context, _hasEdits);

  @override
  Widget build(BuildContext context) {
    final preview = _preview;
    final metadata = preview?.metadata;
    final domain =
        preview?.sourceDomain ??
        (_url == null ? '' : UrlUtils.displayHost(_url));
    return UnsavedChangesGuard(
      hasChanges: _hasEdits,
      child: Scaffold(
        body: StashlyBackground(
          child: SafeArea(
            child: Column(
              children: [
                CaptionTopBar(
                  caption: context.l10n.sharedToStashly,
                  onLeading: _close,
                  trailing: IconTapButton(
                    icon: AppIcons.close19,
                    iconSize: 19,
                    semanticLabel: context.l10n.actionClose,
                    onPressed: _close,
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    children: [
                      Container(
                        height: 190,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: context.colors.card,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: context.colors.border,
                            width: 1.36,
                          ),
                        ),
                        child: _phase == _PreviewPhase.checking
                            ? const LoadingView()
                            : PreviewImage(
                                imageUrl: metadata?.previewImageUrl,
                                domain: domain,
                                placeholderIcon: placeholderIconForContentType(
                                  (preview?.contentType ?? ContentType.other)
                                      .apiValue,
                                ),
                              ),
                      ),
                      const SizedBox(height: 10),
                      _StatusBanner(
                        phase: _phase,
                        error: _url == null
                            ? context.l10n.shareNoLink
                            : _urlError,
                      ),
                      const SizedBox(height: 17),
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: context.colors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: context.colors.border,
                            width: 1.36,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (preview != null) ...[
                                  GoldBadge(
                                    context.l10n.contentType(
                                      preview.contentType.apiValue,
                                    ),
                                    fontSize: 11,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 4,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Expanded(
                                  child: Text(
                                    domain,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.text.micro.copyWith(
                                      color: context.colors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 9),
                            Text(
                              _url ?? widget.sharedText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.tiny,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 19),
                      StashlyTextField(
                        label: context.l10n.titleLabel,
                        controller: _title,
                        hint: context.l10n.titleHint,
                        maxLength: widget.titleMaxLength,
                        textCapitalization: TextCapitalization.sentences,
                        errorText: _errors['title'],
                      ),
                      const SizedBox(height: 14),
                      PickerField(
                        label: context.l10n.collectionLabel,
                        optional: true,
                        value: collectionsLabel(context.l10n, _collections),
                        onTap: _pickCollections,
                      ),
                      const SizedBox(height: 14),
                      StashlyTextField(
                        label: context.l10n.tagsLabel,
                        optional: true,
                        controller: _tags,
                        hint: context.l10n.sharedTagsHint,
                        icon: AppIcons.tagInput,
                        errorText: _errors['tags'],
                      ),
                      const SizedBox(height: 14),
                      StashlyTextField(
                        label: context.l10n.personalNote,
                        optional: true,
                        controller: _note,
                        hint: context.l10n.noteHint,
                        multiline: true,
                        maxLength: widget.noteMaxLength,
                        textCapitalization: TextCapitalization.sentences,
                        errorText: _errors['note'],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 17),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppIcon(
                              AppIcons.shield16,
                              size: 16,
                              color: context.colors.gold,
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                context.l10n.storageNotice,
                                style: context.text.tiny,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PrimaryButton(
                        label: context.l10n.saveNow,
                        icon: AppIcons.save,
                        loading: _saving,
                        onPressed: _url == null || _urlError != null
                            ? null
                            : _save,
                      ),
                      TextActionButton(
                        label: context.l10n.actionCancel,
                        minHeight: 48,
                        style: context.text.body,
                        onPressed: _close,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.phase, required this.error});

  final _PreviewPhase phase;
  final String? error;

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return InfoBanner(
        icon: AppIcons.info,
        iconColor: context.colors.danger,
        background: context.colors.dangerTint,
        title: context.l10n.cantSaveThis,
        message: error!,
      );
    }
    final (title, message, icon) = switch (phase) {
      _PreviewPhase.checking => (
        context.l10n.lookingForPreview,
        context.l10n.lookingForPreviewBody,
        AppIcons.loader,
      ),
      _PreviewPhase.ready => (
        context.l10n.previewReady,
        context.l10n.previewReadyBody,
        AppIcons.checkCircle,
      ),
      _PreviewPhase.partial => (
        context.l10n.previewPartial,
        context.l10n.previewPartialBody,
        AppIcons.checkCircle,
      ),
      _PreviewPhase.none => (
        context.l10n.previewNone,
        context.l10n.previewNoneBody,
        AppIcons.info,
      ),
      _PreviewPhase.blocked => (
        context.l10n.previewUnavailable,
        context.l10n.previewUnavailableBody,
        AppIcons.info,
      ),
      _PreviewPhase.offline => (
        context.l10n.offlineTitle,
        context.l10n.offlineSaveBody,
        AppIcons.info,
      ),
    };
    return InfoBanner(icon: icon, title: title, message: message);
  }
}
