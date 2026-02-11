import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import '../services/api_service.dart';
import '../services/fx_rate_service.dart';
import '../services/regions_service.dart';
import '../models/subscription_plan.dart';
import '../repositories/pricing_repository.dart' as repo;
import '../screens/payment_screen_global.dart';
import '../screens/payment_screen_syria.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentScreen extends StatefulWidget {
  final String? initialPlanId;
  final String returnUrl;
  final bool paymentSuccess;

  const PaymentScreen({
    super.key,
    this.initialPlanId,
    required this.returnUrl,
    this.paymentSuccess = false,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    if (widget.paymentSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSuccessDialog();
      });
    }
    _dataFuture = _fetchData();
  }

  Future<Map<String, dynamic>> _fetchData() async {
    final pricingRepo = repo.PricingRepository();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) throw Exception("User not logged in");

    // 1. Config und Pläne laden (wie bisher)
    final subscriptionConfig = await pricingRepo.fetchSubscriptionConfig();
    final allPlans = subscriptionConfig.plans;
    final allowedPlans = allPlans.toList();
    allowedPlans.sort((a, b) => a.billingCycle.compareTo(b.billingCycle));

    // 2. Region ermitteln (Neue Logik: SY hat Priorität!)
    // Wenn IRGENDWO SY steht (API ODER manuell), dann SY zeigen
    debugPrint("--- DEBUG START: Region Check (Frontend) ---");
    String region = 'GLOBAL';
    String? apiCountry;
    String? manualCountry;

    // SCHRITT A: API-Land aus stores_public lesen
    try {
      final publicDoc = await FirebaseFirestore.instance
          .collection('stores_public')
          .doc(uid)
          .get();

      if (publicDoc.exists && publicDoc.data() != null) {
        final rawData = publicDoc.data()!;
        final data = _sanitizeData(rawData);
        apiCountry = data['api_address_country']
            ?.toString()
            .trim()
            .toUpperCase();
        debugPrint("DEBUG: stores_public 'api_address_country': $apiCountry");
      }
    } catch (e) {
      debugPrint("DEBUG: Fehler beim Lesen von stores_public: $e");
    }

    // SCHRITT B: Manuelle Adresse aus stores_private lesen
    try {
      var storeConfig = await ApiService.fetchStoreConfig();
      manualCountry = storeConfig?['address_country']
          ?.toString()
          .trim()
          .toUpperCase();
      debugPrint("DEBUG: stores_private 'address_country': $manualCountry");
    } catch (e) {
      debugPrint("DEBUG: Fehler beim Lesen von stores_private: $e");
    }

    // SCHRITT C: SY-Priorität prüfen
    // Wenn EINES von beiden SY ist, dann SY verwenden
    if (apiCountry == 'SY' || manualCountry == 'SY') {
      region = 'SY';
      debugPrint(
        "DEBUG: SY erkannt (API: $apiCountry, Manual: $manualCountry) → SY",
      );
    } else if (apiCountry != null &&
        apiCountry.isNotEmpty &&
        apiCountry != 'GLOBAL') {
      // Sonst: API-Land hat Priorität (wenn nicht GLOBAL)
      region = apiCountry;
      debugPrint("DEBUG: Region aus API übernommen: $region");
    } else if (manualCountry != null &&
        manualCountry.isNotEmpty &&
        manualCountry != 'GLOBAL') {
      // Dann: Manuelles Land
      region = manualCountry;
      debugPrint("DEBUG: Region aus manueller Eingabe übernommen: $region");
    }

    // SCHRITT D: Cloud Function Fallback (nur wenn noch GLOBAL)
    if (region == 'GLOBAL') {
      debugPrint("DEBUG: Region noch unklar. Starte Cloud Function...");
      try {
        final result = await FirebaseFunctions.instanceFor(
          region: 'europe-west3',
        ).httpsCallable('resolveUserRegion').call();

        debugPrint("DEBUG: Cloud Function Result: ${result.data}");
        if (result.data['country'] != null) {
          region = result.data['country'].toString().trim().toUpperCase();
        }
      } catch (e) {
        debugPrint("DEBUG: Cloud Function fehlgeschlagen: $e");
        region = 'GLOBAL';
      }
    }

    debugPrint("DEBUG: FINALER WERT für Weiche: '$region'");
    debugPrint("--- DEBUG END ---");

    // SCHRITT E: FX-Rate laden (nur für Nicht-Syrien)
    double fxRate = 1.0;
    String userCurrencyCode = 'eur';
    String userCurrencySymbol = '€';
    bool fxIsFallback = false;

    if (region != 'SY') {
      // Währung aus /system/regions ermitteln
      try {
        final countryConfig = await RegionsService().getCountryConfig(region);
        userCurrencyCode = countryConfig.currencyCode;
        userCurrencySymbol = countryConfig.currencySymbol;
      } catch (e) {
        debugPrint("DEBUG: RegionsService Fehler: $e → EUR Fallback");
      }

      // FX-Rate aus /system/fx_rates holen
      if (userCurrencyCode != 'eur') {
        try {
          final fxResult = await FxRateService().getFxRate(userCurrencyCode);
          fxRate = fxResult.fxRate;
          fxIsFallback = fxResult.isFallback;

          // Wenn Fallback → Währung auf EUR setzen
          if (fxIsFallback) {
            userCurrencyCode = 'eur';
            userCurrencySymbol = '€';
            fxRate = 1.0;
          }

          debugPrint(
            "DEBUG: FX-Rate für $userCurrencyCode: $fxRate (fallback: $fxIsFallback)",
          );
        } catch (e) {
          debugPrint("DEBUG: FX-Rate Fehler: $e → EUR Fallback");
          userCurrencyCode = 'eur';
          userCurrencySymbol = '€';
          fxRate = 1.0;
          fxIsFallback = true;
        }
      }
    }

    return {
      'plans': allowedPlans,
      'region': region,
      'syriaContactPhone': subscriptionConfig.syriaContactPhone,
      'pricingMessageGlobal': subscriptionConfig.pricingMessageGlobal,
      'pricingMessageSyria': subscriptionConfig.pricingMessageSyria,
      'userCurrencyCode': userCurrencyCode,
      'userCurrencySymbol': userCurrencySymbol,
      'fxRate': fxRate,
      'fxIsFallback': fxIsFallback,
    };
  }

  void _showSuccessDialog() {
    final colors = Theme.of(context).colorScheme;
    final s = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Icon(Icons.stars_rounded, color: colors.tertiary, size: 80),
            const SizedBox(height: 16),
            Text(
              s.activationSuccessTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          s.activationSuccessMsg,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => context.go('/home'),
            child: Text(
              s.startNowButton,
              style: TextStyle(color: colors.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final s = AppLocalizations.of(context)!;

    if (widget.paymentSuccess) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: colors.primary)),
      );
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: colors.primary),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Text('${s.loadingErrorPrefix}${snapshot.error}'),
            ),
          );
        }

        final List<SubscriptionPlan> plans = snapshot.data!['plans'];
        final String region = snapshot.data!['region'];

        // -----------------------------------------------------------
        // Basis-Plan identifizieren (premium_monthly - einzige Quelle für regions!)
        // -----------------------------------------------------------
        final SubscriptionPlan basePlan = plans.firstWhere(
          (p) => p.id == 'premium_monthly',
          orElse: () => plans.firstWhere(
            (p) => p.billingCycle == 1,
            orElse: () => plans.first,
          ),
        );

        // -----------------------------------------------------------
        // Region-Key normalisieren (SY → syria, sonst → global)
        // -----------------------------------------------------------
        final String regionKey = region == 'SY' ? 'syria' : 'global';

        // -----------------------------------------------------------
        // Resolve pricing message for current locale
        // -----------------------------------------------------------
        final lang = Localizations.localeOf(context).languageCode;

        String? resolve(Map<String, String>? map) {
          if (map == null || map.isEmpty) return null;
          return map[lang] ?? map['ar'] ?? map.values.first;
        }

        // -----------------------------------------------------------
        // Weiche: Syria vs Global (basierend auf regionKey)
        // -----------------------------------------------------------
        if (regionKey == 'syria') {
          return PaymentScreenSyria(
            availablePlans: plans,
            basePlan: basePlan,
            pricingMessage: resolve(
              snapshot.data!['pricingMessageSyria'] as Map<String, String>?,
            ),
          );
        } else {
          // -----------------------------------------------------------
          // FX-Daten aus _fetchData (bereits mit Fallback-Logik)
          // -----------------------------------------------------------
          final String userCurrencyCode =
              snapshot.data!['userCurrencyCode'] ?? 'eur';
          final String userCurrencySymbol =
              snapshot.data!['userCurrencySymbol'] ?? '€';
          final double fxRate =
              (snapshot.data!['fxRate'] as num?)?.toDouble() ?? 1.0;

          return PaymentScreenGlobal(
            availablePlans: plans,
            basePlan: basePlan,
            userCurrencyCode: userCurrencyCode,
            userCurrencySymbol: userCurrencySymbol,
            fxRate: fxRate,
            pricingMessage: resolve(
              snapshot.data!['pricingMessageGlobal'] as Map<String, String>?,
            ),
          );
        }
      },
    );
  }

  /// Wandelt Firestore Timestamps in Strings um, damit jsonEncode nicht abstürzt
  Map<String, dynamic> _sanitizeData(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is Timestamp) {
        // Timestamp zu ISO-8601 String konvertieren
        return MapEntry(key, value.toDate().toIso8601String());
      }
      if (value is Map<String, dynamic>) {
        // Rekursiv für verschachtelte Maps
        return MapEntry(key, _sanitizeData(value));
      }
      if (value is List) {
        // Listen prüfen (optional, falls Listen Maps enthalten)
        return MapEntry(key, value);
      }
      return MapEntry(key, value);
    });
  }
}
