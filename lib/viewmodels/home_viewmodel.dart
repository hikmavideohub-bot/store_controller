import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/store_config_service.dart';
import '../storage/store_prefs.dart';
import 'base_viewmodel.dart';

/// ViewModel für HomeScreen (Dashboard)
class HomeViewModel extends BaseViewModel {
  HomeViewModel() {
    _init();
  }

  // ===========================================
  // STATE
  // ===========================================

  bool _loading = true;
  bool _hasInternet = true;
  bool _missingStore = false;
  String? _storeId;
  List<Product> _products = [];

  // Status für die Kundennachricht (statt FutureBuilder im UI)
  String _customerMessage = '';

  // ===========================================
  // GETTERS
  // ===========================================

  bool get loading => _loading;
  bool get hasInternet => _hasInternet;
  bool get missingStore => _missingStore;
  String? get storeId => _storeId;
  List<Product> get products => _products;
  String get customerMessage => _customerMessage; // Getter für UI

  /// Store-Name - liest von der einzigen Quelle: StoreConfigService
  String? get storeName {
    final name = StoreConfigService.storeName;
    return name.isNotEmpty ? name : null;
  }
  String? get publicStoreUrl {
    final s = StoreConfigService.store;
    final url = (s?['public_store_url'] ?? '').toString().trim();
    if (url.isEmpty) return null;
    return url.startsWith('http') ? url : 'https://$url';
  }

  /// Generiert den Einladungstext basierend auf der aktuellen Sprache
  String getInvitationText(AppLocalizations s) {
    final name = storeName ?? s.defaultStoreName;
    final url = publicStoreUrl ?? '';
    return s.inviteText(name, url);
  }

  List<String> get categories =>
      _products
          .map((p) => p.category.trim())
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

  // ===========================================
  // STATISTIKEN
  // ===========================================

  int get totalProducts => _products.length;
  int get activeProducts => _products.where((p) => p.productActive).length;
  int get inactiveProducts => totalProducts - activeProducts;
  int get productsWithOffer =>
      _products.where((p) => p.hasOffer && p.offerActive).length;
  int get productsWithoutImage =>
      _products.where((p) => p.image.trim().isEmpty).length;

  /// Anzahl der Kategorien wo ALLE Produkte ein aktives Angebot haben
  int get categoriesWithFullOffers {
    final result = <String>[];
    final catProducts = <String, List<Product>>{};

    // Gruppiere Produkte nach Kategorie
    for (final p in _products) {
      final cat = p.category.trim();
      if (cat.isEmpty) continue;
      catProducts.putIfAbsent(cat, () => []).add(p);
    }

    // Prüfe ob ALLE Produkte einer Kategorie im Angebot sind
    catProducts.forEach((cat, products) {
      if (products.isNotEmpty &&
          products.every((p) => p.hasOffer && p.offerActive)) {
        result.add(cat);
      }
    });

    return result.length;
  }

  /// Liste der Kategorien wo ALLE Produkte ein aktives Angebot haben
  List<String> get categoriesWithFullOffersList {
    final result = <String>[];
    final catProducts = <String, List<Product>>{};

    // Gruppiere Produkte nach Kategorie
    for (final p in _products) {
      final cat = p.category.trim();
      if (cat.isEmpty) continue;
      catProducts.putIfAbsent(cat, () => []).add(p);
    }

    // Prüfe ob ALLE Produkte einer Kategorie im Angebot sind
    catProducts.forEach((cat, products) {
      if (products.isNotEmpty &&
          products.every((p) => p.hasOffer && p.offerActive)) {
        result.add(cat);
      }
    });

    return result..sort();
  }

  MapEntry<String, int> get topCategory {
    final catCount = <String, int>{};
    for (final p in _products) {
      final c = p.category.trim();
      if (c.isEmpty) continue;
      catCount[c] = (catCount[c] ?? 0) + 1;
    }

    String topCat = '-';
    int topCatN = 0;
    catCount.forEach((k, v) {
      if (v > topCatN) {
        topCat = k;
        topCatN = v;
      }
    });

    return MapEntry(topCat, topCatN);
  }

  List<Product> getActiveProducts() =>
      _products.where((p) => p.productActive).toList();
  List<Product> getInactiveProducts() =>
      _products.where((p) => !p.productActive).toList();
  List<Product> getProductsWithOffer() =>
      _products.where((p) => p.hasOffer && p.offerActive).toList();
  List<Product> getProductsWithoutImage() =>
      _products.where((p) => p.image.trim().isEmpty).toList();
  List<Product> getProductsByCategory(String category) =>
      _products.where((p) => p.category.trim() == category).toList();

