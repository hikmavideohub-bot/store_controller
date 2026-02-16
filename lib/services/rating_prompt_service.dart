import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'api_service.dart';
import 'store_config_service.dart';
import '../core/access_manager.dart';

class RatingPromptService {
  static const String _kFirstLaunch = 'rating_first_launch';
  static const String _kLaunchCount = 'rating_launch_count';
  static const String _kHasRatedOrDismissed = 'rating_done';
  static const String _kTotalSessionTime = 'total_session_time_seconds';

  static DateTime? _sessionStartTime;

  /// Startet die Zeitmessung für die aktuelle Sitzung
  static void startSession() {
    _sessionStartTime = DateTime.now();
  }

  /// Beendet die Sitzung und speichert die Dauer
  static Future<void> endSession() async {
    if (_sessionStartTime == null) return;

    final duration = DateTime.now().difference(_sessionStartTime!).inSeconds;
    final prefs = await SharedPreferences.getInstance();

    int totalTime = prefs.getInt(_kTotalSessionTime) ?? 0;
    totalTime += duration;
    await prefs.setInt(_kTotalSessionTime, totalTime);

    _sessionStartTime = null;
    await syncUsageToFirebase();
  }

  /// Erhöht den Zähler bei jedem App-Start und synchronisiert mit Firebase
  static Future<void> incrementLaunchCount() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(_kFirstLaunch)) {
      await prefs.setInt(_kFirstLaunch, DateTime.now().millisecondsSinceEpoch);
    }

    int count = prefs.getInt(_kLaunchCount) ?? 0;
    count++;
    await prefs.setInt(_kLaunchCount, count);

    startSession(); // Starte Zeitmessung
    await syncUsageToFirebase(launchCount: count);
  }

  /// Sendet Nutzungsstatistiken an Firebase Collection 'app_usage_stats'
  static Future<void> syncUsageToFirebase({int? launchCount}) async {
    final storeId = ApiService.storeId;
    if (storeId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final firstLaunch = prefs.getInt(_kFirstLaunch) ?? 0;
    final totalSeconds = prefs.getInt(_kTotalSessionTime) ?? 0;
    final count = launchCount ?? (prefs.getInt(_kLaunchCount) ?? 0);

    try {
      await FirebaseFirestore.instance
          .collection('app_usage_stats')
          .doc(storeId)
          .set({
            'storeId': storeId,
            'storeName': StoreConfigService.storeName.isNotEmpty
                ? StoreConfigService.storeName
                : 'Unknown',
            'launchCount': count,
            'firstLaunch': Timestamp.fromMillisecondsSinceEpoch(firstLaunch),
            'lastSeen': FieldValue.serverTimestamp(),
            'hasRated': prefs.getBool(_kHasRatedOrDismissed) ?? false,
            'totalTimeMinutes': (totalSeconds / 60).toStringAsFixed(
              2,
            ), // Zeit in Minuten
            'subscriptionStatus': AccessManager.status, // Conversion-Tracking
            'isPremium': AccessManager.isActive,
          }, SetOptions(merge: true));
    } catch (e) {
      // Fehler silent ignorieren
    }
  }

  static Future<bool> shouldShowPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kHasRatedOrDismissed) ?? false) return false;

    final firstLaunchTime = prefs.getInt(_kFirstLaunch) ?? 0;
    final launchCount = prefs.getInt(_kLaunchCount) ?? 0;

    final now = DateTime.now().millisecondsSinceEpoch;
    final threeDaysInMillis = 3 * 24 * 60 * 60 * 1000;

    return (now - firstLaunchTime) >= threeDaysInMillis && launchCount >= 5;
  }

  static Future<bool> hasAlreadyRated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kHasRatedOrDismissed) ?? false;
  }

  static Future<void> markAsDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHasRatedOrDismissed, true);

    final storeId = ApiService.storeId;
    if (storeId != null) {
      FirebaseFirestore.instance
          .collection('app_usage_stats')
          .doc(storeId)
          .update({'hasRated': true});
    }
  }
}
