import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

/// Available display sizes for the loading widget.
enum LoadingSize { small, medium, fullscreen }

/// Reusable loading widget for async tasks across the app.
///
/// Use cases:
/// - loading products from SQLite/Provider
/// - add to cart, checkout, login/register
/// - any FutureBuilder/async action that needs user feedback
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    this.message = 'Loading...',
    this.size = LoadingSize.medium,
    this.indicatorColor,
    this.overlayColor,
    this.messageStyle,
    this.customIndicator,
    this.padding = const EdgeInsets.all(16),
    this.strokeWidth = 3,
  });

  const LoadingWidget.small({
    super.key,
    this.message = 'Loading...',
    this.indicatorColor,
    this.overlayColor,
    this.messageStyle,
    this.customIndicator,
    this.padding = const EdgeInsets.all(12),
    this.strokeWidth = 2.5,
  }) : size = LoadingSize.small;

  const LoadingWidget.medium({
    super.key,
    this.message = 'Loading...',
    this.indicatorColor,
    this.overlayColor,
    this.messageStyle,
    this.customIndicator,
    this.padding = const EdgeInsets.all(16),
    this.strokeWidth = 3,
  }) : size = LoadingSize.medium;

  const LoadingWidget.fullscreen({
    super.key,
    this.message = 'Loading...',
    this.indicatorColor,
    this.overlayColor,
    this.messageStyle,
    this.customIndicator,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    this.strokeWidth = 3.5,
  }) : size = LoadingSize.fullscreen;

  final String? message;
  final LoadingSize size;
  final Color? indicatorColor;
  final Color? overlayColor;
  final TextStyle? messageStyle;
  final Widget? customIndicator;
  final EdgeInsetsGeometry padding;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final colors = AppColors.of(context);
    final Color color = indicatorColor ?? theme.primaryColor;
    final double indicatorSize = _resolveIndicatorSize(size);

    final Widget indicator =
        customIndicator ??
        SizedBox(
          width: indicatorSize,
          height: indicatorSize,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        );

    // Reusable loading content block for all sizes.
    final Widget content = Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          indicator,
          if (message != null && message!.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: messageStyle ?? theme.textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );

    // Full-screen mode for blocking async operations.
    if (size == LoadingSize.fullscreen) {
      return ColoredBox(
        color: overlayColor ?? colors.shadow.withValues(alpha: 0.35),
        child: Center(
          child: Material(
            color: theme.colorScheme.surface,
            elevation: 2,
            borderRadius: BorderRadius.circular(12),
            child: content,
          ),
        ),
      );
    }

    // Small/medium mode for partial sections.
    return Center(child: content);
  }

  double _resolveIndicatorSize(LoadingSize size) {
    switch (size) {
      case LoadingSize.small:
        return 20;
      case LoadingSize.medium:
        return 30;
      case LoadingSize.fullscreen:
        return 40;
    }
  }
}

/// Helper widget to show a full-screen loading overlay on top of [child].
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message = 'Loading...',
    this.indicatorColor,
    this.overlayColor,
    this.customIndicator,
  });

  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? indicatorColor;
  final Color? overlayColor;
  final Widget? customIndicator;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: LoadingWidget.fullscreen(
              message: message,
              indicatorColor: indicatorColor,
              overlayColor: overlayColor,
              customIndicator: customIndicator,
            ),
          ),
      ],
    );
  }
}
