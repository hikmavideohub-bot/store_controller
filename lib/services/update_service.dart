import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'version_service.dart';

/// Prüft ob eine neuere App-Version verfügbar ist.
///
/// Liest `latest_version` aus Firestore `system/app_config`.
class UpdateService {
  static bool _checked = false;

  /// Prüft einmal pro Session ob ein Update verfügbar ist.
  /// Gibt `true` zurück wenn eine neuere Version existiert.
  /// Auf Web wird immer `false` zurückgegeben.
  static Future<bool> shouldShowUpdateDialog() async {
    if (kIsWeb || _checked) return false;
    _checked = true;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('system')
          .doc('app_config')
          .get();

      if (!doc.exists || doc.data() == null) return false;

      final latest = doc.data()!['latest_version']?.toString().trim() ?? '';
      if (latest.isEmpty) return false;

      final current = VersionService.version;
      return _isNewer(latest, current);
    } catch (e) {
      debugPrint('[UpdateService] Error checking update: $e');
      return false;
    }
  }

  /// Vergleicht zwei Semver-Strings (z.B. "1.2.0" > "1.1.3").
  static bool _isNewer(String latest, String current) {
    final latestParts = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // Auf gleiche Länge auffüllen
    while (latestParts.length < 3) {
      latestParts.add(0);
    }
    while (currentParts.length < 3) {
      currentParts.add(0);
    }

    for (var i = 0; i < 3; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false; // Gleich → kein Update
  }
}
