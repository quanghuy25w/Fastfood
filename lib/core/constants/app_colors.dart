import 'package:flutter/material.dart';

/// A complete color palette for one brightness mode.
@immutable
class AppColorPalette {
  const AppColorPalette({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.scaffoldBackground,
    required this.surface,
    required this.cardBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.hintText,
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
    required this.buttonPrimary,
    required this.buttonOnPrimary,
    required this.buttonDisabled,
    required this.buttonDisabledText,
    required this.border,
    required this.divider,
    required this.shadow,
    required this.iconAccent,
  });

  // Primary/secondary colors.
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;

  // Background and surface colors.
  final Color scaffoldBackground;
  final Color surface;
  final Color cardBackground;

  // Text colors.
  final Color textPrimary;
  final Color textSecondary;
  final Color hintText;

  // Status colors.
  final Color success;
  final Color error;
  final Color warning;
  final Color info;

  // Button colors.
  final Color buttonPrimary;
  final Color buttonOnPrimary;
  final Color buttonDisabled;
  final Color buttonDisabledText;

  // Border/divider and elevation helper colors.
  final Color border;
  final Color divider;
  final Color shadow;

  // Highlight icon color.
  final Color iconAccent;
}

/// Defines all app colors in one place for consistency and easy maintenance.
///
/// Supports light/dark modes via two complete palettes.
class AppColors {
  AppColors._();

  static const AppColorPalette light = AppColorPalette(
    primary: Color(0xFFDA291C),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFFDE5E3),
    onPrimaryContainer: Color(0xFF5E110C),
    secondary: Color(0xFFFFC72C),
    onSecondary: Color(0xFF352700),
    secondaryContainer: Color(0xFFFFF1C2),
    onSecondaryContainer: Color(0xFF4A3600),
    scaffoldBackground: Color(0xFFF7F7F7),
    surface: Color(0xFFFFFFFF),
    cardBackground: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF151515),
    textSecondary: Color(0xFF616161),
    hintText: Color(0xFF8A8A8A),
    success: Color(0xFF2E7D32),
    error: Color(0xFFB42318),
    warning: Color(0xFFD97706),
    info: Color(0xFF2563EB),
    buttonPrimary: Color(0xFFDA291C),
    buttonOnPrimary: Color(0xFFFFFFFF),
    buttonDisabled: Color(0xFFD4D4D8),
    buttonDisabledText: Color(0xFF71717A),
    border: Color(0xFFE5E7EB),
    divider: Color(0xFFEDEDED),
    shadow: Color(0x1F000000),
    iconAccent: Color(0xFFFFC72C),
  );

  static const AppColorPalette dark = AppColorPalette(
    primary: Color(0xFFFF5A4E),
    onPrimary: Color(0xFF2B0907),
    primaryContainer: Color(0xFF5E1A14),
    onPrimaryContainer: Color(0xFFFFDAD6),
    secondary: Color(0xFFFFD970),
    onSecondary: Color(0xFF332500),
    secondaryContainer: Color(0xFF4D3900),
    onSecondaryContainer: Color(0xFFFFEEB7),
    scaffoldBackground: Color(0xFF121212),
    surface: Color(0xFF1B1B1B),
    cardBackground: Color(0xFF242424),
    textPrimary: Color(0xFFF3F4F6),
    textSecondary: Color(0xFFD1D5DB),
    hintText: Color(0xFF9CA3AF),
    success: Color(0xFF6BCB77),
    error: Color(0xFFFF6B6B),
    warning: Color(0xFFFBBF24),
    info: Color(0xFF60A5FA),
    buttonPrimary: Color(0xFFFF5A4E),
    buttonOnPrimary: Color(0xFF2B0907),
    buttonDisabled: Color(0xFF3A3A3A),
    buttonDisabledText: Color(0xFFA1A1AA),
    border: Color(0xFF3F3F46),
    divider: Color(0xFF2F2F2F),
    shadow: Color(0x66000000),
    iconAccent: Color(0xFFFFD970),
  );

  /// Resolves the active palette from current theme brightness.
  static AppColorPalette of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}
