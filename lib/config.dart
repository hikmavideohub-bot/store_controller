import 'package:flutter/material.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';

/// =====================================================
/// AppConfig
/// -----------------------------------------------------
/// Globale App-Konstanten und Helper
/// =====================================================
class AppConfig {
  // =====================================================
  // 🏷 APP META
  // =====================================================

  static const String appVersion = '1.0.0';

  /// Maximale Anzahl an Produkten für die kostenlose Version
  static const int maxFreeProducts = 400;

  // =====================================================
  // 🌐 LOCALE CONFIGURATION
  // =====================================================

  // Wir entfernen 'appLocale' und 'textDirection', damit die App
  // die Systemeinstellungen oder den User-Switch nutzt.
  static const List<Locale> supportedLocales = [
    Locale('ar'), // Arabisch
    Locale('en'), // Englisch
    Locale('de'), // Deutsch (NEU)
    Locale('tr'), // Türkisch (NEU)
  ];

  // =====================================================
  // ⚖️ UNITS HELPER
  // =====================================================

  /// Gibt die lokalisierte Einheit zurück.
  /// Benötigt [AppLocalizations], da Strings jetzt dynamisch sind.
  static String unitLabel(String raw, AppLocalizations s) {
    final k = raw.trim().toLowerCase();
    switch (k) {
      case 'g':
        return s.unitG;
      case 'kg':
        return s.unitKg;
      case 'ml':
        return s.unitMl;
      case 'l':
        return s.unitL;
      case 'pcs':
        return s.unitPcs;
      default:
        return raw;
    }
  }

  // =====================================================
  // 🐞 DEBUG
  // =====================================================

  static const bool debugLogApi = false;
}