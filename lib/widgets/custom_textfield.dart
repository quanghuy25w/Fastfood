import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable TextField with a unified app style.
///
/// Features:
/// - validation and inline error message
/// - optional password show/hide
/// - prefix/suffix icon support
/// - onChanged callback for Provider/Form state
class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.initialValue,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.enablePasswordToggle = true,
    this.autofocus = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.contentPadding,
    this.borderRadius = 16,
    this.filled,
    this.fillColor,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.inputFormatters,
    this.autovalidateMode,
    this.textStyle,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onTap;
  final String? initialValue;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final bool enablePasswordToggle;
  final bool autofocus;
  final bool autocorrect;
  final bool enableSuggestions;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final EdgeInsetsGeometry? contentPadding;
  final double borderRadius;
  final bool? filled;
  final Color? fillColor;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode? autovalidateMode;
  final TextStyle? textStyle;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  void didUpdateWidget(covariant CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _isObscured = widget.obscureText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final canTogglePassword = widget.obscureText && widget.enablePasswordToggle;

    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: BorderSide(color: colorScheme.primary, width: 2),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: BorderSide(color: colorScheme.error, width: 1.5),
    );

    // Reusable TextField standard for all form screens.
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      initialValue: widget.controller == null ? widget.initialValue : null,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      onTap: widget.onTap,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      obscureText: _isObscured,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.obscureText ? 1 : widget.minLines,
      maxLength: widget.maxLength,
      textCapitalization: widget.textCapitalization,
      autofillHints: widget.autofillHints,
      inputFormatters: widget.inputFormatters,
      autovalidateMode: widget.autovalidateMode,
      style: widget.textStyle ?? theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        helperText: widget.helperText,
        prefixIcon: widget.prefixIcon,
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIcon: canTogglePassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
                icon: Icon(
                  _isObscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              )
            : widget.suffixIcon,
        suffixIconColor: colorScheme.onSurfaceVariant,
        filled: widget.filled ?? true,
        fillColor: widget.fillColor ?? colorScheme.surface,
        contentPadding:
            widget.contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: baseBorder,
        enabledBorder: baseBorder,
        focusedBorder: focusedBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
    );
  }
}
