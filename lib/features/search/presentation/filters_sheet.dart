import 'package:flutter/material.dart';

import 'package:stashly/core/l10n/l10n.dart';
import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/app_icon.dart';
import 'package:stashly/core/widgets/buttons.dart';
import 'package:stashly/core/widgets/chips.dart';
import 'package:stashly/core/widgets/overlays.dart';
import 'package:stashly/core/widgets/pickers.dart';
import 'package:stashly/core/widgets/state_views.dart';
import 'package:stashly/core/result/result.dart';
import 'package:stashly/features/links/domain/links_repository.dart';
import 'package:stashly/features/search/domain/search.dart';

/// "Search filters" sheet (Figma 1:3976), options from `GET /search/filters`.
/// Resolves to the updated query, or null when dismissed.
Future<LinkQuery?> showFiltersSheet(
  BuildContext context, {
  required SearchRepository search,
  required LinkQuery query,
}) {
  return showStashlySheet<LinkQuery>(
    context,
    builder: (context) => _FiltersSheet(search: search, initial: query),
  );
}

class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet({required this.search, required this.initial});

  final SearchRepository search;
  final LinkQuery initial;

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late LinkQuery _query = widget.initial;
  FilterOptions? _options;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    final result = await widget.search.filterOptions();
    if (!mounted) return;
    setState(() {
      switch (result) {
        case Ok(:final value):
          _options = value;
        case Err(:final failure):
          _error = failure.describe(context.l10n);
      }
    });
  }

  Set<T> _toggle<T>(Set<T> set, T value) =>
      set.contains(value) ? ({...set}..remove(value)) : {...set, value};

  @override
  Widget build(BuildContext context) {
    final options = _options;
    return SheetFrame(
      eyebrow: context.l10n.refineEyebrow,
      title: context.l10n.searchFilters,
      footer: Container(
        padding: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: context.colors.divider, width: 1.36),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: TextActionButton(
                label: context.l10n.resetAll,
                minHeight: 48,
                style: context.text.buttonSecondary,
                onPressed: () => setState(
                  () => _query = LinkQuery(
                    text: _query.text,
                    limit: _query.limit,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: PrimaryButton(
                label: context.l10n.applyFilters,
                onPressed: () => Navigator.of(context).pop(_query),
              ),
            ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null)
            FailureCardCompact(message: _error!, onRetry: _load)
          else if (options == null)
            const LoadingView()
          else ...[
            _Group(
              label: context.l10n.contentTypeLabel,
              children: [
                for (final option in options.contentTypes)
                  _chip(
                    context.l10n.contentType(option.value.apiValue),
                    _query.contentTypes.contains(option.value),
                    () => _query = _query.copyWith(
                      contentTypes: _toggle(_query.contentTypes, option.value),
                    ),
                  ),
              ],
            ),
            if (options.sources.isNotEmpty)
              _Group(
                label: context.l10n.sourceLabel,
                children: [
                  for (final option in options.sources)
                    _chip(
                      option.label,
                      _query.sources.contains(option.value),
                      () => _query = _query.copyWith(
                        sources: _toggle(_query.sources, option.value),
                      ),
                    ),
                ],
              ),
            if (options.collections.isNotEmpty)
              _Group(
                label: context.l10n.collectionLabel,
                children: [
                  for (final option in options.collections)
                    _chip(
                      option.label,
                      _query.collectionIds.contains(option.value),
                      () => _query = _query.copyWith(
                        collectionIds: _toggle(
                          _query.collectionIds,
                          option.value,
                        ),
                      ),
                    ),
                ],
              ),
            if (options.tags.isNotEmpty)
              _Group(
                label: context.l10n.tagsLabel,
                children: [
                  for (final option in options.tags)
                    _chip(
                      option.label,
                      _query.tags.contains(option.value),
                      () => _query = _query.copyWith(
                        tags: _toggle(_query.tags, option.value),
                      ),
                    ),
                ],
              ),
            _Group(
              label: context.l10n.dateSaved,
              children: [
                _chip(
                  context.l10n.anyTime,
                  _query.savedWithinDays == null,
                  () => _query = _query.copyWith(clearSavedWithin: true),
                ),
                for (final days
                    in options.datePresets.isEmpty
                        ? const [7, 30]
                        : [for (final p in options.datePresets) p.value])
                  _chip(
                    context.l10n.lastDays(days),
                    _query.savedWithinDays == days,
                    () => _query = _query.copyWith(savedWithinDays: days),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            _ToggleRow(
              icon: AppIcons.heart17Outline,
              label: context.l10n.favoritesOnly,
              trailing: CheckSquare(checked: _query.favoritesOnly, size: 22),
              onTap: () => setState(
                () => _query = _query.copyWith(
                  favoritesOnly: !_query.favoritesOnly,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _ToggleRow(
              icon: AppIcons.sort17,
              label: context.l10n.sortOrder,
              trailing: Text(
                context.l10n.linkSort(_query.sort.name),
                style: context.text.tiny.copyWith(color: context.colors.gold),
              ),
              onTap: () => setState(
                () => _query = _query.copyWith(sort: _query.sort.toggled),
              ),
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback apply) => PillChip(
    label: label,
    size: PillSize.compact,
    selected: selected,
    onTap: () => setState(apply),
  );
}

class _Group extends StatelessWidget {
  const _Group({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.colors.divider, width: 1.36),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.text.micro.copyWith(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 9),
          Wrap(spacing: 7, runSpacing: 7, children: children),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.trailing,
    required this.onTap,
  });

  final String icon;
  final String label;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.colors.border, width: 1.36),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 49),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                AppIcon(icon, size: 17, color: context.colors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: context.text.micro.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
