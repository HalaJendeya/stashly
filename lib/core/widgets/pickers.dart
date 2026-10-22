import 'package:flutter/material.dart';

import 'package:stashly/core/l10n/l10n.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/app_icon.dart';
import 'package:stashly/core/widgets/buttons.dart';
import 'package:stashly/core/widgets/chips.dart';
import 'package:stashly/core/widgets/fields.dart';
import 'package:stashly/core/widgets/overlays.dart';
import 'package:stashly/core/widgets/state_views.dart';

/// One selectable row in [MultiSelectSheet].
class PickerOption {
  const PickerOption({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.preselected = false,
  });

  final String id;
  final String title;
  final String subtitle;

  /// Starts selected when it first appears (e.g. a link already in the
  /// collection), unless the user already toggled it.
  final bool preselected;
}

/// A page of options; [nextCursor] is null on the last page.
class PickerPage {
  const PickerPage(this.options, {this.nextCursor});

  final List<PickerOption> options;
  final String? nextCursor;
}

/// Multi-select sheet used for "Add to collections" and "Add existing items".
/// Returns the final selection, or null when dismissed.
class MultiSelectSheet extends StatefulWidget {
  const MultiSelectSheet({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.helper,
    required this.loadPage,
    required this.initialSelection,
    required this.saveLabel,
    this.selectedSubtitle,
    this.onCreate,
    this.createLabel,
    this.createHint,
    this.showClear = true,
    this.emptyMessage,
  });

  final String eyebrow;
  final String title;
  final String helper;
  final Future<Result<PickerPage>> Function(String? cursor) loadPage;
  final Set<String> initialSelection;
  final String saveLabel;

  /// Subtitle shown on selected rows instead of their own ("Selected").
  final String? selectedSubtitle;

  /// Creates a new option inline; null hides the create affordance.
  final Future<Result<PickerOption>> Function(String name)? onCreate;

  /// Defaults to "Create collection".
  final String? createLabel;

  /// Defaults to "Collection name".
  final String? createHint;
  final bool showClear;

  /// Defaults to "Nothing here yet.".
  final String? emptyMessage;

  @override
  State<MultiSelectSheet> createState() => _MultiSelectSheetState();
}

class _MultiSelectSheetState extends State<MultiSelectSheet> {
  final List<PickerOption> _options = [];
  late final Set<String> _selected = {...widget.initialSelection};
  final Set<String> _touched = {};

  /// After "Clear selection" later pages must not re-select anything.
  bool _cleared = false;
  final _createController = TextEditingController();
  String? _cursor;
  bool _loading = true;
  bool _loadingMore = false;
  bool _creating = false;
  bool _showCreate = false;
  String? _createError;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _createController.dispose();
    super.dispose();
  }

  Future<void> _load({bool more = false}) async {
    setState(() {
      more ? _loadingMore = true : _loading = true;
      _loadError = null;
    });
    final result = await widget.loadPage(more ? _cursor : null);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _loadingMore = false;
      switch (result) {
        case Ok(:final value):
          if (!more) _options.clear();
          _options.addAll(value.options);
          for (final option in value.options) {
            if (option.preselected &&
                !_cleared &&
                !_touched.contains(option.id)) {
              _selected.add(option.id);
            }
          }
          _cursor = value.nextCursor;
        case Err(:final failure):
          _loadError = failure.describe(context.l10n);
      }
    });
  }

  Future<void> _create() async {
    final name = _createController.text.trim();
    if (name.isEmpty) {
      setState(() => _createError = context.l10n.enterAName);
      return;
    }
    setState(() {
      _creating = true;
      _createError = null;
    });
    final result = await widget.onCreate!(name);
    if (!mounted) return;
    setState(() {
      _creating = false;
      switch (result) {
        case Ok(:final value):
          _options.insert(0, value);
          _selected.add(value.id);
          _createController.clear();
          _showCreate = false;
        case Err(:final failure):
          _createError =
              failure.fieldError('name') ?? failure.describe(context.l10n);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SheetFrame(
      eyebrow: widget.eyebrow,
      title: widget.title,
      helper: widget.helper,
      footer: _footer(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_loading)
            const LoadingView()
          else if (_loadError != null)
            FailureCardCompact(message: _loadError!, onRetry: _load)
          else if (_options.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                widget.emptyMessage ?? context.l10n.nothingHereYet,
                textAlign: TextAlign.center,
                style: context.text.caption,
              ),
            )
          else
            for (final option in _options) ...[
              SelectionRow(
                title: option.title,
                subtitle:
                    _selected.contains(option.id) &&
                        widget.selectedSubtitle != null
                    ? widget.selectedSubtitle!
                    : option.subtitle,
                selected: _selected.contains(option.id),
                onTap: () => setState(() {
                  _touched.add(option.id);
                  _selected.contains(option.id)
                      ? _selected.remove(option.id)
                      : _selected.add(option.id);
                }),
              ),
              const SizedBox(height: 7),
            ],
          if (_cursor != null && !_loading)
            SecondaryButton(
              label: context.l10n.actionLoadMore,
              loading: _loadingMore,
              onPressed: () => _load(more: true),
              textStyle: context.text.bodySmall,
            ),
          if (widget.onCreate != null) ...[
            const SizedBox(height: 5),
            if (_showCreate) _createBox() else _createLink(),
          ],
        ],
      ),
    );
  }

  Widget _createLink() {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _showCreate = true),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(AppIcons.plus17, size: 17, color: context.colors.gold),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.createLabel ?? context.l10n.createCollection,
                  style: context.text.micro.copyWith(
                    color: context.colors.gold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createBox() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border, width: 1.36),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StashlyTextField(
            controller: _createController,
            hint: widget.createHint ?? context.l10n.collectionName,
            autofocus: true,
            maxLength: 60,
            errorText: _createError,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => _create(),
          ),
          const SizedBox(height: 7),
          // Wraps under large text instead of overflowing.
          Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 7,
            runSpacing: 7,
            children: [
              TextActionButton(
                label: context.l10n.actionCancel,
                minHeight: 37,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                style: context.text.tiny.copyWith(
                  color: context.colors.textPrimary,
                ),
                onPressed: () => setState(() {
                  _showCreate = false;
                  _createError = null;
                }),
              ),
              SecondaryButton(
                label: context.l10n.actionCreate,
                height: 37,
                loading: _creating,
                textStyle: context.text.tiny,
                onPressed: _create,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footer() {
    final save = PrimaryButton(
      label: widget.saveLabel,
      onPressed: _loading ? null : () => Navigator.of(context).pop(_selected),
    );
    if (!widget.showClear) return save;
    return Container(
      padding: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: context.colors.divider, width: 1.36),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextActionButton(
              label: context.l10n.clearSelection,
              minHeight: 48,
              style: context.text.micro.copyWith(
                color: context.colors.textPrimary,
              ),
              onPressed: () => setState(() {
                _selected.clear();
                _cleared = true;
              }),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(flex: 4, child: save),
        ],
      ),
    );
  }
}

