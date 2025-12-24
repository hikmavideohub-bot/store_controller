import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../config.dart';
import '../services/store_config_service.dart';
import 'package:flutter/foundation.dart'; // debugPrint
import 'package:shared_preferences/shared_preferences.dart';



/// =======================================================
/// ApiService
/// -------------------------------------------------------
/// خدمة الاتصال مع Google Apps Script لإدارة المتجر الإلكتروني
/// =======================================================
class ApiService {
  // =======================================================
  // الثوابت والإعدادات الأساسية
  // =======================================================
  static const String _baseUrl = AppConfig.apiBaseUrl;
  static const Duration _timeout = Duration(seconds: 20);
  static const Duration _catTtl = Duration(minutes: 10);

  // =======================================================
  // المتغيرات الثابتة للتخزين المؤقت
  // =======================================================
  static List<String>? _cachedCategories;
  static DateTime? _categoriesFetchedAt;
  static List<Product>? _cachedProducts;
  static List<Product>? get cachedProducts => _cachedProducts;
  static String? _storeId;
  static String? _cachedCustomerMessage;
  static DateTime? _cachedCustomerMessageAt;
  static const Duration _customerMsgTtl = Duration(minutes: 10);
  static String? _token;
  static bool get isLoggedIn => _token != null && _token!.isNotEmpty;
  static String? get token => _token;
  static final ValueNotifier<int> authTick = ValueNotifier<int>(0);







  // =======================================================
  // دوال المساعدة (Helpers)
  // =======================================================

  static Future<void> bootstrapAuth() async {
    // Token/StoreId aus Speicher laden
    _token = await AppConfig.getToken();
    _storeId = await AppConfig.getStoreId();

    // Router/redirect neu auswerten
    authTick.value++;
  }

  static Future<void> clearAuth() async {
    _token = null;
    _storeId = null;

    await AppConfig.clearToken();
    await AppConfig.clearStoreId();

    authTick.value++; // 🔔 Router informieren
  }


  static void setAuth({required String token, required String storeId}) {
    _token = token;
    _storeId = storeId;

    // caches invalidieren (customer message etc.)
    _cachedCustomerMessage = null;
    _cachedCustomerMessageAt = null;
  }


