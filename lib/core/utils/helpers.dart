import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/loading_widget.dart';

/// Helper functions dung chung cho toan app.
///
/// Giam lap code va chuan hoa logic xu ly:
/// - dialog/alert
/// - navigation
/// - async handling + loading
/// - validate/null checks
/// - error handling
class AppHelpers {
  AppHelpers._();

  // =========================
  // Dialog / Alert helpers
  // =========================

  static Future<void> showSuccessDialog(
    BuildContext context, {
    required String message,
    String title = 'Thanh cong',
    String buttonText = 'Dong',
  }) {
    return showAlertDialog(
      context,
      title: title,
      message: message,
      buttonText: buttonText,
      icon: Icons.check_circle_outline,
      iconColor: AppColors.of(context).success,
    );
  }

  static Future<void> showErrorDialog(
    BuildContext context, {
    required String message,
    String title = 'Co loi xay ra',
    String buttonText = 'Dong',
  }) {
    return showAlertDialog(
      context,
      title: title,
      message: message,
      buttonText: buttonText,
      icon: Icons.error_outline,
      iconColor: AppColors.of(context).error,
    );
  }

  static Future<void> showWarningDialog(
    BuildContext context, {
    required String message,
    String title = 'Canh bao',
    String buttonText = 'Dong',
  }) {
    return showAlertDialog(
      context,
      title: title,
      message: message,
      buttonText: buttonText,
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.of(context).warning,
    );
  }

  static Future<void> showAlertDialog(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Dong',
    IconData? icon,
    Color? iconColor,
    bool barrierDismissible = true,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          title: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: iconColor ?? colorScheme.primary),
                const SizedBox(width: 8),
              ],
              Expanded(child: Text(title)),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
  }

  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Dong y',
    String cancelText = 'Huy',
    IconData? icon,
    bool isDestructive = false,
  }) {
    return ConfirmDialog.show(
      context,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      icon: icon,
      isDestructive: isDestructive,
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppColors.of(context).success,
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppColors.of(context).error,
    );
  }

  static void showWarningSnackBar(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppColors.of(context).warning,
    );
  }

  static void _showSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration,
          backgroundColor: backgroundColor,
        ),
      );
  }

  // =========================
  // Navigation helpers
  // =========================

  static Future<T?> push<T>(BuildContext context, Widget page) {
    return Navigator.of(
      context,
    ).push<T>(MaterialPageRoute(builder: (_) => page));
  }

  static Future<T?> pushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?> pushReplacementNamed<T, TO>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.of(context).pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  static Future<T?> pushNamedAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    RoutePredicate? predicate,
  }) {
    return Navigator.of(context).pushNamedAndRemoveUntil<T>(
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop<T>(result);
    }
  }

  static void popToRoot(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // =========================
  // Async helpers
  // =========================

  static Future<T> runWithLoading<T>(
    BuildContext context,
    Future<T> Function() action, {
    String message = 'Dang xu ly...',
    bool barrierDismissible = false,
  }) async {
    final navigator = Navigator.of(context, rootNavigator: true);

    showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) {
        return PopScope(
          canPop: barrierDismissible,
          child: Dialog(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: LoadingWidget.medium(message: message),
            ),
          ),
        );
      },
    );

    try {
      return await action();
    } finally {
      if (navigator.mounted && navigator.canPop()) {
        navigator.pop();
      }
    }
  }

  static Future<void> delay({int milliseconds = 300}) {
    return Future<void>.delayed(Duration(milliseconds: milliseconds));
  }

  // =========================
  // Data checks
  // =========================

  static bool isNullOrEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  static bool hasText(String? value) {
    return !isNullOrEmpty(value);
  }

  static bool isNullOrEmptyList<T>(List<T>? items) {
    return items == null || items.isEmpty;
  }

  static bool hasItems<T>(List<T>? items) {
    return !isNullOrEmptyList(items);
  }

  // =========================
  // Error handling
  // =========================

  static String parseErrorMessage(
    Object error, {
    String fallback = 'Co loi xay ra. Vui long thu lai.',
  }) {
    final raw = error.toString().replaceFirst('Exception:', '').trim();
    if (raw.isEmpty) {
      return fallback;
    }

    final lower = raw.toLowerCase();

    if (lower.contains('socket') ||
        lower.contains('network') ||
        lower.contains('timed out')) {
      return 'Khong the ket noi mang. Vui long kiem tra Internet.';
    }

    if (lower.contains('sqlite') ||
        lower.contains('database') ||
        lower.contains('db')) {
      return 'Du lieu dang gap loi. Vui long thu lai sau.';
    }

    if (lower.contains('permission')) {
      return 'Ban khong co quyen thuc hien thao tac nay.';
    }

    if (lower.contains('not found')) {
      return 'Khong tim thay du lieu phu hop.';
    }

    return raw;
  }

  // =========================
  // Other utilities
  // =========================

  static void dismissKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
}
