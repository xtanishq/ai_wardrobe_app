import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core dark theme
  static const Color backgroundDark = Color(0xFF0B0B0F);
  static const Color backgroundLight = Color(0xFF121217);
  static const Color surfacePrimary = Color(0xFF1A1A22);
  static const Color surfaceSecondary = Color(0xFF202129);
  static const Color surfaceTertiary = Color(0xFF292A33);

  // Text
  static const Color textMain = Color(0xFFF7F7FA);
  static const Color textSecondary = Color(0xFFD6D6DF);
  static const Color textMuted = Color(0xFF9A9AAA);
  static const Color textDisabled = Color(0xFF666674);

  // Main brand gradient
  static const Color accentPurple = Color(0xFF9A8CFF);
  static const Color accentBlue = Color(0xFFFFC978);
  // Better premium supporting accents
  static const Color accentLavender = Color(0xFF9B8CFF);
  static const Color accentSky = Color(0xFF64D2FF);
  static const Color accentWarm = Color(0xFFFFC978);

  // Borders / dividers
  static const Color borderSubtle = Color(0x1FFFFFFF); // 12% white
  static const Color borderMedium = Color(0x33FFFFFF); // 20% white

  // Cards
  static const Color cardDark = Color(0xFF15151C);
  static const Color cardElevated = Color(0xFF1C1D25);
  static const Color cardSelected = Color(0xFF242536);

  // Bottom navigation
  static const Color navBackground = Color(0xFF171820);
  static const Color navSelected = Color(0xFF8A72FF);
  static const Color navUnselected = Color(0xFF8B8B9A);

  // Image overlay colors
  static const Color imageOverlayDark = Color(0x99000000); // 60% black
  static const Color imageOverlaySoft = Color(0x66000000); // 40% black

  // Legacy aliases
  static const Color primary = accentPurple;
  static const Color background = backgroundDark;
  static const Color surface = surfacePrimary;

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    primaryColor: accentPurple,
    colorScheme: const ColorScheme.dark(
      primary: accentPurple,
      secondary: accentBlue,
      surface: surfacePrimary,
      background: backgroundDark,
      onPrimary: Colors.white,
      onSurface: textMain,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textMain),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: backgroundDark,
      ),
    ),
    textTheme: GoogleFonts.outfitTextTheme().apply(
      bodyColor: textMain,
      displayColor: textMain,
    ).copyWith(
      displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textMain),
      displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textMain),
      displaySmall: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textMain),
      headlineLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textMain),
      headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textMain),
      headlineSmall: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textMain),
      titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textMain),
      bodyLarge: GoogleFonts.outfit(color: textMain, letterSpacing: 0.5),
      bodyMedium: GoogleFonts.outfit(color: textMain, letterSpacing: 0.5),
    ),
  );
}
