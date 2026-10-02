import 'package:flutter/material.dart';

/// Central place for colors, text styles and shared decorations so every
/// screen looks consistent with the NeuroInsight-PD design.
///
/// This palette mirrors the web portal's (`SeniorProject-Web-`) design
/// system (`lib/core/theme/app_colors.dart`) — same navy brand color, same
/// neutrals and status tones — so the patient app and the doctor/
/// radiologist web portal read as one product.
class AppColors {
  // Brand (matches web AppColors.navy / accentBlue)
  static const primary = Color(0xFF0B2545);
  static const primaryDark = Color(0xFF081A33);
  static const accent = Color(0xFF2F6DB5);
  static const softBlue = Color(0xFFE6EEF8);

  // Neutrals
  static const background = Color(0xFFF5F7FA);
  static const cardBackground = Colors.white;
  static const textPrimary = Color(0xFF14213D);
  static const textSecondary = Color(0xFF52607A);
  static const border = Color(0xFFDCE3EB);
  static const borderStrong = Color(0xFF7D8A9C);

  // Status
  static const success = Color(0xFF1C6536);
  static const warning = Color(0xFF774A00);
  static const danger = Color(0xFFB3261E);

  // Status badge / chip tones (background / foreground pairs)
  static const chipViewedBg = Color(0xFFE3F3E8);
  static const chipViewedText = Color(0xFF1C6536);
  static const chipNewBg = Color(0xFFE6EEF8);
  static const chipNewText = Color(0xFF0B2545);
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
      ).copyWith(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.softBlue,
        onPrimaryContainer: AppColors.primary,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        surface: AppColors.cardBackground,
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.borderStrong,
        outlineVariant: AppColors.border,
        error: AppColors.danger,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.borderStrong),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}

/// Reusable card decoration used across profile / report / upload screens.
BoxDecoration cardDecoration() {
  return BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: AppColors.border),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
