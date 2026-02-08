import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for category recommendations based on a global Firestore dictionary.
/// Caches global_categories once and looks up product→category mappings.
class CategoryDictionaryService {
  CategoryDictionaryService._();
  static final instance = CategoryDictionaryService._();

  final _db = FirebaseFirestore.instance;

  /// categoryId → { 'de': 'Getränke', 'en': 'Beverages', ... }
  Map<String, Map<String, String>>? _categoriesCache;

  /// Bulk-load retry cooldown – avoids hammering Firestore on repeated failures.
  DateTime? _bulkRetryAfter;

  /// In-flight single-doc lookups keyed by categoryId (dedup concurrent reads).
  final _pendingLookups = <String, Future<Map<String, String>?>>{};

  // ─── Category cache ───────────────────────────────────────────────────────

  Future<Map<String, Map<String, String>>> _ensureCategories() async {
    if (_categoriesCache != null) return _categoriesCache!;

    // Respect retry cooldown after a previous failure
    if (_bulkRetryAfter != null && DateTime.now().isBefore(_bulkRetryAfter!)) {
      return {};
    }

    try {
      final snap = await _db.collection('global_categories').get();
      final map = <String, Map<String, String>>{};
      for (final doc in snap.docs) {
        final labels = doc.data()['labels'];
        if (labels is Map) {
          map[doc.id] =
              labels.map((k, v) => MapEntry(k.toString(), v.toString()));
        }
      }
      _categoriesCache = map;
      _bulkRetryAfter = null;
      return map;
    } catch (_) {
      // Don't set cache → stays null → retries after cooldown
      _bulkRetryAfter = DateTime.now().add(const Duration(seconds: 30));
      return {};
    }
  }

  /// Resolve a categoryId to its localized label.
  /// Fallback: labels[locale] → labels['en'] → labels['de'] → categoryId.
  /// On cache miss: single-doc read (deduplicated), result cached for future.
  Future<String> _resolveLabel(String categoryId, String locale) async {
    var labels = _categoriesCache?[categoryId];

    // Cache miss → deduplicated single-doc lookup
    labels ??= await _lookupCategory(categoryId);

    if (labels == null) return categoryId;
    return labels[locale] ?? labels['en'] ?? labels['de'] ?? categoryId;
  }

  /// Single-doc Firestore read with in-flight deduplication.
  Future<Map<String, String>?> _lookupCategory(String categoryId) {
    // Reuse an in-flight Future for the same categoryId
    return _pendingLookups.putIfAbsent(categoryId, () async {
      try {
        final doc =
            await _db.collection('global_categories').doc(categoryId).get();
        if (doc.exists) {
          final raw = doc.data()?['labels'];
          if (raw is Map) {
            final labels =
                raw.map((k, v) => MapEntry(k.toString(), v.toString()));
            _categoriesCache ??= {};
            _categoriesCache![categoryId] = labels;
            return labels;
          }
        }
      } catch (_) {
        // Firestore read failed – fall through to fallback
      } finally {
        _pendingLookups.remove(categoryId);
      }
      return null;
    });
  }

  void invalidateCache() {
    _categoriesCache = null;
    _bulkRetryAfter = null;
  }

  // ─── Normalize (mirrors Cloud Function logic) ─────────────────────────────

  static String normalize(String text) {
    if (text.isEmpty) return '';
    var s = text.trim().toLowerCase();
    // Separators → space
    s = s.replaceAll(RegExp(r'[/\\._~#\[\]*]+'), ' ');
    // Keep unicode letters, numbers, spaces, hyphens
    s = s.replaceAll(RegExp(r'[^\p{L}\p{N}\s-]', unicode: true), '');
    // Spaces → hyphen
    s = s.replaceAll(RegExp(r'\s+'), '-');
    // Collapse multiple hyphens
    s = s.replaceAll(RegExp(r'-{2,}'), '-');
    // Trim leading/trailing hyphens
    s = s.replaceAll(RegExp(r'^-|-$'), '');
    return s;
  }

  // ─── Search ───────────────────────────────────────────────────────────────

  /// Returns the best recommendation for [productName] or null.
  /// Result: `{ 'categoryId': '...', 'label': '...' }`
  /// [label] is the localized display name (not the raw ID).
  Future<({String categoryId, String label})?> getBestRecommendation(
    String productName,
    String locale,
  ) async {
    final normalized = normalize(productName);
    if (normalized.isEmpty) return null;

    await _ensureCategories();

    // 1. Exact doc match (cheapest: 1 read)
    final exactDoc = await _db
        .collection('global_product_category_dictionary')
        .doc(normalized)
        .get();

    if (exactDoc.exists) {
      final catId = exactDoc.data()?['topCategoryId'] as String?;
      if (catId != null && catId.isNotEmpty) {
        final label = await _resolveLabel(catId, locale);
        return (categoryId: catId, label: label);
      }
    }

    // 2. Prefix query (fallback)
    final prefixEnd = '$normalized\uf8ff';
    final prefixSnap = await _db
        .collection('global_product_category_dictionary')
        .where('normalizedName', isGreaterThanOrEqualTo: normalized)
        .where('normalizedName', isLessThanOrEqualTo: prefixEnd)
        .orderBy('normalizedName')
        .limit(10)
        .get();

    if (prefixSnap.docs.isNotEmpty) {
      // Pick the one with highest topCount
      DocumentSnapshot? best;
      int bestCount = -1;
      for (final doc in prefixSnap.docs) {
        final cnt = (doc.data() as Map?)?['topCount'] as int? ?? 0;
        if (cnt > bestCount) {
          bestCount = cnt;
          best = doc;
        }
      }
      if (best != null) {
        final catId = (best.data() as Map?)?['topCategoryId'] as String?;
        if (catId != null && catId.isNotEmpty) {
          final label = await _resolveLabel(catId, locale);
          return (categoryId: catId, label: label);
        }
      }
    }

    return null;
  }
}
