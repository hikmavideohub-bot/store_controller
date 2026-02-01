import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- NEUE FARBPALETTE (Modern & Premium) ---

  // Primärfarbe: "Royal Indigo" - Stark, modern, vertrauenswürdig
  static const _primaryLight = Color(0xFF0288D1); // Ruhiges Blau-Aqua
  static const _primaryDark  = Color(0xFF00ACC1); // Helleres Petrol



  // Hintergrund: "Slate" (Kühles, modernes Grau statt schmutziges Braun-Grau)
// "Royal White": Rein, hell, mit einem luxuriösen, warmen Gold-Unterton.
  static const _bgLight = Color(0xFFFFFEFA);      // "Snow with Gold" - Fast Weiß, sehr edel.
  static const _bgDark = Color(0xFF14120E);       // "Onyx" - Ein sehr tiefes, warmes Schwarz.
  // Oberflächen
  static const _surfaceLight = Color(0xFFFFFFFF); // Reinweiß für maximalen Kontrast
  static const _surfaceDark = Color(0xFF1E293B);  // Slate 800 (sichtbar heller als BG)

  // Premium / Akzent (Gold - angepasst für Blau)
  static const _gold = Color(0xFFFFD700);         // Helles Gold
  static const _goldDark = Color(0xFFD4AF37);     // Metallic Gold

  // Fehler
  static const _danger = Color(0xFFEF4444);       // Modernes, klares Rot

  // --- THEME DATA BUILDER ---

  static ThemeData light() {
    return _buildTheme(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _primaryLight,
        onPrimary: Colors.white,
        secondary: _primaryLight,
        onSecondary: Colors.white,
        tertiary: _goldDark,
        surface: _surfaceLight,
        onSurface: Color(0xFF0F172A), // Fast schwarz, sehr gut lesbar
        error: _danger,
        outline: Color(0xFFE2E8F0),   // Sehr subtile Ränder
      ),
      scaffoldBg: _bgLight,
    );
  }

  static ThemeData dark() {
    return _buildTheme(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _primaryDark,
        onPrimary: Colors.black, // Schwarzer Text auf hellem Indigo liest sich besser
        secondary: _primaryDark,
        onSecondary: Colors.black,
        tertiary: _gold,
        surface: _surfaceDark,
        onSurface: Color(0xFFF1F5F9), // Helles Grauweiß
        error: _danger,
        outline: Color(0xFF334155),
      ),
      scaffoldBg: _bgDark,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color scaffoldBg,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: GoogleFonts.cairoTextTheme(
        brightness == Brightness.dark
            ? ThemeData.dark().textTheme
            : ThemeData.light().textTheme,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );

    return base.copyWith(
      // AppBar: Clean & Modern
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0, // Flach bleiben, auch beim Scrollen
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),

      // Cards: Etwas modernerer Schatten
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0, // Flat Design Trend (oder sehr niedrig)
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outline.withAlpha(50), // Feine Outline statt fetter Schatten
            width: 1,
          ),
        ),
      ),

      // Buttons: Kräftiger und runder
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          shadowColor: colorScheme.primary.withAlpha(100), // Farbiger Schatten (Glow-Effekt)
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Inputs: Sehr clean
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.dark
            ? const Color(0xFF0F172A) // Dunkler als Surface für Tiefe
            : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outline), // Subtiler Rahmen
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),

      // Bottom Nav
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        elevation: 0, // Modernes Flat-Design (kein Schatten oben)
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // Dialoge
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 10,
      ),
    );
  }
}