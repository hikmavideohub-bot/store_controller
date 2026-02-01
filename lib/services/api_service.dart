import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import '../models/product.dart';
import 'cache_store.dart';
import 'store_config_service.dart';
import 'slug_service.dart';
import '../storage/store_prefs.dart';
import 'package:store_controller/core/access_manager.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// API SERVICE - Dual Collection Architecture
// ═══════════════════════════════════════════════════════════════════════════════
//
// COLLECTIONS:
// - stores_public/{storeId}          → Öffentliche Shop-Daten
// - stores_public/{storeId}/products → Produkte
// - stores_private/{storeId}         → Sensible System-/User-Daten
//
// SECURITY:
// - Public reads: stores_public (wenn stage <= 2)
// - Admin reads: stores_public + stores_private
// - All writes: Nur Owner oder Cloud Functions
// ═══════════════════════════════════════════════════════════════════════════════

class ApiResult<T> {
  final bool ok;
  final T? data;
  final String? error;
  final String? details;

  const ApiResult.ok(this.data) : ok = true, error = null, details = null;

  const ApiResult.fail(this.error, {this.details, this.data}) : ok = false;
}

/// Speichert temporäre Google-Credential-Daten für deferred Sign-In
class PendingGoogleCredential {
  final OAuthCredential credential;
  final String email;
  final String? displayName;
  final String? photoUrl;

  const PendingGoogleCredential({
    required this.credential,
    required this.email,
    this.displayName,
    this.photoUrl,
  });
}

