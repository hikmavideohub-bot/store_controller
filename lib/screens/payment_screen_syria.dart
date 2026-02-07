import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';

import '../models/subscription_plan.dart';
import '../widgets/premium_app_bar.dart';
import '../services/api_service.dart';
import '../services/store_config_service.dart';
import '../repositories/activation_request_repository.dart';
// WICHTIG: Pfad anpassen, falls nötig
import '../logic/pricing_calculator.dart';
import '../widgets/app_drawer.dart';

class PaymentScreenSyria extends StatefulWidget {
  final List<SubscriptionPlan> availablePlans;
  final SubscriptionPlan
  basePlan; // NEU: Referenz zum Monats-Plan für Fallbacks
  final String? pricingMessage;

  const PaymentScreenSyria({
    super.key,
    required this.availablePlans,
    required this.basePlan,
    this.pricingMessage,
  });

  @override
  State<PaymentScreenSyria> createState() => _PaymentScreenSyriaState();
}

class _PaymentScreenSyriaState extends State<PaymentScreenSyria> {
  SubscriptionPlan? _selectedPlan;

  /// Dynamische Payment-ID aus Firestore (plans.premium_monthly.regions.syria.account_details)
  String get _paymentId {
    final syriaData = widget.basePlan.getPriceForRegion('syria');
    return syriaData.accountDetails ?? '';
  }

  final _formKey = GlobalKey<FormState>();
  final _transferAccountNameController = TextEditingController();

  bool _isSubmitting = false;

  // Status-Variablen für die Prüfung
  bool _isLoadingCheck = true;
  bool _hasExistingRequest = false;

  final _activationRepo = ActivationRequestRepository();

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

    // 1. Standard-Plan auswählen (aber nur aus den sichtbaren Plänen!)
    final plansDisplay = _visiblePlans;

    if (plansDisplay.isNotEmpty) {
      _selectedPlan = plansDisplay.firstWhere(
        (p) {
          // Calculator nutzen um 'Best Value' zu finden
          final pricing = PricingCalculator.calculateSyria(
            plan: p,
            basePlan: widget.basePlan,
          );
          return pricing.isBestValue;
        },
        orElse: () => plansDisplay.firstWhere(
          (p) => p.id.contains('yearly'),
          orElse: () => plansDisplay.first,
        ),
      );
    }

