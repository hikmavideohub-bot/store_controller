// Datei: lib/models/subscription_plan.dart

import 'package:intl/intl.dart';

/// Konfiguration aus dem Dokument (pricing/subscription_config)
class SubscriptionConfig {
  final List<SubscriptionPlan> plans;
  final String? syriaContactPhone;

  SubscriptionConfig({required this.plans, this.syriaContactPhone});

  factory SubscriptionConfig.fromMap(Map<String, dynamic> data) {
    final syriaContactPhone = data['syria_contact_phone']?.toString();
    final plansMap = data['plans'] as Map<String, dynamic>? ?? {};

    final plans = plansMap.entries.map((entry) {
      // entry.key ist z.B. "premium_biannual"
      return SubscriptionPlan.fromMap(
        entry.key,
        entry.value as Map<String, dynamic>,
      );
    }).toList();

    // Sortiere nach billing_cycle (kürzeste zuerst)
    plans.sort((a, b) => a.billingCycle.compareTo(b.billingCycle));

    return SubscriptionConfig(
      plans: plans,
      syriaContactPhone: syriaContactPhone,
    );
  }
}

/// Model für einen einzelnen Abo-Plan
class SubscriptionPlan {
  final String id;
  final String title;
  final int billingCycle; // Anzahl Monate
  final bool offerActive; // NEU: Rabatt aktiv?
  final int? discountPercent; // NEU: Rabatt in %
  final Map<String, PlanPricingDetail> regions;

  SubscriptionPlan({
    required this.id,
    required this.title,
    required this.billingCycle,
    this.offerActive = false,
    this.discountPercent,
    required this.regions,
  });

  factory SubscriptionPlan.fromMap(String id, Map<String, dynamic> data) {
    final regionsMap = data['regions'] as Map<String, dynamic>? ?? {};

    return SubscriptionPlan(
      id: data['id']?.toString() ?? id,
      title: data['title']?.toString() ?? '',
      billingCycle: _toInt(data['billing_cycle']) > 0
          ? _toInt(data['billing_cycle'])
          : 1, // Default: 1 Monat
      offerActive: data['offer_active'] == true,
      discountPercent: _toInt(data['discount_percent']) > 0
          ? _toInt(data['discount_percent'])
          : null,
      regions: regionsMap.map(
        (key, value) => MapEntry(
          key,
          PlanPricingDetail.fromMap(value as Map<String, dynamic>),
        ),
      ),
    );
  }

  /// Preis für Region holen (Fallback: global)
  PlanPricingDetail getPriceForRegion(String regionCode) {
    if (regions.containsKey(regionCode)) {
      return regions[regionCode]!;
    }
    return regions['global'] ??
        PlanPricingDetail(monthlyPrice: 0, currency: 'USD', provider: 'manual');
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}

/// Details zu Preis & QR Code
class PlanPricingDetail {
  final double monthlyPrice;
  final double? originalMonthlyPrice;
  final String currency; // Symbol (€, $, ل.س)
  final String? currencyCode; // ISO Code (eur, usd) - für Stripe
  final String provider;
  final bool offerActive;
  final bool isBestValue;
  final String? qrImageUrl;
  final String? accountDetails; // Für Syria manual payment

  PlanPricingDetail({
    required this.monthlyPrice,
    this.originalMonthlyPrice,
    required this.currency,
    this.currencyCode,
    required this.provider,
    this.offerActive = false,
    this.isBestValue = false,
    this.qrImageUrl,
    this.accountDetails,
  });

