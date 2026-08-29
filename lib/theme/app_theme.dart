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
  static const Color primary = Color(0xFF1E88E5);        // Modern Blue
  static const Color primaryDark = Color(0xFF1565C0);     // Deep Blue
  static const Color primaryLight = Color(0xFF42A5F5);    // Light Blue
  static const Color secondary = Color(0xFF7C4DFF);       // Vibrant Purple
  static const Color accent = Color(0xFF00BCD4);         // Cyan
  static const Color success = Color(0xFF26A69A);        // Teal Green
  static const Color warning = Color(0xFFFF6F00);        // Deep Orange
  static const Color danger = Color(0xFFE53935);         // Red
  static const Color purple = Color(0xFF9C27B0);         // Purple
  static const Color pink = Color(0xFFEC407A);           // Hot Pink

  // ─── Theme-aware Backgrounds, Surfaces & Text ───────────────────────────────
  static bool get isDark => themeMode.value == ThemeMode.dark;
  static Color get bgDark => isDark ? const Color(0xFF0A0E27) : const Color(0xFFF0F4FF);
  static Color get bgDarker => isDark ? const Color(0xFF050812) : const Color(0xFFE3EBFF);
  static Color get bgCard => isDark ? const Color(0xFF0F1729) : Colors.white;
  static Color get bgCard2 => isDark ? const Color(0xFF1A2847) : const Color(0xFFF5F8FF);
  static Color get bgCardGlass => isDark ? const Color(0xDD0F1729) : const Color(0xF7FFFFFF);
  static Color get borderLight => isDark ? const Color(0xFF2A3F5F) : const Color(0xFFD0DDF0);
  static Color get borderSubtle => isDark ? const Color(0xFF1E2E48) : const Color(0xFFDEE8F5);
  static Color get textPrimary => isDark ? const Color(0xFFF8FAFF) : const Color(0xFF0D1B3D);
  static Color get textSecondary => isDark ? const Color(0xFF9CB3D1) : const Color(0xFF445A7F);
  static Color get textMuted => isDark ? const Color(0xFF6B8AC4) : const Color(0xFF7A92B3);
  static Color get divider => isDark ? const Color(0xFF1C2D44) : const Color(0xFFD5DEF0);

  // ─── Gradients ──────────────────────────────────────────────────────────────
  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get accentGradient => const LinearGradient(
        colors: [Color(0xFF00BCD4), Color(0xFF1E88E5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get purpleGradient => const LinearGradient(
        colors: [Color(0xFF9C27B0), Color(0xFF7C4DFF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get successGradient => const LinearGradient(
        colors: [Color(0xFF26A69A), Color(0xFF009688)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get dangerGradient => const LinearGradient(
        colors: [Color(0xFFE53935), Color(0xFFC62828)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get warningGradient => const LinearGradient(
        colors: [Color(0xFFFF6F00), Color(0xFFE65100)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get darkGradient => const LinearGradient(
        colors: [Color(0xFFE3EBFF), Color(0xFFF0F4FF)],
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
          Color(0xFF1E88E5),
          Color(0xFF7C4DFF),
          Color(0xFF00BCD4),
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
        color: borderColor ?? borderLight.withValues(alpha: 0.7),
        width: 1.2,
      ),
      boxShadow: shadows ??
          [
            BoxShadow(
              color: const Color(0xFF1E88E5).withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: const Color(0xFF7C4DFF).withValues(alpha: 0.06),
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
    const background = Color(0xFF0A0E27);
    const surface = Color(0xFF0F1729);
    const surfaceVariant = Color(0xFF1A2847);
    const subtleBorder = Color(0xFF1E2E48);
    const primaryText = Color(0xFFF8FAFF);
    const secondaryText = Color(0xFF9CB3D1);
    const mutedText = Color(0xFF6B8AC4);

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
