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

class _CurrencyDropdown extends StatelessWidget {
  final SettingsViewModel vm;
  const _CurrencyDropdown({required this.vm});

  // Bevorzugte Währungen (werden zuerst angezeigt)
  static const List<(String symbol, String label)> _preferred = [
    // Syrien bleibt oben
    ('ل.س', 'ل.س  الليرة السورية (SYP)'),

    // Alphabetisch nach dem internationalen Code sortiert
    ('د.إ', 'د.إ  درهم إماراتي (AED)'),
    ('ج.م', 'ج.م  الجنيه المصري (EGP)'),
    ('€', '€  Euro (EUR)'),
    ('د.أ', 'د.أ  دينار أردني (JOD)'),
    ('د.ك', 'د.ك  دينار كويتي (KWD)'),
    ('ر.ع.', 'ر.ع.  ريال عماني (OMR)'),
    ('ر.ق', 'ر.ق  ريال قطري (QAR)'),
    ('﷼', '﷼  ريال سعودي (SAR)'),
    ('₺', '₺  Türk Lirası (TRY)'),
    ('\$', '\$  US Dollar (USD)'),
  ];

  // Alle anderen Weltwährungen (alphabetisch nach Code)
  static const List<(String symbol, String label)> _allOther = [
    ('Lek', 'Lek  ALL - Albanian Lek'),
    ('դր', 'դր  AMD - Armenian Dram'),
    ('Kz', 'Kz  AOA - Angolan Kwanza'),
    ('\$', '\$  ARS - Argentine Peso'),
    ('A\$', 'A\$  AUD - Australian Dollar'),
    ('₼', '₼  AZN - Azerbaijani Manat'),
    ('KM', 'KM  BAM - Bosnia Mark'),
    ('\$', '\$  BBD - Barbados Dollar'),
    ('৳', '৳  BDT - Bangladeshi Taka'),
    ('лв', 'лв  BGN - Bulgarian Lev'),
    ('د.ب', 'د.ب  BHD - Bahraini Dinar'),
    ('FBu', 'FBu  BIF - Burundian Franc'),
    ('\$', '\$  BMD - Bermudian Dollar'),
    ('\$', '\$  BND - Brunei Dollar'),
    ('Bs', 'Bs  BOB - Bolivian Boliviano'),
    ('R\$', 'R\$  BRL - Brazilian Real'),
    ('\$', '\$  BSD - Bahamian Dollar'),
    ('Nu.', 'Nu.  BTN - Bhutanese Ngultrum'),
    ('P', 'P  BWP - Botswana Pula'),
    ('Br', 'Br  BYN - Belarusian Ruble'),
    ('\$', '\$  BZD - Belize Dollar'),
    ('C\$', 'C\$  CAD - Canadian Dollar'),
    ('FC', 'FC  CDF - Congolese Franc'),
    ('CHF', 'CHF  CHF - Swiss Franc'),
    ('\$', '\$  CLP - Chilean Peso'),
    ('¥', '¥  CNY - Chinese Yuan'),
    ('\$', '\$  COP - Colombian Peso'),
    ('₡', '₡  CRC - Costa Rican Colón'),
    ('\$', '\$  CUP - Cuban Peso'),
    ('Esc', 'Esc  CVE - Cape Verdean Escudo'),
    ('Kč', 'Kč  CZK - Czech Koruna'),
    ('Fdj', 'Fdj  DJF - Djiboutian Franc'),
    ('kr', 'kr  DKK - Danish Krone'),
    ('\$', '\$  DOP - Dominican Peso'),
    ('د.ج', 'د.ج  DZD - Algerian Dinar'),
    ('kr', 'kr  EEK - Estonian Kroon'),
    ('Nfk', 'Nfk  ERN - Eritrean Nakfa'),
    ('Br', 'Br  ETB - Ethiopian Birr'),
    ('\$', '\$  FJD - Fijian Dollar'),
    ('£', '£  FKP - Falkland Pound'),
    ('£', '£  GBP - British Pound'),
    ('₾', '₾  GEL - Georgian Lari'),
    ('GH₵', 'GH₵  GHS - Ghanaian Cedi'),
    ('£', '£  GIP - Gibraltar Pound'),
    ('D', 'D  GMD - Gambian Dalasi'),
    ('FG', 'FG  GNF - Guinean Franc'),
    ('Q', 'Q  GTQ - Guatemalan Quetzal'),
    ('\$', '\$  GYD - Guyanese Dollar'),
    ('HK\$', 'HK\$  HKD - Hong Kong Dollar'),
    ('L', 'L  HNL - Honduran Lempira'),
    ('kn', 'kn  HRK - Croatian Kuna'),
    ('G', 'G  HTG - Haitian Gourde'),
    ('Ft', 'Ft  HUF - Hungarian Forint'),
    ('Rp', 'Rp  IDR - Indonesian Rupiah'),
    ('₪', '₪  ILS - Israeli Shekel'),
    ('₹', '₹  INR - Indian Rupee'),
    ('ع.د', 'ع.د  IQD - Iraqi Dinar'),
    ('﷼', '﷼  IRR - Iranian Rial'),
    ('kr', 'kr  ISK - Icelandic Króna'),
    ('\$', '\$  JMD - Jamaican Dollar'),
    ('¥', '¥  JPY - Japanese Yen'),
    ('KSh', 'KSh  KES - Kenyan Shilling'),
    ('сом', 'сом  KGS - Kyrgyz Som'),
    ('៛', '៛  KHR - Cambodian Riel'),
    ('CF', 'CF  KMF - Comorian Franc'),
    ('₩', '₩  KRW - South Korean Won'),
    ('₭', '₭  LAK - Lao Kip'),
    ('ل.ل', 'ل.ل  LBP - Lebanese Pound'),
    ('Rs', 'Rs  LKR - Sri Lankan Rupee'),
    ('\$', '\$  LRD - Liberian Dollar'),
    ('M', 'M  LSL - Lesotho Loti'),
    ('د.ل', 'د.ل  LYD - Libyan Dinar'),
    ('د.م.', 'د.م.  MAD - Moroccan Dirham'),
    ('L', 'L  MDL - Moldovan Leu'),
    ('Ar', 'Ar  MGA - Malagasy Ariary'),
    ('ден', 'ден  MKD - Macedonian Denar'),
    ('K', 'K  MMK - Myanmar Kyat'),
    ('₮', '₮  MNT - Mongolian Tögrög'),
    ('MOP\$', 'MOP\$  MOP - Macanese Pataca'),
    ('UM', 'UM  MRU - Mauritanian Ouguiya'),
    ('Rs', 'Rs  MUR - Mauritian Rupee'),
    ('Rf', 'Rf  MVR - Maldivian Rufiyaa'),
    ('MK', 'MK  MWK - Malawian Kwacha'),
    ('\$', '\$  MXN - Mexican Peso'),
    ('RM', 'RM  MYR - Malaysian Ringgit'),
    ('MT', 'MT  MZN - Mozambican Metical'),
    ('\$', '\$  NAD - Namibian Dollar'),
    ('₦', '₦  NGN - Nigerian Naira'),
    ('C\$', 'C\$  NIO - Nicaraguan Córdoba'),
    ('kr', 'kr  NOK - Norwegian Krone'),
    ('Rs', 'Rs  NPR - Nepalese Rupee'),
    ('NZ\$', 'NZ\$  NZD - New Zealand Dollar'),
    ('B/.', 'B/.  PAB - Panamanian Balboa'),
    ('S/', 'S/  PEN - Peruvian Sol'),
    ('K', 'K  PGK - Papua New Guinean Kina'),
    ('₱', '₱  PHP - Philippine Peso'),
    ('Rs', 'Rs  PKR - Pakistani Rupee'),
    ('zł', 'zł  PLN - Polish Zloty'),
    ('₲', '₲  PYG - Paraguayan Guaraní'),
    ('lei', 'lei  RON - Romanian Leu'),
    ('дин', 'дин  RSD - Serbian Dinar'),
    ('₽', '₽  RUB - Russian Ruble'),
    ('FRw', 'FRw  RWF - Rwandan Franc'),
    ('\$', '\$  SBD - Solomon Islands Dollar'),
    ('Rs', 'Rs  SCR - Seychellois Rupee'),
    ('ج.س', 'ج.س  SDG - Sudanese Pound'),
    ('kr', 'kr  SEK - Swedish Krona'),
    ('S\$', 'S\$  SGD - Singapore Dollar'),
    ('£', '£  SHP - Saint Helena Pound'),
    ('Le', 'Le  SLL - Sierra Leonean Leone'),
    ('Sh', 'Sh  SOS - Somali Shilling'),
    ('\$', '\$  SRD - Surinamese Dollar'),
    ('£', '£  SSP - South Sudanese Pound'),
    ('Db', 'Db  STN - São Tomé Dobra'),
    ('\$', '\$  SVC - Salvadoran Colón'),
    ('E', 'E  SZL - Eswatini Lilangeni'),
    ('฿', '฿  THB - Thai Baht'),
    ('SM', 'SM  TJS - Tajikistani Somoni'),
    ('T', 'T  TMT - Turkmenistani Manat'),
    ('د.ت', 'د.ت  TND - Tunisian Dinar'),
    ('T\$', 'T\$  TOP - Tongan Paʻanga'),
    ('\$', '\$  TTD - Trinidad Dollar'),
    ('NT\$', 'NT\$  TWD - Taiwan Dollar'),
    ('TSh', 'TSh  TZS - Tanzanian Shilling'),
    ('₴', '₴  UAH - Ukrainian Hryvnia'),
    ('USh', 'USh  UGX - Ugandan Shilling'),
    ('\$U', '\$U  UYU - Uruguayan Peso'),
    ('сўм', 'сўм  UZS - Uzbekistani Som'),
    ('Bs.S', 'Bs.S  VES - Venezuelan Bolívar'),
    ('₫', '₫  VND - Vietnamese Dong'),
    ('VT', 'VT  VUV - Vanuatu Vatu'),
    ('T', 'T  WST - Samoan Tala'),
    ('FCFA', 'FCFA  XAF - Central African CFA'),
    ('EC\$', 'EC\$  XCD - East Caribbean Dollar'),
    ('CFA', 'CFA  XOF - West African CFA'),
    ('CFP', 'CFP  XPF - CFP Franc'),
    ('ر.ي', 'ر.ي  YER - Yemeni Rial'),
    ('R', 'R  ZAR - South African Rand'),
    ('ZK', 'ZK  ZMW - Zambian Kwacha'),
    ('Z\$', 'Z\$  ZWL - Zimbabwean Dollar'),
  ];

  static List<(String, String)> get _allCurrencies => [
    ..._preferred,
    ..._allOther,
  ];

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    return TextFormField(
      controller: vm.currencyCtrl,
      readOnly: true,
      decoration: InputDecoration(
        labelText: s.currencyLabel,
        prefixIcon: const Icon(Icons.currency_exchange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: PopupMenuButton<String>(
          icon: const Icon(Icons.arrow_drop_down),
          onSelected: (val) => vm.setCurrency(val),
          constraints: const BoxConstraints(maxHeight: 400),
          itemBuilder: (ctx) => _allCurrencies
              .map(
                (e) => PopupMenuItem(
                  value: e.$1,
                  child: Text(e.$2, textDirection: TextDirection.ltr),
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