  factory PlanPricingDetail.fromMap(Map<String, dynamic> map) {
    // Fallback: monthly_price → amount (für Altdaten)
    final monthlyPrice = _toDouble(map['monthly_price']) > 0
        ? _toDouble(map['monthly_price'])
        : _toDouble(map['amount']);

    return PlanPricingDetail(
      monthlyPrice: monthlyPrice,
      originalMonthlyPrice: map['original_monthly_price'] != null
          ? _toDouble(map['original_monthly_price'])
          : null,
      currency: map['currency']?.toString() ?? 'USD',
      currencyCode: map['currency_code']?.toString().toLowerCase(),
      provider: map['provider']?.toString() ?? 'stripe',
      offerActive: map['offer_active'] == true,
      isBestValue: map['is_best_value'] == true,
      qrImageUrl: map['qr_image_url']?.toString(),
      accountDetails: map['account_details']?.toString(),
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    final s = v.toString().trim().replaceAll(',', '.');
    return double.tryParse(s) ?? 0.0;
  }
}

// =====================================================
// PRICING CALCULATOR - Reine Berechnungslogik
// =====================================================

/// Berechnete Preisinformationen für die UI
class CalculatedPricing {
  final double monthlyPrice;
  final double totalPrice;
  final double? originalMonthlyPrice;
  final double? originalTotalPrice;
  final double? monthlySavings;
  final double? totalSavings;
  final int? discountPercent;
  final int billingCycle;
  final String currency;
  final bool hasOffer;
  final bool isBestValue;

  CalculatedPricing({
    required this.monthlyPrice,
    required this.totalPrice,
    this.originalMonthlyPrice,
    this.originalTotalPrice,
    this.monthlySavings,
    this.totalSavings,
    this.discountPercent,
    required this.billingCycle,
    required this.currency,
    required this.hasOffer,
    required this.isBestValue,
  });

  /// Berechnet alle Preiswerte aus Plan + Region
  factory CalculatedPricing.fromPlan(SubscriptionPlan plan, String regionCode) {
    final pricing = plan.getPriceForRegion(regionCode);
    final billingCycle = plan.billingCycle;

    final monthlyPrice = pricing.monthlyPrice;
    final totalPrice = monthlyPrice * billingCycle;

    double? originalMonthlyPrice;
    double? originalTotalPrice;
    double? monthlySavings;
    double? totalSavings;
    int? discountPercent;

    // Berechne Ersparnis nur wenn Angebot aktiv und original_monthly_price vorhanden
    if (pricing.offerActive &&
        pricing.originalMonthlyPrice != null &&
        pricing.originalMonthlyPrice! > 0) {
      originalMonthlyPrice = pricing.originalMonthlyPrice;
      originalTotalPrice = originalMonthlyPrice! * billingCycle;
      monthlySavings = originalMonthlyPrice - monthlyPrice;
      totalSavings = monthlySavings * billingCycle;

      // Rabatt in % (gerundet)
      if (originalMonthlyPrice > 0) {
        discountPercent = ((monthlySavings / originalMonthlyPrice) * 100)
            .round();
      }
    }

    return CalculatedPricing(
      monthlyPrice: monthlyPrice,
      totalPrice: totalPrice,
      originalMonthlyPrice: originalMonthlyPrice,
      originalTotalPrice: originalTotalPrice,
      monthlySavings: monthlySavings,
      totalSavings: totalSavings,
      discountPercent: discountPercent,
      billingCycle: billingCycle,
      currency: pricing.currency,
      hasOffer:
          pricing.offerActive && discountPercent != null && discountPercent > 0,
      isBestValue: pricing.isBestValue,
    );
  }
}

// =====================================================
// PRICE FORMATTER - Formatierung für Anzeige
// =====================================================

class PriceFormatter {
  /// Formatiert einen Preis mit Währungssymbol
  static String formatPrice(
    double price,
    String currency, {
    String locale = 'de_DE',
  }) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: _getCurrencySymbol(currency),
      decimalDigits: _getDecimalDigits(price),
    );
    return formatter.format(price);
  }

  /// Formatiert einen Preis kompakt (ohne Dezimalstellen wenn .00)
  static String formatPriceCompact(double price, String currency) {
    final symbol = _getCurrencySymbol(currency);
    if (price == price.truncateToDouble()) {
      return '${price.toInt()} $symbol';
    }
    return '${price.toStringAsFixed(2)} $symbol';
  }

  /// Liefert Währungssymbol
  static String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      case 'SYP':
        return 'ل.س';
      case 'TRY':
        return '₺';
      default:
        return currency;
    }
  }

  /// Anzahl Dezimalstellen basierend auf Preis
  static int _getDecimalDigits(double price) {
    // Für große Beträge (z.B. SYP) keine Dezimalstellen
    if (price > 1000) return 0;
    // Für glatte Beträge keine Dezimalstellen
    if (price == price.truncateToDouble()) return 0;
    return 2;
  }
}
