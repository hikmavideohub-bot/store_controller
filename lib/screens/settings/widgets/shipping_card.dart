import 'package:flutter/material.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import '../settings_viewmodel.dart';

class ShippingCard extends StatelessWidget {
  final SettingsViewModel vm;

  const ShippingCard({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;

    // Design angepasst auf ExpansionTile Stil (wie SecuritySection)
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colors.outline.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(s.shippingTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: const Icon(Icons.local_shipping_outlined),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: vm.shippingEnabled,
            onChanged: (v) => vm.toggleShipping(v),
            title: Text(s.shippingEnabled),
            subtitle: Text(
              s.shippingEnabledSubtitle,
              style: const TextStyle(fontSize: 12),
            ),
          ),

          if (vm.shippingEnabled) ...[
            const SizedBox(height: 12),
            TextField(
              controller: vm.shippingPriceCtrl,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                labelText: s.shippingCostLabel,
                hintText: s.shippingCostHint,
                prefixIcon: const Icon(Icons.attach_money, size: 20),
                suffixText: vm.currencyCtrl.text,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}