/// Compact inline error with retry, used inside sheets.
class FailureCardCompact extends StatelessWidget {
  const FailureCardCompact({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.text.caption.copyWith(color: context.colors.danger),
          ),
          TextActionButton(
            label: context.l10n.actionTryAgain,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

/// "Edit tags" sheet: current tags as removable chips, an input to add, and
/// suggestions from the user's existing tags. Returns the new list or null.
class TagEditorSheet extends StatefulWidget {
  const TagEditorSheet({
    super.key,
    required this.initialTags,
    required this.loadSuggestions,
    this.maxTags = 20,
    this.maxLength = 40,
  });

  final List<String> initialTags;
  final Future<Result<List<String>>> Function() loadSuggestions;
  final int maxTags;
  final int maxLength;

  /// Mirrors the server's normalization (trim, drop leading #, collapse
  /// spaces, lowercase) so the chips match what will be stored.
  static String normalize(String raw) => raw
      .trim()
      .replaceFirst(RegExp(r'^#+'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .toLowerCase();

  @override
  State<TagEditorSheet> createState() => _TagEditorSheetState();
}

class _TagEditorSheetState extends State<TagEditorSheet> {
  late final List<String> _tags = [
    for (final tag in widget.initialTags) TagEditorSheet.normalize(tag),
  ];
  final _controller = TextEditingController();
  List<String> _suggestions = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    widget.loadSuggestions().then((result) {
      if (!mounted) return;
      setState(() => _suggestions = result.valueOrNull ?? const []);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add(String raw) {
    final tag = TagEditorSheet.normalize(raw);
    if (tag.isEmpty) return;
    setState(() {
      if (tag.length > widget.maxLength) {
        _error = context.l10n.tagTooLong(widget.maxLength);
      } else if (_tags.length >= widget.maxTags && !_tags.contains(tag)) {
        _error = context.l10n.tooManyTags(widget.maxTags);
      } else {
        _error = null;
        if (!_tags.contains(tag)) _tags.add(tag);
        _controller.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = TagEditorSheet.normalize(_controller.text);
    final suggestions = _suggestions
        .where(
          (s) => !_tags.contains(s) && (query.isEmpty || s.startsWith(query)),
        )
        .take(18)
        .toList();
    return SheetFrame(
      eyebrow: context.l10n.itemTagsEyebrow,
      title: context.l10n.editTags,
      footer: PrimaryButton(
        label: context.l10n.saveTags,
        onPressed: () => Navigator.of(context).pop(List<String>.of(_tags)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_tags.isNotEmpty) ...[
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final tag in _tags)
                  _RemovableTag(
                    label: '#$tag',
                    onRemove: () => setState(() => _tags.remove(tag)),
                  ),
              ],
            ),
            const SizedBox(height: 14),
          ],
          Row(
            children: [
              Expanded(
                child: StashlyTextField(
                  controller: _controller,
                  hint: context.l10n.findOrCreateTag,
                  icon: AppIcons.tagFind,
                  maxLength: widget.maxLength + 1,
                  textInputAction: TextInputAction.done,
                  onSubmitted: _add,
                ),
              ),
              const SizedBox(width: 7),
              SizedBox(
                width: 56,
                child: PrimaryButton(
                  label: context.l10n.actionAdd,
                  height: 52,
                  horizontalPadding: 4,
                  labelStyle: context.text.micro.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                  onPressed: query.isEmpty
                      ? null
                      : () => _add(_controller.text),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 6),
            Text(
              _error!,
              style: context.text.micro.copyWith(color: context.colors.danger),
            ),
          ],
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(context.l10n.suggestions, style: context.text.tiny),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 7,
              children: [
                for (final suggestion in suggestions)
                  PillChip(
                    label: '#$suggestion',
                    size: PillSize.compact,
                    onTap: () => _add(suggestion),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RemovableTag extends StatelessWidget {
  const _RemovableTag({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(9, 5, 5, 5),
      decoration: ShapeDecoration(
        color: context.colors.goldTint,
        shape: StadiumBorder(
          side: BorderSide(color: context.colors.goldBorderSoft, width: 1.36),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: context.text.tiny.copyWith(color: context.colors.gold),
          ),
          const SizedBox(width: 3),
          IconTapButton(
            icon: AppIcons.x12,
            iconSize: 12,
            size: 24,
            color: context.colors.gold,
            semanticLabel: context.l10n.removeItem(label),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
