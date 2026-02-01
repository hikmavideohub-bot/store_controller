// lib/core/access_manager.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// ACCESS MANAGER - Server-gesteuerte Zugriffslogik
// ═══════════════════════════════════════════════════════════════════════════════
//
// ARCHITEKTUR:
// - Access-Daten kommen NUR aus stores_private (via ApiService.fetchStoreConfig)
// - Stage steuert die öffentliche Sichtbarkeit:
//   - Stage 0-2: Store ist öffentlich sichtbar
//   - Stage >= 3: Store ist gesperrt/privat
//
// STATUS:
// - 'active': Volles Abo aktiv
// - 'trial': Testphase läuft
// - 'expired': Testphase/Abo abgelaufen
// - 'suspended': Account gesperrt
//
// STAGE (bei expired):
// - 0: Voller Zugriff (Testphase)
// - 1: Bilder öffentlich versteckt
// - 2: Preise öffentlich versteckt
// - 3: Store komplett privat
// ═══════════════════════════════════════════════════════════════════════════════

class AccessManager extends ChangeNotifier {
  static final AccessManager _instance = AccessManager._internal();
  factory AccessManager() => _instance;
  AccessManager._internal();

  static const String _prefsKey = 'cached_access';
  Map<String, dynamic>? _access;
  bool _isLoaded = false;

  static Map<String, dynamic>? get access => _instance._access;
  static bool get isLoaded => _instance._isLoaded;

  // ═══════════════════════════════════════════════════════════════════════════
  // SERVER-DRIVEN STATUS & STAGE
  // ═══════════════════════════════════════════════════════════════════════════

  static String get status =>
      (_instance._access?['status'] ?? '').toString().toLowerCase();

  static int get stage {
    final s = _instance._access?['stage'];
    if (s is int) return s;
    return int.tryParse('$s') ?? 0;
  }

  static int? get daysRemaining {
    final d = _instance._access?['daysRemaining'];
    if (d is int) return d;
    return int.tryParse('$d');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STATUS CHECKS
  // ═══════════════════════════════════════════════════════════════════════════

  static bool get isActive => status == 'active';
  static bool get isTrial => status == 'trial';
  static bool get isExpired => status == 'expired';
  static bool get isSuspended => status == 'suspended';

  // ═══════════════════════════════════════════════════════════════════════════
  // VISIBILITY FLAGS (entspricht Firestore Security Rules)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Store ist öffentlich sichtbar wenn:
  /// - Nicht suspendiert UND
  /// - Stage <= 2
  ///
  /// Dies entspricht der canPublicRead() Funktion in firestore.rules
  static bool get isPubliclyVisible {
    if (isSuspended) return false;
    return stage <= 2;
  }

  /// Store ist komplett gesperrt (stage >= 3 oder suspended)
  static bool get isBlocked {
    if (isSuspended) return true;
    if (isExpired && stage >= 3) return true;
    return false;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PERMISSION FLAGS (für UI-Steuerung)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Admin kann schreiben wenn:
  /// - Nicht suspendiert UND
  /// - Nicht (expired && stage >= 3)
  static bool get canWriteAdmin {
    if (isSuspended) return false;
    if (isExpired && stage >= 3) return false;
    return true;
  }

  /// Bilder öffentlich anzeigen wenn:
  /// - Nicht suspendiert UND
  /// - Nicht (expired && stage >= 1)
  static bool get canShowImagesPublic {
    if (isSuspended) return false;
    if (isExpired && stage >= 1) return false;
    return true;
  }

  /// Preise öffentlich anzeigen wenn:
  /// - Nicht suspendiert UND
  /// - Nicht (expired && stage >= 2)
  static bool get canShowPricesPublic {
    if (isSuspended) return false;
    if (isExpired && stage >= 2) return false;
    return true;
  }

  /// Größen = Preise
  static bool get canShowSizesPublic => canShowPricesPublic;

  /// Store ist öffentlich erreichbar (Legacy-Name, entspricht isPubliclyVisible)
  static bool get isStorePublic => isPubliclyVisible;

  // ═══════════════════════════════════════════════════════════════════════════
  // UI HELPER - Stage-basierte Nachrichten
  // ═══════════════════════════════════════════════════════════════════════════

  /// Gibt die aktuelle Einschränkung als Key zurück (für l10n)
  static String? get currentRestrictionKey {
    if (isSuspended) return 'suspended';
    if (!isExpired) return null;

    switch (stage) {
      case 0:
        return null; // Keine Einschränkung
      case 1:
        return 'images_hidden';
      case 2:
        return 'prices_hidden';
      default:
        return 'store_blocked';
    }
  }

  /// Prüft ob ein bestimmtes Feature verfügbar ist
  static bool isFeatureAvailable(String feature) {
    if (isSuspended) return false;
    if (isActive || isTrial) return true;
    if (!isExpired) return true;

    switch (feature) {
      case 'write':
        return stage < 3;
      case 'images':
        return stage < 1;
      case 'prices':
      case 'sizes':
        return stage < 2;
      case 'public':
        return stage <= 2;
      default:
        return true;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CACHE & UPDATE
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<void> loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_prefsKey);
    if (cached != null) {
      try {
        _instance._access = json.decode(cached);
        _instance._isLoaded = true;
      } catch (e) {
        debugPrint('AccessManager: Failed to load cache: $e');
      }
    }
  }

  /// Update aus ApiService (kommt aus stores_private.access)
  static void updateFromApi(Map<String, dynamic> accessJson) {
    _instance._access = Map<String, dynamic>.from(accessJson);
    _instance._isLoaded = true;

    // Cache speichern
    SharedPreferences.getInstance().then((p) {
      try {
        String encoded = json.encode(
          accessJson,
          toEncodable: (item) {
            if (item is Timestamp) {
              return item.toDate().toIso8601String();
            }
            return item.toString();
          },
        );
        p.setString(_prefsKey, encoded);
      } catch (e) {
        debugPrint('AccessManager: Failed to save cache: $e');
      }
    });

    _instance.notifyListeners();
  }

  /// Alias für updateFromApi
  static void updateFromServer(Map<String, dynamic>? accessJson) {
    if (accessJson != null) updateFromApi(accessJson);
  }

  static Future<void> clear() async {
    _instance._access = null;
    _instance._isLoaded = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    _instance.notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DEBUG
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String toString() {
    return 'AccessManager(status: $status, stage: $stage, '
        'isPubliclyVisible: $isPubliclyVisible, isBlocked: $isBlocked)';
  }
}
