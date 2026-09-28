import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier(ThemeMode.light);

  static void toggleTheme() {
    themeMode.value = themeMode.value == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  // ─── Brand Colors ───────────────────────────────────────────────────────────
  // Modern Healthcare Color Palette
  static const Color primary = Color(0xFF0F766E);        // Deep teal
  static const Color primaryDark = Color(0xFF115E59);    // Forest teal
  static const Color primaryLight = Color(0xFF14B8A6);   // Fresh mint
  static const Color secondary = Color(0xFFF97316);      // Warm coral
  static const Color accent = Color(0xFFF59E0B);         // Amber
  static const Color success = Color(0xFF16A34A);        // Green
  static const Color warning = Color(0xFFEA580C);        // Orange
  static const Color danger = Color(0xFFDC2626);         // Red
  static const Color purple = Color(0xFF6366F1);         // Indigo accent
  static const Color pink = Color(0xFFEC4899);            // Pink accent

  // ─── Theme-aware Backgrounds, Surfaces & Text ───────────────────────────────
  static bool get isDark => themeMode.value == ThemeMode.dark;
  static Color get bgDark => isDark ? const Color(0xFF09201F) : const Color(0xFFF2FAF8);
  static Color get bgDarker => isDark ? const Color(0xFF061413) : const Color(0xFFDCEFEA);
  static Color get bgCard => isDark ? const Color(0xFF102B29) : Colors.white;
  static Color get bgCard2 => isDark ? const Color(0xFF173A37) : const Color(0xFFEAF6F3);
  static Color get bgCardGlass => isDark ? const Color(0xE6102B29) : const Color(0xF5FFFFFF);
  static Color get borderLight => isDark ? const Color(0xFF347A70) : const Color(0xFF8ED3C7);
  static Color get borderSubtle => isDark ? const Color(0xFF286057) : const Color(0xFFBFE6DD);
  static Color get textPrimary => isDark ? const Color(0xFFF1FFFC) : const Color(0xFF123532);
  static Color get textSecondary => isDark ? const Color(0xFFA7D2C9) : const Color(0xFF486F69);
  static Color get textMuted => isDark ? const Color(0xFF78A9A0) : const Color(0xFF72938E);
  static Color get divider => isDark ? const Color(0xFF24504A) : const Color(0xFFC9E4DE);

  // ─── Gradients ──────────────────────────────────────────────────────────────
  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get accentGradient => const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get purpleGradient => const LinearGradient(
        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get successGradient => const LinearGradient(
        colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get dangerGradient => const LinearGradient(
        colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get warningGradient => const LinearGradient(
        colors: [Color(0xFFFBBF24), Color(0xFFEA580C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get darkGradient => const LinearGradient(
        colors: [Color(0xFFDCEFEA), Color(0xFFF2FAF8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get glassGradient => LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.95),
          Colors.white.withValues(alpha: 0.65),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // Premium Multi-color Gradient
  static LinearGradient get premiumGradient => const LinearGradient(
        colors: [
          Color(0xFF0F766E),
          Color(0xFFF97316),
          Color(0xFFF59E0B),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.5, 1.0],
      );

  // ─── Reusable Glassmorphism Card Decoration ─────────────────────────────────
  static BoxDecoration glassBox({
    Color? color,
    Color? borderColor,
    double borderRadius = 20,
    List<BoxShadow>? shadows,
    Gradient? gradient,
  }) {
    return BoxDecoration(
      color: color ?? bgCardGlass,
      gradient: gradient,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? primaryLight.withValues(alpha: 0.38),
        width: 1.2,
      ),
      boxShadow: shadows ??
          [
            BoxShadow(
              color: primary.withValues(alpha: 0.16),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: secondary.withValues(alpha: 0.10),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
    );
  }

  // ─── Theme Data ─────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgDark,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: bgCard,
        error: danger,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textPrimary,
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderSubtle, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: primary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgCard2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: borderSubtle, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: danger, width: 1),
        ),
        labelStyle: GoogleFonts.poppins(color: textSecondary, fontSize: 14),
        hintStyle: GoogleFonts.poppins(color: textMuted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
    );
  }

  static ThemeData get darkTheme {
    const background = Color(0xFF09201F);
    const surface = Color(0xFF102B29);
    const surfaceVariant = Color(0xFF173A37);
    const subtleBorder = Color(0xFF286057);
    const primaryText = Color(0xFFF1FFFC);
    const secondaryText = Color(0xFFA7D2C9);
    const mutedText = Color(0xFF78A9A0);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: danger,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primaryText,
        iconTheme: IconThemeData(color: primaryText),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: subtleBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: primary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: subtleBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: danger),
        ),
        labelStyle: GoogleFonts.poppins(color: secondaryText, fontSize: 14),
        hintStyle: GoogleFonts.poppins(color: mutedText, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
    );
  }
}

