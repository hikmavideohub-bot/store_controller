import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:store_controller/screens/products.dart';
import '../services/store_config_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../a2hs/a2hs.dart';
import 'home_screen.dart';
import 'categories.dart';
import 'package:store_controller/core/access_manager.dart';
import '../core/paywall_messages.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _boot();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      A2HS.maybeShow(context);

      // Trial Welcome Popup nach kurzer Verzögerung
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted && TrialWelcomeManager.shouldShow) {
        // 🟢 WICHTIG: Direkter Aufruf der freistehenden Funktion
        await showTrialWelcomePopup(context);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshWebsiteStatus();
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
    unawaited(_refreshWebsiteStatus()); // holt auch access + updated AccessManager
  }

  Future<void> _openStoreWebsite() async {
    final s = StoreConfigService.store;

    final url = (s?['public_store_url'] ?? '').toString().trim();

    if (url.isEmpty) return;

    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  late final List<Widget> pages = const [
    HomeScreen(),
    ProductsScreen(),
    CategoriesScreen(),
  ];






  // Optional: Erweiterte FAB-Farben basierend auf Status
  Color _getFabColor() {
    if (!AccessManager.isLoaded) return Colors.grey.shade400;
    return AccessManager.canWriteAdmin
        ? const Color(0xFFFFD700)
        : Colors.grey.shade400;
  }

  bool get _fabEnabled =>
      AccessManager.isLoaded && AccessManager.canWriteAdmin;
  

  Future<void> _onFabPressed() async {
    // Wenn wir es sicher wissen (Access geladen) und keine Schreibrechte: Paywall zeigen
    if (AccessManager.isLoaded && !AccessManager.canWriteAdmin) {
      final msg = buildPaywallMessage(forFab: true);
      if (msg?.ctaText != null) {
        await _showFabPaywallDialog(context, msg!);
      } else {
        await showFabPaywallDialog(context);
      }
      return;
    }

    // Status leise im Hintergrund aktualisieren (ohne den Klick zu blockieren)
    unawaited(_refreshWebsiteStatus());

    // Direkt navigieren
    context.push('/add');
  }



  Future<void> _showFabPaywallDialog(BuildContext context, PaywallMessage msg) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        icon: Icon(
          msg.icon ?? Icons.payment_rounded,
          size: 48,
          color: msg.iconColor ?? const Color(0xFFFFD700),
        ),
        title: Text(msg.title, textAlign: TextAlign.right),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(msg.body, textAlign: TextAlign.right),
              if (msg.showFeatures) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                _buildFeaturesList(),
              ],
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لاحقاً'),
          ),
          if (msg.ctaText != null)
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: msg.iconColor ?? const Color(0xFFFFD700),
                foregroundColor: Colors.white,
              ),
              child: Text(msg.ctaText!),
            ),
        ],
      ),
    );

    // ✅ Fix: BuildContext nach await nur verwenden, wenn noch gemounted
    if (!context.mounted) return;

    if (result == true) {
      context.push('/payment', extra: {
        'plan': 'premium_monthly',
        'returnUrl': '/home',
      });
    }
  }


  Widget _buildFeaturesList() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('بالتفعيل تحصل على:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        ListTile(
          leading: Icon(Icons.check_circle, color: Colors.green),
          title: Text('إضافة منتجات جديدة'),
          dense: true,
        ),
        ListTile(
          leading: Icon(Icons.check_circle, color: Colors.green),
          title: Text('تعديل المنتجات الحالية'),
          dense: true,
        ),
        ListTile(
          leading: Icon(Icons.check_circle, color: Colors.green),
          title: Text('إدارة الطلبات'),
          dense: true,
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final active = Theme.of(context).colorScheme.primary;
    final inactive = Theme.of(context).colorScheme.onSurface.withValues(alpha:0.4);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _index,
              children: pages,
            ),
          ),
        ],
      ),

      // Dein Floating Action Button mit ListenableBuilder
      floatingActionButton: ListenableBuilder(
        listenable: AccessManager(),
        builder: (context, _) {
          final enabled = _fabEnabled;
          final fabColor = _getFabColor();

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), // Abgerundete Ecken
              boxShadow: [
                BoxShadow(
                  color: enabled
                      ? fabColor.withValues(alpha:0.3)
                      : Colors.black.withValues(alpha:0.1),
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
                width: 56, // Kleiner
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), // Quadrat mit abgerundeten Ecken
                  gradient: enabled
                      ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFB8860B), // Gold-Töne
                      Color(0xFFFFD740),
                    ],
                  )
                      : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.grey.shade400,
                      Colors.grey.shade600,
                    ],
                  ),
                  border: enabled
                      ? Border.all(
                    color: Colors.white.withValues(alpha:0.6),
                    width: 1.5,
                  )
                      : Border.all(
                    color: Colors.white.withValues(alpha:0.3),
                    width: 1.0,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _onFabPressed,
                  splashColor: enabled
                      ? Colors.amber.withValues(alpha:0.2)
                      : Colors.grey.withValues(alpha:0.2),
                  child: Icon(
                    Icons.add_rounded,
                    size: 28, // Kleineres Icon
                    color: enabled ? Colors.black : Colors.white,
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
                        active.withValues(alpha:0.1),
                        active.withValues(alpha:0.8),
                        active.withValues(alpha:0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
            BottomAppBar(
              height: 65,
              color: Theme.of(context).scaffoldBackgroundColor,
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
                      'الرئيسية',
                      0,
                      active,
                      inactive,
                    ),
                  ),
                  Expanded(
                    child: _buildElegantItem(
                      Icons.inventory_2_rounded,
                      'المنتجات',
                      1,
                      active,
                      inactive,
                    ),
                  ),
                  const SizedBox(width: 70),
                  Expanded(
                    child: _buildElegantItem(
                      Icons.grid_view_rounded,
                      'الفئات',
                      2,
                      active,
                      inactive,
                    ),
                  ),
                  Expanded(child: _buildWolfItem(active, inactive)),
                ],
              ),
            )
          ],
        ),
      ),
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
      onTap: () => setState(() => _index = idx),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? active.withValues(alpha:0.08) : Colors.transparent,
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: active.withValues(alpha:0.05),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ]
                  : [],
            ),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 500),
              scale: isSelected ? 1.12 : 1.0,
              curve: Curves.elasticOut,
              child: Icon(icon, size: 22, color: isSelected ? active : inactive),
            ),
          ),
          const SizedBox(height: 1),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              softWrap: false,
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

  Widget _buildWolfItem(Color active, Color inactive) {
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: StoreConfigService.storeNotifier,
      builder: (context, s, _) {
        final connected =
            (s?['store_slug'] ?? '').toString().trim().isNotEmpty;

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
                  color: connected ? active.withValues(alpha:0.08) : Colors.transparent,
                  boxShadow: connected
                      ? [
                    BoxShadow(
                      color: active.withValues(alpha:0.05),
                      blurRadius: 12,
                      spreadRadius: 1,
                    )
                  ]
                      : [],
                ),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 500),
                  scale: connected ? 1.08 : 1.0,
                  curve: Curves.easeOutBack,
                  child: Image.asset(
                    'assets/icon/wolf.png',
                    width: 24,
                    height: 24,
                    color: connected ? active : inactive,
                  ),
                ),
              ),
              const SizedBox(height: 1),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'الموقع',
                  maxLines: 1,
                  softWrap: false,
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
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