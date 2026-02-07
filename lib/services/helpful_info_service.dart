import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service für hilfreiche Infos aus /system/helpful_info (Firestore)
class HelpfulInfoService {
  static final HelpfulInfoService _instance = HelpfulInfoService._internal();
  factory HelpfulInfoService() => _instance;
  HelpfulInfoService._internal();

  Map<String, List<String>>? _cache;
  DateTime? _cacheTimestamp;
  static const Duration _cacheTtl = Duration(hours: 6);

  /// Lädt die hilfreichen Infos für eine bestimmte Sprache.
  ///
  /// Fallback auf 'ar' wenn die Sprache nicht vorhanden ist.
  Future<List<String>> getInfo(String langCode) async {
    await _loadIfNeeded();

    final items = _cache?[langCode] ?? _cache?['ar'] ?? [];
    return items;
  }

  Future<void> _loadIfNeeded() async {
    if (_cache != null && _cacheTimestamp != null) {
      final age = DateTime.now().difference(_cacheTimestamp!);
      if (age < _cacheTtl) return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('system')
          .doc('helpful_info')
          .get();

      if (!doc.exists || doc.data() == null) {
        debugPrint('[HelpfulInfoService] No helpful_info document found');
        _cache = {};
        _cacheTimestamp = DateTime.now();
        return;
      }

      final data = doc.data()!;
      _cache = {};

      for (final lang in ['ar', 'en', 'de', 'tr']) {
        final langMap = data[lang];
        if (langMap is Map<String, dynamic>) {
          // Sortiere nach numerischem Key (1, 2, 3, ...)
          final sortedKeys = langMap.keys.toList()
            ..sort((a, b) {
              final ai = int.tryParse(a) ?? 999;
              final bi = int.tryParse(b) ?? 999;
              return ai.compareTo(bi);
            });

          _cache![lang] = [
            for (final key in sortedKeys)
              if (langMap[key] is String && (langMap[key] as String).isNotEmpty)
                langMap[key] as String,
          ];
        }
      }

      _cacheTimestamp = DateTime.now();
      debugPrint(
        '[HelpfulInfoService] Loaded info for ${_cache!.keys.join(", ")}',
      );
    } catch (e) {
      debugPrint('[HelpfulInfoService] Error loading: $e');
      _cache ??= {};
      _cacheTimestamp = DateTime.now();
    }
  }

  void clearCache() {
    _cache = null;
    _cacheTimestamp = null;
  }
}
