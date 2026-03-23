import 'package:flutter/material.dart';

/// Token & theme tập trung vào **độ dễ đọc** (contrast, hierarchy, nền tách lớp).
/// Text chính #111, phụ #666, nền app #F5F5F5, card trắng.
class AppReadabilityTheme {
  AppReadabilityTheme._();

  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color scaffoldBg = Color(0xFFFAFAFA);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color subtleBorder = Color(0xFFEEEEEE);

  /// Orange mềm — premium, dễ nhìn (light).
  static const Color primary = Color(0xFFE85D2C);

  /// True Dark — bảng màu chuẩn nền sâu.
  static const Color darkScaffoldBg = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceElevated = Color(0xFF2C2C2C);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color darkOnSurfaceVariant = Color(0xFFA0A0A0);
  /// Cam đào — accent dark (icon, giá, trạng thái, tab Tôi).
  static const Color darkAccent = Color(0xFFFF8A65);
  static const Color darkBorder = Color(0xFF2C2C2C);
  static const Color darkOutlineMuted = Color(0xFF5C5C5C);

  /// Light theme — ưu tiên chữ đậm trên nền nhạt, nút chính chữ trắng.
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
    ).copyWith(
      surface: cardSurface,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      surfaceContainerHighest: const Color(0xFFF0F0F0),
      outline: const Color(0xFFBDBDBD),
      outlineVariant: subtleBorder,
    );

    final base = ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBg,
      useMaterial3: true,
      fontFamily: 'Roboto',
    );

    final t = base.textTheme;

    return base.copyWith(
      textTheme: t.copyWith(
        displayLarge: t.displayLarge?.copyWith(color: textPrimary),
        displayMedium: t.displayMedium?.copyWith(color: textPrimary),
        displaySmall: t.displaySmall?.copyWith(color: textPrimary),
        headlineLarge: t.headlineLarge?.copyWith(color: textPrimary, fontWeight: FontWeight.w700),
        headlineMedium: t.headlineMedium?.copyWith(color: textPrimary, fontWeight: FontWeight.w700),
        headlineSmall: t.headlineSmall?.copyWith(color: textPrimary, fontWeight: FontWeight.w700),
        titleLarge: t.titleLarge?.copyWith(color: textPrimary, fontWeight: FontWeight.w700),
        titleMedium: t.titleMedium?.copyWith(color: textPrimary, fontWeight: FontWeight.w600),
        titleSmall: t.titleSmall?.copyWith(color: textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: t.bodyLarge?.copyWith(color: textPrimary, height: 1.35),
        bodyMedium: t.bodyMedium?.copyWith(color: textPrimary, height: 1.35),
        bodySmall: t.bodySmall?.copyWith(color: textSecondary, height: 1.35),
        labelLarge: t.labelLarge?.copyWith(color: textSecondary, fontWeight: FontWeight.w600),
        labelMedium: t.labelMedium?.copyWith(color: textPrimary, fontWeight: FontWeight.w600),
        labelSmall: t.labelSmall?.copyWith(color: textSecondary, fontWeight: FontWeight.w500),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        backgroundColor: cardSurface,
        foregroundColor: textPrimary,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: subtleBorder,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: Colors.white,
          disabledForegroundColor: Color(0xFFE0E0E0),
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, letterSpacing: 0.2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: subtleBorder),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardSurface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primary.withOpacity(0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            fontSize: 12,
            color: selected ? primary : textSecondary,
            height: 1.2,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? primary : textSecondary,
            size: 24,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF2C2C2C),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14, height: 1.35),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: base.textTheme.titleMedium?.copyWith(color: textPrimary),
        subtitleTextStyle: base.textTheme.bodySmall?.copyWith(color: textSecondary),
      ),
    );
  }

  /// Dark — True Dark Mode (#121212 / #1E1E1E / chữ #FFF & #A0A0A0 / accent #FF8A65).
  static ThemeData dark() {
    final scheme = ColorScheme.dark(
      primary: darkAccent,
      onPrimary: Color(0xFF1A0A00),
      primaryContainer: darkSurfaceElevated,
      onPrimaryContainer: darkAccent,
      surface: darkSurface,
      onSurface: darkOnSurface,
      onSurfaceVariant: darkOnSurfaceVariant,
      outline: darkOutlineMuted,
      outlineVariant: darkBorder,
    ).copyWith(
      surfaceContainerHighest: darkSurfaceElevated,
    );

    final base = ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: darkScaffoldBg,
      useMaterial3: true,
      fontFamily: 'Roboto',
    );

    final t = base.textTheme;

    return base.copyWith(
      textTheme: t.copyWith(
        displayLarge: t.displayLarge?.copyWith(color: darkOnSurface),
        displayMedium: t.displayMedium?.copyWith(color: darkOnSurface),
        displaySmall: t.displaySmall?.copyWith(color: darkOnSurface),
        headlineLarge: t.headlineLarge?.copyWith(color: darkOnSurface, fontWeight: FontWeight.w700),
        headlineMedium: t.headlineMedium?.copyWith(color: darkOnSurface, fontWeight: FontWeight.w700),
        headlineSmall: t.headlineSmall?.copyWith(color: darkOnSurface, fontWeight: FontWeight.w700),
        titleLarge: t.titleLarge?.copyWith(color: darkOnSurface, fontWeight: FontWeight.w700),
        titleMedium: t.titleMedium?.copyWith(color: darkOnSurface, fontWeight: FontWeight.w600),
        titleSmall: t.titleSmall?.copyWith(color: darkOnSurface, fontWeight: FontWeight.w600),
        bodyLarge: t.bodyLarge?.copyWith(color: darkOnSurface, height: 1.35),
        bodyMedium: t.bodyMedium?.copyWith(color: darkOnSurface, height: 1.35),
        bodySmall: t.bodySmall?.copyWith(color: darkOnSurfaceVariant, height: 1.35),
        labelLarge: t.labelLarge?.copyWith(color: darkOnSurfaceVariant, fontWeight: FontWeight.w600),
        labelMedium: t.labelMedium?.copyWith(color: darkOnSurface, fontWeight: FontWeight.w600),
        labelSmall: t.labelSmall?.copyWith(color: darkOnSurfaceVariant, fontWeight: FontWeight.w500),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        backgroundColor: darkSurface,
        foregroundColor: darkOnSurface,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: darkOnSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: scheme.onPrimary,
          backgroundColor: darkAccent,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkOnSurfaceVariant,
          side: BorderSide(color: darkOutlineMuted),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: darkAccent),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: darkAccent.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
            color: selected ? darkAccent : darkOnSurfaceVariant,
            height: 1.2,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? darkAccent : darkOnSurfaceVariant,
            size: 24,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSurfaceElevated,
        contentTextStyle: const TextStyle(color: darkOnSurface, fontSize: 14, height: 1.35),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: base.textTheme.titleMedium?.copyWith(color: darkOnSurface),
        subtitleTextStyle: base.textTheme.bodySmall?.copyWith(color: darkOnSurfaceVariant),
        iconColor: darkOnSurfaceVariant,
      ),
    );
  }
}
