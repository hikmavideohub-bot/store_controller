import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand-Palette (Wolf / Gold / Dark)
  static const Color bg = Color(0xFF0B0B0D);          // fast schwarz
  static const Color surface = Color(0xFF141418);     // Cards / Flächen
  static const Color surface2 = Color(0xFF1B1B22);    // leicht heller
  static const Color gold = Color(0xFFFFC24A);        // Hauptgold
  static const Color gold2 = Color(0xFFFFD77A);       // Highlight-Gold
  static const Color text = Color(0xFFF2F2F2);        // Text hell
  static const Color muted = Color(0xFFB8B8C2);       // Subtext
  static const Color danger = Color(0xFFE0474C);      // Fehler
  static const Color outline = Color(0xFF2A2A33);     // Borders
  static const Color darkGold = Color(0xFF8C6A2B);


  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: text,
        displayColor: text,
      ),
      colorScheme: const ColorScheme.dark(
        primary: gold,
        secondary: gold2,
        surface: surface,
        error: danger,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: text,
        onError: Colors.white,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: bg,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        centerTitle: true,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      // Cards
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: outline, width: 1),
        ),
      ),

      // Divider / Outline
      dividerTheme: const DividerThemeData(
        color: outline,
        thickness: 1,
        space: 24,
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: gold,
          side: const BorderSide(color: gold, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFFFC24A),
        foregroundColor: Colors.black,
        elevation: 0,
      ),


      // Inputs (TextField etc.)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2,
        hintStyle: const TextStyle(color: muted),
        labelStyle: const TextStyle(color: muted),
        prefixIconColor: muted,
        suffixIconColor: muted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: gold, width: 1.6),
        ),
      ),

      // Switch / Checkbox / Radio
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) return gold;
          return muted;
        }),
        trackColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) return gold.withValues(alpha:0.35);
          return outline;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) return gold;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.black),
        side: const BorderSide(color: outline, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),

      // Snackbars
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: surface2,
        contentTextStyle: const TextStyle(color: text),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      // Icons
      iconTheme: const IconThemeData(color: text),

      // BottomNavigation (wichtig, weil HomeShell)
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bg,
        selectedItemColor: gold,
        unselectedItemColor: muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Page transitions (optional, fühlt sich “smooth” an)
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // Optional: Light (falls du es behalten willst). Sonst kannst du es löschen.
  static ThemeData light() {
    // Porcelain Light
    const bg = Color(0xFFF6F5F2);
    const surface = Color(0xFFFFFFFF);
    const surface2 = Color(0xFFF1F0EB);
    const outline = Color(0xFFE6E3DC);
    const Color _darkGold = Color(0xFF8C6A2B);


    const text = Color(0xFF141416);
    const muted = Color(0xFF6E6E78);

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: text,
        displayColor: text,
      ),
      colorScheme: const ColorScheme.light(
        primary: gold,       // ✅ dein Gold bleibt "Premium-Akzent"
        secondary: gold2,
        surface: surface,
        error: danger,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: text,
        onError: Colors.white,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: bg,

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent, // ✅ wirkt "leicht"
        foregroundColor: text,
        centerTitle: true,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: outline, width: 1),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: outline,
        thickness: 1,
        space: 24,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          side: const BorderSide(color: outline, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2,
        hintStyle: const TextStyle(color: muted),
        labelStyle: const TextStyle(color: muted),
        prefixIconColor: muted,
        suffixIconColor: muted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: gold, width: 1.6),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: surface,
        contentTextStyle: const TextStyle(color: text),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: gold,
        unselectedItemColor: muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