  /// تحويل القيمة إلى قيمة منطقية
  static bool _asBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.trim().toLowerCase();
      return s == 'true' || s == '1' || s == 'yes' || s == 'ok';
    }
    return false;
  }

  /// فك تشفير JSON مع معالجة الأخطاء
  static Map<String, dynamic>? _decodeJson(String body) {
    try {
      final t = body.trim();
      final start = t.indexOf('{');
      if (start == -1) return null;

      final jsonStr = t.substring(start);
      final obj = json.decode(jsonStr);
      return obj is Map<String, dynamic> ? obj : null;
    } catch (_) {
      return null;
    }
  }

  /// التحقق من صلاحية ذاكرة التخزين المؤقت للتصنيفات
  static bool _catCacheValid() {
    if (_cachedCategories == null || _categoriesFetchedAt == null) return false;
    return DateTime.now().difference(_categoriesFetchedAt!) < _catTtl;
  }

  // =======================================================
  // إدارة معرف المتجر (StoreId)
  // =======================================================

  static Future<Map<String, String>?> register(
      String username,
      String password,
      String storeId,
      ) async {
    final resp = await _sendPost({
      'action': 'register',
      'username': username,
      'password': password,
      'storeId': storeId,
    });

    final j = _decodeJson(resp.body);
    if (j == null || !_asBool(j['success'])) return null;

    final r = j['result'];
    final token = r['token']?.toString();
    final sid = r['storeId']?.toString();

    if (token == null || sid == null) return null;

    _token = token;
    _storeId = sid;

    return {'token': token, 'storeId': sid};
  }

  static Future<Map<String, String>?> login(String username, String password) async {
    final resp = await _sendPost({
      'action': 'login',
      'username': username,
      'password': password,
    });

    final j = _decodeJson(resp.body);
    if (j == null || !_asBool(j['success'])) return null;

    final r = j['result'];
    final token = (r is Map ? r['token'] : null)?.toString();
    final storeId = (r is Map ? r['storeId'] : null)?.toString();

    if (token == null || token.isEmpty || storeId == null || storeId.isEmpty) return null;

    _token = token;
    _storeId = storeId; // optional

    return {'token': token, 'storeId': storeId};
  }

  /// تهيئة معرف المتجر من الذاكرة المحلية
  static Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    _token = sp.getString('auth_token');

    // storeId optional nur für Anzeige / Legacy
    _storeId = sp.getString('storeId');
  }


  /// الحصول على معرف المتجر الحالي
  static String? get storeId => _storeId;

  /// تعيين معرف متجر جديد وحفظه في الذاكرة المحلية

  static Future<void> setStoreId(String id) async {
    _storeId = id;
    await AppConfig.setStoreId(id); // <-- statt prefs.setString('storeId', id)
  }

  /// مسح معرف المتجر من الذاكرة
  static Future<void> clearStoreId() async {
    _storeId = null;
    await AppConfig.clearStoreId();

    // ✅ DAS IST DIE ENTSCHEIDENDE ZEILE
    authTick.value++;
  }



  // =======================================================
  // إدارة التخزين المؤقت (Cache Management)
  // =======================================================

  /// تعيين ذاكرة التخزين المؤقت للمنتجات
  static void setProductsCache(List<Product> items) {
    _cachedProducts = List<Product>.from(items);
  }
  static void _log(String msg) {
    if (AppConfig.debugLogApi) debugPrint(msg);
  }


  /// تعيين ذاكرة التخزين المؤقت للتصنيفات
  static void setCategoriesCache(List<String> cats) {
    final unique = cats.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet().toList()..sort();
    _cachedCategories = unique;
    _categoriesFetchedAt = DateTime.now();
  }

  /// إبطال ذاكرة التخزين المؤقت للتصنيفات
  static void invalidateCategoriesCache() {
    _cachedCategories = null;
    _categoriesFetchedAt = null;
  }

  static Future<Map<String, dynamic>?> fetchWebsiteStatus() async {
    if (_storeId == null || _storeId!.isEmpty) return null;

    // nutzt deinen bestehenden _sendGet – nur anderer type
    final response = await _sendGet('websiteStatus');
    if (response.statusCode != 200) return null;

    final j = _decodeJson(response.body);
    if (j == null || !_asBool(j['success'])) return null;

    final raw = j['data'];
    return raw is Map ? Map<String, dynamic>.from(raw) : null;
  }


  /// استخراج التصنيفات من المنتجات المخزنة مؤقتاً

  static List<String> categoriesFromCachedProducts() {
    final items = _cachedProducts ?? const <Product>[];
    final set = <String>{};

    for (final p in items) {
      final c = p.category.trim();
      if (c.isNotEmpty) set.add(c);
    }

    final list = set.toList()..sort();
    return list;
  }

  /// استخراج أجزاء من أوصاف المنتجات للاقتراحات
  static List<String> descriptionSnippets({int max = 50}) {
    final items = _cachedProducts ?? const <Product>[];
    final snippets = <String>[];

    for (final p in items) {
      final d = p.description.trim();
      if (d.isEmpty) continue;

      final parts = d
          .split(RegExp(r'[\n•]+'))
          .map((s) => s.trim())
          .where((s) => s.length >= 8 && s.length <= 80)
          .toList();

      snippets.addAll(parts);
      if (snippets.length >= max) break;
    }

    return snippets.toSet().toList();
  }

  // =======================================================
  // دوال الاتصال الأساسية (HTTP Methods)
  // =======================================================

  /// إرسال طلب GET إلى السيرفر
  static Future<http.Response> _sendGet(String type) async {
    final ts = DateTime.now().millisecondsSinceEpoch;

    final qp = <String, String>{
      'type': type,
      '_ts': '$ts',
    };

    // ✅ Premium: token statt storeId
    if (_token != null && _token!.isNotEmpty) {
      qp['token'] = _token!;
    }

    final uri = Uri.parse(_baseUrl).replace(queryParameters: qp);

    return http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(_timeout);
  }


  /// إرسال طلب POST مع معالجة التحويلات (Redirect)
  static Future<http.Response> _sendPost(Map<String, dynamic> body) async {
    final client = http.Client();
    try {
      // ✅ Premium: token automatisch mitsenden
      final Map<String, dynamic> payload = Map<String, dynamic>.from(body);
      if (_token != null && _token!.isNotEmpty) {
        payload['token'] = _token!;
      }

      final uri = Uri.parse(_baseUrl);
      final req = http.Request('POST', uri)
        ..followRedirects = false
        ..headers['Content-Type'] = 'application/json'
        ..headers['Accept'] = 'application/json'
        ..body = json.encode(payload);

      final streamed = await client.send(req).timeout(_timeout);
      final resp = await http.Response.fromStream(streamed);

      // ✅ معالجة التحويلات من Google Apps Script
      final location = resp.headers['location'];
      if ((resp.statusCode == 302 || resp.statusCode == 303) &&
          location != null &&
          location.isNotEmpty) {
        // ✅ Premium: token auch beim Redirect-GET anhängen
        var redirectUri = Uri.parse(location);
        if (_token != null && _token!.isNotEmpty) {
          final qp = Map<String, String>.from(redirectUri.queryParameters);
          qp['token'] = _token!;
          redirectUri = redirectUri.replace(queryParameters: qp);
        }

        return await client
            .get(redirectUri, headers: {'Accept': 'application/json'})
            .timeout(_timeout);
      }

      return resp;
    } finally {
      client.close();
    }
  }


  // =======================================================
  // دوال المنتجات (Products)
  // =======================================================

  /// جلب قائمة جميع المنتجات
  static Future<List<Product>> fetchProducts() async {
    try {
      final response = await _sendGet('products');
      if (response.statusCode != 200) return [];

      final j = _decodeJson(response.body);
      if (j == null || !_asBool(j['success'])) return [];

      final list = j['products'];
      if (list is! List) return [];

      final products = list
          .whereType<Map>()
          .map((e) => Product.fromMap(Map<String, dynamic>.from(e)))
          .toList();

      setProductsCache(products);
      return products;
    } catch (_) {
      return [];
    }
  }
  static Future<bool> registerFull({
    required Map<String, dynamic> store,
    required String username,
    required String password,
  }) async {
    final resp = await _sendPost({
      'action': 'registerFull',
      'username': username,
      'password': password,
      'store': store,
    });

    final j = _decodeJson(resp.body);
    if (j == null || !_asBool(j['success'])) return false;

    final r = j['result'];
    final token = (r is Map ? r['token'] : null)?.toString();
    final storeId = (r is Map ? r['storeId'] : null)?.toString();

    if (token == null || token.isEmpty || storeId == null || storeId.isEmpty) return false;

    _token = token;
    _storeId = storeId; // optional

    return true;
  }
  static Future<void> persistAuthToPrefs() async {
    final sp = await SharedPreferences.getInstance();
    if (_token != null) await sp.setString('auth_token', _token!);
    if (_storeId != null) await sp.setString('storeId', _storeId!);
  }



  /// إضافة منتج جديد
  static Future<bool> addProduct(Product product) async {
    // Premium: storeId kommt serverseitig aus token/session
    if (_token == null || _token!.isEmpty) return false;

    final response = await _sendPost({
      'action': 'addProduct',
      'data': product.toJson(),
    });

    final j = _decodeJson(response.body);
    if (j == null) {
      _log("addProduct: invalid JSON: ${response.body}");
      return false;
    }
    if (!_asBool(j['success'])) {
      _log("addProduct failed: ${j['error']}");
      return false;
    }
    return true;
  }


  /// تحديث بيانات منتج موجود
  static Future<bool> updateProduct(Product product) async {
    if (_storeId == null || _storeId!.isEmpty) return false;
    final response = await _sendPost({
      'action': 'updateProduct',
      'storeId': _storeId ?? '',
      'data': product.toJson(),
    });

    final j = _decodeJson(response.body);
    return j != null && _asBool(j['success']);
  }

  /// حذف منتج
  static Future<bool> deleteProduct(String id) async {
    if (_storeId == null || _storeId!.isEmpty) return false;
    final response = await _sendPost({
      'action': 'deleteProduct',
      'storeId': _storeId ?? '',
      'id': id,
    });

    final j = _decodeJson(response.body);
    return j != null && _asBool(j['success']);
  }

  // =======================================================
  // دوال التصنيفات (Categories)
  // =======================================================

  /// جلب قائمة التصنيفات
  static Future<List<String>> fetchCategories() async {
    try {
      if (_catCacheValid()) return List<String>.from(_cachedCategories!);

      final response = await _sendGet('categories');
      if (response.statusCode != 200) return [];

      final j = _decodeJson(response.body);
      if (j == null || !_asBool(j['success'])) return [];

      final list = j['categories'];
      if (list is! List) return [];

      final cats = list.map((e) => e.toString()).toList();
      setCategoriesCache(cats);
      return List<String>.from(_cachedCategories!);
    } catch (_) {
      return _cachedCategories != null ? List<String>.from(_cachedCategories!) : [];
    }
  }

  /// إضافة تصنيف جديد
  static Future<bool> addCategory(String name) async {
    if (_storeId == null || _storeId!.isEmpty) return false;
    final response = await _sendPost({
      'action': 'addCategory',
      'storeId': _storeId ?? '',
      'category': name,
    });

    final j = _decodeJson(response.body);
    final ok = j != null && _asBool(j['success']);

    if (ok) invalidateCategoriesCache();
    return ok;
  }

  /// إعادة تسمية تصنيف
  static Future<bool> renameCategory(String oldName, String newName) async {
    if (_storeId == null || _storeId!.isEmpty) return false;
    final response = await _sendPost({
      'action': 'renameCategory',
      'storeId': _storeId ?? '',
      'oldName': oldName,
      'newName': newName,
    });

    final j = _decodeJson(response.body);
    final ok = j != null && _asBool(j['success']);

    if (ok) invalidateCategoriesCache();
    return ok;
  }

  /// حذف تصنيف
  static Future<bool> deleteCategory(String name, {String moveToCategory = ''}) async {
    if (_storeId == null || _storeId!.isEmpty) return false;
    final response = await _sendPost({
      'action': 'deleteCategory',
      'storeId': _storeId ?? '',
      'category': name,
      'moveToCategory': moveToCategory,
    });

    final j = _decodeJson(response.body);
    final ok = j != null && _asBool(j['success']);

    if (ok) invalidateCategoriesCache();
    return ok;
  }

  // =======================================================
  // دوال إعدادات المتجر (Store Settings)
  // =======================================================

  /// جلب إعدادات المتجر
  static Future<Map<String, dynamic>?> fetchStoreConfig() async {
    if (_storeId == null || _storeId!.isEmpty) {
      _log('fetchStoreConfig: storeId empty');
      return null;
    }

    final response = await _sendGet('storeConfig');
    _log('fetchStoreConfig status=${response.statusCode}');
    _log('fetchStoreConfig body=${response.body}');

    if (response.statusCode != 200) return null;

    final j = _decodeJson(response.body);
    _log('fetchStoreConfig json=$j');

    if (j == null || !_asBool(j['success'])) return null;

    // ✅ WICHTIG: Apps Script liefert "data", nicht "store"
    final raw = j['data'] ?? j['store'] ?? j['result'];

    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }

    return null;
  }



  /// تسجيل متجر جديد
  static Future<String?> registerStore(Map<String, dynamic> data) async {
    final response = await _sendPost({
      'action': 'registerStore',
      'data': data,
    });

    final j = _decodeJson(response.body);
    if (j == null || !_asBool(j['success'])) return null;

    final result = j['result'];
    final storeId =
        (result is Map ? (result['store_id'] ?? result['storeId']) : null)?.toString() ??
            (j['store_id'] ?? j['storeId'])?.toString();

    if (storeId == null || storeId.isEmpty) return null;

    await setStoreId(storeId);

    // ✅ einmal config laden + cachen
    final s = await fetchStoreConfig();
    if (s != null) {
      await StoreConfigService.set(s);
    } else {
      // optional: zumindest leeres Store-Objekt nicht überschreiben
      // debugPrint('registerStore: fetchStoreConfig returned null');
    }

    return storeId;
  }


  /// تحديث إعدادات المتجر
  static Future<bool> updateStore(Map<String, dynamic> data) async {
    if (_storeId == null || _storeId!.isEmpty) return false;

    final response = await _sendPost({
      'action': 'updateStore',
      'storeId': _storeId ?? '',
      'data': data,
    });

    final j = _decodeJson(response.body);
    final ok = j != null && _asBool(j['success']);
    if (ok) {
      await StoreConfigService.mergeNonEmpty(data); // ✅ snake_case passt zu deinem _fill()
    }
    return ok;

  }
  // =======================================================
