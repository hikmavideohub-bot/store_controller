import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/store_config_service.dart';

/// =====================================================
/// AppConfig
/// -----------------------------------------------------
/// ❗ GLOBAL & FIX
/// ❗ NICHT store-spezifisch
/// =====================================================
class AppConfig {
  // =====================================================
  // 🌍 BACKEND
  // =====================================================

  /// Google Apps Script Web App URL
  static const String apiBaseUrl =
      'https://script.google.com/macros/s/AKfycbxmTLI6-1V7tELp7uvkDnCAMDCp6M5ZPsl4lZFL6KmaBRH9Hc9dqQdsgRDs0deca4RV6w/exec';

  // =====================================================
  // 🏷 APP BRANDING (DEIN PRODUKT)
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
  // 🎨 DESIGN (GLOBAL)
  // =====================================================

  static const Color primaryColor = Color(0xFF1EA54C);
  static const Color accentColor  = Colors.amber;

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
  // ⚖️ UNITS (UI-HILFE, NICHT STORE-DATEN)
  // =====================================================

  static const Map<String, String> unitLabels = {
    'g': 'غ',
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
  // 🆔 STORE ID (ZENTRAL)
  // =====================================================

  static const String _storeIdKey = 'store_id';

  static Future<String?> getStoreId() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_storeIdKey);
  }

  static Future<void> setStoreId(String id) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_storeIdKey, id);
  }

  static Future<void> clearStoreId() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_storeIdKey);
  }
  static Future<void> clearToken() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove('token');
  }
  static Future<String?> getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString('token');
  }




  // =====================================================
  // 🐞 DEBUG
  // =====================================================

  static const bool debugLogApi = true;
}
