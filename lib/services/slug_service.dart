import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/slug_generator.dart';

/// Service for managing store slugs with Firestore.
///
/// NOTE: Slug RESERVATION happens only via Cloud Function (finalizeStoreSetup).
/// This service provides:
/// - Slug availability checking (read-only)
/// - Slug lookups (read-only)
/// - Slug generation (local, no writes)
class SlugService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Base URL for public store pages
  static const String baseUrl = 'https://aldeebtech.de/s/';

  /// Maximum attempts to find an available slug with suffix
  static const int _maxSuffixAttempts = 100;

  // ═══════════════════════════════════════════════════════════════════════════
  // READ-ONLY OPERATIONS (Safe for client)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Checks if a slug is available (not taken and not reserved).
  /// Safe for client - read-only operation.
  static Future<bool> isSlugAvailable(String slug) async {
    if (slug.isEmpty) return false;
    if (SlugGenerator.isReserved(slug)) return false;
    return !await _slugExists(slug);
  }

  /// Checks if a slug document exists.
  static Future<bool> _slugExists(String slug) async {
    final doc = await _db.collection('slugs').doc(slug).get();
    return doc.exists;
  }

  /// Looks up store_id from slug (O(1) operation).
  /// Returns null if slug doesn't exist.
  static Future<String?> getStoreIdFromSlug(String slug) async {
    final doc = await _db.collection('slugs').doc(slug).get();
    if (!doc.exists) return null;
    return doc.data()?['store_id'];
  }

  /// Looks up slug from store_id.
  /// Returns null if store doesn't have a slug.
  static Future<String?> getSlugFromStoreId(String storeId) async {
    final doc = await _db.collection('stores_public').doc(storeId).get();
    if (!doc.exists) return null;
    final slug = doc.data()?['store_slug'];
    // Return null if slug is empty or missing
    if (slug == null || slug.toString().trim().isEmpty) return null;
    return slug.toString();
  }

  /// Gets the full public URL for a store.
  /// Returns null if store doesn't have a slug.
  static Future<String?> getPublicUrlForStore(String storeId) async {
    final slug = await getSlugFromStoreId(storeId);
    if (slug == null) return null;
    return '$baseUrl$slug';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SLUG GENERATION (Local only - no Firestore writes)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Generates a slug candidate from store name.
  /// Does NOT reserve it - just generates a candidate.
  /// Use isSlugAvailable() to check availability.
  static String generateSlugCandidate(String storeName) {
    String? baseSlug = SlugGenerator.generateSlug(storeName);

    // Fallback: if store name produces no valid slug
    if (baseSlug == null || baseSlug.isEmpty) {
      baseSlug = 'store-${DateTime.now().millisecondsSinceEpoch}';
    }

    return baseSlug;
  }

  /// Generates an available slug candidate by checking Firestore.
  /// Does NOT reserve it - the Cloud Function does that atomically.
  ///
  /// Returns (slug, publicUrl) tuple.
  static Future<(String slug, String publicUrl)> findAvailableSlug(
    String storeName,
  ) async {
    String? baseSlug = SlugGenerator.generateSlug(storeName);

    // Fallback: if store name produces no valid slug
    if (baseSlug == null || baseSlug.isEmpty) {
      baseSlug = 'store-${DateTime.now().millisecondsSinceEpoch}';
    }

    // Find available slug
    for (int suffix = 1; suffix <= _maxSuffixAttempts; suffix++) {
      final candidateSlug = SlugGenerator.appendSuffix(baseSlug, suffix);

      final exists = await _slugExists(candidateSlug);
      if (!exists) {
        if (kDebugMode) {
          debugPrint('SlugService: Found available slug "$candidateSlug"');
        }
        return (candidateSlug, '$baseUrl$candidateSlug');
      }
    }

    // Fallback with timestamp
    final fallbackSlug =
        '${baseSlug.substring(0, baseSlug.length.clamp(0, 20))}-${DateTime.now().millisecondsSinceEpoch}';
    return (fallbackSlug, '$baseUrl$fallbackSlug');
  }

  /// Validates a user-provided slug.
  /// Returns null if valid, error message if invalid.
  static String? validateSlug(String slug) {
    if (slug.isEmpty) return 'Slug cannot be empty';
    if (slug.length < 3) return 'Slug must be at least 3 characters';
    if (slug.length > 50) return 'Slug must be less than 50 characters';
    if (!RegExp(r'^[a-z0-9][a-z0-9-]*[a-z0-9]$').hasMatch(slug)) {
      return 'Slug can only contain lowercase letters, numbers, and hyphens';
    }
    if (slug.contains('--')) return 'Slug cannot contain consecutive hyphens';
    if (SlugGenerator.isReserved(slug)) return 'This slug is reserved';
    return null;
  }
}
