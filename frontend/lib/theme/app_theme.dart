import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Core Colors ──
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceLight = Color(0xFF1C2333);
  static const Color surfaceBorder = Color(0xFF2A3140);
  static const Color cardBackground = Color(0xFF1A1F2E);
  static const Color cardBorder = Color(0xFF2D3548);

  // ── Accent Colors ──
  static const Color primary = Color(0xFF7C5CFC);
  static const Color primaryLight = Color(0xFF9B7FFF);
  static const Color secondary = Color(0xFF4ECDC4);
  static const Color accent = Color(0xFF00D4AA);
  static const Color accentPink = Color(0xFFFF6B9D);
  static const Color accentOrange = Color(0xFFFF9F43);
  static const Color accentBlue = Color(0xFF54A0FF);

  // ── Text Colors ──
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted = Color(0xFF6E7681);

  // ── Status Colors ──
  static const Color success = Color(0xFF3FB950);
  static const Color warning = Color(0xFFD29922);
  static const Color error = Color(0xFFF85149);
  static const Color info = Color(0xFF58A6FF);

  // ── Gradient ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C5CFC), Color(0xFF4ECDC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient ctaGradient = LinearGradient(
    colors: [Color(0xFF7C5CFC), Color(0xFF9B7FFF), Color(0xFF4ECDC4)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient sliderGradient = LinearGradient(
    colors: [Color(0xFF4ECDC4), Color(0xFF7C5CFC)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ── Border Radius ──
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusFull = 100.0;

  // ── Spacing ──
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 20.0;
  static const double spacingXxl = 24.0;

  // ── ThemeData ──
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
