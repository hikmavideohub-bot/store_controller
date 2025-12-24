import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:store_controller/screens/products.dart';
import '../services/store_config_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

import 'home_screen.dart';
import 'categories.dart';

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
    await StoreConfigService.mergeNonEmpty(m);
  }

  Future<void> _boot() async {
    await ApiService.init();
    await StoreConfigService.load();
    ApiService.fetchProducts();
    ApiService.fetchCategories();
    ApiService.fetchWebsiteStatus().then((m) {
      if (m == null) return;
      StoreConfigService.mergeNonEmpty(m);
    });
  }

  Future<void> _openStoreWebsite() async {
    final s = StoreConfigService.store;
    final websiteUrl = (s?['store_website'] ?? '').toString().trim();
    if (websiteUrl.isEmpty) return;
    final uri = Uri.tryParse(websiteUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomeScreen(),
      const ProductsScreen(),
      const CategoriesScreen(),
    ];

    final active = Theme.of(context).colorScheme.primary;
    final inactive = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: pages[_index],
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: active.withValues(alpha: 0.3),
              blurRadius: 25,
              spreadRadius: 1,
            ),
          ],
        ),
        child: FloatingActionButton(
          elevation: 4,
          highlightElevation: 0,
          onPressed: () => context.push('/add'),
          child: const Icon(Icons.add_rounded, size: 30),
        ),
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
              height: 65, // Relativ niedrig für Items mit Text + Scale
              color: Theme.of(context).scaffoldBackgroundColor,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 8), // Etwas Seitenabstand hilft gegen Überlappen am Rand
              shape: const CircularNotchedRectangle(),
              notchMargin: 8, // Etwas reduziert für 65px Höhe
              child: Row(
                children: [
                  Expanded(child: _buildElegantItem(Icons.home_rounded, 'الرئيسية', 0, active, inactive)),
                  Expanded(child: _buildElegantItem(Icons.inventory_2_rounded, 'المنتجات', 1, active, inactive)),

                  const SizedBox(width: 70), // Platz für den FAB

                  Expanded(child: _buildElegantItem(Icons.grid_view_rounded, 'الفئات', 2, active, inactive)),
                  Expanded(child: _buildWolfItem(active, inactive)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildElegantItem(IconData icon, String label, int idx, Color active, Color inactive) {
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
              color: isSelected ? active.withValues(alpha: 0.08) : Colors.transparent,
              boxShadow: isSelected
                  ? [BoxShadow(color: active.withValues(alpha: 0.05), blurRadius: 10, spreadRadius: 2)]
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
            (s?['website_active'] == true || s?['website_active']?.toString() == 'true') &&
                (s?['store_website'] ?? '').toString().trim().isNotEmpty;

        return GestureDetector(
          onTap: connected ? _openStoreWebsite : null,
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisSize: MainAxisSize.min, // ✅ wichtig gegen Overflow/Overlaps
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: connected ? active.withValues(alpha: 0.08) : Colors.transparent,
                  boxShadow: connected
                      ? [BoxShadow(color: active.withValues(alpha: 0.05), blurRadius: 12, spreadRadius: 1)]
                      : [],
                ),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 500),
                  scale: connected ? 1.08 : 1.0, // 🔽 minimal weniger als vorher
                  curve: Curves.easeOutBack,
                  child: Image.asset(
                    'assets/icon/wolf.png',
                    width: 24,  // 🔽 26 -> 24
                    height: 24, // 🔽 26 -> 24
                    color: connected ? active : inactive,
                  ),
                ),
              ),
              const SizedBox(height: 1), // 🔽 4 -> 1
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'الموقع',
                  maxLines: 1,
                  softWrap: false,
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    fontSize: 9, // 🔽 10 -> 9
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