import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import 'cache_store.dart';
import 'store_config_service.dart';
import '../storage/store_prefs.dart';
import 'package:store_controller/core/access_manager.dart';

class ApiResult<T> {
  final bool ok;
  final T? data;
  final String? error;
  final String? details;

  const ApiResult.ok(this.data)
      : ok = true,
        error = null,
        details = null;

  const ApiResult.fail(this.error, {this.details})
      : ok = false,
        data = null;
}

class ApiService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =======================================================
  // Auth / identity
  // =======================================================
  static String? get _token => _auth.currentUser?.uid;
  static String? get _storeId => _auth.currentUser?.uid;
  
  static bool get isLoggedIn => _auth.currentUser != null;
  static String? get token => _token;
  static String? get storeId => _storeId;
  static bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  static String? _storeName;
  static String? get storeName => (_storeName ?? '').trim().isEmpty ? null : _storeName;

  static final ValueNotifier<int> authTick = ValueNotifier<int>(0);

  // =======================================================
  // Access
  // =======================================================
  static Map<String, dynamic>? _access;
  static Map<String, dynamic>? get access => _access;

  static bool canWriteAdmin() {
    if (_access == null) return true; // Fallback für neue/einfache Shops
    return _access?['flags']?['canWriteAdmin'] == true;
  }

  // =======================================================
  // Caches
  // =======================================================
  static List<Product>? _cachedProducts;
  static List<Product>? get cachedProducts => _cachedProducts;

  static List<String>? _cachedCategories;

  // =======================================================
  // Helpers
  // =======================================================
  static void bumpAuthTick() {
    authTick.value = authTick.value + 1;
  }

  static void _logError(String where, Object e, [StackTrace? st]) {
    debugPrint('❌ ApiService[$where] $e');
    if (st != null) debugPrint('$st');
  }

  // =======================================================
  // Auth lifecycle
  // =======================================================
  static Future<void> init() async {
    _storeName = CacheStore.readString('storeName');
    
    // Auth Listener
    _auth.userChanges().listen((user) async {
      if (user != null) {
        await fetchStoreConfig();
      }
      bumpAuthTick();
    });
  }

  static Future<void> bootstrapAuth() async {
    await init();
  }

  static Future<void> persistAuthToPrefs() async {
    if (_storeId != null) await StorePrefs.setStoreId(_storeId!);
  }

  static Future<void> clearAuth() async {
    await _auth.signOut();
    _storeName = null;
    _cachedProducts = null;
    _cachedCategories = null;
    _access = null;
    await StorePrefs.clearStoreId();
    await AccessManager.clear();
    await StoreConfigService.clear();
    bumpAuthTick();
  }

  static Future<void> clearStoreId() async {
    await StorePrefs.clearStoreId();
  }

  // =======================================================
  // Auth endpoints (Firebase)
  // =======================================================
  static Future<Map<String, String>?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      final uid = cred.user!.uid;
      await fetchStoreConfig(); 
      
      return {'token': uid, 'storeId': uid};
    } catch (e, st) {
      _logError('login', e, st);
      return null;
    }
  }

  static Future<ApiResult<Map<String, String>>> registerFull({
    required Map<String, dynamic> store,
    required String username, 
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: username.trim(),
        password: password,
      );
      
      final uid = cred.user!.uid;

      final storeData = {
        'store_name': store['store_name'] ?? 'Mein Shop',
        'owner_email': username.trim(),
        'created_at': FieldValue.serverTimestamp(),
        'plan': 'free',
        'store_id': uid,
        'access': {
          'flags': {
            'canWriteAdmin': true,
          }
        }
      };

      await _db.collection('stores').doc(uid).set(storeData);
      _access = storeData['access'] as Map<String, dynamic>?;

      return ApiResult.ok({
        'storeId': uid,
        'token': uid,
        'needs_email_verify': 'true',
      });
    } on FirebaseAuthException catch (e) {
      return ApiResult.fail(e.code, details: e.message);
    } catch (e, st) {
      _logError('registerFull', e, st);
      return const ApiResult.fail('network_error');
    }
  }

  static Future<ApiResult<void>> startEmailVerify(String _) async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      return const ApiResult.ok(null);
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }

  static Future<ApiResult<void>> confirmEmailVerifyRaw({
    required String storeId,
    required String otp,
    String? username,
  }) async {
    await _auth.currentUser?.reload();
    return const ApiResult.ok(null);
  }

  static Future<bool> startPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } catch (e) {
      return false;
    }
  }

  // =======================================================
  // Data: Products (Firestore)
  // =======================================================
  static Future<List<Product>> fetchProducts({bool forceRefresh = false, String? v}) async {
    if (_storeId == null) return [];

    try {
      final snapshot = await _db
          .collection('stores')
          .doc(_storeId)
          .collection('products')
          .get();

      final products = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Product.fromMap(data);
      }).toList();

      _cachedProducts = products;
      unawaited(CacheStore.saveJsonList('products', products.map((e) => e.toJson()).toList()));
      
      return products;
    } catch (e, st) {
      _logError('fetchProducts', e, st);
      return _cachedProducts ?? [];
    }
  }

  static Future<bool> addProduct(Product product) async {
    if (_storeId == null) return false;
    try {
      final docRef = _db.collection('stores').doc(_storeId).collection('products').doc();
      final data = product.toJson();
      data['id'] = docRef.id;
      
      await docRef.set(data);
      
      final pWithId = product.copyWith(id: docRef.id);
      _cachedProducts = [pWithId, ...?_cachedProducts];
      return true;
    } catch (e) {
      _logError('addProduct', e);
      return false;
    }
  }

  static Future<bool> updateProduct(Product product) async {
    if (_storeId == null) return false;
    try {
      await _db
          .collection('stores')
          .doc(_storeId)
          .collection('products')
          .doc(product.id)
          .update(product.toJson());
      
      return true;
    } catch (e) {
      _logError('updateProduct', e);
      return false;
    }
  }

  static Future<bool> deleteProduct(String id) async {
    if (_storeId == null) return false;
    try {
      await _db
          .collection('stores')
          .doc(_storeId)
          .collection('products')
          .doc(id)
          .delete();
      return true;
    } catch (e) {
      _logError('deleteProduct', e);
      return false;
    }
  }

  // =======================================================
  // Data: Categories
  // =======================================================
  static Future<List<String>> fetchCategories({bool forceRefresh = false}) async {
    final products = await fetchProducts(forceRefresh: forceRefresh);
    final set = <String>{};
    for (var p in products) {
      if (p.category.trim().isNotEmpty) set.add(p.category.trim());
    }
    final list = set.toList()..sort();
    _cachedCategories = list;
    return list;
  }

  static Future<bool> renameCategory(String oldName, String newName) async {
    if (_storeId == null) return false;
    try {
      final batch = _db.batch();
      final snapshot = await _db
          .collection('stores')
          .doc(_storeId)
          .collection('products')
          .where('category', isEqualTo: oldName)
          .get();

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'category': newName});
      }
      await batch.commit();
      return true;
    } catch (e) {
      _logError('renameCategory', e);
      return false;
    }
  }

  static Future<bool> deleteCategory(String name, {String moveToCategory = 'اخرى'}) async {
    if (_storeId == null) return false;
    try {
      final batch = _db.batch();
      final snapshot = await _db
          .collection('stores')
          .doc(_storeId)
          .collection('products')
          .where('category', isEqualTo: name)
          .get();

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'category': moveToCategory});
      }
      await batch.commit();
      return true;
    } catch (e) {
      _logError('deleteCategory', e);
      return false;
    }
  }

  // =======================================================
  // Store Config / Status
  // =======================================================
  static Future<Map<String, dynamic>?> fetchStoreConfig() async {
    if (_storeId == null) return null;
    try {
      final doc = await _db.collection('stores').doc(_storeId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      _storeName = data['store_name'];
      _access = data['access'] as Map<String, dynamic>?;

      // ✅ AccessManager aktualisieren (für Paywall-Logik)
      if (_access != null) {
        AccessManager.updateFromServer(_access);
      }

      if (_storeName != null) CacheStore.saveString('storeName', _storeName!);

      return data;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchWebsiteStatus() async {
    return fetchStoreConfig();
  }

  static Future<bool> updateStore(Map<String, dynamic> data) async {
    if (_storeId == null) return false;
    try {
      await _db.collection('stores').doc(_storeId).update(data);
      if (data.containsKey('store_name')) {
        _storeName = data['store_name'];
        CacheStore.saveString('storeName', _storeName!);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // =======================================================
  // Customer Message (Firestore)
  // =======================================================
  static Future<String?> getCustomerMessage({bool forceRefresh = false}) async {
    if (_storeId == null) return null;
    try {
      final doc = await _db.collection('stores').doc(_storeId).get();
      return doc.data()?['customer_message'] ?? '';
    } catch (e) {
      return null;
    }
  }

  static Future<bool> setCustomerMessage(String message) async {
    if (_storeId == null) return false;
    try {
      await _db.collection('stores').doc(_storeId).update({'customer_message': message});
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> clearCustomerMessage() async {
    return setCustomerMessage('');
  }

  // Hilfsmethoden für alte Screens
  static List<String> categoriesFromCachedProducts() {
    return _cachedCategories ?? [];
  }

  static List<String> descriptionSnippets({int max = 50}) {
    final items = _cachedProducts ?? const <Product>[];
    final snippets = <String>[];

    for (final p in items) {
      final d = p.description.trim();
      if (d.isEmpty) continue;

      final parts = d
          .split(RegExp(r'[\n•]+'))
          .map((s) => s.trim())
          .where((s) => s.length >= 8 && s.length <= 90)
          .toList();

      snippets.addAll(parts);
      if (snippets.length >= max) break;
    }

    if (snippets.isEmpty) {
      snippets.addAll([
        'منتج عالي الجودة ومناسب للاستخدام اليومي.',
        'تم اختياره بعناية لتقديم أفضل قيمة.',
        'طازج ومناسب للعائلة.',
        'مذاق ممتاز وسعر مناسب.',
      ]);
    }

    return snippets.toSet().toList();
  }
}
