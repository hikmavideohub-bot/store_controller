import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import '../services/api_service.dart';
import '../services/helpful_info_service.dart';
import '../app_theme_mode.dart';
import '../core/access_manager.dart';
import '../main.dart';
import '../services/store_config_service.dart';
import '../services/rating_prompt_service.dart';
import '../services/version_service.dart';
import '../repositories/pricing_repository.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;
  final String headerSubtitle;
  final Future<void> Function()? onSync;

  const AppDrawer({
    super.key,
    required this.currentRoute,
    required this.headerSubtitle,
    this.onSync,
  });

  // --- Logik-Methoden ---

  static String _storeName(AppLocalizations s) {
    final name = StoreConfigService.storeName;
    if (name.isNotEmpty) return name;
    return s.drawerStoreFallback;
  }

  String? _storeLogoUrl() {
    final s = StoreConfigService.store;
    final logo = (s?['has_logo'] ?? s?['hasLogo'] ?? '').toString().trim();
    if (logo.isNotEmpty && logo.startsWith('http')) return logo;
    return null;
  }

  Widget _buildLogo(ColorScheme colors, String storeName) {
    final logoUrl = _storeLogoUrl();

    if (logoUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: CachedNetworkImage(
          imageUrl: logoUrl,
          fit: BoxFit.cover,
          width: 60,
          height: 60,
          placeholder: (_, __) => _buildInitials(colors, storeName),
          errorWidget: (_, __, ___) => _buildInitials(colors, storeName),
        ),
      );
    }
    return _buildInitials(colors, storeName);
  }

  Widget _buildInitials(ColorScheme colors, String name) {
    final displayName = name.isNotEmpty ? name : 'Store';

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              displayName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  static String _storeId() {
    final s = StoreConfigService.store;
    return (s?['id'] ?? s?['store_id'] ?? 'unknown').toString();
  }

  static String _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  static Future<void> _sendSupportEmail(BuildContext context) async {
    final s = AppLocalizations.of(context)!;
    final name = _storeName(s);
    final id = _storeId();

    const supportMail = 'contact.aldeebtech@gmail.com';

    final uri = Uri(
      scheme: 'mailto',
      path: supportMail,
      query: _encodeQueryParameters({
        'subject': s.supportEmailSubject(name, id),
        'body': s.supportEmailBody(name, id),
      }),
    );

    try {
      final ok = await launchUrl(uri, mode: LaunchMode.platformDefault);
      if (!ok) {
        await Clipboard.setData(const ClipboardData(text: supportMail));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Keine Mail-App gefunden. Email kopiert: $supportMail')),
        );
      }
    } catch (e) {
      await Clipboard.setData(const ClipboardData(text: supportMail));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mail konnte nicht geöffnet werden. Email kopiert: $supportMail')),
      );
    }
  }


  // --- UI Dialoge ---

  static void showSupportDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;

    // syriaPhone einmal am Anfang laden
    final syriaPhone = await _getSyriaContactPhone();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: colors.surface,
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.support_agent_rounded,
                color: colors.onPrimaryContainer,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  s.supportCenterTitle,
                  style: TextStyle(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch, // Buttons über volle Breite
          children: [
            Text(
              s.supportCenterMsg,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            // --- EMAIL BUTTON ---
            FilledButton.icon(
              icon: const Icon(Icons.forward_to_inbox_rounded, size: 22),
              label: Text(
                s.contactEmailLabel,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                await _sendSupportEmail(context);
              },
            ),

            // --- WHATSAPP BUTTON (Nur wenn Nummer vorhanden) ---
            if (syriaPhone != null && syriaPhone.isNotEmpty) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                icon: const Icon(Icons.wechat, size: 22),
                label: Text(
                  s.contactWhatsAppLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  // Typische WhatsApp Farben für einen schönen Kontrast
                  backgroundColor: const Color(0xFF25D366).withValues(alpha: 0.15),
                  foregroundColor: const Color(0xFF1DA851),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: const Color(0xFF25D366).withValues(alpha: 0.3),
                      )
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _openWhatsApp(syriaPhone, context);
                },
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        actions: [
          // Einfacher Schließen-Button unten rechts
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              s.closeButton, // Schließen
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<String?> _getSyriaContactPhone() async {
    try {
      final pricingRepo = PricingRepository();
      final config = await pricingRepo.fetchSubscriptionConfig();
      return config.syriaContactPhone;
    } catch (e) {
      debugPrint('Fehler beim Laden der Syria Contact Phone: $e');
      return null;
    }
  }

  static Future<void> _openWhatsApp(String phone, BuildContext context) async {
    final s = AppLocalizations.of(context)!;
    // WhatsApp URL Format: https://wa.me/phone_without_plus_or_spaces
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final url = Uri.parse('https://wa.me/$cleanPhone');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: Kopiere Nummer in Zwischenablage
        await Clipboard.setData(ClipboardData(text: phone));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            // ✅ HIER: String-Interpolation statt dem '+' Operator
            SnackBar(content: Text('${s.whatsappNotAvailable} $phone')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          // ✅ Hier zur Sicherheit auch als direkter String
          SnackBar(content: Text('${s.whatsappError}')),
        );
      }
    }
  }

  // --- Build Methode ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;

    return Drawer(
      width: 300,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(0)),
      ),
      child: Column(
        children: [
          // 1. Verbesserter Header (Side-by-Side)
          _buildModernHeader(context),

          // 2. Scrollbarer Listen-Inhalt
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              children: [
                ListenableBuilder(
                  listenable: AccessManager(),
                  builder: (context, _) => _buildSubscriptionInfoCard(context),
                ),

                const SizedBox(height: 8),

                _drawerItem(
                  context: context,
                  icon: Icons.person_outline_rounded,
                  title: s.drawerProfile,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/settings');
                  },
                  isActive: currentRoute == '/settings',
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: colors.outlineVariant,
                  ),
                ),

                // Theme Mode Selector
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: Icon(
                      Icons.dark_mode_outlined,
                      color: colors.onSurfaceVariant,
                      size: 24,
                    ),
                    title: Text(
                      s.drawerTheme,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<AppThemeMode>(
                          value: MyApp.themeOf(context) ?? AppThemeMode.system,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: colors.onSurfaceVariant,
                          ),
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          dropdownColor: colors.surfaceContainer,
                          onChanged: (mode) {
                            if (mode != null) MyApp.setThemeOf(context, mode);
                          },
                          items: [
                            DropdownMenuItem(
                              value: AppThemeMode.system,
                              child: Text(s.themeSystem),
                            ),
                            DropdownMenuItem(
                              value: AppThemeMode.light,
                              child: Text(s.themeLight),
                            ),
                            DropdownMenuItem(
                              value: AppThemeMode.dark,
                              child: Text(s.themeDark),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: colors.outlineVariant,
                  ),
                ),

                _drawerItem(
                  context: context,
                  icon: Icons.support_agent_rounded,
                  title: s.drawerSupport,
                  onTap: () async {
                    Navigator.pop(context);
                    final rootCtx = Navigator.of(context, rootNavigator: true).context;
                    showSupportDialog(rootCtx);
                  },
                ),

                _drawerItem(
                  context: context,
                  icon: Icons.analytics_outlined,
                  title: s.drawerAdvancedStats,
                  onTap: () {
                    Navigator.pop(context);
                    _showAdvancedStats(context);
                  },
                ),

                _drawerItem(
                  context: context,
                  icon: Icons.lightbulb_outline_rounded,
                  title: s.drawerHelpfulInfo,
                  onTap: () {
                    Navigator.pop(context);
                    _showHelpfulInfoSheet(context);
                  },
                ),

                _drawerItem(
                  context: context,
                  icon: Icons.info_outline_rounded,
                  title: s.drawerAbout,
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                ),

                // Dynamisches Rating-Item basierend auf Bewertungs-Status
                FutureBuilder<bool>(
                  future: RatingPromptService.hasAlreadyRated(),
                  builder: (context, snapshot) {
                    final hasRated = snapshot.data ?? false;
                    
                    return _drawerItem(
                      context: context,
                      icon: hasRated 
                          ? Icons.star_rounded 
                          : Icons.star_border_rounded,
                      title: hasRated 
                          ? (s.updateRating)
                          : s.drawerRate,
                      onTap: () {
                        Navigator.pop(context);
                        showAppRatingDialog(context);
                      },
                    );
                  },
                ),

                const SizedBox(height: 24),

                Center(
                  child: Text(
                    s.versionLabel(VersionService.version),
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.outline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // 3. Logout Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: FilledButton.tonalIcon(
              icon: Icon(Icons.logout_rounded, size: 18, color: colors.error),
              label: Text(
                s.logoutButton,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: colors.error,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: colors.errorContainer.withValues(alpha: 0.5),
                foregroundColor: colors.onErrorContainer,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () async => _logoutDefault(context),
            ),
          ),
        ],
      ),
    );
  }

  // --- Header Implementation (Updated) ---

  Widget _buildModernHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        context.push('/settings');
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 20,
          bottom: 24,
          left: 20,
          right: 20,
        ),
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Deko-Hintergrund
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: colors.onPrimary.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Zeile: Text und Logo nebeneinander
                // ValueListenableBuilder: reagiert sofort auf Store-Änderungen
                ValueListenableBuilder<Map<String, dynamic>?>(
                  valueListenable: StoreConfigService.storeNotifier,
                  builder: (context, _, __) {
                    final storeName = _storeName(s);

                    // Im App Drawer: Store-Name IMMER neben Logo anzeigen
                    // (show_name_with_logo ist nur für die öffentliche Webseite)
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Text Bereich (Nimmt restlichen Platz ein)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                storeName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colors.onPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                headerSubtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.onPrimary.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Logo Container (Squircle)
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _buildLogo(colors, storeName),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),

                // 2. Zeile: Status Badge (unter dem Text/Logo Bereich)
                ListenableBuilder(
                  listenable: AccessManager(),
                  builder: (context, _) => _buildModernBadge(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernBadge(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final s = AppLocalizations.of(context)!;

    if (!AccessManager.isLoaded) {
      return _badgeContainer(
        context,
        s.loadingStatus,
        colors.surface.withValues(alpha: 0.2),
        colors.onPrimary,
      );
    }

    switch (AccessManager.status) {
      case 'active':
        return GestureDetector(
          onTap: () {
            Navigator.pop(context);
            context.push('/subscription');
          },
          child: _badgeContainer(
            context,
            s.premiumStatus,
            colors.tertiaryContainer,
            colors.onTertiaryContainer,
          ),
        );
      case 'trial':
        return GestureDetector(
          onTap: () {
            Navigator.pop(context);
            context.push('/subscription');
          },
          child: _badgeContainer(
            context,
            AccessManager.daysRemaining != null
                ? s.trialStatusDays(AccessManager.daysRemaining!)
                : s.trialStatus,
            colors.secondaryContainer,
            colors.onSecondaryContainer,
          ),
        );
      default:
        return GestureDetector(
          onTap: () {
            Navigator.pop(context);
            context.push('/subscription');
          },
          child: _badgeContainer(
            context,
            s.expiredStatus,
            colors.errorContainer,
            colors.onErrorContainer,
          ),
        );
    }
  }

  Widget _badgeContainer(
    BuildContext context,
    String text,
    Color bg,
    Color fg,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20), // Runderer Badge
        border: Border.all(color: fg.withValues(alpha: 0.1)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSubscriptionInfoCard(BuildContext context) {
    if (!AccessManager.isLoaded) return const SizedBox.shrink();
    final status = AccessManager.status;
    if (status == 'active') return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    final s = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        context.push(
          '/payment',
          extra: {'plan': 'premium_monthly', 'returnUrl': currentRoute},
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.tertiaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.tertiary.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                s.upgradeBannerText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colors.onTertiaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.star_rounded, color: colors.tertiary),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? colors.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(
          icon,
          color: isActive ? colors.onPrimaryContainer : colors.onSurfaceVariant,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            color: isActive ? colors.onPrimaryContainer : colors.onSurface,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  // --- Helpful Info BottomSheet ---

  void _showHelpfulInfoSheet(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;
    final langCode = Localizations.localeOf(context).languageCode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => FutureBuilder<List<String>>(
          future: HelpfulInfoService().getInfo(langCode),
          builder: (context, snapshot) {
            return Column(
              children: [
                // Handle
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Titel
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        color: colors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        s.drawerHelpfulInfo,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: colors.outlineVariant),
                // Inhalt
                Expanded(
                  child: _buildHelpfulInfoContent(
                    snapshot,
                    scrollController,
                    colors,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHelpfulInfoContent(
    AsyncSnapshot<List<String>> snapshot,
    ScrollController scrollController,
    ColorScheme colors,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    final items = snapshot.data ?? [];
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Icon(
            Icons.info_outline_rounded,
            size: 48,
            color: colors.outlineVariant,
          ),
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final text = items[index];
        // Trenne Titel (vor dem ':') und Beschreibung (nach dem ':')
        final colonIndex = text.indexOf(':');
        final hasTitle = colonIndex > 0 && colonIndex < 60;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: hasTitle
                    ? RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${text.substring(0, colonIndex)}:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: colors.onSurface,
                                height: 1.5,
                              ),
                            ),
                            TextSpan(
                              text: text.substring(colonIndex + 1),
                              style: TextStyle(
                                fontSize: 14,
                                color: colors.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Text(
                        text,
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Andere Dialoge (Identisch) ---

  void _showAboutDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        // Icon, Name und Version zentriert oben
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: colors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset('assets/icon/wolf.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Aldeeb', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              VersionService.version,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        // Der Beschreibungstext
        content: Text(s.aboutAppDesc, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () {
              // Use dialog context (ctx) for showLicensePage, not the parent context
              Navigator.pop(ctx);
              showLicensePage(
                context: ctx,
                applicationName: 'Aldeeb',
                applicationVersion: VersionService.fullVersion,
                applicationIcon: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset('assets/icon/wolf.png', width: 48),
                ),
              );
            },
            child: Text(s.licensesButton),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.closeButton),
          ),
        ],
      ),
    );
  }

  void _showAdvancedStats(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.advancedStatsTitle),
        content: Text(s.advancedStatsMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.okButton),
          ),
        ],
      ),
    );
  }

  static void showAppRatingDialog(BuildContext context) async {
    // Prüfen ob der Nutzer bereits bewertet hat
    final hasRated = await RatingPromptService.hasAlreadyRated();
    
    if (hasRated) {
      await _showAlreadyRatedDialog(context);
    } else {
      await _showRatingDialog(context);
    }
  }

  static Future<void> _showAlreadyRatedDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        title: Row(
          children: [
            Icon(
              Icons.star_rounded,
              color: Colors.amber,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                s.alreadyRatedTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.visible,
                maxLines: 2,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.alreadyRatedMsg,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: colors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s.alreadyRatedHint ,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              s.cancelButton,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.store_rounded, size: 18),
            label: Text(s.goToPlayStore ),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final url = Uri.parse(
                'https://play.google.com/store/apps/details?id=com.aldeebtech.storecontroller',
              );
              if (await canLaunchUrl(url)) {
                await launchUrl(
                  url,
                  mode: LaunchMode.externalApplication,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  static Future<void> _showRatingDialog(BuildContext context) async {
    int selectedStars = 0;
    final commentCtrl = TextEditingController();

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          scrollable: true,
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: Text(
            s.rateAppTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                s.rateAppMsg,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              FittedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starValue = index + 1;
                    return IconButton(
                      icon: Icon(
                        starValue <= selectedStars
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: Colors.amber,
                        size: 40,
                      ),
                      onPressed: () =>
                          setState(() => selectedStars = starValue),
                    );
                  }),
                ),
              ),
              if (selectedStars > 0 && selectedStars <= 3) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: commentCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: s.rateAppHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: colors.surfaceContainerHighest,
                  ),
                ),
              ],
              if (selectedStars >= 4) ...[
                const SizedBox(height: 16),
                Text(
                  s.rateAppGooglePlayMsg,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(ctx);
                await RatingPromptService.markAsDone();
                navigator.pop();
              },
              child: Text(s.laterButton),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: selectedStars == 0
                  ? null
                  : () async {
                      final stars = selectedStars;
                      final comment = commentCtrl.text;
                      // Capture messenger and message BEFORE closing dialog to avoid deactivated widget error
                      final messenger = ScaffoldMessenger.of(context);
                      final thanksMsg = s.ratingThanksMsg;
                      Navigator.pop(ctx);

                      await RatingPromptService.markAsDone();

                      await ApiService.submitAppReview(
                        stars: stars,
                        comment: comment,
                      );

                      if (stars >= 4) {
                        final url = Uri.parse(
                          'https://play.google.com/store/apps/details?id=com.aldeebtech.storecontroller',
                        );
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      } else {
                        messenger.showSnackBar(
                          SnackBar(content: Text(thanksMsg)),
                        );
                      }
                    },
              child: Text(s.sendButton),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logoutDefault(BuildContext context) async {
    final router = GoRouter.of(context);
    final s = AppLocalizations.of(context)!;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.logoutConfirmTitle),
        content: Text(s.logoutConfirmMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.logoutButton),
          ),
        ],
      ),
    );

    if (ok == true) {
      await ApiService.clearAuth();
      router.refresh();
      router.go('/login');
    }
  }
}
