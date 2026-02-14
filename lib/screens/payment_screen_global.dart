import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import '../widgets/premium_app_bar.dart';
import '../models/subscription_plan.dart';
import '../logic/pricing_calculator.dart';
import '../services/fx_rate_service.dart';

/// Verfügbare Währungsoptionen für Dropdown
class CurrencyOption {
  final String code;
  final String symbol;
  final String label;

  const CurrencyOption({
    required this.code,
    required this.symbol,
    required this.label,
  });
}

/// Währungen die von Stripe NICHT unterstützt werden
/// Für diese Länder wird automatisch auf USD zurückgefallen
const _stripeUnsupportedCurrencies = {'omr', 'syp', 'irr', 'iqd', 'lbp', 'yer'};

class PaymentScreenGlobal extends StatefulWidget {
  final List<SubscriptionPlan> availablePlans;
  final SubscriptionPlan basePlan; // NEU: Referenz zum Monats-Plan
  final String userCurrencyCode; // z.B. "omr", "sar", "eur"
  final String userCurrencySymbol; // z.B. "ر.ع", "€"
  final double fxRate; // EUR → userCurrency (1.0 für EUR)
  final String? pricingMessage;

  const PaymentScreenGlobal({
    super.key,
    required this.availablePlans,
    required this.basePlan,
    required this.userCurrencyCode,
    required this.userCurrencySymbol,
    required this.fxRate,
    this.pricingMessage,
  });

  @override
  State<PaymentScreenGlobal> createState() => _PaymentScreenGlobalState();
}

class _PaymentScreenGlobalState extends State<PaymentScreenGlobal> {
  SubscriptionPlan? _selectedPlan;
  bool _loading = false;
  String? _error;

  // Currency Dropdown State
  late List<CurrencyOption> _currencyOptions;
  late CurrencyOption _selectedCurrency;
  bool _loadingCurrency = false;

  // Effective Currency Values (mit Fallback auf Firestore-Basis wenn FX ungültig)
  late String _effectiveCurrencyCode;
  late String _effectiveCurrencySymbol;
  late double _effectiveFxRate;
  bool _usingFallbackCurrency = false;

  // Hilfsmethode: Filtern wir den Monatsplan (basePlan) aus der Anzeige heraus,
  // behalten ihn aber in widget.basePlan für die Mathe-Logik.
  List<SubscriptionPlan> get _visiblePlans {
    return widget.availablePlans
        .where((p) => p.id != widget.basePlan.id)
        .toList();
  }

  @override
  void initState() {
    super.initState();

    // 1. Currency Options aufbauen (Default + USD + EUR)
    _buildCurrencyOptions();

    // 2. Effective Values initial setzen
    _effectiveCurrencyCode = _selectedCurrency.code;
    _effectiveCurrencySymbol = _selectedCurrency.symbol;
    _effectiveFxRate = widget.fxRate;
    _usingFallbackCurrency = false;

    // 3. FX-Validierung
    _validateAndSetFxRate();

    // 4. Standard-Plan auswählen (nur aus sichtbaren Plänen)
    final plansDisplay = _visiblePlans;

    if (plansDisplay.isNotEmpty) {
      _selectedPlan = plansDisplay.firstWhere(
        (p) {
          final pricing = _calculatePricingForPlan(p);
          return pricing.isBestValue;
        },
        orElse: () => plansDisplay.firstWhere(
          (p) => p.id == 'premium_yearly',
          orElse: () => plansDisplay.first,
        ),
      );
    }
  }

  /// Baut die Währungsoptionen für den Dropdown
  void _buildCurrencyOptions() {
    final defaultCode = widget.userCurrencyCode.toLowerCase();
    final defaultSymbol = widget.userCurrencySymbol;

    // Basis-Optionen
    final options = <CurrencyOption>[];

    // 1. Default Currency zuerst hinzufügen
    if (defaultCode == 'eur') {
      // EUR ist Default → EUR zuerst, dann USD
      options.add(
        const CurrencyOption(code: 'eur', symbol: '€', label: 'EUR (€)'),
      );
      options.add(
        const CurrencyOption(code: 'usd', symbol: '\$', label: 'USD (\$)'),
      );
    } else if (defaultCode == 'usd') {
      // USD ist Default → USD zuerst, dann EUR
      options.add(
        const CurrencyOption(code: 'usd', symbol: '\$', label: 'USD (\$)'),
      );
      options.add(
        const CurrencyOption(code: 'eur', symbol: '€', label: 'EUR (€)'),
      );
    } else {
      // Exotische Währung → Default zuerst, dann USD, dann EUR
      options.add(
        CurrencyOption(
          code: defaultCode,
          symbol: defaultSymbol,
          label: '${defaultCode.toUpperCase()} ($defaultSymbol)',
        ),
      );
      options.add(
        const CurrencyOption(code: 'usd', symbol: '\$', label: 'USD (\$)'),
      );
      options.add(
        const CurrencyOption(code: 'eur', symbol: '€', label: 'EUR (€)'),
      );
    }

    _currencyOptions = options;
    _selectedCurrency = options.first; // Default auswählen
  }

