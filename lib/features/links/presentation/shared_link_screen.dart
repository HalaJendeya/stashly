import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    if (_url == null) {
      _urlError = 'This share doesn’t contain a web link Stashly can save.';
    } else {
      _loadPreview();
    }
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
          _urlError = 'This link can’t be saved.';
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
        _errors['tags'] = 'An item can have at most 20 tags.';
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
        showStashlySnack(context, 'Saved to Stashly');
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
            _urlError = failure.userMessage;
          }
        });
        if (_errors.values.every((e) => e == null) && _urlError == null) {
          showStashlySnack(context, failure.userMessage, error: true);
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
                  caption: 'Shared to Stashly',
                  onLeading: _close,
                  trailing: IconTapButton(
                    icon: AppIcons.close19,
                    iconSize: 19,
                    semanticLabel: 'Close',
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
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppColors.border,
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
                      _StatusBanner(phase: _phase, error: _urlError),
                      const SizedBox(height: 17),
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.border,
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
                                    preview.contentType.label,
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
                                    style: AppTextStyles.micro.copyWith(
                                      color: AppColors.textPrimary,
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
                              style: AppTextStyles.tiny,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 19),
                      StashlyTextField(
                        label: 'Title',
                        controller: _title,
                        hint: 'Add a memorable title',
                        maxLength: widget.titleMaxLength,
                        textCapitalization: TextCapitalization.sentences,
                        errorText: _errors['title'],
                      ),
                      const SizedBox(height: 14),
                      PickerField(
                        label: 'Collection',
                        optional: true,
                        value: collectionsLabel(_collections),
                        onTap: _pickCollections,
                      ),
                      const SizedBox(height: 14),
                      StashlyTextField(
                        label: 'Tags',
                        optional: true,
                        controller: _tags,
                        hint: 'travel, watch later',
                        icon: AppIcons.tagInput,
                        errorText: _errors['tags'],
                      ),
                      const SizedBox(height: 14),
                      StashlyTextField(
                        label: 'Personal note',
                        optional: true,
                        controller: _note,
                        hint: 'Why is this worth keeping?',
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
                            const AppIcon(
                              AppIcons.shield16,
                              size: 16,
                              color: AppColors.gold,
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                'Only the URL and available metadata are stored—not the original video or image.',
                                style: AppTextStyles.tiny,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PrimaryButton(
                        label: 'Save now',
                        icon: AppIcons.save,
                        loading: _saving,
                        onPressed: _url == null || _urlError != null
                            ? null
                            : _save,
                      ),
                      TextActionButton(
                        label: 'Cancel',
                        minHeight: 48,
                        style: AppTextStyles.body,
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
        iconColor: AppColors.danger,
        background: AppColors.dangerTint,
        title: 'Can’t save this',
        message: error!,
      );
    }
    final (title, message, icon) = switch (phase) {
      _PreviewPhase.checking => (
        'Looking for a preview…',
        'You can save right away; details can arrive later.',
        AppIcons.loader,
      ),
      _PreviewPhase.ready => (
        'Preview ready',
        'Title and thumbnail found.',
        AppIcons.checkCircle,
      ),
      _PreviewPhase.partial => (
        'Partial preview',
        'Some details were found. We’ll keep looking after you save.',
        AppIcons.checkCircle,
      ),
      _PreviewPhase.none => (
        'No preview yet',
        'Save now — we’ll try to fetch the title and image in the background.',
        AppIcons.info,
      ),
      _PreviewPhase.blocked => (
        'Preview unavailable',
        'This page can’t be previewed, but you can still save the link.',
        AppIcons.info,
      ),
      _PreviewPhase.offline => (
        'You’re offline',
        'Connect to the internet to save this link.',
        AppIcons.info,
      ),
    };
    return InfoBanner(icon: icon, title: title, message: message);
  }
}
