import 'package:store_controller/l10n/generated/app_localizations.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../core/access_manager.dart';
import 'base_viewmodel.dart';

/// ViewModel für CategoriesScreen
/// Enthält alle Business-Logik für Kategorien-Verwaltung
class CategoriesViewModel extends BaseViewModel {
  CategoriesViewModel() {
    _init();
  }

  // ===========================================
  // STATE
  // ===========================================

  List<Product> _products = [];
  bool _loading = true;

  // ===========================================
  // GETTERS
  // ===========================================

  List<Product> get products => _products;
  bool get loading => _loading;

  /// Prüft ob Schreibaktionen erlaubt sind
  bool get canWrite => AccessManager.canWriteAdmin;

  /// Zählt Produkte pro Kategorie
  Map<String, int> get categoryCounts {
    final map = <String, int>{};
    for (final p in _products) {
      final c = p.category.trim();
      if (c.isEmpty) continue;
      map[c] = (map[c] ?? 0) + 1;
    }
    return map;
  }

  /// Sortierte Liste aller Kategorien
  List<String> get sortedCategories {
    return categoryCounts.keys.toList()..sort();
  }

  /// Gesamtzahl der Kategorien
  int get totalCategories => categoryCounts.length;

  /// Gesamtzahl der Produkte
  int get totalProducts => _products.length;

  // ===========================================
  // INITIALIZATION
  // ===========================================

  Future<void> _init() async {
    ApiService.productsNotifier.addListener(_onProductsChanged);
    // Initialer Load ist silent und hat noch keinen Context/Localization
    await reload(null, silent: true);
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
  // LADEN
  // ===========================================

  Future<void> reload(AppLocalizations? s, {bool silent = false}) async {
    bool showedCache = false;

    final cached = ApiService.cachedProducts;
    if (cached != null && cached.isNotEmpty) {
      showedCache = true;
      _products = cached;
      _loading = false;
      notifyListeners();
    } else if (!silent) {
      setBusy(true);
      _loading = true;
      notifyListeners();
    }

    try {
      final data = await ApiService.fetchProducts();
      _products = data;
      _loading = false;
    } catch (e) {
      _loading = false;
      if (!showedCache && _products.isEmpty) {
        // Fallback Nachricht, falls s null ist (beim init)
        setError(s?.categoriesLoadError ?? 'Error loading categories');
      }
    }

    setBusy(false);
    notifyListeners();
  }

  // ===========================================
  // KATEGORIE-AKTIONEN
  // ===========================================

  /// Benennt eine Kategorie um
  Future<bool> renameCategory(
    AppLocalizations s,
    String oldName,
    String newName,
  ) async {
    if (!canWrite) return false;
    if (oldName == newName) return false;

    setBusy(true);

    try {
      final ok = await ApiService.renameCategory(oldName, newName);

      if (ok) {
        await reload(s, silent: true);
      }

      setBusy(false);
      return ok;
    } catch (e) {
      setBusy(false);
      setError(s.categoryRenameError);
      return false;
    }
  }

  /// Löscht eine Kategorie und verschiebt Produkte
  Future<bool> deleteCategory(
    AppLocalizations s,
    String name, {
    String? moveToCategory,
  }) async {
    if (!canWrite) return false;

    // Wenn kein Ziel angegeben ist, nutzen wir den lokalisierten "Others" String
    final targetCat = moveToCategory ?? s.defaultCategoryOthers;

    setBusy(true);

    try {
      final success = await ApiService.deleteCategory(
        name,
        moveToCategory: targetCat,
      );

      if (success) {
        await reload(s, silent: true);
      }

      setBusy(false);
      return success;
    } catch (e) {
      setBusy(false);
      setError(s.categoryDeleteError);
      return false;
    }
  }

  /// Gibt Produkte für eine bestimmte Kategorie zurück
  List<Product> getProductsForCategory(String category) {
    return _products
        .where((p) => p.category.trim() == category.trim())
        .toList();
  }

  /// Gibt Anzahl der Produkte in einer Kategorie zurück
  int getProductCount(String category) {
    return categoryCounts[category] ?? 0;
  }
}
