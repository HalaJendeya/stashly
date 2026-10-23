import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:stashly/core/l10n/l10n.dart';
import 'package:stashly/core/theme/app_colors.dart';
import 'package:stashly/core/theme/app_text_styles.dart';
import 'package:stashly/core/widgets/app_icon.dart';

/// Label row above a field: "Email" on the left, "Optional" on the right.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.label, {super.key, this.optional = false});

  final String label;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: context.text.fieldLabel)),
        if (optional)
          Text(context.l10n.labelOptional, style: context.text.micro),
      ],
    );
  }
}

/// Text input styled as in the design (surface, radius 16, min 52 px).
class StashlyTextField extends StatefulWidget {
  const StashlyTextField({
    super.key,
    this.label,
    this.optional = false,
    this.controller,
    this.hint,
    this.icon,
    this.password = false,
    this.multiline = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.errorText,
    this.enabled = true,
    this.readOnly = false,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.fill,
    this.trailing,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
  });

  final String? label;
  final bool optional;
  final TextEditingController? controller;
  final String? hint;
  final String? icon;
  final bool password;
  final bool multiline;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final String? errorText;
  final bool enabled;
  final bool readOnly;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  /// Field background; defaults to the surface colour.
  final Color? fill;
  final Widget? trailing;
  final bool autofocus;
  final TextCapitalization textCapitalization;

  @override
  State<StashlyTextField> createState() => _StashlyTextFieldState();
}

class _StashlyTextFieldState extends State<StashlyTextField> {
  bool _obscured = true;

  bool get _latinOnly =>
      widget.password ||
      widget.keyboardType == TextInputType.url ||
      widget.keyboardType == TextInputType.emailAddress;

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final field = Container(
      constraints: BoxConstraints(minHeight: widget.multiline ? 113 : 52),
      padding: EdgeInsetsDirectional.only(
        start: widget.multiline ? 14 : 15,
        end: widget.password ? 4 : 15,
      ),
      decoration: BoxDecoration(
        color: widget.enabled
            ? widget.fill ?? context.colors.surface
            : (widget.fill ?? context.colors.surface).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasError ? context.colors.danger : context.colors.border,
          width: 1.36,
        ),
      ),
      child: Row(
        crossAxisAlignment: widget.multiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            AppIcon(widget.icon!, size: 19, color: context.colors.textMuted),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: TextField(
              // Links, emails and passwords read left-to-right even in Arabic.
              textDirection: _latinOnly ? TextDirection.ltr : null,
              controller: widget.controller,
              focusNode: widget.focusNode,
              enabled: widget.enabled,
              readOnly: widget.readOnly,
              autofocus: widget.autofocus,
              obscureText: widget.password && _obscured,
              keyboardType: widget.multiline
                  ? TextInputType.multiline
                  : widget.keyboardType,
              textInputAction: widget.textInputAction,
              textCapitalization: widget.textCapitalization,
              autofillHints: widget.autofillHints,
              maxLines: widget.multiline ? 6 : 1,
              minLines: widget.multiline ? 4 : 1,
              inputFormatters: widget.maxLength == null
                  ? null
                  : [LengthLimitingTextInputFormatter(widget.maxLength)],
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              style: widget.multiline
                  ? context.text.input.copyWith(fontSize: 14, height: 1.6)
                  : context.text.input.copyWith(
                      color: widget.readOnly || !widget.enabled
                          ? context.colors.textSecondary
                          : context.colors.textPrimary,
                    ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: widget.multiline ? 12 : 16,
                ),
                hintText: widget.hint,
                hintTextDirection: _latinOnly ? TextDirection.ltr : null,
                hintStyle: context.text.input.copyWith(
                  color: context.colors.placeholder,
                  fontSize: widget.multiline ? 14 : 15,
                ),
              ),
            ),
          ),
          if (widget.password)
            Semantics(
              button: true,
              label: _obscured
                  ? context.l10n.showPassword
                  : context.l10n.hidePassword,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(() => _obscured = !_obscured),
                child: SizedBox(
                  width: 38,
                  height: 44,
                  child: Center(
                    child: AppIcon(
                      AppIcons.eye,
                      size: 18,
                      color: _obscured
                          ? context.colors.textMuted
                          : context.colors.gold,
                    ),
                  ),
                ),
              ),
            ),
          ?widget.trailing,
        ],
      ),
    );

    if (widget.label == null && widget.errorText == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          FieldLabel(widget.label!, optional: widget.optional),
          const SizedBox(height: 7),
        ],
        field,
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            style: context.text.micro.copyWith(color: context.colors.danger),
          ),
        ],
      ],
    );
  }
}

/// A field that opens a picker (design "dropdown"): icon, value, chevron.
class PickerField extends StatelessWidget {
  const PickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.optional = false,
    this.icon = AppIcons.folderInput,
    this.fill,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final bool optional;
  final String icon;

  /// Field background; defaults to the surface colour.
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        FieldLabel(label, optional: optional),
        const SizedBox(height: 7),
        Semantics(
          button: true,
          label: context.l10n.fieldValue(label, value),
          child: Material(
            color: fill ?? context.colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: context.colors.border, width: 1.36),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 52),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      AppIcon(icon, size: 18, color: context.colors.textMuted),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.input,
                        ),
                      ),
                      const SizedBox(width: 10),
                      AppIcon(
                        AppIcons.chevronDown,
                        size: 18,
                        color: context.colors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Inline notice: gold-tinted box with an icon (e.g. the save hint).
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.message,
    this.icon = AppIcons.shield,
    this.title,
    this.iconColor,
    this.background,
  });

  final String message;
  final String? title;
  final String icon;

  /// Defaults to gold.
  final Color? iconColor;

  /// Defaults to the gold tint.
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.5),
      decoration: BoxDecoration(
        color: background ?? context.colors.goldTint,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIcon(icon, size: 18, color: iconColor ?? context.colors.gold),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: context.text.micro.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                Text(
                  message,
                  style: title == null
                      ? context.text.micro.copyWith(
                          color: context.colors.textSecondary,
                          height: 1.55,
                        )
                      : context.text.tiny.copyWith(
                          color: context.colors.textSecondary,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
