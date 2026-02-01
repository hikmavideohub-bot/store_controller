import 'dart:convert';
import 'package:hive/hive.dart';

class CacheStore {
  static Box get _box => Hive.box('cache');

  // ---------- JSON List (List<Map<String,dynamic>>) ----------
  static Future<void> saveJsonList(
    String key,
    List<Map<String, dynamic>> items,
  ) async {
    await _box.put(key, jsonEncode(items));
  }

  static List<Map<String, dynamic>>? readJsonList(String key) {
    try {
      final s = _box.get(key) as String?;
      if (s == null || s.trim().isEmpty) return null;
      final decoded = jsonDecode(s);
      if (decoded is! List) return null;

      return decoded
          .whereType<dynamic>()
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // ---------- String List ----------
  static Future<void> saveStringList(String key, List<String> items) async {
    await _box.put(key, items);
  }

  static List<String>? readStringList(String key) {
    try {
      final v = _box.get(key);
      if (v is List) return v.whereType<String>().toList();
      return null;
    } catch (_) {
      return null;
    }
  }

  // ---------- Single string ----------
  static Future<void> saveString(String key, String value) async {
    await _box.put(key, value);
  }

  static String? readString(String key) {
    try {
      final v = _box.get(key);
      return v is String ? v : null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> invalidate(String key) async {
    await _box.delete(key);
  }
}
