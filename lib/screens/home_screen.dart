import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/premium_app_bar.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import '../services/store_config_service.dart';
import '../theme.dart'; // ✅ Korrekte Import-Syntax
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  List<Product> _products = [];
  bool _hasInternet = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool silent = false}) async {
    final cached = ApiService.cachedProducts;
    if (!silent && cached != null && cached.isNotEmpty) {
      setState(() {
        _products = cached;
        _loading = false;
        _hasInternet = true;
      });
    } else if (!silent) {
      setState(() => _loading = true);
    }

    try {
      await ApiService.init();
      await StoreConfigService.load(allowNetworkIfEmpty: true);
      final data = await ApiService.fetchProducts();
      if (!mounted) return;
      setState(() {
        _products = data.isNotEmpty ? data : _products;
        _hasInternet = true;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasInternet = false;
        _loading = false;
      });
    }
  }

  // ==============================
  // DRAWER (Kebab-Menü)
  // ==============================





  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('عن التطبيق'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: AppTheme.gold.withValues(alpha: 0.1),
                ),
                child: Image.asset('assets/icon/wolf.png'),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Al-Deeb Store Controller',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'تطبيق متكامل لإدارة متجرك بكل سهولة و احترافية. يمكنك إدارة المنتجات، الفئات، العروض والمزيد.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'المطور: Al-Deeb Team\nالإصدار: 2.1.0',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _showAdvancedStats(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة الإحصائيات المتقدمة في التحديث القادم')),
    );
  }

  Future<void> _syncAllData() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري مزامنة البيانات...')),
    );
    await _load(silent: false);
  }

  void _rateApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('قيم التطبيق'),
        content: const Text('هل ترغب في تقييم التطبيق في متجر التطبيقات؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لاحقاً'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('شكراً لك على دعمك!')),
              );
            },
            child: const Text('تقييم'),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('المساعدة والدعم'),
        content: const Text(
          'للحصول على المساعدة:\n\n'
              '• support@aldeeb.com\n'
              '• +123 456 7890\n'
              '• FAQ متاحة على الموقع\n\n'
              'ساعات العمل: 9 صباحاً - 6 مساءً',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هذه الوظيفة قيد التطوير. سيتم تفعيلها قريباً.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  // ==============================
  // STATISTIKEN & UI-ELEMENTE
  // ==============================

  Widget _buildElegantDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppTheme.gold.withValues(alpha: isDark ? 0.2 : 0.1),
            AppTheme.gold.withValues(alpha: isDark ? 0.4 : 0.2),
            AppTheme.gold.withValues(alpha: isDark ? 0.2 : 0.1),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    String? subValue,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.gold.withValues(alpha: 0.12), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.gold).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: iconColor ?? AppTheme.gold),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subValue != null) ...[
              const SizedBox(height: 2),
              Text(
                subValue,
                style: TextStyle(
                  fontSize: 9,
                  color: AppTheme.gold.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid(BuildContext context) {
    final total = _products.length;
    final activeItems = _products.where((p) => p.productActive).length;
    final inactiveItems = total - activeItems;
    final withOffer = _products.where((p) => p.hasOffer && p.offerActive).length;
    final noImage = _products.where((p) => p.image.trim().isEmpty).length;

    final catCount = <String, int>{};
    for (final p in _products) {
      final c = p.category.trim();
      if (c.isEmpty) continue;
      catCount[c] = (catCount[c] ?? 0) + 1;
    }

    String topCat = '-';
    int topCatN = 0;
    catCount.forEach((k, v) {
      if (v > topCatN) { topCat = k; topCatN = v; }
    });

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.85,
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        _statCard(
          title: 'المنتجات',
          value: '$total',
          icon: Icons.inventory_2_rounded,
          onTap: () => context.push('/products'),
          iconColor: AppTheme.gold,
        ),
        _statCard(
          title: 'نشط',
          value: '$activeItems',
          icon: Icons.check_circle_outline_rounded,
          onTap: () => _showProductsByFilter(
              context,
              'نشط',
              _products.where((p) => p.productActive).toList()
          ),
          iconColor: Colors.green,
        ),
        _statCard(
          title: 'غير نشط',
          value: '$inactiveItems',
          icon: Icons.pause_circle_outline_rounded,
          onTap: () => _showProductsByFilter(
              context,
              'غير نشط',
              _products.where((p) => !p.productActive).toList()
          ),
          iconColor: Colors.orange,
        ),
        _statCard(
          title: 'عروض',
          value: '$withOffer',
          icon: Icons.local_offer_outlined,
          onTap: () => _showProductsByFilter(
              context,
              'عروض',
              _products.where((p) => p.hasOffer && p.offerActive).toList()
          ),
          iconColor: Colors.purple,
        ),
        _statCard(
          title: 'بدون صورة',
          value: '$noImage',
          icon: Icons.no_photography_outlined,
          onTap: () => _showProductsByFilter(
              context,
              'بدون صورة',
              _products.where((p) => p.image.trim().isEmpty).toList()
          ),
          iconColor: Colors.blueGrey,
        ),
        _statCard(
          title: 'أكبر فئة',
          value: topCat.length > 6 ? '${topCat.substring(0, 6)}...' : topCat,
          icon: Icons.auto_awesome_motion_rounded,
          subValue: topCatN > 0 ? '$topCatN منتج' : '',
          onTap: topCat != '-' ? () => _showProductsByFilter(
              context,
              'فئة: $topCat',
              _products.where((p) => p.category.trim() == topCat).toList()
          ) : () {},
          iconColor: Colors.teal,
        ),
      ],
    );
  }

  Widget _section(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _quickActionButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.gold.withValues(alpha: 0.12), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (color ?? AppTheme.gold).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color ?? AppTheme.gold, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductsByFilter(BuildContext context, String filterTitle, List<Product> filteredProducts) {
    if (filteredProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا توجد منتجات في $filterTitle'),
          backgroundColor: AppTheme.gold,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: PremiumAnimatedAppBar(
            title: filterTitle,
            showBackButton: true,
            showSettings: false,
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  leading: product.image.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      product.image,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, error, stackTrace) => Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppTheme.surface2,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.image_not_supported, color: AppTheme.muted),
                      ),
                    ),
                  )
                      : Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.surface2,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.image_not_supported, color: AppTheme.muted),
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${product.price} € / ${product.sizeValue} ${product.sizeUnit}',
                    style: TextStyle(color: AppTheme.muted, fontSize: 12),
                  ),
                  trailing: Icon(
                    product.productActive ? Icons.check_circle : Icons.cancel,
                    color: product.productActive ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  onTap: () => context.push('/edit/${product.id}', extra: product),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ==============================
  // MAIN BUILD METHOD
  // ==============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        currentRoute: '/home',
        headerSubtitle: 'لوحة التحكم',
        onSync: () async => _syncAllData(),
      ),
      appBar: PremiumAnimatedAppBar(
        title: 'الرئيسية',
        showSettings: false,
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      body: _loading
          ? const Center(
        child: CircularProgressIndicator(
          color: AppTheme.gold,
          strokeWidth: 2.5,
        ),
      )
          : RefreshIndicator(
        color: AppTheme.gold,
        backgroundColor: Theme.of(context).colorScheme.surface,
        onRefresh: () => _load(silent: true),
        child: _buildHomeContent(context),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Willkommensnachricht
        _buildWelcomeMessage(),

        _buildElegantDivider(context),
        const SizedBox(height: 16),

        _section('إحصائيات المتجر', context),
        const SizedBox(height: 12),

        _buildStatisticsGrid(context),

        const SizedBox(height: 24),
        _buildElegantDivider(context),
        const SizedBox(height: 20),

        _section('إجراءات سريعة', context),
        const SizedBox(height: 12),

        Column(
          children: [
            _quickActionButton(
              title: 'رسالة إلى العملاء',
              icon: Icons.campaign_outlined,
              onTap: () => context.push('/customer-message'),
              color: Colors.teal,
            ),


            const SizedBox(height: 10),
            _quickActionButton(
              title: 'تصفح المنتجات',
              icon: Icons.storefront_rounded,
              onTap: () => context.push('/products'),
            ),
            const SizedBox(height: 10),
            _quickActionButton(
              title: 'إدارة الفئات',
              icon: Icons.grid_view_outlined,
              onTap: () => context.push('/categories'),
            ),
            const SizedBox(height: 10),
            _quickActionButton(
              title: 'عرض الموقع',
              icon: Icons.public_rounded,
              onTap: () {
                final s = StoreConfigService.store;
                final websiteUrl = (s?['store_website'] ?? '').toString().trim();
                if (websiteUrl.isNotEmpty) {
                  // Hier später URL öffnen Logic einfügen
                }
              },
              color: Colors.blue,
            ),
          ],
        ),

        SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 16),
      ],
    );
  }

  Widget _buildWelcomeMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً بك!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'إدارة متجرك أصبحت أسهل',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.gold.withValues(alpha: 0.2)),
                ),
                child: Text(
                  '${_products.length} منتج',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.gold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}