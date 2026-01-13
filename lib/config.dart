import 'package:flutter/material.dart';

/// =====================================================
/// AppConfig
/// -----------------------------------------------------
/// Globale App-Konstanten (NICHT store-spezifisch)
/// Auth wird von Firebase Auth + StorePrefs gehandhabt
/// =====================================================
class AppConfig {
  // =====================================================
  // 🏷 APP BRANDING
  // =====================================================

  static const String appName = 'إدارة المنتجات';
  static const String appSubtitle = 'Store Controller';
  static const String appVersion = '1.0.0';

  // =====================================================
  // 🌐 LOCALE / DIRECTION
  // =====================================================

  static const Locale appLocale = Locale('ar');
  static const List<Locale> supportedLocales = [Locale('ar')];
  static const TextDirection textDirection = TextDirection.rtl;

  // =====================================================
  // 🎨 DESIGN
  // =====================================================

  static const Color primaryColor = Color(0xFF1EA54C);
  static const Color accentColor = Colors.amber;

  static const LinearGradient appGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1EA54C),
      Colors.white,
      Colors.black,
    ],
  );

  // =====================================================
  // ⚖️ UNITS
  // =====================================================

  static const Map<String, String> unitLabels = {
    'g': 'غرام',
    'kg': 'كغ',
    'ml': 'مل',
    'l': 'لتر',
    'pcs': 'قطعة',
  };

  static String unitLabel(String raw) {
    final k = raw.trim().toLowerCase();
    return unitLabels[k] ?? raw;
  }

  // =====================================================
  // 🐞 DEBUG
  // =====================================================

  static const bool debugLogApi = true;
}
