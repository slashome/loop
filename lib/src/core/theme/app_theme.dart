import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Couleurs de marque, dérivées du logo (∞ dégradé bleu→vert, wordmark ardoise).
abstract final class AppColors {
  static const blue = Color(0xFF3B82C4);
  static const green = Color(0xFF46A758);
  static const ink = Color(0xFF2C3242); // texte principal (ardoise)
  static const muted = Color(0xFF6B7280); // texte secondaire
  static const bg = Color(0xFFF6F8FB); // fond de l'app
  static const line = Color(0xFFE6E9EF); // hairlines

  /// Le dégradé signature du logo.
  static const brand = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [blue, green],
  );

  /// Palette de priorité (chaud = urgent, bleu/vert de marque = bas).
  static const priority = {
    5: Color(0xFFE5484D),
    4: Color(0xFFF76B15),
    3: blue,
    2: green,
    1: Color(0xFF8B93A1),
  };
}

ThemeData buildAppTheme() {
  final scheme =
      ColorScheme.fromSeed(seedColor: AppColors.blue, primary: AppColors.blue)
          .copyWith(
    secondary: AppColors.green,
    surface: Colors.white,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: const Color(0xFFFBFCFD),
    surfaceContainer: const Color(0xFFF2F4F8),
    surfaceContainerHigh: const Color(0xFFEDF0F5),
    surfaceContainerHighest: const Color(0xFFE8EBF1),
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.muted,
    outline: const Color(0xFFCFD5DE),
    outlineVariant: AppColors.line,
    error: const Color(0xFFE5484D),
  );

  final text = GoogleFonts.manropeTextTheme().apply(
    bodyColor: AppColors.ink,
    displayColor: AppColors.ink,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: text,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.line),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: AppColors.blue.withValues(alpha: 0.12),
      side: const BorderSide(color: AppColors.line),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
      labelStyle: text.labelLarge?.copyWith(color: AppColors.ink),
      showCheckmark: false,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: AppColors.blue.withValues(alpha: 0.14),
      elevation: 0,
      height: 64,
      labelTextStyle: WidgetStatePropertyAll(
        text.labelMedium?.copyWith(color: AppColors.ink),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.line),
      ),
    ),
  );
}
