// lib/core/access_manager.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AccessManager mit Singleton + ChangeNotifier + Cache
/// ✅ Server-driven Access mit TTL-Cache
/// ✅ Statische Getter für einfachen Zugriff
/// ✅ ChangeNotifier für UI-Reaktivitat
/// ✅ SharedPreferences als Fallback nach Neustart
class AccessManager extends ChangeNotifier {
  // ============================
  // Singleton Pattern
  // ============================
  static final AccessManager _instance = AccessManager._internal();
  factory AccessManager() => _instance;
  AccessManager._internal();

  // ============================
  // Private Fields
  // ============================
  static const String _prefsKey = 'cached_access';
  Map<String, dynamic>? _access;
  bool _isLoaded = false;
  DateTime? _lastUpdated;

  // ============================
  // Öffentliche Getter (Type-Safe!)
  // ============================

  /// Access-Daten (raw)
  static Map<String, dynamic>? get access => _instance._access;

  /// Sind Access-Daten geladen?
  static bool get isLoaded => _instance._isLoaded;

  /// Wann wurden die Daten zuletzt aktualisiert?
  static DateTime? get lastUpdated => _instance._lastUpdated;

  /// Flags (type-safe)
  static Map<String, dynamic> get flags {
    final f = _instance._access?['flags'];
    return f is Map ? Map<String, dynamic>.from(f) : <String, dynamic>{};
  }

  /// Kann Admin-Bereich schreiben (Backend-spezifisch)
  static bool get canWriteAdmin => flags['canWriteAdmin'] == true;

  /// Kann Preise öffentlich anzeigen
  static bool get canShowPricesPublic => flags['canShowPricesPublic'] == true;

  /// Kann Größen öffentlich anzeigen
  static bool get canShowSizesPublic => flags['canShowSizesPublic'] == true;

  /// Kann Bilder öffentlich anzeigen
  static bool get canShowImagesPublic => flags['canShowImagesPublic'] == true;

  /// Kann Kontakt öffentlich anzeigen
  static bool get canShowContactPublic => flags['canShowContactPublic'] == true;


  /// Stage (type-safe mit Fallback)
  static int get stage {
    final s = _instance._access?['stage'];
    if (s is int) return s;
    if (s is num) return s.round(); // ✅ auch double abfangen
    return int.tryParse('$s') ?? -1;
  }

  /// Verbleibende Tage (optional)
  static int? get daysRemaining {
    final d = _instance._access?['daysRemaining'];
    if (d is int) return d;
    if (d is num) return d.round(); // ✅ auch 7.0 -> 7
    if (d is String) return int.tryParse(d);
    return null;
  }


  /// Status (type-safe mit Fallback)
  static String get status => (_instance._access?['status'] ?? '').toString().toLowerCase();

  /// Banner Key vom Server
  static String get banner => (_instance._access?['banner'] ?? '').toString();




  // ============================
  // Cache Management
  // ============================

