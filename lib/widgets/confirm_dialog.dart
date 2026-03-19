import 'dart:async';

import 'package:flutter/material.dart';

import 'custom_button.dart';

typedef ConfirmAction = FutureOr<bool> Function();
typedef ConfirmErrorBuilder = String Function(Object error);

/// Reusable confirm dialog for important actions.
///
/// Typical usage:
/// - delete item/product
/// - cancel order
/// - confirm logout
class ConfirmDialog extends StatefulWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Dong y',
    this.cancelText = 'Huy',
    this.icon,
    this.iconColor,
    this.isDestructive = false,
    this.showCancelButton = true,
    this.fullScreen = false,
    this.onConfirm,
    this.onCancel,
    this.errorBuilder,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final IconData? icon;
  final Color? iconColor;
  final bool isDestructive;
  final bool showCancelButton;
  final bool fullScreen;
  final ConfirmAction? onConfirm;
  final VoidCallback? onCancel;
  final ConfirmErrorBuilder? errorBuilder;

  /// Helper to show a confirm dialog and return the final choice.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Dong y',
    String cancelText = 'Huy',
    IconData? icon,
    Color? iconColor,
    bool isDestructive = false,
    bool showCancelButton = true,
    bool fullScreen = false,
    bool barrierDismissible = true,
    ConfirmAction? onConfirm,
    VoidCallback? onCancel,
    ConfirmErrorBuilder? errorBuilder,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) {
        return ConfirmDialog(
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
          icon: icon,
          iconColor: iconColor,
          isDestructive: isDestructive,
          showCancelButton: showCancelButton,
          fullScreen: fullScreen,
          onConfirm: onConfirm,
          onCancel: onCancel,
          errorBuilder: errorBuilder,
        );
      },
    );

    return result ?? false;
  }

  @override
  State<ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  bool _isLoading = false;
  String? _errorText;

  Future<void> _handleConfirm() async {
    if (_isLoading) {
      return;
    }

    if (widget.onConfirm == null) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final shouldClose = await widget.onConfirm!.call();
      if (!mounted) {
        return;
      }

      if (shouldClose) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorText =
            widget.errorBuilder?.call(error) ??
            'Thao tác thất bại. Vui lòng thử lại.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleCancel() {
    if (_isLoading) {
      return;
    }

    widget.onCancel?.call();
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildContent(context);

    if (widget.fullScreen) {
      return Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: content,
              ),
            ),
          ),
        ),
      );
    }

    return Dialog(child: content);
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Color destructiveColor = colorScheme.error;

    return Material(
      color: theme.dialogTheme.backgroundColor ?? colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.icon != null)
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: (widget.iconColor ?? colorScheme.primary)
                        .withValues(alpha: 0.12),
                    child: Icon(
                      widget.icon,
                      color: widget.iconColor ?? colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              )
            else
              Text(widget.title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            Text(widget.message, style: theme.textTheme.bodyMedium),
            if (_errorText != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _errorText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (widget.showCancelButton)
              Row(
                children: [
                  Expanded(
                    child: CustomButton.outline(
                      text: widget.cancelText,
                      onPressed: _handleCancel,
                      enabled: !_isLoading,
                      height: 42,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomButton.primary(
                      text: widget.confirmText,
                      onPressed: _handleConfirm,
                      isLoading: _isLoading,
                      backgroundColor: widget.isDestructive
                          ? destructiveColor
                          : null,
                      foregroundColor: widget.isDestructive
                          ? colorScheme.onError
                          : null,
                      height: 42,
                    ),
                  ),
                ],
              )
            else
              CustomButton.primary(
                text: widget.confirmText,
                onPressed: _handleConfirm,
                isLoading: _isLoading,
                fullWidth: true,
                backgroundColor: widget.isDestructive ? destructiveColor : null,
                foregroundColor: widget.isDestructive
                    ? colorScheme.onError
                    : null,
                height: 42,
              ),
          ],
        ),
      ),
    );
  }
}
