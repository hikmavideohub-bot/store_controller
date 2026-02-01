import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import 'package:store_controller/services/api_service.dart';

import 'settings_viewmodel.dart';
import 'widgets/settings_header.dart';
import 'widgets/store_info_card.dart';
import 'widgets/contact_section.dart';
import 'widgets/working_hours_card.dart';
import 'widgets/social_links_card.dart';
import 'widgets/security_section.dart';
import 'widgets/appearance_card.dart';
import 'widgets/shipping_card.dart';

class SettingsScreen extends StatefulWidget {
  final bool firstSetup;

  const SettingsScreen({super.key, required this.firstSetup});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PageController _pageController = PageController();
  int _currentWizardStep = 0;

  /// Ermittelt die Textrichtung basierend auf dem ersten Buchstaben
  TextDirection? _getTextDirection(String text) {
    final trimmed = text.trimLeft();
    if (trimmed.isEmpty) return null; // Default verwenden
    final firstChar = trimmed.codeUnitAt(0);
    // Arabisch: U+0600–U+06FF, U+0750–U+077F, U+08A0–U+08FF
    final isArabic =
        (firstChar >= 0x0600 && firstChar <= 0x06FF) ||
        (firstChar >= 0x0750 && firstChar <= 0x077F) ||
        (firstChar >= 0x08A0 && firstChar <= 0x08FF);
    return isArabic ? TextDirection.rtl : TextDirection.ltr;
  }

