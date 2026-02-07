import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_picker/country_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import '../settings_viewmodel.dart';
import 'location_picker_screen.dart';
import 'social_links_card.dart';

class ContactSection extends StatelessWidget {
  final SettingsViewModel vm;

  const ContactSection({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Nummern
        _ContactSubSection(
          icon: Icons.phone_outlined,
          title: s.phoneNumberLabel.replaceAll('*', '').trim(),
          colors: colors,
          theme: theme,
          children: [
            _PhoneRow(
              label: s.phoneNumberLabel,
              code: vm.phoneCode,
              controller: vm.phoneCtrl,
              onPickCode: (code) => vm.setPhoneCode(code),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: vm.waLinkedToPhone,
              onChanged: (val) => vm.toggleWaSync(val),
              title: Text(s.whatsappSameAsPhone),
            ),
            if (!vm.waLinkedToPhone)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _PhoneRow(
                  label: s.whatsappNumberLabel,
                  code: vm.waCode,
                  controller: vm.waCtrl,
                  onPickCode: (code) => vm.setWaCode(code),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // 2. Adresse
        _ContactSubSection(
          icon: Icons.location_on_outlined,
          title: s.addressLabel,
          colors: colors,
          theme: theme,
          children: [
            _AddressSelector(vm: vm),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: vm.showAddressDescription,
              onChanged: (val) => vm.toggleAddressDescription(val),
              title: Text(s.addressDescriptionToggle),
            ),
            if (vm.showAddressDescription)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: vm.addressDescCtrl,
                  maxLines: 4,
                  minLines: 2,
                  maxLength: 500,
                  decoration: InputDecoration(
                    labelText: s.addressDescriptionLabel,
                    hintText: s.addressDescriptionHint,
                    border: const OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // 3. Social Media & Links
        _ContactSubSection(
          icon: Icons.share_outlined,
          title: s.socialLinksTitle,
          colors: colors,
          theme: theme,
          children: [
            SocialLinksContent(vm: vm),
          ],
        ),
      ],
    );
  }
}

/// Klappbare Untersektion innerhalb des Contact-Bereichs
class _ContactSubSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final ColorScheme colors;
  final ThemeData theme;
  final List<Widget> children;

  const _ContactSubSection({
    required this.icon,
    required this.title,
    required this.colors,
    required this.theme,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          leading: Icon(icon, size: 20, color: colors.primary),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          children: children,
        ),
      ),
    );
  }
}

/// Adress-Selektor: Nur per Karte oder GPS befüllbar
/// Keine manuelle Tastatureingabe erlaubt
class _AddressSelector extends StatelessWidget {
  final SettingsViewModel vm;

  const _AddressSelector({required this.vm});

  Future<void> _openMapPicker(BuildContext context) async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => LocationPickerScreen(
          initialLat: vm.latitude,
          initialLng: vm.longitude,
        ),
      ),
    );

    if (result != null) {
      await vm.updateLocationFromMap(result.latitude, result.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;
    final hasAddress = vm.addressCtrl.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Adress-Container (klickbar, aber nicht editierbar)
        GestureDetector(
          onTap: vm.fetchingLocation ? null : () => _openMapPicker(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasAddress
                    ? colors.primary.withValues(alpha: 0.3)
                    : colors.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: hasAddress
                        ? colors.primary.withValues(alpha: 0.1)
                        : colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: hasAddress ? colors.primary : theme.hintColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Adresse oder Platzhalter
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasAddress ? vm.addressCtrl.text : s.addressHint,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: hasAddress
                              ? FontWeight.w500
                              : FontWeight.normal,
                          color: hasAddress
                              ? colors.onSurface
                              : theme.hintColor,
                          fontStyle: hasAddress
                              ? FontStyle.normal
                              : FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!hasAddress) ...[
                        const SizedBox(height: 4),
                        Text(
                          s.selectLocationOnMap,
                          style: TextStyle(fontSize: 12, color: colors.primary),
                        ),
                      ],
                    ],
                  ),
                ),

                // Trailing: Edit Icon
                Icon(
                  Icons.edit_location_alt_outlined,
                  color: theme.hintColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Action Buttons Row
        Row(
          children: [
            // Map Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: vm.fetchingLocation
                    ? null
                    : () => _openMapPicker(context),
                icon: const Icon(Icons.map_outlined, size: 18),
                label: Text(s.selectLocationOnMap),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // GPS Button
            SizedBox(
              height: 48,
              width: 48,
              child: vm.fetchingLocation
                  ? Container(
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : IconButton.filled(
                      onPressed: () => vm.useCurrentLocation(s),
                      icon: const Icon(Icons.my_location, size: 20),
                      tooltip: s.useCurrentLocationTooltip,
                      style: IconButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PhoneRow extends StatelessWidget {
  final String label;
  final String code;
  final TextEditingController controller;
  final ValueChanged<String> onPickCode;

  const _PhoneRow({
    required this.label,
    required this.code,
    required this.controller,
    required this.onPickCode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          textDirection: TextDirection.ltr,
          children: [
            InkWell(
              onTap: () {
                showCountryPicker(
                  context: context,
                  showPhoneCode: true,
                  onSelect: (Country country) =>
                      onPickCode('+${country.phoneCode}'),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      code,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textDirection: TextDirection.ltr,
                    ),
                    const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '123456789',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
