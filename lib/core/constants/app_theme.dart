import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Defines ThemeData for the whole app (Light/Dark).
///
/// Connected to AppColors so UI stays consistent and easy to maintain.
/// Used by MaterialApp in main.dart and switched dynamically by ThemeProvider.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _buildTheme(
    brightness: Brightness.light,
    palette: AppColors.light,
    inversePalette: AppColors.dark,
  );

  static ThemeData get darkTheme => _buildTheme(
    brightness: Brightness.dark,
    palette: AppColors.dark,
    inversePalette: AppColors.light,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required AppColorPalette palette,
    required AppColorPalette inversePalette,
  }) {
    final colorScheme = _buildColorScheme(
      brightness: brightness,
      palette: palette,
      inversePalette: inversePalette,
    );

    final textTheme = _buildTextTheme(palette);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Roboto',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.scaffoldBackground,
      cardColor: palette.cardBackground,
      dividerColor: palette.divider,
      textTheme: textTheme,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.primary,
        foregroundColor: palette.onPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: palette.onPrimary, size: 22),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: palette.onPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      iconTheme: IconThemeData(color: palette.textSecondary, size: 22),
      dividerTheme: DividerThemeData(
        color: palette.divider,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: palette.cardBackground,
        elevation: brightness == Brightness.dark ? 0.6 : 1.8,
        shadowColor: palette.shadow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.buttonPrimary,
          foregroundColor: palette.buttonOnPrimary,
          disabledBackgroundColor: palette.buttonDisabled,
          disabledForegroundColor: palette.buttonDisabledText,
          elevation: 0,
          minimumSize: const Size(double.infinity, 54),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          side: BorderSide(color: palette.border),
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        hintStyle: textTheme.bodyMedium?.copyWith(color: palette.hintText),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: palette.textSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.error, width: 1.4),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.secondaryContainer,
        selectedColor: palette.secondary,
        secondarySelectedColor: palette.secondary,
        disabledColor: palette.buttonDisabled,
        labelStyle: textTheme.bodySmall?.copyWith(color: palette.onSecondary),
        secondaryLabelStyle: textTheme.bodySmall?.copyWith(
          color: palette.onSecondary,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(color: palette.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.textPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: brightness == Brightness.dark
              ? const Color(0xFF111111)
              : const Color(0xFFFFFFFF),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: palette.textSecondary,
        textColor: palette.textPrimary,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.primary,
        foregroundColor: palette.onPrimary,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.primary,
      ),
    );
  }

  static TextTheme _buildTextTheme(AppColorPalette palette) {
    return TextTheme(
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: palette.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        color: palette.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: palette.textPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        height: 1.35,
        color: palette.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.4,
        color: palette.textSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        height: 1.35,
        color: palette.textSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: palette.textPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: palette.textSecondary,
      ),
    );
  }

  static ColorScheme _buildColorScheme({
    required Brightness brightness,
    required AppColorPalette palette,
    required AppColorPalette inversePalette,
  }) {
    return ColorScheme(
      brightness: brightness,
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      primaryContainer: palette.primaryContainer,
      onPrimaryContainer: palette.onPrimaryContainer,
      secondary: palette.secondary,
      onSecondary: palette.onSecondary,
      secondaryContainer: palette.secondaryContainer,
      onSecondaryContainer: palette.onSecondaryContainer,
      tertiary: palette.info,
      onTertiary: brightness == Brightness.dark
          ? const Color(0xFF002635)
          : const Color(0xFFFFFFFF),
      tertiaryContainer: palette.info.withValues(alpha: 0.18),
      onTertiaryContainer: palette.info,
      error: palette.error,
      onError: brightness == Brightness.dark
          ? const Color(0xFF410002)
          : const Color(0xFFFFFFFF),
      errorContainer: palette.error.withValues(alpha: 0.2),
      onErrorContainer: palette.error,
      surface: palette.surface,
      onSurface: palette.textPrimary,
      onSurfaceVariant: palette.textSecondary,
      outline: palette.border,
      outlineVariant: palette.divider,
      shadow: palette.shadow,
      scrim: const Color(0x66000000),
      inverseSurface: inversePalette.surface,
      onInverseSurface: inversePalette.textPrimary,
      inversePrimary: inversePalette.primary,
      surfaceTint: palette.primary,
    );
  }
}
