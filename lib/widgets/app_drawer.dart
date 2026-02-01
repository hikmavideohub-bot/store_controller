import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import '../services/api_service.dart';
import '../app_theme_mode.dart';
import '../core/access_manager.dart';
import '../main.dart';
import '../services/store_config_service.dart';
import '../services/rating_prompt_service.dart';
import '../services/version_service.dart';

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
    final store = StoreConfigService.store;
    final name =
        (store?['store_name'] ??
                store?['storeName'] ??
                store?['name'] ??
                store?['store'] ??
                '')
            .toString()
            .trim();

    if (name.isNotEmpty) return name;
    return s.drawerStoreFallback;
  }

  String _storeLogo() {
    final s = StoreConfigService.store;
    final logo = (s?['has_logo'] ?? s?['hasLogo'] ?? '').toString().trim();
    if (logo.isNotEmpty) return logo;
    return '🏪';
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

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'contact.aldeebtech@gmail.com',
      query: _encodeQueryParameters({
        'subject': s.supportEmailSubject(name, id),
        'body': s.supportEmailBody(name, id),
      }),
    );

    try {
      if (!await launchUrl(
        emailLaunchUri,
        mode: LaunchMode.externalApplication,
      )) {
        throw 'Could not launch email app';
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
    }
  }

  // --- UI Dialoge ---

  static void showSupportDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;

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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              s.supportCenterMsg,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              s.contactEmailLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'contact.aldeebtech@gmail.com',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.copy_rounded,
                      size: 20,
                      color: colors.primary,
                    ),
                    onPressed: () {
                      Clipboard.setData(
                        const ClipboardData(
                          text: 'contact.aldeebtech@gmail.com',
                        ),
                      );
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(s.emailCopiedMsg)));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              s.closeButton,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.send_rounded, size: 18),
            label: Text(s.sendNowButton),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _sendSupportEmail(context);
            },
          ),
        ],
      ),
    );
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
                  onTap: () {
                    Navigator.pop(context);
                    showSupportDialog(context);
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
                  icon: Icons.info_outline_rounded,
                  title: s.drawerAbout,
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                ),

                _drawerItem(
                  context: context,
                  icon: Icons.star_border_rounded,
                  title: s.drawerRate,
                  onTap: () {
                    Navigator.pop(context);
                    showAppRatingDialog(context);
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Text Bereich (Nimmt restlichen Platz ein)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _storeName(s),
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
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _storeLogo(),
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                    ),
                  ],
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

  static void showAppRatingDialog(BuildContext context) {
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