  /// Validiert FX-Rate und Stripe-Unterstützung, setzt Fallback wenn nötig
  void _validateAndSetFxRate() {
    final bool fxValid =
        _effectiveFxRate > 0 &&
        !_effectiveFxRate.isNaN &&
        !_effectiveFxRate.isInfinite;

    // Prüfen ob Stripe diese Währung unterstützt
    final bool stripeSupported = !_stripeUnsupportedCurrencies.contains(
      _effectiveCurrencyCode.toLowerCase(),
    );

    if ((!fxValid || !stripeSupported) &&
        _effectiveCurrencyCode != 'eur' &&
        _effectiveCurrencyCode != 'usd') {
      // Fallback auf USD (bekannter in Golf-Region als EUR)
      _effectiveCurrencyCode = 'usd';
      _effectiveCurrencySymbol = '\$';
      _effectiveFxRate = _getUsdFxRate();
      _usingFallbackCurrency = true;
      debugPrint(
        '[PaymentScreenGlobal] ${!stripeSupported ? "Currency not supported by Stripe" : "FX invalid"} → USD fallback',
      );
    }
  }

  /// Holt den USD-Wechselkurs (EUR → USD ist ca. 1.08-1.10)
  double _getUsdFxRate() {
    // Konservativer Schätzwert, wird beim Währungswechsel durch echten Kurs ersetzt
    return 1.08;
  }

  /// Wird aufgerufen wenn User Währung im Dropdown ändert
  Future<void> _onCurrencyChanged(CurrencyOption newCurrency) async {
    if (newCurrency.code == _selectedCurrency.code) return;

    // Prüfen ob Stripe diese Währung unterstützt
    final bool stripeSupported = !_stripeUnsupportedCurrencies.contains(
      newCurrency.code.toLowerCase(),
    );

    if (!stripeSupported) {
      // Sofort auf USD zurückfallen, aber echten FX-Kurs laden
      setState(() {
        _loadingCurrency = true;
        _selectedCurrency = newCurrency;
      });

      try {
        final fxResult = await FxRateService().getFxRate('usd');
        setState(() {
          _effectiveCurrencyCode = 'usd';
          _effectiveCurrencySymbol = '\$';
          _effectiveFxRate = fxResult.isFallback ? 1.08 : fxResult.fxRate;
          _usingFallbackCurrency = true;
          _loadingCurrency = false;
        });
      } catch (e) {
        setState(() {
          _effectiveCurrencyCode = 'usd';
          _effectiveCurrencySymbol = '\$';
          _effectiveFxRate = 1.08; // Konservativer Fallback
          _usingFallbackCurrency = true;
          _loadingCurrency = false;
        });
      }
      debugPrint(
        '[PaymentScreenGlobal] ${newCurrency.code} not supported by Stripe → USD fallback',
      );
      return;
    }

    setState(() {
      _loadingCurrency = true;
      _selectedCurrency = newCurrency;
    });

    try {
      // FX-Rate für neue Währung laden
      final fxResult = await FxRateService().getFxRate(newCurrency.code);

      if (fxResult.isFallback) {
        // Fallback auf USD
        setState(() {
          _effectiveCurrencyCode = 'usd';
          _effectiveCurrencySymbol = '\$';
          _effectiveFxRate = 1.08;
          _usingFallbackCurrency = true;
          _loadingCurrency = false;
        });
      } else {
        setState(() {
          _effectiveCurrencyCode = newCurrency.code;
          _effectiveCurrencySymbol = newCurrency.symbol;
          _effectiveFxRate = fxResult.fxRate;
          _usingFallbackCurrency = false;
          _loadingCurrency = false;
        });
      }
    } catch (e) {
      debugPrint('[PaymentScreenGlobal] Currency change error: $e');
      // Fallback auf USD
      setState(() {
        _effectiveCurrencyCode = 'usd';
        _effectiveCurrencySymbol = '\$';
        _effectiveFxRate = 1.08;
        _usingFallbackCurrency = true;
        _loadingCurrency = false;
      });
    }
  }

  // Zentralisierter Getter für das Pricing des ausgewählten Plans
  PricingResult get _currentPricing {
    if (_selectedPlan == null) {
      throw Exception('No plan selected');
    }
    return _calculatePricingForPlan(_selectedPlan!);
  }

