import 'package:flutter/material.dart';

/// Button variants for reusable app actions.
enum AppButtonVariant { primary, secondary, outline }

/// Reusable button with unified theme styling for the app.
///
/// Supports:
/// - async/loading state
/// - disabled state
/// - leading/trailing icon
/// - full-width or fixed width layout
/// - subtle press animation for better tactile feedback
class CustomButton extends StatefulWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.enabled = true,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.fullWidth = false,
    this.width,
    this.height = 54,
    this.padding,
    this.borderRadius = 18,
    this.textStyle,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.loadingIndicator,
  });

  const CustomButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.enabled = true,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.fullWidth = false,
    this.width,
    this.height = 54,
    this.padding,
    this.borderRadius = 18,
    this.textStyle,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.loadingIndicator,
  }) : variant = AppButtonVariant.primary;

  const CustomButton.secondary({
    super.key,
    required this.text,
    required this.onPressed,
    this.enabled = true,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.fullWidth = false,
    this.width,
    this.height = 54,
    this.padding,
    this.borderRadius = 18,
    this.textStyle,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.loadingIndicator,
  }) : variant = AppButtonVariant.secondary;

  const CustomButton.outline({
    super.key,
    required this.text,
    required this.onPressed,
    this.enabled = true,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.fullWidth = false,
    this.width,
    this.height = 54,
    this.padding,
    this.borderRadius = 18,
    this.textStyle,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.loadingIndicator,
  }) : variant = AppButtonVariant.outline;

  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool enabled;
  final bool isLoading;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool fullWidth;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final Widget? loadingIndicator;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool isDisabled =
        !widget.enabled || widget.onPressed == null || widget.isLoading;
    final VoidCallback? callback = isDisabled ? null : widget.onPressed;

    final buttonChild = _buildButtonChild(context);
    final buttonStyle = _resolveStyle(theme, colorScheme);

    final Widget button;
    switch (widget.variant) {
      case AppButtonVariant.outline:
        button = OutlinedButton(
          onPressed: callback,
          style: buttonStyle,
          child: buttonChild,
        );
      case AppButtonVariant.primary:
      case AppButtonVariant.secondary:
        button = ElevatedButton(
          onPressed: callback,
          style: buttonStyle,
          child: buttonChild,
        );
    }

    final targetWidth = widget.fullWidth ? double.infinity : widget.width;

    return Listener(
      onPointerDown: isDisabled
          ? null
          : (_) {
              setState(() {
                _isPressed = true;
              });
            },
      onPointerUp: isDisabled
          ? null
          : (_) {
              setState(() {
                _isPressed = false;
              });
            },
      onPointerCancel: isDisabled
          ? null
          : (_) {
              setState(() {
                _isPressed = false;
              });
            },
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: SizedBox(width: targetWidth, height: widget.height, child: button),
      ),
    );
  }

  Widget _buildButtonChild(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveTextStyle =
        widget.textStyle ??
        theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700);

    if (widget.isLoading) {
      final indicatorColor =
          widget.foregroundColor ?? _defaultForegroundColor(colorScheme);
      final indicator =
          widget.loadingIndicator ??
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            ),
          );

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          const SizedBox(width: 10),
          Text(widget.text, style: effectiveTextStyle),
        ],
      );
    }

    if (widget.leadingIcon == null && widget.trailingIcon == null) {
      return Text(widget.text, style: effectiveTextStyle);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.leadingIcon != null) ...[
          IconTheme(
            data: IconThemeData(
              size: 18,
              color: widget.foregroundColor ?? _defaultForegroundColor(colorScheme),
            ),
            child: widget.leadingIcon!,
          ),
          const SizedBox(width: 8),
        ],
        Flexible(child: Text(widget.text, style: effectiveTextStyle)),
        if (widget.trailingIcon != null) ...[
          const SizedBox(width: 8),
          IconTheme(
            data: IconThemeData(
              size: 18,
              color: widget.foregroundColor ?? _defaultForegroundColor(colorScheme),
            ),
            child: widget.trailingIcon!,
          ),
        ],
      ],
    );
  }

  ButtonStyle _resolveStyle(ThemeData theme, ColorScheme colorScheme) {
    final disabledBackground = colorScheme.onSurface.withValues(alpha: 0.12);
    final disabledForeground = colorScheme.onSurface.withValues(alpha: 0.38);

    switch (widget.variant) {
      case AppButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: widget.backgroundColor ?? colorScheme.primary,
          foregroundColor: widget.foregroundColor ?? colorScheme.onPrimary,
          disabledBackgroundColor: disabledBackground,
          disabledForegroundColor: disabledForeground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          padding:
              widget.padding ??
              const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: theme.textTheme.labelLarge,
        );
      case AppButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor:
              widget.backgroundColor ?? colorScheme.secondary,
          foregroundColor:
              widget.foregroundColor ?? colorScheme.onSecondary,
          disabledBackgroundColor: disabledBackground,
          disabledForegroundColor: disabledForeground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          padding:
              widget.padding ??
              const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: theme.textTheme.labelLarge,
        );
      case AppButtonVariant.outline:
        return OutlinedButton.styleFrom(
          foregroundColor: widget.foregroundColor ?? colorScheme.primary,
          disabledForegroundColor: disabledForeground,
          side: BorderSide(color: widget.borderColor ?? colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          padding:
              widget.padding ??
              const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: theme.textTheme.labelLarge,
        );
    }
  }

  Color _defaultForegroundColor(ColorScheme colorScheme) {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return colorScheme.onPrimary;
      case AppButtonVariant.secondary:
        return colorScheme.onSecondary;
      case AppButtonVariant.outline:
        return colorScheme.primary;
    }
  }
}
