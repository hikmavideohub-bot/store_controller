import 'package:intl/intl.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/store_config_service.dart';
import '../storage/store_prefs.dart';
import '../core/access_manager.dart';
import 'base_viewmodel.dart';

/// ViewModel für ProductsScreen
/// Enthält alle Business-Logik für Produktliste, Filter, CRUD-Operationen
class ProductsViewModel extends BaseViewModel {
  ProductsViewModel() {
    _init();
  }

  // ===========================================
  // STATE
  // ===========================================

  List<Product> _products = [];
  bool _loading = true;
  bool _actionBusy = false;
  String? _storeId;
  bool _missingStore = false;

  String _searchQuery = '';
  String _categoryFilter = 'all';
  String _offerFilter = 'all';
  String _stockFilter = 'all';

  // Cache-Busting
  String? _revBundle;
  String _vParam = '';

  final NumberFormat _moneyFmt = NumberFormat("#,##0.00", "en");
  final NumberFormat _sizeFmt = NumberFormat("#,##0.##", "en");

  // ===========================================
  // GETTERS
  // ===========================================

  List<Product> get products => _products;
  bool get loading => _loading;
  bool get actionBusy => _actionBusy;
  String? get storeId => _storeId;
  bool get missingStore => _missingStore;

  String get searchQuery => _searchQuery;
  String get categoryFilter => _categoryFilter;
  String get offerFilter => _offerFilter;
  String get stockFilter => _stockFilter;

  /// Prüft ob Schreibaktionen erlaubt sind
  bool get canWrite => AccessManager.canWriteAdmin;

  /// Gibt Währung zurück
  String get currency {
    final settings = StoreConfigService.store;
    return settings?['currency']?.toString() ?? '€';
  }