  // Wrapper um den zentralen Calculator mit FX-Umrechnung
  // Nutzt effective-Werte (mit Fallback auf EUR wenn FX ungültig)
  PricingResult _calculatePricingForPlan(SubscriptionPlan plan) {
    return PricingCalculator.calculateGlobal(
      plan: plan,
      basePlan: widget.basePlan,
      userCurrencyCode: _effectiveCurrencyCode,
      userCurrencySymbol: _effectiveCurrencySymbol,
      fxRate: _effectiveFxRate,
    );
  }

  Future<void> _initiateStripePayment() async {
    final s = AppLocalizations.of(context)!;
    if (_selectedPlan == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final platform = kIsWeb
          ? 'web'
          : (defaultTargetPlatform == TargetPlatform.android
                ? 'android'
                : 'ios');

      final calc = _currentPricing;

      // Amount Guard: Preis muss positiv sein
      if (calc.totalPrice <= 0) {
        throw Exception("Invalid price: ${calc.totalPrice}");
      }

      // Amount in kleinster Währungseinheit für Stripe (währungsspezifisch!)
      // EUR: 2 Dezimalstellen (Cents), OMR: 3 Dezimalstellen (Baisa), JPY: 0
      final amountInSmallestUnit = PricingCalculator.toSmallestCurrencyUnit(
        calc.totalPrice,
        calc.currencyCode,
      );

      final result = await FirebaseFunctions.instanceFor(region: 'europe-west3')
          .httpsCallable('createStripeCheckoutSession')
          .call({
            'planId': _selectedPlan!.id,
            'amount': amountInSmallestUnit,
            'currency': calc.currencyCode, // ISO Code aus Calculator
            'platform': platform,
          });

      if (result.data != null && result.data['url'] != null) {
        final uri = Uri.parse(result.data['url'].toString());
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        setState(() => _loading = false);
      } else {
        throw s.paymentLinkError;
      }
    } catch (e) {
      debugPrint("Stripe Error: $e");
      if (mounted) {
        setState(() {
          _error = s.paymentPrepError;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;

    // Nur sichtbare Pläne verwenden
    final plansToDisplay = _visiblePlans;

    return Scaffold(
      appBar: PremiumAnimatedAppBar(
        title: s.choosePlanTitle,
        showBackButton: true,
      ),
      body: plansToDisplay.isEmpty
          ? Center(child: Text(s.noPlansAvailable))
          : ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.of(context).viewPadding.bottom,
        ),
        children: [

          Text(
                  s.choosePlanSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Pricing Message (aus Firestore)
                if (widget.pricingMessage != null &&
                    widget.pricingMessage!.trim().isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.secondary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.campaign_outlined,
                          color: colors.secondary,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.pricingMessage!,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.onSecondaryContainer,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Currency Dropdown
                if (_currencyOptions.length > 1) ...[
                  _buildCurrencyDropdown(colors, s),
                  const SizedBox(height: 16),
                ],

                // Info-Banner wenn Fallback auf EUR aktiv
                if (_usingFallbackCurrency) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: colors.tertiaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: colors.tertiary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colors.tertiary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            s.pricingFallbackEurInfo, // "Zahlung in EUR (lokale Umrechnung nicht verfügbar)"
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // PLAN AUSWAHL CARDS - Nur die gefilterte Liste anzeigen
                ...plansToDisplay.map((plan) => _buildPlanCard(plan, s)),

                const SizedBox(height: 24),

                // Preis-Zusammenfassung
                const SizedBox(height: 24),

                if (_loading)
                  Center(
                    child: CircularProgressIndicator(color: colors.primary),
                  )
                else if (_error != null)
                  Text(
                    _error!,
                    style: TextStyle(color: colors.error),
                    textAlign: TextAlign.center,
                  )
                else
                  Column(
                    children: [
                      _buildCheckoutSummaryCard(s),
                      const SizedBox(height: 12),
                      _buildPayButton(s),
                    ],
                  ),


                const SizedBox(height: 30),
                _buildFeaturesList(context),
              ],
            ),
    );
  }

  Widget _buildCurrencyDropdown(ColorScheme colors, AppLocalizations s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.currency_exchange, color: colors.primary, size: 20),
          const SizedBox(width: 12),
          Text(
            s.pricingCurrencyLabel, // "Währung:"
            style: TextStyle(color: colors.onSurface, fontSize: 14),
          ),
          const Spacer(),
          if (_loadingCurrency)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.primary,
              ),
            )
          else
            DropdownButton<CurrencyOption>(
              value: _selectedCurrency,
              underline: const SizedBox(),
              icon: Icon(Icons.arrow_drop_down, color: colors.primary),
              items: _currencyOptions.map((option) {
                return DropdownMenuItem<CurrencyOption>(
                  value: option,
                  child: Text(
                    option.label,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  _onCurrencyChanged(newValue);
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan, AppLocalizations s) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final currentSelectedId = _selectedPlan?.id ?? _visiblePlans.first.id;
    final isSelected = plan.id == currentSelectedId;

    final calc = _calculatePricingForPlan(plan);

    final activeColor = colors.tertiary;
    final bestValueColor = colors.primary;
    final conversionGreen = Colors.green.shade700; // erlaubt laut dir

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.1)
              : calc.isBestValue
              ? bestValueColor.withValues(alpha: 0.06)
              : colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? activeColor
                : calc.isBestValue
                ? bestValueColor.withValues(alpha: 0.35)
                : colors.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            // ⭐ BEST VALUE BADGE
            if (calc.isBestValue)
              Positioned(
                top: 0,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: bestValueColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Text(
                    s.pricingMostPopular, // 🆕 ARB
                    style: TextStyle(
                      color: colors.onPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // RADIO
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: isSelected ? activeColor : theme.hintColor,
                  ),
                  const SizedBox(width: 16),

                  // PLAN INFO
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          calc.billingCycle == 6
                              ? s
                                    .pricingBilledSixMonths // 🆕 ARB
                              : s.pricingBilledYearly, // 🆕 ARB
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurface.withValues(alpha: 0.6),
                          ),
                        ),

                        // 💚 RABATT
                        if (calc.hasOffer && calc.discountPercent != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: conversionGreen.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              s.pricingSavePercent(calc.discountPercent!),
                              style: TextStyle(
                                color: conversionGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // 💰 PREIS (KLAR + STARK)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (calc.hasOffer && calc.originalMonthlyPrice != null)
                        Text(
                          PricingCalculator.formatPriceForCurrency(
                            calc.originalMonthlyPrice!,
                            calc.currencyCode,
                            calc.currencySymbol,
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            decoration: TextDecoration.lineThrough,
                            color: colors.onSurface.withValues(alpha: 0.45),
                          ),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        PricingCalculator.formatPriceForCurrency(
                          calc.monthlyPrice,
                          calc.currencyCode,
                          calc.currencySymbol,
                        ),
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: calc.hasOffer
                              ? conversionGreen
                              : isSelected
                              ? activeColor
                              : colors.onSurface,
                        ),
                      ),
                      Text(
                        s.pricingPerMonth, // 🆕 ARB
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCheckoutSummaryCard(AppLocalizations s) {
    final colors = Theme.of(context).colorScheme;
    final calc = _currentPricing;

    final planText =
    (calc.billingCycle == 12) ? s.pricingActivationYearly : s.pricingActivationSixMonths;

    final hasOffer = calc.hasOffer && calc.originalMonthlyPrice != null;
    final originalTotal = hasOffer ? (calc.originalMonthlyPrice! * calc.billingCycle) : calc.totalPrice;
    final discountAmount = hasOffer ? (originalTotal - calc.totalPrice) : 0.0;

    String fmt(double v) => PricingCalculator.formatPriceForCurrency(
      v,
      calc.currencyCode,
      calc.currencySymbol,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outline.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.pricingCheckoutTitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 10),

          // الخطة
          Row(
            children: [
              Expanded(
                child: Text(
                  s.pricingCheckoutPlanLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
              Text(
                planText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),

          // السعر الأصلي قبل العرض + تطبيق العرض (فقط إذا فيه عرض)
          if (hasOffer) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    s.pricingCheckoutOriginalLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                Text(
                  fmt(originalTotal),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.lineThrough,
                    color: colors.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    s.pricingCheckoutOfferLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                Text(
                  s.pricingCheckoutDiscountValue(calc.discountPercent!, fmt(discountAmount)),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: colors.tertiary,
                  ),
                ),
              ],
            ),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),

          // المجموع
          Row(
            children: [
              Expanded(
                child: Text(
                  s.pricingCheckoutTotalLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                  ),
                ),
              ),
              Text(
                fmt(calc.totalPrice),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: colors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton(AppLocalizations s) {
    final colors = Theme.of(context).colorScheme;
    // Fallback falls calc fehlschlägt (sollte nicht passieren da Button nur sichtbar wenn selectedPlan != null)
    final calc = _currentPricing;

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _initiateStripePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          s.payAndActivate(
            PricingCalculator.formatPriceForCurrency(
              calc.totalPrice,
              calc.currencyCode,
              calc.currencySymbol,
            ),
          ),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    return Column(
      children: [
        _featureItem(context, s.featureUnlimitedProducts),
        _featureItem(context, s.featurePremiumSupport),
        _featureItem(context, s.featureAdvancedStats),
        _featureItem(context, s.featureNoCommission),
      ],
    );
  }

  Widget _featureItem(BuildContext context, String text) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: colors.primary, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
