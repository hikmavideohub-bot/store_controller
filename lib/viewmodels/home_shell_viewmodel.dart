import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../services/store_config_service.dart';
import '../core/access_manager.dart';
import 'base_viewmodel.dart';

/// ViewModel für HomeShell (Bottom Navigation, FAB)
/// Enthält alle Business-Logik für Navigation und Status-Refresh
class HomeShellViewModel extends BaseViewModel {
  HomeShellViewModel() {
    _init();
  }

  // ===========================================
  // STATE
  // ===========================================

  int _currentIndex = 0;
  bool _isWebsiteConnected = false;

  // ===========================================
  // GETTERS
  // ===========================================

  int get currentIndex => _currentIndex;
  bool get isWebsiteConnected => _isWebsiteConnected;

  /// FAB ist nur gold wenn Trial aktiv oder bezahlt (active)
  bool get fabEnabled =>
      AccessManager.isLoaded &&
      (AccessManager.isActive || AccessManager.isTrial);

  /// Gibt FAB-Farbe basierend auf Status zurück
  bool get isFabActive => fabEnabled;

  /// Prüft ob Store-Website verbunden ist
  bool get hasStoreWebsite {
    final s = StoreConfigService.store;
    return (s?['store_slug'] ?? '').toString().trim().isNotEmpty;
  }

  String? get storeWebsiteUrl {
    final s = StoreConfigService.store;
    return (s?['public_store_url'] ?? '').toString().trim();
  }

  // ===========================================
  // SETTERS
  // ===========================================

  void setCurrentIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  // ===========================================
  // INITIALIZATION
  // ===========================================

  Future<void> _init() async {
    await boot();
  }

  Future<void> boot() async {
    await StoreConfigService.load();

    // Parallel laden ohne zu warten
    unawaited(ApiService.fetchProducts());
    unawaited(ApiService.fetchCategories());
    unawaited(refreshWebsiteStatus());
  }

  // ===========================================
  // STATUS REFRESH
  // ===========================================

  Future<void> refreshWebsiteStatus() async {
    try {
      final m = await ApiService.fetchWebsiteStatus();
      if (m == null) return;

      final access = m['access'];
      if (access is Map) {
        AccessManager.updateFromApi(Map<String, dynamic>.from(access));
      }

      await StoreConfigService.mergeNonEmpty(m);

      _isWebsiteConnected = hasStoreWebsite;
      notifyListeners();
    } catch (_) {
      // Ignore errors
    }
  }

  // ===========================================
  // AKTIONEN
  // ===========================================

  /// Wird aufgerufen wenn FAB gedrückt wird
  /// Gibt true zurück wenn Navigation erlaubt, false wenn Paywall nötig
  Future<bool> onFabPressed() async {
    // Wenn Trial abgelaufen (expired) oder suspended: Paywall zeigen
    if (AccessManager.isLoaded && !fabEnabled) {
      return false; // UI zeigt Paywall
    }

    // Status leise im Hintergrund aktualisieren
    unawaited(refreshWebsiteStatus());

    return true; // Navigation erlaubt
  }

  Future<bool> openStoreWebsite() async {
    final url = storeWebsiteUrl;
    if (url == null || url.isEmpty) return false;

    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }
}
