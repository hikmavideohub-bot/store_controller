import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Daten für ein Land aus /system/regions
class CountryConfig {
  final String currencyCode;
  final String currencySymbol;
  final bool forceManual;

  CountryConfig({
    required this.currencyCode,
    required this.currencySymbol,
    this.forceManual = false,
  });

  factory CountryConfig.fromMap(Map<String, dynamic> data) {
    return CountryConfig(
      currencyCode: data['currency_code']?.toString().toLowerCase() ?? 'eur',
      currencySymbol: data['currency_symbol']?.toString() ?? '€',
      forceManual: data['force_manual'] == true,
    );
  }

  /// EUR Fallback
  factory CountryConfig.eurFallback() {
    return CountryConfig(
      currencyCode: 'eur',
      currencySymbol: '€',
      forceManual: false,
    );
  }
}

/// Service für /system/regions
class RegionsService {
  static final RegionsService _instance = RegionsService._internal();
  factory RegionsService() => _instance;
  RegionsService._internal();

  // Memory Cache
  Map<String, CountryConfig>? _countriesCache;
  DateTime? _cacheTimestamp;
  static const Duration _cacheTtl = Duration(hours: 24);

  /// Lädt alle Countries aus Firestore
  Future<Map<String, CountryConfig>> _loadCountries() async {
    // Cache prüfen
    if (_countriesCache != null && _cacheTimestamp != null) {
      final age = DateTime.now().difference(_cacheTimestamp!);
      if (age < _cacheTtl) {
        return _countriesCache!;
      }
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('system')
          .doc('regions')
          .get();

      if (!doc.exists || doc.data() == null) {
        debugPrint('[RegionsService] No regions document found');
        return {};
      }

      final data = doc.data()!;
      final countriesMap = data['countries'] as Map<String, dynamic>? ?? {};

      final result = <String, CountryConfig>{};
      for (final entry in countriesMap.entries) {
        final countryCode = entry.key.toUpperCase();
        final countryData = entry.value as Map<String, dynamic>? ?? {};
        result[countryCode] = CountryConfig.fromMap(countryData);
      }

      _countriesCache = result;
      _cacheTimestamp = DateTime.now();

      debugPrint('[RegionsService] Loaded ${result.length} countries');
      return result;
    } catch (e) {
      debugPrint('[RegionsService] Error loading regions: $e');
      return _countriesCache ?? {};
    }
  }

  /// Holt CountryConfig für ein Land
  Future<CountryConfig> getCountryConfig(String countryCode) async {
    final countries = await _loadCountries();
    final normalized = countryCode.toUpperCase().trim();

    if (countries.containsKey(normalized)) {
      return countries[normalized]!;
    }

    // Fallback auf EUR
    debugPrint(
      '[RegionsService] No config for $normalized, using EUR fallback',
    );
    return CountryConfig.eurFallback();
  }

  /// Prüft ob ein Land force_manual hat
  Future<bool> isForceManual(String countryCode) async {
    final config = await getCountryConfig(countryCode);
    return config.forceManual;
  }

  /// Cache leeren
  void clearCache() {
    _countriesCache = null;
    _cacheTimestamp = null;
  }
}