    _checkExistingRequest();
  }

  Future<void> _checkExistingRequest() async {
    final storeId = ApiService.storeId;
    if (storeId != null) {
      final exists = await _activationRepo.hasPendingRequest(storeId);
      if (mounted) {
        setState(() {
          _hasExistingRequest = exists;
          _isLoadingCheck = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoadingCheck = false);
    }
  }

  @override
  void dispose() {
    _transferAccountNameController.dispose();
    super.dispose();
  }

  // Zentralisierter Getter: Nutzt calculateSyria() für direkte Preise aus Firestore
  PricingResult get _currentPricing {
    if (_selectedPlan == null) {
      final syriaData = widget.basePlan.getPriceForRegion('syria');
      return PricingResult(
        monthlyPrice: 0,
        totalPrice: 0,
        billingCycle: 1,
        currencySymbol: syriaData.currency,
        currencyCode: syriaData.currencyCode ?? 'syp',
        hasOffer: false,
        isBestValue: false,
      );
    }

    return PricingCalculator.calculateSyria(
      plan: _selectedPlan!,
      basePlan: widget.basePlan,
    );
  }

  Future<void> _submitActivationRequest(AppLocalizations s) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPlan == null) return;

    setState(() => _isSubmitting = true);

    try {
      final storeId = ApiService.storeId ?? '';
      final storeName = StoreConfigService.storeName;
      final userPhone = (StoreConfigService.store?['phone'] as String?) ?? '';

      final calc = _currentPricing;

      final request = ActivationRequest(
        storeId: storeId,
        storeName: storeName,
        userId: storeId,
        planId: _selectedPlan!.id,
        amount: calc.totalPrice, // Preis kommt jetzt sicher aus dem Calculator
        currency: calc.currencySymbol,
        transferAccountName: _transferAccountNameController.text.trim(),
        contactInfo: userPhone,
      );

      await _activationRepo.createActivationRequest(request);

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: Icon(
            Icons.check_circle_outline_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 64,
          ),
          title: Text(s.activationRequestSentTitle),
          content: Text(
            s.activationRequestSentMsg,
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/');
              },
              child: Text(s.goToHomeButton),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.activationRequestError),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: PremiumAnimatedAppBar(
        title: s.paymentAndActivationTitle,
        showBackButton: true,
      ),
      body: _buildBody(context, s, colors),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations s,
    ColorScheme colors,
  ) {
    if (_isLoadingCheck) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasExistingRequest) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.hourglass_top_rounded,
                size: 80,
                color: colors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                s.pendingRequestTitle,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                s.pendingRequestMessage,
                style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: Text(s.goToHomeButton),
              ),
            ],
          ),
        ),
      );
    }

    // Wir nutzen hier _visiblePlans anstatt widget.availablePlans direkt
    final plansToDisplay = _visiblePlans;

    if (plansToDisplay.isEmpty) {
      // Fallback, falls gar keine Pläne (außer dem BasePlan) da sind
      return Center(child: Text(s.noPlansAvailable));
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: colors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    s.paymentSyriaInfoBox,
                    style: TextStyle(fontSize: 13, color: colors.onSurface),
                  ),
                ),
              ],
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

          Text(
            s.step1ChoosePlan,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),

          // HIER: Nur die sichtbaren Pläne rendern (kein Monthly)
          ...plansToDisplay.map((plan) => _buildPlanCard(plan, context, s)),

          const SizedBox(height: 24),
          Text(
            s.step2PaymentDetails,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _buildPaymentDetailsCard(context, s),

          const SizedBox(height: 24),
          Text(
            s.step3TransferInfo,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _buildTransferAccountNameField(context, s),

          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting
                  ? null
                  : () => _submitActivationRequest(s),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              icon: _isSubmitting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(colors.onPrimary),
                      ),
                    )
                  : const Icon(Icons.verified_user_rounded),
              label: Text(
                _isSubmitting ? s.submittingRequest : s.confirmPaymentButton,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: Column(
              children: [
                Text(
                  s.paymentSupportTitle,
                  style: TextStyle(color: colors.outline, fontSize: 12),
                ),
                TextButton.icon(
                  onPressed: () => AppDrawer.showSupportDialog(context),
                  icon: Icon(
                    Icons.email_outlined,
                    size: 16,
                    color: colors.primary,
                  ),
                  label: Text(
                    s.paymentSupportAction,
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    SubscriptionPlan plan,
    BuildContext context,
    AppLocalizations s,
  ) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    // Sicherheit: Falls _selectedPlan null ist (sollte nicht passieren), ersten nehmen
    final currentSelectedId = _selectedPlan?.id ?? _visiblePlans.first.id;
    final isSelected = plan.id == currentSelectedId;

    // Verwende Calculator für Syrien
    final calc = PricingCalculator.calculateSyria(
      plan: plan,
      basePlan: widget.basePlan,
    );

    final activeColor = colors.tertiary;
    final bestValueColor = colors.primary;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.1)
              : calc.isBestValue
              ? bestValueColor.withValues(alpha: 0.05)
              : colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? activeColor
                : calc.isBestValue
                ? bestValueColor.withValues(alpha: 0.3)
                : colors.outline.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            if (calc.isBestValue)
              Positioned(
                top: 0,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: bestValueColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    s.pricingBestValue,
                    style: TextStyle(
                      color: colors.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: isSelected
                        ? activeColor
                        : colors.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          calc.billingCycle == 1
                              ? s.pricingOneMonth
                              : s.pricingMonthsCount(calc.billingCycle),
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        if (calc.hasOffer && calc.discountPercent != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              s.pricingSavePercent(calc.discountPercent!),
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
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
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                            color: colors.onSurface.withValues(alpha: 0.5),
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
                          fontSize: 22, // 👈 größer = Fokus
                          fontWeight: FontWeight.w900,
                          color: isSelected
                              ? (calc.hasOffer
                                    ? Colors.green.shade700
                                    : activeColor)
                              : theme.hintColor,
                        ),
                      ),
                      Text(
                        s.pricingPerMonth, // ✅ sauberer ARB-Key
                        style: TextStyle(
                          fontSize: 11,
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

  Widget _buildQrCodeImage(AppLocalizations s) {
    // WICHTIG: Hier kommt der Fallback zum Tragen!
    // Wenn 'yearly' keinen QR hat, liefert 'calc.qrImageUrl'
    // automatisch den Link vom 'basePlan'.
    final qrUrl = _currentPricing.qrImageUrl;

    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: qrUrl != null && qrUrl.isNotEmpty
          ? Image.network(
              qrUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => _buildQrFallback(s),
            )
          : _buildQrFallback(s),
    );
  }

  Widget _buildQrFallback(AppLocalizations s) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_2, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            s.qrCodePlaceholder,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsCard(BuildContext context, AppLocalizations s) {
    final colors = Theme.of(context).colorScheme;
    final calc = _currentPricing;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildQrCodeImage(s),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payments_outlined, color: colors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  s.pricingTotal(
                    PricingCalculator.formatPriceForCurrency(
                      calc.totalPrice,
                      calc.currencyCode,
                      calc.currencySymbol,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Divider(color: colors.outline.withValues(alpha: 0.2)),
          const SizedBox(height: 16),

          Text(
            s.accountNumberLabel,
            style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: _paymentId));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(s.copyIdSuccess),
                  backgroundColor: colors.primary,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _paymentId,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.copy_rounded, size: 18, color: colors.primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            s.paymentMethodElectronic,
            style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferAccountNameField(
    BuildContext context,
    AppLocalizations s,
  ) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                color: colors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                s.transferAccountNameLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _transferAccountNameController,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: s.transferAccountNameHint,
              filled: true,
              fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.primary, width: 1.5),
              ),
            ),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? s.transferAccountNameRequired
                : null,
          ),
        ],
      ),
    );
  }
}
