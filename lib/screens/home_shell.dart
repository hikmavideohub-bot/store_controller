import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:store_controller/screens/products.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';

import '../services/store_config_service.dart';
import '../services/api_service.dart';
import '../a2hs/a2hs.dart';
import 'home_screen.dart';
import 'categories.dart';
import 'package:store_controller/core/access_manager.dart';
import '../core/paywall_messages.dart';
import '../services/rating_prompt_service.dart';
import '../widgets/app_drawer.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  int _index = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _index);
    _initObserversAndBoot();
  }

  void _initObserversAndBoot() {
    WidgetsBinding.instance.addObserver(this);
    _boot();

    // Nutzung tracken für Bewertungs-Prompt
    RatingPromptService.incrementLaunchCount();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      A2HS.maybeShow(context);

      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        if (TrialWelcomeManager.shouldShow) {
          await showTrialWelcomePopup(context);
        } else {
          _checkExpirationAndShowDialog();
        }
      }

      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        final showRating = await RatingPromptService.shouldShowPrompt();
        if (showRating && mounted) AppDrawer.showAppRatingDialog(context);
      }
    });
  }

  void _checkExpirationAndShowDialog() {
    final days = AccessManager.daysRemaining;
    if (days == 7 || days == 3) {
      _showExpirationReminderDialog(days!);
    }
  }

  Future<void> _showExpirationReminderDialog(int days) async {
    if (!mounted) return;
    final colors = Theme.of(context).colorScheme;
    final s = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      barrierDismissible: false, // Zwingt den Nutzer zur Wahrnehmung
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titlePadding: const EdgeInsets.only(top: 24),
        title: Column(
          children: [
            // Finanz-Psychologie: Orange steht für Aufmerksamkeit, nicht für Gefahr (Rot)
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.orange.withValues(alpha: 0.1),
              child: const Icon(
                Icons.hourglass_bottom_rounded,
                color: Colors.orange,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              s.expirationAlertTitle,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              s.expirationAlertMsg(days),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurface.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            // Exklusiver Hinweis auf den Sparvorteil
            if (days <= 7)
              Text(
                "Tipp: Sparen Sie 20% mit dem Jahresabo", // Hierfür einen .arb Key nutzen
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          // Dezentere "Später"-Option
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.laterButton, style: TextStyle(color: colors.outline)),
          ),
          const SizedBox(width: 8),
          // Dominanter Call-to-Action (CTA)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              // Übergabe des Jahresabos als Standard-Empfehlung
              context.push(
                '/payment',
                extra: {'plan': 'premium_yearly', 'returnUrl': '/home'},
              );
            },
            child: Text(
              s.renewNowButton,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshWebsiteStatus();
      // Sitzung neu starten wenn App wieder aktiv
      RatingPromptService.startSession();
    } else if (state == AppLifecycleState.paused) {
      // Sitzungszeit speichern wenn App in Hintergrund geht
      RatingPromptService.endSession();
    }
  }

  Future<void> _refreshWebsiteStatus() async {
    final m = await ApiService.fetchWebsiteStatus();
    if (!mounted || m == null) return;
    final access = m['access'];
    if (access is Map) {
      AccessManager.updateFromApi(Map<String, dynamic>.from(access));
    }
    await StoreConfigService.mergeNonEmpty(m);
  }

  Future<void> _boot() async {
    await StoreConfigService.load();
    unawaited(ApiService.fetchProducts());
    unawaited(ApiService.fetchCategories());
    unawaited(_refreshWebsiteStatus());
  }

  Future<void> _openStoreWebsite() async {
    final s = StoreConfigService.store;
    final url = (s?['public_store_url'] ?? '').toString().trim();
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  late final List<Widget> pages = const [
    HomeScreen(),
    ProductsScreen(),
    CategoriesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;
    final active = colors.primary; // Teal
    final inactive = colors.onSurface.withValues(alpha: 0.4);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (idx) => setState(() => _index = idx),
              children: pages,
            ),
          ),
        ],
      ),
      floatingActionButton: ListenableBuilder(
        listenable: AccessManager(),
        builder: (context, _) {
          final enabled =
              AccessManager.isLoaded &&
              (AccessManager.isActive || AccessManager.isTrial);
          // Premium = Gold, Standard = Teal (Primary)
          // Wir nutzen hier Teal (Primary) für den FAB, weil es ruhig und standard ist (wie WhatsApp)
          final fabBaseColor = AccessManager.canWriteAdmin
              ? colors.primary
              : Colors.grey.shade400;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: enabled
                      ? fabBaseColor.withValues(alpha: 0.4)
                      : Colors.black.withValues(alpha: 0.1),
                  blurRadius: enabled ? 16 : 8,
                  spreadRadius: enabled ? 0.5 : 0,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              child: Ink(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  // Ruhiger Gradient in Teal (Primary) statt Gold
                  gradient: enabled
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colors.primary,
                            colors.primary.withValues(alpha: 0.8),
                          ],
                        )
                      : LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.grey.shade400, Colors.grey.shade600],
                        ),
                  border: enabled
                      ? Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 1.5,
                        )
                      : Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.0,
                        ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _onFabPressed,
                  child: Icon(
                    Icons.add_rounded,
                    size: 28,
                    color: enabled ? colors.onPrimary : Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 1.2,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        active.withValues(alpha: 0.1),
                        active.withValues(alpha: 0.8),
                        active.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
            BottomAppBar(
              height: 65,
              color: theme.scaffoldBackgroundColor,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: const CircularNotchedRectangle(),
              notchMargin: 8,
              child: Row(
                children: [
                  Expanded(
                    child: _buildElegantItem(
                      Icons.home_rounded,
                      s.navHome,
                      0,
                      active,
                      inactive,
                    ),
                  ),
                  Expanded(
                    child: _buildElegantItem(
                      Icons.inventory_2_rounded,
                      s.navProducts,
                      1,
                      active,
                      inactive,
                    ),
                  ),
                  const SizedBox(width: 70),
                  Expanded(
                    child: _buildElegantItem(
                      Icons.grid_view_rounded,
                      s.navCategories,
                      2,
                      active,
                      inactive,
                    ),
                  ),
                  Expanded(child: _buildWolfItem(active, inactive, s.navStore)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onFabPressed() async {
    final enabled =
        AccessManager.isLoaded &&
        (AccessManager.isActive || AccessManager.isTrial);

    // 1. Erst prüfen, ob der User überhaupt Schreibrechte hat (Premium/Admin)
    if (!enabled) {
      final msg = buildPaywallMessage(context, forFab: true);
      if (msg != null && mounted) {
        await _showFabPaywallDialog(context, msg);
      }
      return;
    }

    // 2. Alles gut -> Weiterleiten zum Hinzufügen (Limit-Check erfolgt in der Logik beim Speichern)
    unawaited(_refreshWebsiteStatus());
    if (mounted) context.push('/add');
  }

  Future<void> _showFabPaywallDialog(
    BuildContext context,
    PaywallMessage msg,
  ) async {
    // 1. Daten VOR dem async-Gap holen
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = colors.tertiary;
    final s = AppLocalizations.of(context)!;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(msg.icon ?? Icons.payment_rounded, size: 48, color: accent),
        title: Text(msg.title, textAlign: TextAlign.center),
        content: Text(msg.body, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.laterButton),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.black,
            ),
            child: Text(msg.ctaText ?? s.activateButton),
          ),
        ],
      ),
    );

    // 2. Der wichtigste Teil: Sicherstellen, dass wir noch im Baum sind
    if (result == true && context.mounted) {
      // Nutze context.mounted (ab Flutter 3.7 verfügbar) statt nur mounted
      context.push(
        '/payment',
        extra: {'plan': 'premium_yearly', 'returnUrl': '/home'},
      );
    }
  }

  void _goToPage(int idx) {
    _pageController.animateToPage(
      idx,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildElegantItem(
    IconData icon,
    String label,
    int idx,
    Color active,
    Color inactive,
  ) {
    final isSelected = _index == idx;
    return GestureDetector(
      onTap: () => _goToPage(idx),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? active.withValues(alpha: 0.08)
                  : Colors.transparent,
            ),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 500),
              scale: isSelected ? 1.12 : 1.0,
              curve: Curves.elasticOut,
              child: Icon(
                icon,
                size: 22,
                color: isSelected ? active : inactive,
              ),
            ),
          ),
          const SizedBox(height: 1),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? active : inactive,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWolfItem(Color active, Color inactive, String label) {
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: StoreConfigService.storeNotifier,
      builder: (context, s, _) {
        final connected = (s?['store_slug'] ?? '').toString().trim().isNotEmpty;
        return GestureDetector(
          onTap: connected ? _openStoreWebsite : null,
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: connected
                      ? active.withValues(alpha: 0.08)
                      : Colors.transparent,
                ),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 500),
                  scale: connected
                      ? 1.12
                      : 1.0, // Scale etwas erhöht wie bei den anderen Items
                  curve: Curves.elasticOut,
                  // NEU: Icon statt Image.asset
                  child: Icon(
                    Icons.public_rounded, // Oder Icons.language_rounded
                    size: 22,
                    color: connected ? active : inactive,
                  ),
                ),
              ),
              const SizedBox(height: 1),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    fontSize: 9,
                    fontWeight: connected ? FontWeight.w800 : FontWeight.w600,
                    color: connected ? active : inactive,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
