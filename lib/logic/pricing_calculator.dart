import 'dart:math';
import '../models/subscription_plan.dart';

/// Ergebnis der Preisberechnung für UI und Stripe.
class PricingResult {
  final double monthlyPrice; // In lokaler Währung
  final double totalPrice; // In lokaler Währung
  final int billingCycle;
  final String currencySymbol; // Für UI-Anzeige (€, $, ر.ع)
  final String currencyCode; // Für Stripe (eur, usd, omr)
  final bool hasOffer;
  final bool isBestValue;

  // Rabatt-Details
  final double? originalMonthlyPrice;
  final double? originalTotalPrice;
  final double? totalSavings;
  final int? discountPercent;

  // Syrien / Bank-Transfer Spezifika
  final String? qrImageUrl;
  final String? accountDetails;

  PricingResult({
    required this.monthlyPrice,
    required this.totalPrice,
    required this.billingCycle,
    required this.currencySymbol,
    required this.currencyCode,
    required this.hasOffer,
    required this.isBestValue,
    this.originalMonthlyPrice,
    this.originalTotalPrice,
    this.totalSavings,
    this.discountPercent,
    this.qrImageUrl,
    this.accountDetails,
  });
}

class PricingCalculator {
  /// Rundet Preis AUF zur nächsten 0,5-Stufe.
  /// Beispiele: 2.3 → 2.5, 2.6 → 3.0, 2.0 → 2.0, 2.51 → 3.0
  static double roundToHalfCeiling(double price) {
    return (price * 2).ceilToDouble() / 2;
  }

  /// Berechnet Pricing für SYRIEN (direkt aus Firestore, keine Umrechnung).
  ///
  /// [plan] - Der gewählte Plan (biannual, yearly, etc.)
  /// [basePlan] - premium_monthly (einzige Quelle für regions!)
  static PricingResult calculateSyria({
    required SubscriptionPlan plan,
    required SubscriptionPlan basePlan,
  }) {
    final syriaData = basePlan.getPriceForRegion('syria');
    final int cycle = plan.billingCycle > 0 ? plan.billingCycle : 1;

    // Direkter Preis aus Firestore (keine Umrechnung, kein Runden)
    final double monthlyPrice = syriaData.monthlyPrice;
    double totalBeforeDiscount = monthlyPrice * cycle;

    // Rabatt aus Plan (nur aus Firestore, keine Hardcodes!)
    double finalTotal = totalBeforeDiscount;
    bool hasOffer = false;
    int? appliedDiscount;

    if (plan.offerActive && plan.discountPercent != null && plan.discountPercent! > 0) {
      hasOffer = true;
      appliedDiscount = plan.discountPercent;
      finalTotal = totalBeforeDiscount * (1 - appliedDiscount! / 100);
    }

    // Finaler Monatspreis (aus Total)
    double finalMonthlyPrice = finalTotal / cycle;

    return PricingResult(
      monthlyPrice: finalMonthlyPrice,
      totalPrice: finalTotal,
      billingCycle: cycle,
      currencySymbol: syriaData.currency,
      currencyCode: syriaData.currencyCode ?? 'syp',
      hasOffer: hasOffer,
      isBestValue: syriaData.isBestValue,
      originalMonthlyPrice: hasOffer ? monthlyPrice : null,
      originalTotalPrice: hasOffer ? totalBeforeDiscount : null,
      totalSavings: hasOffer ? totalBeforeDiscount - finalTotal : null,
      discountPercent: appliedDiscount,
      accountDetails: syriaData.accountDetails,
      qrImageUrl: syriaData.qrImageUrl,
    );
  }

