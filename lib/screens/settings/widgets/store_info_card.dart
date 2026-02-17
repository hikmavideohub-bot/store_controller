import 'package:flutter/material.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import '../settings_viewmodel.dart';

class StoreInfoCard extends StatelessWidget {
  final SettingsViewModel vm;
  final bool hideDescription;
  final bool showWebsite;
  final bool showCreatedDate;

  const StoreInfoCard({
    super.key,
    required this.vm,
    this.hideDescription = false,
    this.showWebsite = true,
    this.showCreatedDate = true, // Erstellungsdatum im Standard-Modus anzeigen
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppLocalizations.of(context)!;

    // Basis-Container für visuelle Gruppierung
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titel nur anzeigen, wenn wir nicht im Wizard sind (da gibt es schon Titel)
          if (!hideDescription) ...[
            Row(
              children: [
                Icon(Icons.storefront, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  s.storeInfoTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
          ],

          // Shop Name
          _AutoDirectionField(
            controller: vm.storeNameCtrl,
            label: s.storeNameLabel,
            icon: Icons.abc,
            maxLength: 25,
            onChanged: (_) => vm.notifyListeners(), // Damit Header sich updated
          ),

          // Toggle: Name neben Logo anzeigen (nur wenn Logo vorhanden)
          _ShowNameWithLogoToggle(vm: vm),

          const SizedBox(height: 16),

          // Währung
          _CurrencyDropdown(vm: vm),

          const SizedBox(height: 16),

          // Store/Website Sprache
          _StoreLangDropdown(vm: vm),

          if (!hideDescription) ...[
            const SizedBox(height: 16),
            // Beschreibung (multilingual)
            _PageDescMultiLangField(vm: vm),
            const SizedBox(height: 8),
            Text(
              s.storeDescHelper,
              style: TextStyle(fontSize: 12, color: theme.hintColor),
            ),
          ],

          // Store Website ENTFERNT (User Wunsch)

          // Erstellungsdatum (nur im Standard-Modus)
          if (showCreatedDate && vm.createdAtDateOnly != '-') ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: theme.hintColor,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      s.createdAtDate(vm.createdAtDateOnly),
                      style: TextStyle(color: theme.hintColor, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// --- Hilfs-Widgets ---

// Öffentliche Klasse, damit wir die Währungen in der ganzen App nutzen können
extension CurrencyLabelByCodeX on AppLocalizations {
  /// Liefert das lokalisierte Label aus ARB (z.B. currencyLabelUSD)
  /// Fallback: gibt den Code zurück.
  String currencyLabelByCode(String code) => switch (code) {
  // --- Arabische Währungen ---
    'AED' => currencyLabelAED, // VAE Dirham
    'BHD' => currencyLabelBHD, // Bahrain Dinar
    'DJF' => currencyLabelDJF, // Dschibuti-Franc
    'DZD' => currencyLabelDZD, // Algerischer Dinar
    'EGP' => currencyLabelEGP, // Ägyptisches Pfund
    'IQD' => currencyLabelIQD, // Irakischer Dinar
    'JOD' => currencyLabelJOD, // Jordanischer Dinar
    'KMF' => currencyLabelKMF, // Komoren-Franc
    'KWD' => currencyLabelKWD, // Kuwait-Dinar
    'LBP' => currencyLabelLBP, // Libanesisches Pfund
    'LYD' => currencyLabelLYD, // Libyscher Dinar
    'MAD' => currencyLabelMAD, // Marokkanischer Dirham
    'MRU' => currencyLabelMRU, // Mauretanischer Ouguiya
    'OMR' => currencyLabelOMR, // Omanischer Rial
    'QAR' => currencyLabelQAR, // Katar-Riyal
    'SAR' => currencyLabelSAR, // Saudi-Riyal
    'SDG' => currencyLabelSDG, // Sudanesisches Pfund
    'SOS' => currencyLabelSOS, // Somalia-Schilling
    'SYP' => currencyLabelSYP, // Syrische Lira
    'TND' => currencyLabelTND, // Tunesischer Dinar
    'YER' => currencyLabelYER, // Jemen-Rial

// --- Bekannte Weltwährungen ---
    'AUD' => currencyLabelAUD, // Australischer Dollar
    'BRL' => currencyLabelBRL, // Brasilianischer Real
    'CAD' => currencyLabelCAD, // Kanadischer Dollar
    'CHF' => currencyLabelCHF, // Schweizer Franken
    'CNY' => currencyLabelCNY, // Chinesischer Yuan
    'EUR' => currencyLabelEUR, // Euro
    'GBP' => currencyLabelGBP, // Britisches Pfund
    'JPY' => currencyLabelJPY, // Japanischer Yen
    'RUB' => currencyLabelRUB, // Russischer Rubel
    'SEK' => currencyLabelSEK, // Schwedische Krone
    'TRY' => currencyLabelTRY, // Türkische Lira
    'USD' => currencyLabelUSD, // US-Dollar
    _ => code,
  };
}

class StoreCurrencies {
  /// Arabische Länder zuerst (du kannst die Reihenfolge hier ändern)
  static const List<String> arabFirstCodes = [
    'SYP', 'AED', 'BHD', 'DZD', 'EGP', 'IQD', 'JOD', 'KWD', 'LBP', 'LYD',
    'MAD', 'OMR', 'QAR', 'SAR', 'SDG', 'DJF', 'TND', 'YER', 'MRU', 'SOS',
    'KMF',
  ];

  /// Optional: direkt NACH Arab (die 3 wichtigsten Fremdwährungen)
  static const List<String> pinnedOtherCodes = [
    'EUR', 'TRY', 'USD'
  ];

  /// Alle unterstützten Codes (alphabetisch) - Nur arabische und die berühmtesten Weltwährungen
  static const List<String> supportedCodes = [
    'AED', 'AUD', 'BHD', 'BRL', 'CAD', 'CHF', 'CNY', 'DJF', 'DZD', 'EGP',
    'EUR', 'GBP', 'IQD', 'JOD', 'JPY', 'KMF', 'KWD', 'LBP', 'LYD', 'MAD',
    'MRU', 'OMR', 'QAR', 'RUB', 'SAR', 'SDG', 'SEK', 'SOS', 'SYP', 'TND',
    'TRY', 'USD', 'YER',
  ];

  /// ✅ Endgültige Reihenfolge: Arab → (optional pinned) → Rest (alphabetisch, ohne Duplikate)
  static final List<String> orderedCodes = (() {
    final out = <String>[];
    final seen = <String>{};

    void push(Object? code) {
      final c = (code ?? '').toString();
      if (c.isEmpty) return;
      if (seen.add(c)) out.add(c);
    }

    for (final c in arabFirstCodes) push(c);
    for (final c in pinnedOtherCodes) push(c);
    for (final c in supportedCodes) push(c);

    return List<String>.unmodifiable(out);
  })();

}

class _CurrencyDropdown extends StatelessWidget {
  final SettingsViewModel vm;
  const _CurrencyDropdown({required this.vm});

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;

    // ✅ Wichtig: VM speichert nur den Code (z.B. "USD"), nicht das Symbol.
    final code = vm.currencyCode;
    final label = s.currencyLabelByCode(code);

    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: label),
      decoration: InputDecoration(
        labelText: s.currencyLabel,
        prefixIcon: const Icon(Icons.currency_exchange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: PopupMenuButton<String>(
          icon: const Icon(Icons.arrow_drop_down),
          onSelected: (code) => vm.setCurrency(code), // code speichern
          constraints: const BoxConstraints(maxHeight: 400),
          itemBuilder: (ctx) => StoreCurrencies.orderedCodes
              .map(
                (code) => PopupMenuItem(
              value: code,
              child: Text(
                s.currencyLabelByCode(code),
                textDirection: TextDirection.ltr,
              ),
            ),
          )
              .toList(),
        ),
      ),
    );
  }
}

class _AutoDirectionField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int? maxLength;
  final ValueChanged<String>? onChanged;

  const _AutoDirectionField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLength,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Einfache automatische Erkennung der Textrichtung
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final text = controller.text;
        final isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
        final dir = isArabic ? TextDirection.rtl : TextDirection.ltr;

        return TextField(
          controller: controller,
          textDirection: dir,
          maxLength: maxLength,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
    );
  }
}

class _PageDescMultiLangField extends StatefulWidget {
  final SettingsViewModel vm;
  const _PageDescMultiLangField({required this.vm});

  @override
  State<_PageDescMultiLangField> createState() =>
      _PageDescMultiLangFieldState();
}

class _PageDescMultiLangFieldState extends State<_PageDescMultiLangField> {
  String _selectedLang = 'de';

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    final labels = {
      'ar': s.descLangAr,
      'de': s.descLangDe,
      'en': s.descLangEn,
      'tr': s.descLangTr,
    };
    final ctrl = widget.vm.pageDescCtrlFor(_selectedLang);
    final fieldLabel = switch (_selectedLang) {
      'ar' => s.pageDescLabelAr,
      'de' => s.pageDescLabelDe,
      'en' => s.pageDescLabelEn,
      'tr' => s.pageDescLabelTr,
      _ => s.pageDescLabelDe,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<String>(
            segments: labels.entries
                .map((e) => ButtonSegment(value: e.key, label: Text(e.value)))
                .toList(),
            selected: {_selectedLang},
            onSelectionChanged: (sel) =>
                setState(() => _selectedLang = sel.first),
            showSelectedIcon: false,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: ValueKey('pageDesc_$_selectedLang'),
          controller: ctrl,
          textDirection:
          _selectedLang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          maxLines: 3,
          maxLength: 40,
          decoration: InputDecoration(
            labelText: fieldLabel,
            hintText: s.storeDescHint,
            prefixIcon: const Icon(Icons.description_outlined),
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}

class _StoreLangDropdown extends StatelessWidget {
  final SettingsViewModel vm;
  const _StoreLangDropdown({required this.vm});

  // Unterstützte Sprachen für die öffentliche Web-App
  static const List<(String code, String nativeName, String flag)> _languages =
  [
    ('ar', 'العربية', '🇸🇦'),
    ('en', 'English', '🇬🇧'),
    ('de', 'Deutsch', '🇩🇪'),
    ('tr', 'Türkçe', '🇹🇷'),
  ];

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    final current = _languages.firstWhere(
          (e) => e.$1 == vm.storeLang,
      orElse: () => _languages.first,
    );

    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: '${current.$3} ${current.$2}'),
      decoration: InputDecoration(
        labelText: s.storeLangLabel,
        helperText: s.storeLangHelper,
        helperMaxLines: 2,
        prefixIcon: const Icon(Icons.language),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: PopupMenuButton<String>(
          icon: const Icon(Icons.arrow_drop_down),
          onSelected: (val) => vm.setStoreLang(val),
          itemBuilder: (ctx) => _languages
              .map(
                (e) => PopupMenuItem(
              value: e.$1,
              child: Row(
                children: [
                  Text(e.$3, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Text(e.$2),
                ],
              ),
            ),
          )
              .toList(),
        ),
      ),
    );
  }
}

/// Toggle: Store-Name neben Logo anzeigen
/// Wird nur angezeigt wenn ein Logo hochgeladen wurde
class _ShowNameWithLogoToggle extends StatelessWidget {
  final SettingsViewModel vm;
  const _ShowNameWithLogoToggle({required this.vm});

  @override
  Widget build(BuildContext context) {
    final hasLogo = vm.logoUrl.isNotEmpty && vm.logoUrl.startsWith('http');
    if (!hasLogo) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.outline.withValues(alpha: 0.1),
          ),
        ),
        child: SwitchListTile.adaptive(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          title: Text(
            s.showNameWithLogoLabel,
            style: const TextStyle(fontSize: 14),
          ),
          subtitle: Text(
            s.showNameWithLogoHint,
            style: TextStyle(
              fontSize: 12,
              color: theme.hintColor,
            ),
          ),
          secondary: Icon(
            Icons.badge_outlined,
            color: colors.primary,
            size: 22,
          ),
          value: vm.showNameWithLogo,
          onChanged: (v) => vm.setShowNameWithLogo(v),
        ),
      ),
    );
  }
}