  // Track expanded sections
  final Map<String, bool> _expandedSections = {
    'storeInfo': true,
    'contact': false,
    'shipping': false,
    'hours': false,
    'security': false,
    'appearance': false,
  };

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel()..init(),
      child: Consumer<SettingsViewModel>(
        builder: (context, vm, child) {
          if (vm.busy && !vm.saving) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (widget.firstSetup) {
            return _buildWizardLayout(context, vm);
          } else {
            return _buildStandardLayout(context, vm);
          }
        },
      ),
    );
  }

  // ===========================================================================
  // 1. STANDARD LAYOUT
  // ===========================================================================
  Widget _buildStandardLayout(BuildContext context, SettingsViewModel vm) {
    final colors = Theme.of(context).colorScheme;
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.profileTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (vm.saving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: vm.busy ? null : () => _handleSave(vm),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
        children: [
          SettingsHeader(vm: vm),
          const SizedBox(height: 24),

          // 1. STORE INFO
          _buildExpansionSection(
            context: context,
            key: 'storeInfo',
            icon: Icons.storefront_outlined,
            title: s.storeInfoSectionTitle,
            subtitle: s.storeInfoSectionSubtitle,
            children: [StoreInfoCard(vm: vm)],
          ),
          const SizedBox(height: 12),

          // 2. KONTAKT & SOCIAL
          _buildExpansionSection(
            context: context,
            key: 'contact',
            icon: Icons.contact_phone_outlined,
            title: s.contactSectionTitle,
            subtitle: s.contactSectionSubtitle,
            children: [
              ContactSection(vm: vm),
              const SizedBox(height: 16),
              SocialLinksCard(vm: vm),
            ],
          ),
          const SizedBox(height: 12),

          // 3. LIEFERUNG
          _buildExpansionSection(
            context: context,
            key: 'shipping',
            icon: Icons.local_shipping_outlined,
            title: s.step3Title,
            subtitle: s.step3Subtitle,
            children: [ShippingCard(vm: vm)],
          ),
          const SizedBox(height: 12),

          // 4. ÖFFNUNGSZEITEN
          _buildExpansionSection(
            context: context,
            key: 'hours',
            icon: Icons.access_time_outlined,
            title: s.step4Title,
            subtitle: s.step4Subtitle,
            children: [WorkingHoursCard(vm: vm)],
          ),
          const SizedBox(height: 12),

          // 5. SICHERHEIT (Keys müssen in ARB existieren!)
          _buildExpansionSection(
            context: context,
            key: 'security',
            icon: Icons.security_outlined,
            title: s.securitySectionTitle,
            subtitle: s.securitySectionSubtitle,
            children: [SecuritySection(vm: vm)],
          ),
          const SizedBox(height: 12),

          // 6. ERSCHEINUNGSBILD
          _buildExpansionSection(
            context: context,
            key: 'appearance',
            icon: Icons.palette_outlined,
            title: s.appearanceSectionTitle,
            subtitle: s.appearanceSectionSubtitle,
            children: [const AppearanceCard()],
          ),

          const SizedBox(height: 32),

          // SAVE BUTTON
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: vm.busy ? null : () => _handleSave(vm),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: vm.saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                vm.saving ? s.savingButton : s.saveChangesButton,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Logout
          OutlinedButton.icon(
            onPressed: () => _confirmLogout(vm),
            icon: Icon(Icons.logout, color: colors.error),
            label: Text(s.logoutButton, style: TextStyle(color: colors.error)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colors.error),
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionSection({
    required BuildContext context,
    required String key,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isExpanded = _expandedSections[key] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded
              ? colors.primary.withValues(alpha: 0.3)
              : colors.outline.withValues(alpha: 0.1),
        ),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedSections[key] = expanded;
            });
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isExpanded
                  ? colors.primary.withValues(alpha: 0.1)
                  : colors.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isExpanded ? colors.primary : theme.hintColor,
              size: 22,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isExpanded ? colors.primary : colors.onSurface,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: theme.hintColor),
          ),
          trailing: AnimatedRotation(
            turns: isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isExpanded ? colors.primary : theme.hintColor,
            ),
          ),
          children: children,
        ),
      ),
    );
  }

  // ===========================================================================
  // 2. WIZARD LAYOUT
  // ===========================================================================

  static const List<IconData> _stepIcons = [
    Icons.store,
    Icons.phone,
    Icons.local_shipping,
    Icons.schedule,
    Icons.check_circle,
  ];

  void _dismissKeyboard() {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.unfocus();
    }
  }

  Widget _buildWizardLayout(BuildContext context, SettingsViewModel vm) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;

    final stepTitles = [
      s.stepIdentity,
      s.stepContact,
      s.stepDelivery,
      s.stepHours,
      s.stepFinish,
    ];
    final totalSteps = stepTitles.length;

    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.setupStoreTitle),
          centerTitle: true,
          leading: _currentWizardStep > 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                )
              : null,
        ),
        body: Column(
          children: [
            // Step Indicator
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: colors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(totalSteps, (index) {
                  final isActive = index == _currentWizardStep;
                  final isCompleted = index < _currentWizardStep;
                  final stepColor = isActive
                      ? colors.primary
                      : isCompleted
                      ? colors.primary.withValues(alpha: 0.6)
                      : colors.onSurface.withValues(alpha: 0.3);

                  return Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive || isCompleted
                                ? stepColor.withValues(alpha: 0.15)
                                : Colors.transparent,
                            border: Border.all(color: stepColor, width: 2),
                          ),
                          child: Center(
                            child: isCompleted
                                ? Icon(Icons.check, size: 18, color: stepColor)
                                : Icon(
                                    _stepIcons[index],
                                    size: 16,
                                    color: stepColor,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stepTitles[index],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: stepColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            // Page Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (idx) =>
                    setState(() => _currentWizardStep = idx),
                children: [
                  // STEP 1: Identität
                  _buildWizardStep(
                    context: context,
                    icon: Icons.store_rounded,
                    iconColor: colors.primary,
                    title: s.step1Title,
                    subtitle: s.step1Subtitle,
                    child: Column(
                      children: [
                        SettingsHeader(vm: vm, compact: true),
                        const SizedBox(height: 24),
                        StoreInfoCard(
                          vm: vm,
                          hideDescription: true,
                          showWebsite: false,
                          showCreatedDate: false,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: vm.pageDescCtrl,
                          maxLines: 3,
                          textDirection: _getTextDirection(
                            vm.pageDescCtrl.text,
                          ),
                          onChanged: (_) =>
                              setState(() {}), // Rebuild für Richtungswechsel
                          decoration: InputDecoration(
                            labelText: s.shortDescriptionLabel,
                            hintText: '...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // STEP 2: Kontakt & Social
                  _buildWizardStep(
                    context: context,
                    icon: Icons.contact_phone_rounded,
                    iconColor: colors.secondary,
                    title: s.step2Title,
                    subtitle: s.step2Subtitle,
                    child: Column(
                      children: [
                        ContactSection(vm: vm),
                        const SizedBox(height: 24),
                        SocialLinksCard(vm: vm),
                      ],
                    ),
                  ),

                  // STEP 3: Lieferung
                  _buildWizardStep(
                    context: context,
                    icon: Icons.local_shipping_rounded,
                    iconColor: colors.tertiary,
                    title: s.step3Title,
                    subtitle: s.step3Subtitle,
                    isOptional: true,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colors.outline.withValues(alpha: 0.2),
                            ),
                          ),
                          child: SwitchListTile(
                            title: Text(
                              s.enableDeliveryLabel,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              vm.shippingEnabled
                                  ? s.deliveryEnabled
                                  : s.deliveryDisabled,
                              style: TextStyle(
                                color: theme.hintColor,
                                fontSize: 12,
                              ),
                            ),
                            value: vm.shippingEnabled,
                            // FIX: Veraltete activeColor entfernt, nimmt Theme Primary
                            onChanged: (v) => vm.toggleShipping(v),
                          ),
                        ),
                        if (vm.shippingEnabled) ...[
                          const SizedBox(height: 24),
                          TextField(
                            controller: vm.shippingPriceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: s.fixedDeliveryPriceLabel,
                              hintText: '0.00',
                              helperText: s.deliveryPriceHelper,
                              helperMaxLines: 2,
                              prefixIcon: const Icon(Icons.attach_money),
                              suffixText: vm.currencyCtrl.text,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: colors.surface,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // STEP 4: Öffnungszeiten
                  _buildWizardStep(
                    context: context,
                    icon: Icons.access_time_rounded,
                    iconColor: colors.primary, // Einheitlich zum Theme
                    title: s.step4Title,
                    subtitle: s.step4Subtitle,
                    isOptional: true,
                    child: WorkingHoursCard(vm: vm),
                  ),

                  // STEP 5: Abschluss
                  _buildWizardStep(
                    context: context,
                    icon: Icons.check_circle_outline_rounded,
                    iconColor:
                        colors.tertiary, // Erfolg / Abschluss Farbe aus Theme
                    title: s.step5Title,
                    subtitle: kIsWeb ? s.step5SubtitleWeb : s.step5Subtitle,
                    isOptional: false,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // KEY muss in ARB existieren
                        Text(
                          s.setupCompleteMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: colors.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Icon(
                          Icons.rocket_launch,
                          size: 60,
                          color: colors.primary.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    if (_currentWizardStep >= 2 &&
                        _currentWizardStep < (totalSteps - 1))
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: TextButton(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text(
                            s.skipButton,
                            style: TextStyle(
                              color: colors.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ),
                    const Spacer(),
                    if (_currentWizardStep < (totalSteps - 1))
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 24,
                          ),
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _validateAndProceed(vm),
                        icon: const Icon(Icons.arrow_forward, size: 20),
                        label: Text(
                          s.nextButton,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 24,
                          ),
                          backgroundColor: colors
                              .tertiary, // Nutze Tertiary für Abschluss/Erfolg
                          foregroundColor: colors.onTertiary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: vm.busy ? null : () => _finishWizard(vm),
                        icon: vm.busy
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check_circle, size: 20),
                        label: Text(
                          s.finishSetupButton,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWizardStep({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget child,
    bool isOptional = false,
  }) {
    final s = AppLocalizations.of(context)!;
    // Theme für Grau-Töne
    final hintColor = Theme.of(context).hintColor;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.1),
            ),
            child: Icon(icon, size: 32, color: iconColor),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isOptional) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: hintColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    s.optionalBadge,
                    style: TextStyle(fontSize: 10, color: hintColor),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: hintColor, fontSize: 14),
          ),
          const SizedBox(height: 32),
          child,
        ],
      ),
    );
  }

  void _validateAndProceed(SettingsViewModel vm) {
    _dismissKeyboard();
    final s = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    // Step 0: Identität
    if (_currentWizardStep == 0) {
      if (vm.storeNameCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.validationEnterStoreName),
            backgroundColor: colors.error,
          ),
        );
        return;
      }
    }
    // Step 1: Kontakt
    if (_currentWizardStep == 1) {
      if (vm.phoneCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.validationEnterPhone),
            backgroundColor: colors.error,
          ),
        );
        return;
      }
      if (vm.addressCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.validationEnterAddress),
            backgroundColor: colors.error,
          ),
        );
        return;
      }
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finishWizard(SettingsViewModel vm) async {
    _dismissKeyboard();
    final s = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final currentLocale = Localizations.localeOf(context).languageCode;

    // Speichern
    final success = await vm.save(
      s,
      checkPaywall: false,
      isFirstSetup: true,
      currentLocale: currentLocale,
    );

    // FIX: Context usage across async gap
    if (!mounted) return;

    if (success) {
      // Bei Erfolg: Gratulation + Link anzeigen
      await _showCongratulationsDialog(vm);
    } else if (vm.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage!),
          backgroundColor: colors.error,
        ),
      );
      vm.clearError();
    }
  }

  // Gratulations-Dialog mit Link
  Future<void> _showCongratulationsDialog(SettingsViewModel vm) async {
    final colors = Theme.of(context).colorScheme;
    final s = AppLocalizations.of(context)!;
    final storeUrl = vm.storeWebsiteCtrl.text.isNotEmpty
        ? vm.storeWebsiteCtrl.text
        : await ApiService.getPublicStoreUrl() ?? '';

    // FIX: Context usage across async gap
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [colors.primary, colors.tertiary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.celebration_rounded,
                size: 44,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              s.congratulationsTitle,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: colors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              s.storeReadyMsg,
              style: TextStyle(
                fontSize: 16,
                color: colors.onSurface.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (storeUrl.isNotEmpty)
              InkWell(
                onTap: () async {
                  final uri = Uri.parse(storeUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.link_rounded,
                            size: 18,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            s.yourStoreLinkLabel,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        storeUrl,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                          decoration: TextDecoration.underline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  // 1. Schließe den Dialog
                  Navigator.of(ctx).pop();

                  // 2. Nutze Future.microtask, um sicherzustellen, dass der Dialog
                  // vollständig aus dem Widget-Tree entfernt wurde, bevor die Navigation feuert
                  Future.microtask(() {
                    if (mounted) {
                      context.go('/home');
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(
                  s.goToHomeButton,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave(SettingsViewModel vm) async {
    final s = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final currentLocale = Localizations.localeOf(context).languageCode;

    // Capture messenger before async gap for extra safety
    final messenger = ScaffoldMessenger.of(context);

    final success = await vm.save(s, currentLocale: currentLocale);

    // FIX: Context usage across async gap
    if (!mounted) return;

    if (success) {
      messenger.showSnackBar(SnackBar(content: Text(s.saveSuccessMsg)));
      // Settings/Profil → Nach Home zurück (Index 0)
      context.go('/home');
    } else if (vm.hasError) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? s.saveErrorMsg),
          backgroundColor: colors.error,
        ),
      );
    }
  }

  Future<void> _confirmLogout(SettingsViewModel vm) async {
    final s = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.logoutButton),
        content: Text(s.logoutConfirmMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
            ),
            child: Text(s.logoutConfirmButton),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await vm.logout();
      // FIX: Context usage across async gap
      if (!mounted) return;
      context.go('/login');
    }
  }
}