  /// Berechnet Pricing für GLOBAL (Umrechnung EUR → lokale Währung).
  ///
  /// [plan] - Der gewählte Plan (biannual, yearly, etc.)
  /// [basePlan] - premium_monthly (einzige Quelle für regions!)
  /// [userCurrencyCode] - Zielwährung (z.B. "omr", "sar", "eur")
  /// [userCurrencySymbol] - Währungssymbol für UI (z.B. "ر.ع", "€")
  /// [fxRate] - Wechselkurs EUR → userCurrency (1.0 für EUR)
  static PricingResult calculateGlobal({
    required SubscriptionPlan plan,
    required SubscriptionPlan basePlan,
    required String userCurrencyCode,
    required String userCurrencySymbol,
    required double fxRate,
  }) {
    final globalData = basePlan.getPriceForRegion('global');
    final int cycle = plan.billingCycle > 0 ? plan.billingCycle : 1;

    // 1. Basis-Preis (EUR)
    final double baseMonthlyEUR = globalData.monthlyPrice;

    // 2. Umrechnen
    double localMonthlyRaw = baseMonthlyEUR * fxRate;

    // 3. Runden NUR bei Nicht-EUR (vor Rabatt!)
    double localMonthlyRounded;
    if (userCurrencyCode.toLowerCase() != 'eur') {
      localMonthlyRounded = roundToHalfCeiling(localMonthlyRaw);
    } else {
      localMonthlyRounded = localMonthlyRaw; // EUR bleibt exakt
    }

    // 4. Total vor Rabatt
    double totalBeforeDiscount = localMonthlyRounded * cycle;

    // 5. Rabatt aus Plan (nur aus Firestore, keine Hardcodes!)
    double finalTotal = totalBeforeDiscount;
    bool hasOffer = false;
    int? appliedDiscount;

    if (plan.offerActive && plan.discountPercent != null && plan.discountPercent! > 0) {
      hasOffer = true;
      appliedDiscount = plan.discountPercent;
      finalTotal = totalBeforeDiscount * (1 - appliedDiscount! / 100);
      // WICHTIG: Nach Rabatt NICHT runden!
    }

    // 6. Finaler Monatspreis (aus Total)
    double finalMonthlyPrice = finalTotal / cycle;

    return PricingResult(
      monthlyPrice: finalMonthlyPrice,
      totalPrice: finalTotal,
      billingCycle: cycle,
      currencySymbol: userCurrencySymbol,
      currencyCode: userCurrencyCode,
      hasOffer: hasOffer,
      isBestValue: globalData.isBestValue,
      originalMonthlyPrice: hasOffer ? localMonthlyRounded : null,
      originalTotalPrice: hasOffer ? totalBeforeDiscount : null,
      totalSavings: hasOffer ? totalBeforeDiscount - finalTotal : null,
      discountPercent: appliedDiscount,
      accountDetails: null, // Nur für Syria
      qrImageUrl: null,
    );
  }

  /// Gibt die Anzahl der Dezimalstellen (Minor Units) für eine Währung zurück.
  /// Quelle: ISO 4217 / Stripe Dokumentation
  static int getCurrencyDecimals(String currencyCode) {
    final code = currencyCode.toLowerCase();

    // 0 Dezimalstellen (keine Untereinheit)
    const zeroDecimal = [
      'jpy', 'krw', 'vnd', 'clp', 'pyg', 'ugx', 'rwf',
      'gnf', 'kmf', 'xaf', 'xof', 'xpf'
    ];

    // 3 Dezimalstellen (z.B. Baisa, Fils)
    const threeDecimal = ['omr', 'bhd', 'kwd', 'jod', 'tnd'];

    if (zeroDecimal.contains(code)) return 0;
    if (threeDecimal.contains(code)) return 3;

    // Standard: 2 Dezimalstellen (EUR, USD, SAR, etc.)
    return 2;
  }

  /// Konvertiert Betrag in kleinste Währungseinheit für Stripe.
  /// EUR 12.50 → 1250 (Cents), OMR 12.000 → 12000 (Baisa), JPY 1000 → 1000
  static int toSmallestCurrencyUnit(double amount, String currencyCode) {
    final decimals = getCurrencyDecimals(currencyCode);
    return (amount * pow(10, decimals)).round();
  }

  /// Formatiert einen Preis mit korrekter Dezimalstellenzahl für die UI.
  static String formatPriceForCurrency(double price, String currencyCode, String currencySymbol) {
    final decimals = getCurrencyDecimals(currencyCode);

    if (decimals == 0) {
      return '${price.round()} $currencySymbol';
    } else if (price == price.truncateToDouble()) {
      return '${price.toInt()} $currencySymbol';
    } else {
      return '${price.toStringAsFixed(decimals)} $currencySymbol';
    }
  }
}
