import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Ergebnis eines FX-Rate Abrufs
class FxRateResult {
  final double fxRate;
  final String baseCurrency;
  final String targetCurrency;
  final String timestamp;
  final String source;
  final bool isFallback;
  final String? fallbackReason;

  FxRateResult({
    required this.fxRate,
    required this.baseCurrency,
    required this.targetCurrency,
    required this.timestamp,
    required this.source,
    required this.isFallback,
    this.fallbackReason,
  });

  /// EUR Fallback für Fehler oder ungültige Rates
  factory FxRateResult.eurFallback({String reason = 'unknown'}) {
    return FxRateResult(
      fxRate: 1.0,
      baseCurrency: 'eur',
      targetCurrency: 'eur',
      timestamp: DateTime.now().toIso8601String(),
      source: 'fallback',
      isFallback: true,
      fallbackReason: reason,
    );
  }
}

/// Service für FX-Rates aus /system/fx_rates (Firestore direkt)
class FxRateService {
  static final FxRateService _instance = FxRateService._internal();
  factory FxRateService() => _instance;
  FxRateService._internal();

  // Memory Cache für alle Rates
  Map<String, double>? _ratesCache;
  DateTime? _cacheTimestamp;
  String? _cacheSource;
  static const Duration _cacheTtl = Duration(hours: 1);

  /// Lädt alle FX-Rates aus Firestore
  Future<void> _loadRates() async {
    // Cache prüfen
    if (_ratesCache != null && _cacheTimestamp != null) {
      final age = DateTime.now().difference(_cacheTimestamp!);
      if (age < _cacheTtl) {
        return; // Cache noch gültig
      }
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('system')
          .doc('fx_rates')
          .get();

      if (!doc.exists || doc.data() == null) {
        debugPrint('[FxRateService] No fx_rates document found');
        _ratesCache = {};
        return;
      }

      final data = doc.data()!;
      final ratesMap = data['rates'] as Map<String, dynamic>? ?? {};

      _ratesCache = {};
      for (final entry in ratesMap.entries) {
        final code = entry.key.toLowerCase();
        final rate = (entry.value as num?)?.toDouble();
        if (rate != null && rate > 0) {
          _ratesCache![code] = rate;
        }
      }

      _cacheTimestamp = DateTime.now();
      _cacheSource = data['source']?.toString() ?? 'fixer';

      debugPrint(
        '[FxRateService] Loaded ${_ratesCache!.length} rates from $_cacheSource',
      );
    } catch (e) {
      debugPrint('[FxRateService] Error loading rates: $e');
      _ratesCache ??= {};
    }
  }

  /// Holt FX-Rate für eine Zielwährung
  ///
  /// Fallback auf EUR wenn Rate nicht verfügbar
  Future<FxRateResult> getFxRate(String targetCurrency) async {
    final normalized = targetCurrency.toLowerCase().trim();

    // EUR Sonderfall (kein FX nötig)
    if (normalized == 'eur') {
      return FxRateResult(
        fxRate: 1.0,
        baseCurrency: 'eur',
        targetCurrency: 'eur',
        timestamp: DateTime.now().toIso8601String(),
        source: 'identity',
        isFallback: false,
      );
    }

    // Rates laden
    await _loadRates();

    if (_ratesCache == null || _ratesCache!.isEmpty) {
      debugPrint('[FxRateService] No rates available, EUR fallback');
      return FxRateResult.eurFallback(reason: 'no_rates');
    }

    final rate = _ratesCache![normalized];

    if (rate == null || rate <= 0 || rate.isNaN || rate.isInfinite) {
      debugPrint('[FxRateService] No valid rate for $normalized, EUR fallback');
      return FxRateResult.eurFallback(reason: 'rate_not_found');
    }

    return FxRateResult(
      fxRate: rate,
      baseCurrency: 'eur',
      targetCurrency: normalized,
      timestamp:
          _cacheTimestamp?.toIso8601String() ??
          DateTime.now().toIso8601String(),
      source: _cacheSource ?? 'fixer',
      isFallback: false,
    );
  }

  /// Cache leeren
  void clearCache() {
    _ratesCache = null;
    _cacheTimestamp = null;
    _cacheSource = null;
  }
}
