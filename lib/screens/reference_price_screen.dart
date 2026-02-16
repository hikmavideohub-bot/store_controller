import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import '../services/store_config_service.dart';
import '../services/api_service.dart';
import '../widgets/premium_app_bar.dart';
import '../widgets/responsive_center.dart';

class ReferencePriceScreen extends StatefulWidget {
  const ReferencePriceScreen({super.key});

  @override
  State<ReferencePriceScreen> createState() => _ReferencePriceScreenState();
}

class _ReferencePriceScreenState extends State<ReferencePriceScreen> {
  bool _isFeatureEnabled = false;
  late TextEditingController _rateController;
  String _refCurrency = '\$';
  String _localCurrency = '€';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final store = StoreConfigService.store;
    _isFeatureEnabled = store?['use_reference_price'] ?? false;

    double currentRate = (store?['reference_rate'] ?? 1.0).toDouble();
    // trim() entfernt versehentliche Leerzeichen aus der Datenbank
    _refCurrency = (store?['reference_currency'] ?? '\$').toString().trim();
    _localCurrency = (store?['currency'] ?? '€').toString().trim();

    // Strikter Check, um Dropdown-Crashes zu vermeiden
    if (!['€', '\$', '₺'].contains(_refCurrency)) {
      _refCurrency = '\$';
    }

    _rateController = TextEditingController(
      text: currentRate > 0 ? currentRate.toStringAsFixed(0) : '1',
    );
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    final s = AppLocalizations.of(context)!;
    final storeId = StoreConfigService.store?['id'] ?? ApiService.storeId;

    if (storeId != null) {
      final dataToSave = {
        'use_reference_price': _isFeatureEnabled,
        'reference_rate': double.tryParse(_rateController.text) ?? 1.0,
        'reference_currency': _refCurrency,
      };

      try {
        await FirebaseFirestore.instance
            .collection('stores_public')
            .doc(storeId)
            .set(dataToSave, SetOptions(merge: true));

        StoreConfigService.store?['use_reference_price'] = _isFeatureEnabled;
        StoreConfigService.store?['reference_rate'] = dataToSave['reference_rate'];
        StoreConfigService.store?['reference_currency'] = dataToSave['reference_currency'];

        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        StoreConfigService.storeNotifier.notifyListeners();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(s.saveButton),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;

    double inputRate = double.tryParse(_rateController.text) ?? 1.0;
    double exampleBase = 10.0;
    double exampleFinal = exampleBase * (inputRate > 0 ? inputRate : 1);

    // ✅ Sicherheits-Zuweisung für das Dropdown-Menü
    final validCurrencies = ['\$', '€', '₺'];
    final safeCurrency = validCurrencies.contains(_refCurrency) ? _refCurrency : '\$';

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: PremiumAnimatedAppBar(
        title: s.refPriceDialogTitle,
        showBackButton: true,
      ),
      // ✅ Crash-sicherer Bottom-Button (Zentriert ohne LayoutBuilder)
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            heightFactor: 1.0, // Nimmt exakt die Höhe des Buttons an
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _saveSettings,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  )
                      : Text(s.saveButton, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
          ),
        ),
      ),
      body: ResponsiveCenter(
        maxWidth: 720,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: colors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        s.refPriceDialogDesc,
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isFeatureEnabled ? colors.primary : colors.outline.withValues(alpha: 0.2),
                    width: _isFeatureEnabled ? 2 : 1,
                  ),
                ),
                child: SwitchListTile.adaptive(
                  title: Text(
                    s.refPriceEnable,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _isFeatureEnabled ? colors.primary : colors.onSurface,
                    ),
                  ),
                  value: _isFeatureEnabled,
                  activeColor: colors.primary,
                  onChanged: (val) => setState(() => _isFeatureEnabled = val),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),


              if (_isFeatureEnabled) ...[
                const SizedBox(height: 32),
                Text(
                  s.refPriceMenuTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),

                // Währung (Dropdown) & Rate (Textfield)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: safeCurrency, // ✅ Garantiert ein korrekter Wert
                        decoration: InputDecoration(
                          labelText: s.refCurrencyLabel,
                          filled: true,
                          fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.3),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: colors.outline.withValues(alpha: 0.2)),
                          ),
                        ),
                        items: [ // ❌ HIER KEIN 'const' MEHR!
                          DropdownMenuItem(
                            value: '\$',
                            child: Text(s.currencyUsd, overflow: TextOverflow.ellipsis),
                          ),
                          DropdownMenuItem(
                            value: '€',
                            child: Text(s.currencyEur, overflow: TextOverflow.ellipsis),
                          ),
                          DropdownMenuItem(
                            value: '₺',
                            child: Text(s.currencyTry, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _refCurrency = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _rateController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        decoration: InputDecoration(
                          labelText: '${s.refRateLabel} ($_localCurrency)',
                          filled: true,
                          fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.3),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: colors.outline.withValues(alpha: 0.2)),
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Live-Beispiel
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          s.refPriceExample(
                            '$exampleBase $safeCurrency',
                            exampleFinal.toStringAsFixed(0),
                            _localCurrency,
                          ),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ✅ NEU: Der Erklärungs-Hinweis für die Unsichtbarkeit
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.visibility_off_outlined,
                      size: 16,
                      color: theme.hintColor, // Dezentes Grau
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.refCurrencyHiddenHint,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: theme.hintColor,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}