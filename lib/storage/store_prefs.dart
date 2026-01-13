import 'package:shared_preferences/shared_preferences.dart';

class StorePrefs {
  // Haupt-Key (neu & einheitlich)
  static const String _kStoreId = 'store_id';

  // Legacy / Fallback (für alte Versionen)
  static const String _kStoreIdLegacy = 'storeId';

  /// ================================
  /// 📦 StoreId lesen (robust)
  /// ================================
  static Future<String?> getStoreId() async {
    final sp = await SharedPreferences.getInstance();

    // 1) Neuer Key
    final id = sp.getString(_kStoreId);
    if (id != null && id.trim().isNotEmpty) {
      return id.trim();
    }

    // 2) Fallback: alter Key
    final legacy = sp.getString(_kStoreIdLegacy);
    if (legacy != null && legacy.trim().isNotEmpty) {
      // 🔁 migrieren auf neuen Key
      await sp.setString(_kStoreId, legacy.trim());
      await sp.remove(_kStoreIdLegacy);
      return legacy.trim();
    }

    return null;
  }

  /// ================================
  /// 💾 StoreId speichern
  /// ================================
  static Future<void> setStoreId(String id) async {
    final clean = id.trim();
    if (clean.isEmpty) return;

    final sp = await SharedPreferences.getInstance();

    // neu + legacy (für maximale Kompatibilität)
    await sp.setString(_kStoreId, clean);
    await sp.setString(_kStoreIdLegacy, clean);
  }

  /// ================================
  /// ❌ StoreId löschen
  /// ================================
  static Future<void> clearStoreId() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kStoreId);
    await sp.remove(_kStoreIdLegacy);
  }

  /// ================================
  /// 🧹 Komplett-Reset (optional)
  /// ================================
  static Future<void> clearAll() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kStoreId);
    await sp.remove(_kStoreIdLegacy);
  }
}
