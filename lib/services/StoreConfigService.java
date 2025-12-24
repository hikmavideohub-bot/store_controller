import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class StoreConfigService {
  static const _cacheKey = 'store_config_cache_v1';

  static Map<String, dynamic>? _store;
  static Map<String, dynamic>? get store => _store;
  static bool get isLoaded => _store != null;

  /// ✅ Standard: NICHT jedes Mal Netzwerk.
  /// Lädt zuerst aus Memory, dann aus Disk.
  /// Optional (nur wenn Cache leer): einmal Netzwerk.
  static Future<void> load({bool allowNetworkIfEmpty = true}) async {
    // 1) Memory cache
    if (_store != null) return;

    // 2) Disk cache
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_cacheKey);
    if (raw != null && raw.trim().isNotEmpty) {
      try {
        final decoded = json.decode(raw);
        if (decoded is Map) {
          _store = Map<String, dynamic>.from(decoded);
          return;
        }
      } catch (_) {}
    }

    // 3) First time only (optional)
    if (!allowNetworkIfEmpty) return;

    final fresh = await ApiService.fetchStoreConfig(); // ✅ nutzt deinen ApiService
    if (fresh != null) {
      await set(fresh);
    }
  }

  /// ✅ Force refresh (für Button "تحديث")
  static Future<Map<String, dynamic>?> refresh() async {
    final fresh = await ApiService.fetchStoreConfig();
    if (fresh == null) return null;
    await set(fresh);
    return _store;
  }

  /// ✅ Cache schreiben (memory + disk)
  static Future<void> set(Map<String, dynamic> s) async {
    _store = Map<String, dynamic>.from(s);
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_cacheKey, json.encode(_store));
  }

  /// ✅ Nach updateStore: sofort lokal updaten (ohne Netz)
  static Future<void> merge(Map<String, dynamic> patch) async {
    final current = _store ?? <String, dynamic>{};
    current.addAll(patch); // patch ist bei dir snake_case -> passt zu _fill()
    await set(current);
  }

  static Future<void> clear() async {
    _store = null;
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_cacheKey);
  }
}