  /// Lädt gecachten Access aus SharedPreferences (in main() aufrufen!)
  static Future<void> loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_prefsKey);

      if (cachedJson != null && cachedJson.isNotEmpty) {
        final decoded = json.decode(cachedJson) as Map<String, dynamic>;

        // Prüfe TTL (30 Minuten, nicht 1 Stunde)
        final cachedAtStr = decoded['_cachedAt'] as String?;
        if (cachedAtStr != null) {
          final cachedAt = DateTime.tryParse(cachedAtStr);

          if (cachedAt != null &&
              DateTime.now().difference(cachedAt) < const Duration(minutes: 30)) {
            _instance._access = decoded;
            _instance._isLoaded = true;
            _instance._lastUpdated = cachedAt;

            if (kDebugMode) {
              print('✅ AccessManager: Loaded from cache (${cachedAt.toLocal()})');
              print('   → status: ${status}, stage: $stage, canWriteAdmin: $canWriteAdmin');
            }
            return;
          }

          if (kDebugMode) {
            print('⚠️ AccessManager: Cache expired (older than 30 minutes)');
          }
        }
      }
    } catch (e, st) {
      if (kDebugMode) {
        print('❌ AccessManager: Failed to load cache');
        print('   Error: $e');
        print('   Stack: $st');
      }
    }

    _instance._isLoaded = false;
  }

  /// Speichert Access in SharedPreferences (private)
  Future<void> _saveToCache(Map<String, dynamic> access) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = json.encode(access);
      await prefs.setString(_prefsKey, jsonStr);
    } catch (e) {
      if (kDebugMode) {
        print('❌ AccessManager: Failed to save cache: $e');
      }
    }
  }

  // ============================
  // Update Methods
  // ============================

  /// Haupt-Update Methode (von ApiService aufrufen)
  static void updateFromApi(Map<String, dynamic> accessJson) {
    _instance._updateInternal(accessJson);
  }

  /// Alternative Methode (gleiche Logik)
  static void updateFromServer(Map<String, dynamic>? accessJson) {
    if (accessJson == null || accessJson.isEmpty) return;
    _instance._updateInternal(accessJson);
  }

  /// Interne Update-Logik
  void _updateInternal(Map<String, dynamic> accessJson) {
    try {
      // Validiere required fields
      if (accessJson['status'] == null || accessJson['stage'] == null) {
        if (kDebugMode) {
          print('⚠️ AccessManager: Missing required fields in accessJson');
        }
        return;
      }

      // Erstelle Kopie mit Timestamp
      final now = DateTime.now();
      final updatedAccess = Map<String, dynamic>.from(accessJson)
        ..['_cachedAt'] = now.toIso8601String();

      // Update internen State
      final oldStatus = status;
      final oldStage = stage;
      final oldCanWrite = canWriteAdmin;

      _access = updatedAccess;
      _isLoaded = true;
      _lastUpdated = now;

      // In Cache speichern (async, kein await)
      unawaited(_saveToCache(updatedAccess));

      // Notify Listener (UI reagiert)
      notifyListeners();

      // Debug-Log
      if (kDebugMode) {
        final newStatus = status;
        final newStage = stage;
        final newCanWrite = canWriteAdmin;

        print('🔄 AccessManager: Updated from server');
        print('   → status: $oldStatus → $newStatus');
        print('   → stage: $oldStage → $newStage');
        print('   → canWriteAdmin: $oldCanWrite → $newCanWrite');
        if (daysRemaining != null) {
          print('   → daysRemaining: $daysRemaining');
        }
      }
    } catch (e, st) {
      if (kDebugMode) {
        print('❌ AccessManager: Failed to update');
        print('   Error: $e');
        print('   Stack: $st');
      }
    }
  }

  // ============================
  // Utility Methods
  // ============================

  /// Prüft ob Cache gültig ist (max. 30 Minuten alt)
  static bool get isCacheValid {
    final cachedAtStr = _instance._access?['_cachedAt'] as String?;
    if (cachedAtStr == null) return false;

    final cachedAt = DateTime.tryParse(cachedAtStr);
    if (cachedAt == null) return false;

    return DateTime.now().difference(cachedAt) < const Duration(minutes: 30);
  }

  /// Prüft ob Trial aktiv ist
  static bool get isTrial => status == 'trial';

  /// Prüft ob abgelaufen
  static bool get isExpired => status == 'expired';

  /// Prüft ob aktiv/bezahlt
  static bool get isActive => status == 'active';

  /// Prüft ob suspendiert
  static bool get isSuspended => status == 'suspended';

  /// Löscht Cache (bei Logout)
  static Future<void> clear() async {
    _instance._access = null;
    _instance._isLoaded = false;
    _instance._lastUpdated = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
    } catch (_) {}

    _instance.notifyListeners();

    if (kDebugMode) {
      print('🧹 AccessManager: Cleared');
    }
  }

  /// Debug-Ausgabe
  static void debugPrint() {
    if (kDebugMode) {
      print('=== AccessManager Debug ===');
      print('isLoaded: $isLoaded');
      print('lastUpdated: $lastUpdated');
      print('status: $status');
      print('stage: $stage');
      print('canWriteAdmin: $canWriteAdmin');
      print('banner: $banner');
      print('daysRemaining: $daysRemaining');
      print('flags: $flags');
      print('=========================');
    }
  }
}