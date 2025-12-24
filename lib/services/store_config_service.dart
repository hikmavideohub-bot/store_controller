import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class StoreConfigService {
  static const _cacheKey = 'store_config_cache_v1';

  /// ✅ Reactive state: alle Screens können darauf hören
  static final ValueNotifier<Map<String, dynamic>?> storeNotifier =
  ValueNotifier<Map<String, dynamic>?>(null);

  /// ✅ Backwards compatible: wie vorher StoreConfigService.store
  static Map<String, dynamic>? get store => storeNotifier.value;

  static bool get isLoaded => storeNotifier.value != null;

  static void _setStore(Map<String, dynamic>? s) {
    // Wichtig: immer neue Map setzen, damit Listener sauber triggern
    storeNotifier.value = (s == null) ? null : Map<String, dynamic>.from(s);
  }

  /// ✅ Standard: NICHT jedes Mal Netzwerk.
  /// Lädt zuerst aus Memory, dann aus Disk.
  /// Optional (nur wenn Cache leer): einmal Netzwerk.
  /// Zusätzlich: optional background refresh wenn Cache vorhanden ist.
  static Future<void> load({
    bool allowNetworkIfEmpty = true,
    bool backgroundRefreshIfCached = true,
  }) async {
    // 1) Memory cache
    if (storeNotifier.value != null) return;

    // 2) Disk cache
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_cacheKey);
    if (raw != null && raw.trim().isNotEmpty) {
      try {
        final decoded = json.decode(raw);
        if (decoded is Map) {
          _setStore(Map<String, dynamic>.from(decoded));

          // Optional: im Hintergrund aktualisieren (macht App "fresh", ohne Loader)
          if (backgroundRefreshIfCached) {
            // ignore: unawaited_futures
            _refreshInBackground();
          }
          return;
        }
      } catch (_) {
        // ignore
      }
    }

    // 3) First time only (optional)
    if (!allowNetworkIfEmpty) return;

    final fresh = await ApiService.fetchStoreConfig();
    if (fresh != null) {
      await set(fresh);
    }
  }

  /// ✅ Force refresh (für Button "تحديث")
  static Future<Map<String, dynamic>?> refresh() async {
    final fresh = await ApiService.fetchStoreConfig();
    if (fresh == null) return null;
    await set(fresh);
    return storeNotifier.value;
  }

  /// ✅ Cache schreiben (memory + disk) + reactive update
  static Future<void> set(Map<String, dynamic> s) async {
    final copy = Map<String, dynamic>.from(s);
    _setStore(copy);

    final sp = await SharedPreferences.getInstance();
    await sp.setString(_cacheKey, json.encode(copy));
  }

  /// ✅ Nach updateStore: sofort lokal updaten (ohne Netz) + reactive update
  static Future<void> mergeNonEmpty(Map<String, dynamic> patch) async {
    final current = Map<String, dynamic>.from(storeNotifier.value ?? {});
    patch.forEach((k, v) {
      if (v == null) return;
      if (v is String && v.trim().isEmpty) return; // skip leere Strings
      current[k] = v;
    });
    await set(current);
  }

  static Future<void> clear() async {
    _setStore(null);
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_cacheKey);
  }

  /// Hintergrund-Refresh: niemals UI blockieren
  static Future<void> _refreshInBackground() async {
    try {
      final fresh = await ApiService.fetchStoreConfig();
      if (fresh != null) {
        await set(fresh);
      }
    } catch (_) {
      // still ignore background failures
    }
  }
}
