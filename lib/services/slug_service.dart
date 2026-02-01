import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/slug_generator.dart';

/// Service for managing store slugs with Firestore.
///
/// Handles atomic slug reservation using Firestore transactions
/// to prevent race conditions and ensure uniqueness.
class SlugService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Base URL for public store pages
  static const String baseUrl = 'https://aldeebtech.de/s/';

  /// Maximum attempts to find an available slug with suffix
  static const int _maxSuffixAttempts = 100;

  /// Generates and reserves a unique slug for a store.
  ///
  /// Uses Firestore transaction for atomicity.
  /// If the generated slug already exists, appends a numeric suffix.
  ///
  /// Returns the reserved slug.
  /// Throws on critical failure.
  static Future<String> generateAndReserveSlug({
    required String storeId,
    required String storeName,
  }) async {
    // Generate base slug from store name
    String? baseSlug = SlugGenerator.generateSlug(storeName);

    // Fallback: if store name produces no valid slug, use store ID prefix
    if (baseSlug == null || baseSlug.isEmpty) {
      final prefix = storeId.length >= 8 ? storeId.substring(0, 8) : storeId;
      baseSlug = 'store-$prefix';
    }

    // Try to reserve slug with transaction
    return _reserveSlugWithRetry(
      storeId: storeId,
      storeName: storeName,
      baseSlug: baseSlug,
    );
  }

  /// Attempts to reserve a slug, trying different suffixes if needed.
  static Future<String> _reserveSlugWithRetry({
    required String storeId,
    required String storeName,
    required String baseSlug,
  }) async {
    for (int suffix = 1; suffix <= _maxSuffixAttempts; suffix++) {
      final candidateSlug = SlugGenerator.appendSuffix(baseSlug, suffix);

      try {
        final success = await _tryReserveSlug(
          slug: candidateSlug,
          storeId: storeId,
          storeName: storeName,
        );

        if (success) {
          if (kDebugMode) {
            debugPrint('SlugService: Reserved slug "$candidateSlug" for store $storeId');
          }
          return candidateSlug;
        }
        // Slug exists, try next suffix
      } catch (e) {
        if (kDebugMode) {
          debugPrint('SlugService: Error reserving slug "$candidateSlug": $e');
        }
        // If store already has a slug, rethrow
        if (e.toString().contains('already has a slug')) {
          rethrow;
        }
        // Continue to next attempt for other errors
      }
    }

    // Fallback: use timestamp-based slug if all attempts fail
    final fallbackSlug = '${baseSlug.substring(0, baseSlug.length.clamp(0, 20))}-${DateTime.now().millisecondsSinceEpoch}';

    final success = await _tryReserveSlug(
      slug: fallbackSlug,
      storeId: storeId,
      storeName: storeName,
    );

    if (success) {
      return fallbackSlug;
    }

    throw Exception('Failed to reserve slug after $_maxSuffixAttempts attempts');
  }

  /// Atomic slug reservation using Firestore transaction.
  ///
  /// Creates both the slug document and updates the store document atomically.
  /// Returns true if successful, false if slug already exists.
  static Future<bool> _tryReserveSlug({
    required String slug,
    required String storeId,
    required String storeName,
  }) async {
    final slugDocRef = _db.collection('slugs').doc(slug);
    final storeDocRef = _db.collection('stores_public').doc(storeId);

    return _db.runTransaction<bool>((transaction) async {
      // Check if slug document already exists
      final slugDoc = await transaction.get(slugDocRef);

      if (slugDoc.exists) {
        // Slug is taken
        return false;
      }

      // Check if store already has a slug (should not overwrite)
      final storeDoc = await transaction.get(storeDocRef);
      if (storeDoc.exists) {
        final data = storeDoc.data();
        final existingSlug = data?['store_slug'];
        if (existingSlug != null && existingSlug.toString().trim().isNotEmpty) {
          throw Exception('Store already has a slug assigned: $existingSlug');
        }
      }

      final now = FieldValue.serverTimestamp();
      final publicUrl = '$baseUrl$slug';

      // Create slug document
      transaction.set(slugDocRef, {
        'store_id': storeId,
        'store_name': storeName,
        'created_at': now,
      });

      // Update store document with slug and public URL
      transaction.update(storeDocRef, {
        'store_slug': slug,
        'public_store_url': publicUrl,
        'slug_created_at': now,
      });

      return true;
    });
  }

  /// Generates slug and URL for a new store (without reserving in slugs collection).
  ///
  /// This is used when creating a new store where we need to set the slug
  /// in the same operation as creating the store document.
  ///
  /// Returns a tuple of (slug, publicUrl).
  static Future<(String slug, String publicUrl)> generateSlugForNewStore({
    required String storeId,
    required String storeName,
  }) async {
    // Generate base slug from store name
    String? baseSlug = SlugGenerator.generateSlug(storeName);

    // Fallback: if store name produces no valid slug, use store ID prefix
    if (baseSlug == null || baseSlug.isEmpty) {
      final prefix = storeId.length >= 8 ? storeId.substring(0, 8) : storeId;
      baseSlug = 'store-$prefix';
    }

    // Find available slug
    for (int suffix = 1; suffix <= _maxSuffixAttempts; suffix++) {
      final candidateSlug = SlugGenerator.appendSuffix(baseSlug, suffix);

      final exists = await _slugExists(candidateSlug);
      if (!exists) {
        return (candidateSlug, '$baseUrl$candidateSlug');
      }
    }

    // Fallback with timestamp
    final fallbackSlug = '${baseSlug.substring(0, baseSlug.length.clamp(0, 20))}-${DateTime.now().millisecondsSinceEpoch}';
    return (fallbackSlug, '$baseUrl$fallbackSlug');
  }

  /// Creates the slug document for a new store.
  ///
  /// Call this after successfully creating the store document.
  static Future<void> createSlugDocument({
    required String slug,
    required String storeId,
    required String storeName,
  }) async {
    await _db.collection('slugs').doc(slug).set({
      'store_id': storeId,
      'store_name': storeName,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  /// Checks if a slug document exists.
  static Future<bool> _slugExists(String slug) async {
    final doc = await _db.collection('slugs').doc(slug).get();
    return doc.exists;
  }

  /// Looks up store_id from slug (O(1) operation).
  ///
  /// Returns null if slug doesn't exist.
  static Future<String?> getStoreIdFromSlug(String slug) async {
    final doc = await _db.collection('slugs').doc(slug).get();
    if (!doc.exists) return null;
    return doc.data()?['store_id'];
  }

  /// Looks up slug from store_id.
  ///
  /// Returns null if store doesn't have a slug.
  static Future<String?> getSlugFromStoreId(String storeId) async {
    final doc = await _db.collection('stores_public').doc(storeId).get();
    if (!doc.exists) return null;
    return doc.data()?['store_slug'];
  }

  /// Gets the full public URL for a store.
  ///
  /// Returns null if store doesn't have a slug.
  static Future<String?> getPublicUrlForStore(String storeId) async {
    final slug = await getSlugFromStoreId(storeId);
    if (slug == null) return null;
    return '$baseUrl$slug';
  }

  /// Checks if a slug is available (not taken and not reserved).
  static Future<bool> isSlugAvailable(String slug) async {
    if (SlugGenerator.isReserved(slug)) return false;
    return !await _slugExists(slug);
  }
}