  // ===========================================
  // INITIALIZATION
  // ===========================================

  Future<void> _init() async {
    ApiService.productsNotifier.addListener(_onProductsChanged);
    await boot();
  }

  @override
  void dispose() {
    ApiService.productsNotifier.removeListener(_onProductsChanged);
    super.dispose();
  }

  void _onProductsChanged() {
    final updated = ApiService.productsNotifier.value;
    if (updated.isNotEmpty) {
      _products = updated;
      notifyListeners();
    }
  }

  // ===========================================
  // ACTIONS
  // ===========================================

  Future<void> boot() async {
    String? id = await StorePrefs.getStoreId();
    if (id == null || id.isEmpty) {
      id = ApiService.storeId;
      if (id != null && id.isNotEmpty) await StorePrefs.setStoreId(id);
    }

    if (id == null || id.isEmpty) {
      _missingStore = true;
      _loading = false;
      notifyListeners();
      return;
    }

    _storeId = id;
    await loadProducts(null, silent: true);
  }

  Future<void> loadProducts(AppLocalizations? s, {bool silent = false}) async {
    if (!silent) {
      setBusy(true);
      _loading = true;
      notifyListeners();
    }

    try {
      await StoreConfigService.load(allowNetworkIfEmpty: true);

      // Parallel fetch: Holt Produkte UND Nachricht gleichzeitig für bessere Performance
      final results = await Future.wait([
        ApiService.fetchProducts(),
        ApiService.getCustomerMessage(),
      ]);

      final productData = results[0] as List<Product>;
      final msgData = results[1] as String?;

      _products = productData.isNotEmpty ? productData : _products;
      _customerMessage = msgData ?? ''; // Nachricht speichern

      _hasInternet = true;
      _loading = false;
    } catch (_) {
      _hasInternet = false;
      _loading = false;
      if (s != null && !silent) {
        setError(s.dashboardLoadError);
      }
    } finally {
      if (!silent) setBusy(false);
      notifyListeners();
    }
  }

  // --- NEU: Aktualisiert NUR die Nachricht (für sofortiges UI-Update) ---
  Future<void> refreshMessage() async {
    try {
      final msg = await ApiService.getCustomerMessage();
      _customerMessage = msg ?? '';
      notifyListeners();
    } catch (_) {
      // Fehler ignorieren, alte Nachricht behalten
    }
  }

  Future<void> syncAllData(AppLocalizations? s) async =>
      await loadProducts(s, silent: false);

  Future<bool> applyOfferToCategory(
    AppLocalizations s, {
    required String category,
    required String offerType,
    required double value, // percent or bundlePrice
    int? bundleQty,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    setBusy(true);
    final data = {
      'has_offer': true,
      'offer_active': true,
      'offer_type': offerType,
      'percent': offerType == 'percent' ? value : 0,
      'bundle_price': offerType == 'bundle' ? value : 0,
      'bundle_qty': offerType == 'bundle' ? (bundleQty ?? 0) : 0,
      'offer_start_date':
          "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
      'offer_end_date':
          "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
    };

    try {
      final ok = await ApiService.updateCategoryOffers(category, data);
      if (ok) await loadProducts(s, silent: true);
      setBusy(false);
      return ok;
    } catch (e) {
      setBusy(false);
      setError(s.dashboardUpdateError);
      return false;
    }
  }

  /// Deaktiviert alle Angebote für eine Kategorie
  Future<bool> disableOffersForCategory(
    AppLocalizations s,
    String category,
  ) async {
    setBusy(true);
    final data = {'offer_active': false};

    try {
      final ok = await ApiService.updateCategoryOffers(category, data);
      if (ok) await loadProducts(s, silent: true);
      setBusy(false);
      return ok;
    } catch (e) {
      setBusy(false);
      setError(s.dashboardUpdateError);
      return false;
    }
  }

  Future<bool> copyToClipboard(String text) async {
    if (text.trim().isEmpty) return false;
    await Clipboard.setData(ClipboardData(text: text.trim()));
    return true;
  }

  Future<void> shareStore(AppLocalizations s) async {
    final text = getInvitationText(s);
    if (text.isEmpty) return;
    await Share.share(text);
  }

  Future<bool> openExternalUrl(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return false;
    return await canLaunchUrl(uri)
        ? await launchUrl(uri, mode: LaunchMode.externalApplication)
        : false;
  }
}