class ApiService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ═══════════════════════════════════════════════════════════════════════════
  // COLLECTION REFERENCES
  // ═══════════════════════════════════════════════════════════════════════════

  static CollectionReference<Map<String, dynamic>> get _storesPublic =>
      _db.collection('stores_public');

  static CollectionReference<Map<String, dynamic>> get _storesPrivate =>
      _db.collection('stores_private');

  static CollectionReference<Map<String, dynamic>> get _slugs =>
      _db.collection('slugs');

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTH STATE
  // ═══════════════════════════════════════════════════════════════════════════

  static String? get _storeId => _auth.currentUser?.uid;

  static bool get isLoggedIn => _auth.currentUser != null;
  static String? get storeId => _storeId;
  static bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;
  static String? get currentUserEmail => _auth.currentUser?.email;

  /// Flag um automatische Router-Redirects während des Auth-Prozesses zu verhindern
  static bool _isProcessingAuth = false;
  static bool get isProcessingAuth => _isProcessingAuth;
  static bool hasStore = false;

  /// Gespeicherte Google-Credential für deferred Sign-In (Login → Register Flow)
  static PendingGoogleCredential? _pendingGoogleCredential;
  static PendingGoogleCredential? get pendingGoogleCredential =>
      _pendingGoogleCredential;
  static bool get hasPendingGoogleCredential =>
      _pendingGoogleCredential != null;

  /// Flag ob der aktuelle Firebase User neu ist (für Cleanup bei Fehler)
  static bool _isCurrentUserNew = false;
  static bool get isCurrentUserNew => _isCurrentUserNew;

  // ═══════════════════════════════════════════════════════════════════════════
  // ERROR HANDLING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Mappt Firebase Fehler auf lokalisierte Nachrichten
  static String mapFirebaseErrorToArabic(dynamic error, [AppLocalizations? s]) {
    final msg = error.toString().toLowerCase();

    String loc(String Function(AppLocalizations) f, String fallback) {
      return s != null ? f(s) : fallback;
    }

    if (msg.contains('permission-denied') ||
        msg.contains('insufficient permissions')) {
      return loc(
        (l) => l.errorPermissionDenied,
        'ليس لديك صلاحية الوصول، يرجى التأكد من تسجيل الحساب أولاً',
      );
    }
    if (msg.contains('email-already-in-use')) {
      return loc((l) => l.errorEmailInUse, 'البريد الإلكتروني مستخدم بالفعل');
    }
    if (msg.contains('invalid-email')) {
      return loc(
        (l) => l.errorInvalidEmail,
        'صيغة البريد الإلكتروني غير صحيحة',
      );
    }
    if (msg.contains('weak-password')) {
      return loc(
        (l) => l.errorWeakPassword,
        'كلمة المرور ضعيفة. استخدم 6 أحرف على الأقل',
      );
    }
    if (msg.contains('user-not-found') ||
        msg.contains('wrong-password') ||
        msg.contains('invalid-credential')) {
      return loc((l) => l.errorUserNotFound, 'بيانات الدخول غير صحيحة');
    }
    if (msg.contains('network')) {
      return loc((l) => l.errorNetwork, 'خطأ في الاتصال بالإنترنت');
    }
    return loc((l) => l.errorUnknown, 'حدث خطأ غير متوقع. حاول مرة أخرى');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STORE EXISTENCE & VERIFICATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Prüft ob Store-Dokumente existieren (beide Collections)
  static Future<bool> storeDocumentExists(String uid) async {
    try {
      // Prüfe beide Collections - Store existiert wenn mindestens public existiert
      final publicDoc = await _storesPublic.doc(uid).get();
      return publicDoc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Prüft Verifizierungsstatus aus stores_private
  static Future<String> checkVerificationStatus(String uid) async {
    try {
      final privateDoc = await _storesPrivate.doc(uid).get();
      if (!privateDoc.exists) return 'no_store';

      final data = privateDoc.data()!;
      if (data['is_verified'] ?? true) return 'valid';

      final createdAt = data['created_at'];
      if (createdAt is Timestamp) {
        final diff = DateTime.now().toUtc().difference(createdAt.toDate());
        if (diff.inHours >= 24) return 'expired';
      }
      return 'valid';
    } catch (e) {
      return 'error';
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECURE SERVER-SIDE FUNCTIONS (via Cloud Functions)
  // ═══════════════════════════════════════════════════════════════════════════

  /// SECURE: E-Mail-Verifizierung über Cloud Function bestätigen
  static Future<bool> confirmEmailVerificationSecure() async {
    if (_storeId == null) return false;
    try {
      final callable = FirebaseFunctions.instanceFor(
        region: 'europe-west3',
      ).httpsCallable('confirmEmailVerification');
      final result = await callable.call();
      return result.data['success'] == true;
    } catch (e) {
      debugPrint('confirmEmailVerificationSecure Error: $e');
      return false;
    }
  }

  /// SECURE: Account-Löschung anfordern (Server führt aus)
  static Future<bool> requestAccountDeletion() async {
    if (_storeId == null) return false;
    try {
      final callable = FirebaseFunctions.instanceFor(
        region: 'europe-west3',
      ).httpsCallable('requestAccountDeletion');
      final result = await callable.call();
      if (result.data['success'] == true) {
        hasStore = false;
        await clearAuth();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('requestAccountDeletion Error: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SESSION VALIDATION
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<String> validateSession() async {
    final user = _auth.currentUser;
    if (user == null) {
      hasStore = false;
      return 'not_logged_in';
    }

    final uid = user.uid;
    final exists = await storeDocumentExists(uid);

    if (!exists) {
      hasStore = false;
      await clearAuth();
      return 'no_store';
    }

    hasStore = true;

    final verifyStatus = await checkVerificationStatus(uid);

    if (verifyStatus == 'expired') {
      hasStore = false;
      await clearAuth();
      return 'expired';
    }

    return 'valid';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CACHED STATE
  // ═══════════════════════════════════════════════════════════════════════════

  static String? _storeName;
  static String? get storeName =>
      (_storeName ?? '').trim().isEmpty ? null : _storeName;

  /// ValueNotifier für Store-Name - ermöglicht sofortige UI-Updates
  static final ValueNotifier<String?> storeNameNotifier =
      ValueNotifier<String?>(null);

  /// Setzt den Store-Namen und benachrichtigt Listener
  static void _setStoreName(String? name) {
    _storeName = name;
    storeNameNotifier.value = name;
    if (name != null && name.isNotEmpty) {
      CacheStore.saveString('storeName', name);
    }
  }

  static final ValueNotifier<int> authTick = ValueNotifier<int>(0);

  static Map<String, dynamic>? _access;
  static Map<String, dynamic>? get access => _access;

  static List<Product>? _cachedProducts;
  static List<Product>? get cachedProducts => _cachedProducts;

  static final ValueNotifier<List<Product>> productsNotifier = ValueNotifier(
    [],
  );

  static void _updateProductsNotifier(List<Product> products) {
    _cachedProducts = products;
    productsNotifier.value = List.from(products);
  }

  static List<String>? _cachedCategories;

  static void bumpAuthTick() {
    authTick.value = authTick.value + 1;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<void> init() async {
    _setStoreName(CacheStore.readString('storeName'));
    _auth.userChanges().listen((user) async {
      if (user != null && !_isProcessingAuth) {
        await fetchStoreConfig();
      }
      bumpAuthTick();
    });
  }

  static Future<void> bootstrapAuth() async => await init();

  static Future<void> checkAndSetUserRegion({String? selectedCountry}) async {
    try {
      final storeData = await fetchStoreConfig();
      final storeCountry =
          selectedCountry ?? storeData?['address_country'] ?? '';

      await FirebaseFunctions.instanceFor(region: 'europe-west3')
          .httpsCallable('resolveUserRegion')
          .call({'selectedCountry': storeCountry});

      await fetchStoreConfig();
    } catch (e) {
      debugPrint('Fehler bei Region-Prüfung: $e');
    }
  }

  static Future<void> clearAuth() async {
    hasStore = false;
    await _auth.signOut();
    await signOutGoogle();
    _setStoreName(null);
    _cachedProducts = null;
    _access = null;
    _pendingGoogleCredential = null;
    _isCurrentUserNew = false;
    await StorePrefs.clearStoreId();
    await AccessManager.clear();
    await StoreConfigService.clear();
    bumpAuthTick();
  }

  static Future<void> clearStoreId() async => await StorePrefs.clearStoreId();

  // ═══════════════════════════════════════════════════════════════════════════
  // EMAIL/PASSWORD LOGIN
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<Map<String, String>?> login(
    String email,
    String password,
  ) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = cred.user!.uid;
      await fetchStoreConfig();
      return {'token': uid, 'storeId': uid};
    } catch (e) {
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GOOGLE SIGN-IN
  // ═══════════════════════════════════════════════════════════════════════════

  static final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  static Future<ApiResult<Map<String, dynamic>>> getGoogleCredentialOnly([
    AppLocalizations? s,
  ]) async {
    debugPrint('🔵 Google: Getting credential only');
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const ApiResult.fail(
          'cancelled',
          details: 'User cancelled sign-in',
        );
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      _pendingGoogleCredential = PendingGoogleCredential(
        credential: credential,
        email: googleUser.email,
        displayName: googleUser.displayName,
        photoUrl: googleUser.photoUrl,
      );

      return ApiResult.ok({
        'email': googleUser.email,
        'displayName': googleUser.displayName,
        'photoUrl': googleUser.photoUrl,
      });
    } catch (e) {
      return ApiResult.fail(
        'google_failed',
        details: mapFirebaseErrorToArabic(e, s),
      );
    }
  }

  /// SCHRITT 2: Sign-In mit gespeicherter Credential UND Store-Check
  static Future<ApiResult<Map<String, dynamic>>> signInWithGoogle([
    AppLocalizations? s,
  ]) async {
    _isProcessingAuth = true;
    bumpAuthTick();
    try {
      if (_pendingGoogleCredential == null) {
        final credResult = await getGoogleCredentialOnly(s);
        if (!credResult.ok) {
          return credResult;
        }
      }

      final pending = _pendingGoogleCredential!;
      final userCredential = await _auth.signInWithCredential(
        pending.credential,
      );
      final uid = userCredential.user!.uid;
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      _isCurrentUserNew = isNewUser;

      final storeExists = await storeDocumentExists(uid);

      if (!storeExists) {
        hasStore = false;

        final errorMsg =
            s?.errorNoStoreFound ??
            'عذراً، لا يوجد حساب مرتبط بهذا البريد الإلكتروني.';

        return ApiResult.fail(
          'no_store',
          details: errorMsg,
          data: {
            'uid': uid,
            'isNewUser': isNewUser,
            'email': pending.email,
            'displayName': pending.displayName,
          },
        );
      }

      hasStore = true;
      _pendingGoogleCredential = null;
      _isCurrentUserNew = false;

      await fetchStoreConfig();

      final verifyStatus = await checkVerificationStatus(uid);
      if (verifyStatus == 'expired') {
        hasStore = false;
        await clearAuth();

        final errorMsg =
            s?.errorAccountExpired ??
            'انتهت مهلة تفعيل الحساب. يرجى التسجيل من جديد.';

        return ApiResult.fail('expired', details: errorMsg);
      }

      return ApiResult.ok({
        'storeId': uid,
        'token': uid,
        'isNewUser': false,
        'email': pending.email,
        'displayName': pending.displayName,
      });
    } catch (e) {
      _pendingGoogleCredential = null;
      await clearAuth();
      return ApiResult.fail(
        'google_failed',
        details: mapFirebaseErrorToArabic(e, s),
      );
    } finally {
      _isProcessingAuth = false;
      bumpAuthTick();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REGISTRATION - DUAL COLLECTION ARCHITECTURE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Öffentliche Store-Daten (für stores_public)
  static Map<String, dynamic> _buildPublicStoreData({
    required String uid,
    required String storeName,
    required String slug,
    required String publicUrl,
    String? emailSupport,
    String? selectedCountry,
  }) {
    return {
      'store_name': storeName,
      'store_id': uid,
      'store_slug': slug,
      'public_store_url': publicUrl,
      'email_support': emailSupport ?? '',
      'currency': '€',
      'page_description': '',
      'phone': '',
      'whatsapp': '',
      'address': '',
      'shipping': false,
      'shipping_price': 0,
      'has_logo': '🏪',
      'working_hours': '{}',
      'tiktok': '',
      'instagram': '',
      'facebook': '',
      'customer_message': '',
      'customer_message_expiry': null,
    };
  }

  /// Private Store-Daten (für stores_private)
  static Map<String, dynamic> _buildPrivateStoreData({
    required String uid,
    required String loginEmail,
    required String authProvider,
    required String storeName,
    required bool isVerified,
    String? selectedCountry,
    String? slug,
  }) {
    final now = DateTime.now().toUtc();
    return {
      'store_id': uid,
      'store_slug': slug,
      'email_login': loginEmail,
      'owner_email': loginEmail,
      'auth_provider': authProvider,
      'store_name': storeName,
      'is_verified': isVerified,
      'verified_at': isVerified ? FieldValue.serverTimestamp() : null,
      'created_at': FieldValue.serverTimestamp(),
      'require_email_verify': !isVerified,
      'address_country': selectedCountry ?? '',
      'region': null, // Wird von Cloud Function gesetzt
      'access': {
        'status': 'trial',
        'stage': 0,
        'daysRemaining': 14,
        'trial_start_at': now.toIso8601String(),
        'trial_end_at': now.add(const Duration(days: 14)).toIso8601String(),
      },
    };
  }

  static Future<ApiResult<Map<String, String>>> registerWithGoogle({
    required String storeName,
    String? selectedCountry,
    bool requireEmailVerify = true,
    AppLocalizations? s,
  }) async {
    _isProcessingAuth = true;
    bumpAuthTick();
    try {
      String uid;
      bool isNewUser;

      if (_auth.currentUser != null) {
        uid = _auth.currentUser!.uid;
        isNewUser = _isCurrentUserNew;
      } else if (_pendingGoogleCredential != null) {
        final userCredential = await _auth.signInWithCredential(
          _pendingGoogleCredential!.credential,
        );
        uid = userCredential.user!.uid;
        isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
        _isCurrentUserNew = isNewUser;
      } else {
        final credResult = await getGoogleCredentialOnly(s);
        if (!credResult.ok) {
          return ApiResult.fail(credResult.error, details: credResult.details);
        }

        final userCredential = await _auth.signInWithCredential(
          _pendingGoogleCredential!.credential,
        );
        uid = userCredential.user!.uid;
        isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
        _isCurrentUserNew = isNewUser;
      }

      final storeExists = await storeDocumentExists(uid);
      if (storeExists) {
        hasStore = true;
        _pendingGoogleCredential = null;
        await fetchStoreConfig();
        return ApiResult.ok({'storeId': uid, 'existing': 'true'});
      }

      final (slug, publicUrl) = await SlugService.generateSlugForNewStore(
        storeId: uid,
        storeName: storeName,
      );

      final loginEmail =
          _pendingGoogleCredential?.email ?? _auth.currentUser?.email ?? '';

      // ═══════════════════════════════════════════════════════════════════════
      // DUAL COLLECTION WRITE
      // ═══════════════════════════════════════════════════════════════════════

      final publicData = _buildPublicStoreData(
        uid: uid,
        storeName: storeName,
        slug: slug,
        publicUrl: publicUrl,
        selectedCountry: selectedCountry,
      );

      final privateData = _buildPrivateStoreData(
        uid: uid,
        loginEmail: loginEmail,
        authProvider: 'google',
        isVerified: true, // Google = automatisch verifiziert
        storeName: storeName,
        selectedCountry: selectedCountry,
        slug: slug,
      );

      try {
        // Batch write für Atomizität
        final batch = _db.batch();
        batch.set(_storesPublic.doc(uid), publicData);
        batch.set(_storesPrivate.doc(uid), privateData);
        await batch.commit();
      } catch (e) {
        await _handleRegistrationFailure(isNewUser: isNewUser);
        return ApiResult.fail(
          'store_creation_failed',
          details: mapFirebaseErrorToArabic(e, s),
        );
      }

      try {
        await SlugService.createSlugDocument(
          slug: slug,
          storeId: uid,
          storeName: storeName,
        );
      } catch (e) {
        // Rollback: Lösche erstellte Store-Dokumente
        try {
          final batch = _db.batch();
          batch.delete(_storesPublic.doc(uid));
          batch.delete(_storesPrivate.doc(uid));
          await batch.commit();
        } catch (_) {}
        await _handleRegistrationFailure(isNewUser: isNewUser);
        return ApiResult.fail(
          'slug_creation_failed',
          details: mapFirebaseErrorToArabic(e, s),
        );
      }

      hasStore = true;
      _pendingGoogleCredential = null;
      _isCurrentUserNew = false;
      await StorePrefs.setStoreId(uid);
      await fetchStoreConfig();

      return ApiResult.ok({'storeId': uid});
    } catch (e) {
      await _handleRegistrationFailure(isNewUser: _isCurrentUserNew);
      return ApiResult.fail(
        'registration_failed',
        details: mapFirebaseErrorToArabic(e, s),
      );
    } finally {
      _isProcessingAuth = false;
      bumpAuthTick();
    }
  }

  static Future<void> _handleRegistrationFailure({
    required bool isNewUser,
  }) async {
    if (isNewUser && _auth.currentUser != null) {
      try {
        await _auth.currentUser!.delete();
      } catch (_) {}
    }
    hasStore = false;
    _isCurrentUserNew = false;
    _pendingGoogleCredential = null;
    await _auth.signOut();
    await _googleSignIn.signOut();
    bumpAuthTick();
  }

  static Future<void> cancelPendingGoogleRegistration() async {
    await _handleRegistrationFailure(isNewUser: _isCurrentUserNew);
  }

  static Future<bool> checkGoogleUserHasStore() async {
    if (_auth.currentUser == null) return false;
    return await storeDocumentExists(_auth.currentUser!.uid);
  }

  static Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  static Future<void> cleanupFailedGoogleSignIn({
    bool deleteUser = false,
  }) async {
    await _handleRegistrationFailure(isNewUser: deleteUser);
  }

  static Future<ApiResult<Map<String, String>>> registerFull({
    required Map<String, dynamic> store,
    required String username,
    required String password,
    AppLocalizations? s,
  }) async {
    _isProcessingAuth = true;
    bumpAuthTick();
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: username.trim(),
        password: password,
      );
      final uid = cred.user!.uid;
      final loginEmail = username.trim();
      final storeName = (store['store_name'] ?? 'My Store').toString();
      final (slug, publicUrl) = await SlugService.generateSlugForNewStore(
        storeId: uid,
        storeName: storeName,
      );

      // ═══════════════════════════════════════════════════════════════════════
      // DUAL COLLECTION WRITE
      // ═══════════════════════════════════════════════════════════════════════

      final publicData = _buildPublicStoreData(
        uid: uid,
        storeName: storeName,
        slug: slug,
        publicUrl: publicUrl,
        emailSupport: store['email_support']?.toString(),
        selectedCountry: store['address_country']?.toString(),
      );

      // Überschreibe mit benutzerdefinierten Werten aus store Map
      final allowedPublicFields = {
        'currency',
        'page_description',
        'phone',
        'whatsapp',
        'address',
        'shipping',
        'shipping_price',
        'has_logo',
        'working_hours',
        'tiktok',
        'instagram',
        'facebook',
      };
      for (final key in allowedPublicFields) {
        if (store.containsKey(key)) {
          publicData[key] = store[key];
        }
      }

      final privateData = _buildPrivateStoreData(
        uid: uid,
        loginEmail: loginEmail,
        authProvider: 'email',
        isVerified: false, // Email muss verifiziert werden
        storeName: storeName,
        selectedCountry: store['address_country']?.toString(),
        slug: slug,
      );

      // Batch write für Atomizität
      final batch = _db.batch();
      batch.set(_storesPublic.doc(uid), publicData);
      batch.set(_storesPrivate.doc(uid), privateData);
      await batch.commit();

      await SlugService.createSlugDocument(
        slug: slug,
        storeId: uid,
        storeName: storeName,
      );

      hasStore = true;
      bumpAuthTick();

      await _auth.currentUser?.sendEmailVerification();

      return ApiResult.ok({'storeId': uid});
    } catch (e) {
      await _auth.signOut();
      return ApiResult.fail(
        'registration_failed',
        details: mapFirebaseErrorToArabic(e, s),
      );
    } finally {
      _isProcessingAuth = false;
      bumpAuthTick();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EMAIL VERIFICATION & PASSWORD RESET
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<ApiResult<void>> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
      return const ApiResult.ok(null);
    } catch (e) {
      return ApiResult.fail(e.toString());
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

  static Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  static Future<bool> startPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } catch (e) {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PRODUCTS - unter stores_public/{storeId}/products
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<List<Product>> fetchProducts({
    bool forceRefresh = false,
    String? v,
  }) async {
    if (_storeId == null) return [];
    try {
      final snapshot = await _storesPublic
          .doc(_storeId)
          .collection('products')
          .get();
      final products = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Product.fromMap(data);
      }).toList();
      _updateProductsNotifier(products);
      return products;
    } catch (e) {
      return _cachedProducts ?? [];
    }
  }

  static Future<bool> addProduct(Product product) async {
    if (_storeId == null) return false;
    try {
      final docRef = _storesPublic.doc(_storeId).collection('products').doc();
      final data = product.toJson();
      data['id'] = docRef.id;
      await docRef.set(data);
      if (_cachedProducts != null) {
        _updateProductsNotifier([Product.fromMap(data), ..._cachedProducts!]);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateProduct(Product product) async {
    if (_storeId == null) return false;
    try {
      await _storesPublic
          .doc(_storeId)
          .collection('products')
          .doc(product.id)
          .update(product.toJson());
      if (_cachedProducts != null) {
        final updated = _cachedProducts!
            .map((p) => p.id == product.id ? product : p)
            .toList();
        _updateProductsNotifier(updated);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateCategoryOffers(
    String category,
    Map<String, dynamic> offerData,
  ) async {
    if (_storeId == null) return false;
    try {
      final snapshot = await _storesPublic
          .doc(_storeId)
          .collection('products')
          .where('category', isEqualTo: category)
          .get();
      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, offerData);
      }
      await batch.commit();
      await fetchProducts(forceRefresh: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteProduct(String id) async {
    if (_storeId == null) return false;
    try {
      await _deleteProductImages(_storeId!, id);
      await _storesPublic.doc(_storeId).collection('products').doc(id).delete();
      if (_cachedProducts != null) {
        _updateProductsNotifier(
          _cachedProducts!.where((p) => p.id != id).toList(),
        );
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> _deleteProductImages(
    String storeId,
    String productId,
  ) async {
    final storage = FirebaseStorage.instanceFor(
      bucket: 'gs://aldeebtech-1ec64.firebasestorage.app',
    );
    final basePath = 'stores/$storeId/products/$productId';
    final files = [
      '$basePath/image.jpg',
      '$basePath/image.jpeg',
      '$basePath/image_360x360.jpeg',
      '$basePath/image_1600x1600.jpeg',
    ];
    for (final path in files) {
      try {
        await storage.ref(path).delete();
      } catch (_) {}
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CATEGORIES
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<List<String>> fetchCategories({
    bool forceRefresh = false,
  }) async {
    final products = await fetchProducts(forceRefresh: forceRefresh);
    final list =
        products
            .map((p) => p.category.trim())
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    _cachedCategories = list;
    return list;
  }

  static Future<bool> renameCategory(String oldName, String newName) async {
    if (_storeId == null) return false;
    try {
      final snapshot = await _storesPublic
          .doc(_storeId)
          .collection('products')
          .where('category', isEqualTo: oldName)
          .get();
      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'category': newName});
      }
      await batch.commit();
      await fetchProducts(forceRefresh: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteCategory(
    String name, {
    String moveToCategory = 'اخرى',
  }) async {
    if (_storeId == null) return false;
    try {
      final snapshot = await _storesPublic
          .doc(_storeId)
          .collection('products')
          .where('category', isEqualTo: name)
          .get();
      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'category': moveToCategory});
      }
      await batch.commit();
      await fetchProducts(forceRefresh: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STORE CONFIG - DUAL COLLECTION READ (Admin)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Lädt Store-Konfiguration aus beiden Collections (für Admin-Views)
  static Future<Map<String, dynamic>?> fetchStoreConfig() async {
    if (_storeId == null) return null;
    try {
      final results = await Future.wait([
        _storesPublic.doc(_storeId).get(),
        _storesPrivate.doc(_storeId).get(),
      ]);

      final publicDoc = results[0];
      final privateDoc = results[1];

      if (!publicDoc.exists) {
        hasStore = false;
        return null;
      }

      hasStore = true;

      final data = <String, dynamic>{
        ...publicDoc.data()!,
        if (privateDoc.exists) ...privateDoc.data()!,
      };

      _setStoreName(data['store_name']?.toString());

      // -----------------------------------------------------------------------
      // FIX: Explizite Konvertierung statt Cast (Verhindert den Map-Fehler)
      // -----------------------------------------------------------------------
      if (data['access'] != null) {
        _access = Map<String, dynamic>.from(data['access'] as Map);
      } else {
        _access = null;
      }

      if (_access != null) AccessManager.updateFromServer(_access!);
      if (_storeName != null) CacheStore.saveString('storeName', _storeName!);

      final dataForCache = _sanitizeForJson(data);
      await StoreConfigService.set(dataForCache);

      return data;
    } catch (e) {
      debugPrint('fetchStoreConfig Error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchWebsiteStatus() async =>
      await fetchStoreConfig();

  // ═══════════════════════════════════════════════════════════════════════════
  // STORE UPDATE - SPLIT WRITES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Öffentliche Felder die in stores_public geschrieben werden
  static const Set<String> _publicFields = {
    'store_name',
    'store_slug',
    'store_id',
    'currency',
    'page_description',
    'phone',
    'whatsapp',
    'email_support',
    'address',
    'shipping',
    'shipping_price',
    'has_logo',
    'working_hours',
    'tiktok',
    'instagram',
    'facebook',
    'public_store_url',
    'customer_message',
    'customer_message_expiry',
  };

  /// Private Felder die in stores_private geschrieben werden
  static const Set<String> _privateFields = {
    'email_login',
    'owner_email',
    'auth_provider',
    'is_verified',
    'verified_at',
    'created_at',
    'require_email_verify',
    'address_country',
    'region',
    'access',
  };

  /// Aktualisiert Store-Daten in den richtigen Collections
  static Future<bool> updateStore(Map<String, dynamic> data) async {
    if (_storeId == null) return false;
    try {
      final publicData = <String, dynamic>{};
      final privateData = <String, dynamic>{};

      for (final entry in data.entries) {
        if (_publicFields.contains(entry.key)) {
          publicData[entry.key] = entry.value;
        } else if (_privateFields.contains(entry.key)) {
          privateData[entry.key] = entry.value;
        } else {
          // Unbekannte Felder → Public (sicherer Default)
          publicData[entry.key] = entry.value;
        }
      }

      final batch = _db.batch();

      if (publicData.isNotEmpty) {
        batch.update(_storesPublic.doc(_storeId), publicData);
      }
      if (privateData.isNotEmpty) {
        batch.update(_storesPrivate.doc(_storeId), privateData);
      }

      await batch.commit();

      if (data.containsKey('store_name')) {
        _setStoreName(data['store_name']?.toString());
      }

      return true;
    } catch (e) {
      debugPrint('updateStore Error: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Rekursiv alle Firestore-Timestamps in JSON-kompatible Strings umwandeln
  static dynamic _sanitizeForJson(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    }
    if (value is Map) {
      return Map<String, dynamic>.fromEntries(
        value.entries.map(
          (e) => MapEntry(e.key.toString(), _sanitizeForJson(e.value)),
        ),
      );
    }
    if (value is List) {
      return value.map(_sanitizeForJson).toList();
    }
    return value;
  }

  static List<String> categoriesFromCachedProducts() => _cachedCategories ?? [];

  static List<String> descriptionSnippets({int max = 50}) {
    final items = _cachedProducts ?? [];
    final snippets = <String>[];
    for (final p in items) {
      final parts = p.description
          .trim()
          .split(RegExp(r'[\n•]+'))
          .map((s) => s.trim())
          .where((s) => s.length >= 8 && s.length <= 90)
          .toList();
      snippets.addAll(parts);
      if (snippets.length >= max) break;
    }
    return snippets.toSet().toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CUSTOMER MESSAGE
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<String?> getCustomerMessage({bool forceRefresh = false}) async {
    if (_storeId == null) return null;
    try {
      final doc = await _storesPublic.doc(_storeId).get();
      final data = doc.data();

      final expiry = data?['customer_message_expiry'];
      if (expiry is Timestamp) {
        if (DateTime.now().isAfter(expiry.toDate())) {
          await clearCustomerMessage();
          return '';
        }
      }

      return data?['customer_message'] ?? '';
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getPublicStoreUrl() async {
    if (_storeId == null) return null;
    try {
      final doc = await _storesPublic.doc(_storeId).get();
      return doc.data()?['public_store_url'];
    } catch (e) {
      return null;
    }
  }

  static Future<bool> setCustomerMessage(
    String message, {
    DateTime? expiryDate,
  }) async {
    if (_storeId == null) return false;
    try {
      await _storesPublic.doc(_storeId).update({
        'customer_message': message,
        'customer_message_expiry': expiryDate != null
            ? Timestamp.fromDate(expiryDate)
            : null,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> clearCustomerMessage() async {
    if (_storeId == null) return false;
    try {
      await _storesPublic.doc(_storeId).update({
        'customer_message': '',
        'customer_message_expiry': null,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PUBLIC STORE ACCESS (für öffentliche Shop-Seiten)
  // Liest NUR aus stores_public - keine Auth erforderlich
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>?> getPublicStoreBySlug(String slug) async {
    try {
      final slugDoc = await _slugs.doc(slug).get();
      if (!slugDoc.exists) return null;

      final storeId = slugDoc.data()?['store_id'];
      if (storeId == null) return null;

      // NUR stores_public lesen - keine privaten Daten!
      final storeDoc = await _storesPublic.doc(storeId).get();
      if (!storeDoc.exists) return null;

      final data = storeDoc.data()!;
      data['store_id'] = storeId;

      return data;
    } catch (e) {
      debugPrint('🔴 getPublicStoreBySlug Error: $e');
      return null;
    }
  }

  static Future<List<Product>> getPublicProductsBySlug(String slug) async {
    try {
      final slugDoc = await _slugs.doc(slug).get();
      if (!slugDoc.exists) return [];

      final storeId = slugDoc.data()?['store_id'];
      if (storeId == null) return [];

      final snapshot = await _storesPublic
          .doc(storeId)
          .collection('products')
          .where('product_active', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Product.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('🔴 getPublicProductsBySlug Error: $e');
      return [];
    }
  }

  static Future<Product?> getPublicProductBySlug(
    String slug,
    String productId,
  ) async {
    try {
      final slugDoc = await _slugs.doc(slug).get();
      if (!slugDoc.exists) return null;

      final storeId = slugDoc.data()?['store_id'];
      if (storeId == null) return null;

      final productDoc = await _storesPublic
          .doc(storeId)
          .collection('products')
          .doc(productId)
          .get();

      if (!productDoc.exists) return null;

      final data = productDoc.data()!;
      data['id'] = productDoc.id;
      return Product.fromMap(data);
    } catch (e) {
      debugPrint('🔴 getPublicProductBySlug Error: $e');
      return null;
    }
  }

  static Future<List<String>> getPublicCategoriesBySlug(String slug) async {
    final products = await getPublicProductsBySlug(slug);
    return products
        .map((p) => p.category.trim())
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // APP REVIEWS
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<bool> submitAppReview({
    required int stars,
    required String comment,
  }) async {
    if (_storeId == null) return false;
    try {
      await _db.collection('app_reviews').add({
        'store_id': _storeId,
        'store_name': _storeName,
        'stars': stars,
        'comment': comment,
        'timestamp': FieldValue.serverTimestamp(),
        'platform': defaultTargetPlatform.name.toLowerCase(),
      });
      return true;
    } catch (e) {
      debugPrint('Error submitting review: $e');
      return false;
    }
  }
}