  /// Alle verfügbaren Kategorien
  List<String> get categories {
    return _products
        .map((p) => p.category.trim())
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  // ===========================================
  // SETTERS
  // ===========================================

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setCategoryFilter(String value) {
    _categoryFilter = value;
    notifyListeners();
  }

  void setOfferFilter(String value) {
    _offerFilter = value;
    notifyListeners();
  }

  void setStockFilter(String value) {
    _stockFilter = value;
    notifyListeners();
  }

  void resetFilters() {
    _categoryFilter = 'all';
    _offerFilter = 'all';
    _stockFilter = 'all';
    notifyListeners();
  }

  // ===========================================
  // INITIALIZATION
  // ===========================================

  Future<void> _init() async {
    ApiService.productsNotifier.addListener(_onProductsChanged);
    // Initialer Load ohne Localization (silent error falls nötig)
    await boot(null);
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
  // BOOT / LADEN
  // ===========================================

  Future<void> boot(AppLocalizations? s) async {
    await _initVParam();

    String? id = await StorePrefs.getStoreId();

    if (id == null || id.isEmpty) {
      id = ApiService.storeId;
      if (id != null && id.isNotEmpty) {
        await StorePrefs.setStoreId(id);
      }
    }

    if (id == null || id.isEmpty) {
      _missingStore = true;
      _loading = false;
      notifyListeners();
      return;
    }

    _storeId = id;
    await loadProducts(s);
  }

  Future<void> _initVParam() async {
    _revBundle = null;
    _vParam = (_revBundle != null && _revBundle!.trim().isNotEmpty)
        ? _revBundle!.trim()
        : DateTime.now().millisecondsSinceEpoch.toString();
  }

  void _bustVParam() {
    _vParam = (_revBundle != null && _revBundle!.trim().isNotEmpty)
        ? _revBundle!.trim()
        : DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> loadProducts(AppLocalizations? s, {bool silent = false}) async {
    bool showedCache = false;

    final cached = ApiService.cachedProducts;
    if (cached != null && cached.isNotEmpty) {
      showedCache = true;
      _products = cached;
      _loading = false;
      notifyListeners();
    } else if (!silent) {
      _loading = true;
      notifyListeners();
    }

    try {
      final data = await ApiService.fetchProducts(v: _vParam);
      _products = data;
      _loading = false;
    } catch (e) {
      _loading = false;
      if (!showedCache && _products.isEmpty) {
        // Fallback, falls s null ist (beim init)
        setError(s?.productsLoadError ?? 'Error loading products');
      }
    }

    notifyListeners();
  }

  // ===========================================
  // PRODUKT-AKTIONEN
  // ===========================================

  Future<bool> toggleProductActive(Product p) async {
    if (!canWrite) return false;
    if (_actionBusy) return false;

    _actionBusy = true;
    final newValue = !p.productActive;

    // Optimistic update
    final idx = _products.indexWhere((x) => x.id == p.id);
    if (idx != -1) {
      _products[idx] = _products[idx].copyWith(productActive: newValue);
      notifyListeners();
    }

    final success = await ApiService.updateProduct(p.copyWith(productActive: newValue));

    if (!success && idx != -1) {
      // Rollback
      _products[idx] = _products[idx].copyWith(productActive: p.productActive);
    }

    if (success) _bustVParam();

    _actionBusy = false;
    notifyListeners();
    return success;
  }

  Future<bool> toggleOfferActive(Product p) async {
    if (!canWrite) return false;
    if (_actionBusy) return false;

    _actionBusy = true;
    final newValue = !p.offerActive;

    // Optimistic update
    final idx = _products.indexWhere((x) => x.id == p.id);
    if (idx != -1) {
      _products[idx] = _products[idx].copyWith(offerActive: newValue);
      notifyListeners();
    }

    final success = await ApiService.updateProduct(p.copyWith(offerActive: newValue));

    if (!success && idx != -1) {
      // Rollback
      _products[idx] = _products[idx].copyWith(offerActive: p.offerActive);
    }

    if (success) _bustVParam();

    _actionBusy = false;
    notifyListeners();
    return success;
  }

  Future<bool> deleteProduct(Product p) async {
    if (!canWrite) return false;

    final success = await ApiService.deleteProduct(p.id);

    if (success) {
      _products.removeWhere((x) => x.id == p.id);
      _bustVParam();
      notifyListeners();
    }

    return success;
  }

  void updateProductInList(Product updated) {
    final idx = _products.indexWhere((x) => x.id == updated.id);
    if (idx != -1) {
      _products[idx] = updated;
      _bustVParam();
      notifyListeners();
    }
  }

  // ===========================================
  // FILTER & SORTIERUNG
  // ===========================================

  List<Product> getFilteredProducts() {
    final products = List<Product>.from(_products);

    // Sortierung
    products.sort((a, b) {
      final act = (b.productActive ? 1 : 0).compareTo(a.productActive ? 1 : 0);
      if (act != 0) return act;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    final q = _searchQuery.trim().toLowerCase();

    return products.where((p) {
      final name = p.name.toLowerCase();
      final id = p.id.toLowerCase();
      final matchesSearch = q.isEmpty || name.contains(q) || id.contains(q);

      final matchesCat = (_categoryFilter == 'all') || (p.category == _categoryFilter);

      final hasActiveOfferToday = isOfferInDateRange(p);

      final matchesOffer = (_offerFilter == 'all') ||
          (_offerFilter == 'with' && hasActiveOfferToday) ||
          (_offerFilter == 'without' && !hasActiveOfferToday);

      final matchesStock = (_stockFilter == 'all') ||
          (_stockFilter == 'active' && p.productActive == true) ||
          (_stockFilter == 'inactive' && p.productActive == false);

      return matchesSearch && matchesCat && matchesOffer && matchesStock;
    }).toList();
  }

  // ===========================================
  // HILFSFUNKTIONEN
  // ===========================================

  bool isOfferInDateRange(Product p) {
    if (!p.hasOffer || !p.offerActive) return false;

    final now = DateTime.now();
    final start = DateTime.tryParse(p.offerStartDate);
    final end = DateTime.tryParse(p.offerEndDate);

    if (start == null || end == null) return true;

    final today = DateTime(now.year, now.month, now.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);

    return !today.isBefore(s) && !today.isAfter(e);
  }

  String formatPriceLine(Product p, AppLocalizations s) {
    final price = _moneyFmt.format(p.price);
    final size = _sizeFmt.format(p.sizeValue);
    final priceWithCurrency = '$price $currency';

    // Einheit lokalisieren
    final unit = _getUnitLabel(p.sizeUnit, s);
    return '$priceWithCurrency / $size $unit';
  }

  String _getUnitLabel(String unit, AppLocalizations s) {
    switch (unit) {
      case 'kg': return s.unitKg;
      case 'g': return s.unitG;
      case 'l': return s.unitL;
      case 'ml': return s.unitMl;
      case 'pcs': return s.unitPcs;
      default: return unit;
    }
  }

  String formatOfferText(Product p, AppLocalizations s) {
    if (p.offerType == 'percent') {
      return s.discountPercent(_sizeFmt.format(p.percent));
    }
    if (p.offerType == 'bundle') {
      return s.bundleOfferLabel(_sizeFmt.format(p.bundleQty), _moneyFmt.format(p.bundlePrice), currency);
    }
    return s.offerLabel;
  }

  String formatOfferUntilText(Product p, AppLocalizations s) {
    if (!isOfferInDateRange(p)) return '';

    final end = _parseDateSafe(p.offerEndDate, DateTime.now());
    final dateStr = "${end.day.toString().padLeft(2, '0')}/${end.month.toString().padLeft(2, '0')}/${end.year}";

    return s.offerUntilDate(dateStr);
  }

  DateTime _parseDateSafe(String? value, DateTime fallback) {
    if (value == null || value.isEmpty) return fallback;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return fallback;
    }
  }
}