// Customer Message (A3)
// =======================================================

  static Future<String?> getCustomerMessage({bool forceRefresh = false}) async {
    if (_storeId == null || _storeId!.isEmpty) return null;

    final now = DateTime.now();
    final cacheValid = _cachedCustomerMessageAt != null &&
        now.difference(_cachedCustomerMessageAt!) < _customerMsgTtl;

    if (!forceRefresh && cacheValid) {
      return _cachedCustomerMessage ?? '';
    }

    final response = await _sendGet('customerMessage');
    if (response.statusCode != 200) return _cachedCustomerMessage;

    final j = _decodeJson(response.body);
    if (j == null || !_asBool(j['success'])) return _cachedCustomerMessage;

    _cachedCustomerMessage = (j['message'] ?? '').toString();
    _cachedCustomerMessageAt = now;
    return _cachedCustomerMessage;
  }


  static Future<bool> setCustomerMessage(String message) async {
    if (_storeId == null || _storeId!.isEmpty) return false;

    final response = await _sendPost({
      'action': 'setCustomerMessage',
      'storeId': _storeId ?? '',
      'message': message,
    });

    final j = _decodeJson(response.body);
    final ok = j != null && _asBool(j['success']);
    if (ok) {
      _cachedCustomerMessage = message;
      _cachedCustomerMessageAt = DateTime.now();
    }
    return ok;
  }

  static Future<bool> clearCustomerMessage() async {
    if (_storeId == null || _storeId!.isEmpty) return false;

    final response = await _sendPost({
      'action': 'clearCustomerMessage',
      'storeId': _storeId ?? '',
    });

    final j = _decodeJson(response.body);
    final ok = j != null && _asBool(j['success']);
    if (ok) {
      _cachedCustomerMessage = '';
      _cachedCustomerMessageAt = DateTime.now();
    }
    return ok;
  }




}