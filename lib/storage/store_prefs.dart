import 'package:shared_preferences/shared_preferences.dart';

class StorePrefs {
  static const String _kStoreId = 'store_id';

  /// ================================
  /// 📦 StoreId lesen
  /// ================================
  static Future<String?> getStoreId() async {
    final sp = await SharedPreferences.getInstance();
    final id = sp.getString(_kStoreId);
    if (id != null && id.trim().isNotEmpty) {
      return id.trim();
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
    await sp.setString(_kStoreId, clean);
  }

  /// ================================
  /// ❌ StoreId löschen
  /// ================================
  static Future<void> clearStoreId() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kStoreId);
  }

  /// ================================
  /// 🧹 Komplett-Reset
  /// ================================
  static Future<void> clearAll() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kStoreId);
  }
}
