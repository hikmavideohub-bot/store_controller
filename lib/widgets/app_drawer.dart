import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../app_theme_mode.dart';
import '../core/access_manager.dart';
import '../main.dart';
import '../services/store_config_service.dart';

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

  bool _isActive(String route) => currentRoute == route;

  String _storeName() {
    final s = StoreConfigService.store; // Map? (wie bei dir im Projekt)
    final name = (s?['store_name'] ??
        s?['storeName'] ??
        s?['name'] ??
        s?['store'] ??
        '')
        .toString()
        .trim();

    if (name.isNotEmpty) return name;

    // Fallback (Arabisch UI)
    return 'متجرك';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      width: 280,
      backgroundColor: isDark ? AppTheme.surface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ===== Header =====
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.gold.withValues(alpha: 0.90),
                    AppTheme.gold2.withValues(alpha: 0.70),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo (asset fallback)
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.20),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(35),
                        child: Image.asset(
                          'assets/icon/wolf.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ✅ Store Name (dynamic)
                    Text(
                      _storeName(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),

                    // Subscription Badge
                    ListenableBuilder(
                      listenable: AccessManager(),
                      builder: (context, _) => _buildSubscriptionBadge(),
                    ),

                    const SizedBox(height: 4),

                    // Subtitle
                    Text(
                      headerSubtitle,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.90),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 20),
                children: [
                  // Subscription Card
                  ListenableBuilder(
                    listenable: AccessManager(),
                    builder: (context, _) => _buildSubscriptionInfoCard(context),
                  ),

                  const SizedBox(height: 8),

                  // Theme mode
                  ListTile(
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.gold.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.dark_mode_outlined,
                        color: AppTheme.muted,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'الوضع',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    trailing: DropdownButton<AppThemeMode>(
                      value: MyApp.themeOf(context) ?? AppThemeMode.system,
                      onChanged: (mode) {
                        if (mode != null) MyApp.setThemeOf(context, mode);
                      },
                      items: const [
                        DropdownMenuItem(
                          value: AppThemeMode.system,
                          child: Text('تلقائي', textDirection: TextDirection.rtl),
                        ),
                        DropdownMenuItem(
                          value: AppThemeMode.light,
                          child: Text('نهاري', textDirection: TextDirection.rtl),
                        ),
                        DropdownMenuItem(
                          value: AppThemeMode.dark,
                          child: Text('ليلي', textDirection: TextDirection.rtl),
                        ),
                      ],
                    ),
                  ),

                  _drawerItem(
                    context: context,
                    icon: Icons.home_outlined,
                    title: 'الرئيسية',
                    subtitle:
                    _isActive('/home') ? 'أنت هنا' : 'العودة للصفحة الرئيسية',
                    isActive: _isActive('/home'),
                    onTap: () {
                      Navigator.pop(context);
                      if (!_isActive('/home')) context.go('/home');
                    },
                  ),

                  _drawerItem(
                    context: context,
                    icon: Icons.inventory_2_outlined,
                    title: 'المنتجات',
                    subtitle: _isActive('/products')
                        ? 'أنت هنا'
                        : 'عرض وإدارة المنتجات',
                    isActive: _isActive('/products'),
                    onTap: () {
                      Navigator.pop(context);
                      if (!_isActive('/products')) context.go('/products');
                    },
                  ),

                  _drawerItem(
                    context: context,
                    icon: Icons.grid_view_rounded,
                    title: 'الفئات',
                    subtitle: _isActive('/categories')
                        ? 'أنت هنا'
                        : 'إدارة فئات المنتجات',
                    isActive: _isActive('/categories'),
                    onTap: () {
                      Navigator.pop(context);
                      if (!_isActive('/categories')) context.go('/categories');
                    },
                  ),

                  _drawerItem(
                    context: context,
                    icon: Icons.settings_outlined,
                    title: 'الإعدادات',
                    subtitle: 'إعدادات المتجر والمظهر',
                    isActive: _isActive('/settings'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/settings');
                    },
                  ),

                  const SizedBox(height: 8),
                  const Divider(height: 24, thickness: 0.5),

                  _drawerItem(
                    context: context,
                    icon: Icons.info_outline_rounded,
                    title: 'عن التطبيق',
                    subtitle: 'معلومات عن التطبيق والمطور',
                    onTap: () {
                      Navigator.pop(context);
                      _showAboutDialog(context);
                    },
                  ),

                  _drawerItem(
                    context: context,
                    icon: Icons.analytics_outlined,
                    title: 'إحصائيات متقدمة',
                    subtitle: 'تقارير وأداء المتجر',
                    onTap: () {
                      Navigator.pop(context);
                      _showAdvancedStats(context);
                    },
                  ),

                  _drawerItem(
                    context: context,
                    icon: Icons.sync_rounded,
                    title: 'مزامنة البيانات',
                    subtitle: 'تحديث كل المنتجات',
                    onTap: () async {
                      Navigator.pop(context);

                      if (onSync == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                              Text('لا توجد مزامنة في هذه الصفحة')),
                        );
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('جاري مزامنة البيانات...')),
                      );

                      await onSync!();
                    },
                  ),

                  _drawerItem(
                    context: context,
                    icon: Icons.star_border_rounded,
                    title: 'قيم التطبيق',
                    subtitle: 'شاركنا رأيك',
                    onTap: () {
                      Navigator.pop(context);
                      _rateApp(context);
                    },
                  ),

                  _drawerItem(
                    context: context,
                    icon: Icons.help_outline_rounded,
                    title: 'المساعدة والدعم',
                    subtitle: 'أسئلة شائعة واتصل بنا',
                    onTap: () {
                      Navigator.pop(context);
                      _showHelp(context);
                    },
                  ),

                  const Divider(height: 40, thickness: 0.5),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        Icon(Icons.phone_android_outlined,
                            size: 18, color: AppTheme.muted),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'الإصدار 2.1.0',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Logout
            Padding(
              padding: const EdgeInsets.all(20),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('تسجيل الخروج',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: BorderSide(
                      color: Colors.redAccent.withValues(alpha: 0.40)),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async => _logoutDefault(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Subscription Badge =====
  Widget _buildSubscriptionBadge() {
    if (!AccessManager.isLoaded) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'جاري التحميل...',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    switch (AccessManager.status) {
      case 'active':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_rounded, size: 14, color: Colors.white),
              SizedBox(width: 4),
              Text(
                'بريميوم',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );

      case 'trial':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timelapse_rounded,
                  size: 14, color: Colors.black),
              const SizedBox(width: 4),
              Text(
                AccessManager.daysRemaining != null
                    ? 'تجريبية (${AccessManager.daysRemaining} يوم)'
                    : 'تجريبية',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );

      case 'expired':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 14, color: Colors.white),
              SizedBox(width: 4),
              Text(
                'منتهية',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );

      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            AccessManager.status,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
    }
  }

  // ===== Subscription Info Card =====
  Widget _buildSubscriptionInfoCard(BuildContext context) {
    if (!AccessManager.isLoaded) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Expanded(child: Text('جاري تحميل معلومات الاشتراك...')),
          ],
        ),
      );
    }

    final status = AccessManager.status;
    final stage = AccessManager.stage;
    final daysRemaining = AccessManager.daysRemaining;

    if (status == 'active') return const SizedBox.shrink();

    Color cardColor;
    IconData cardIcon;
    String title;
    String subtitle;
    Color iconColor;

    if (status == 'trial') {
      cardColor = const Color(0xFFFFD700).withValues(alpha: 0.1);
      cardIcon = Icons.celebration_rounded;
      iconColor = const Color(0xFFB8860B);

      if (daysRemaining != null) {
        title = 'الفترة التجريبية';
        subtitle = 'متبقي $daysRemaining يوم';
      } else {
        title = 'الفترة التجريبية';
        subtitle = 'جرّب الميزات مجاناً';
      }
    } else if (status == 'expired') {
      cardColor = Colors.red.withValues(alpha: 0.1);
      cardIcon = Icons.error_outline_rounded;
      iconColor = Colors.red;

      switch (stage) {
        case 1:
          title = 'الفترة التجريبية انتهت';
          subtitle = 'تم إخفاء الأسعار والمقاسات';
          break;
        case 2:
          title = 'بعض المزايا متوقفة';
          subtitle = 'تم إخفاء الصور حالياً';
          break;
        default:
          title = 'المتجر غير نشط';
          subtitle = 'تم تقييد المزايا';
          break;
      }
    } else {
      cardColor = Colors.grey.withValues(alpha: 0.1);
      cardIcon = Icons.info_outline_rounded;
      iconColor = Colors.grey;
      title = 'حالة الاشتراك';
      subtitle = status;
    }

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        if (status != 'active') {
          context.push('/payment', extra: {
            'plan': 'premium_monthly',
            'returnUrl': currentRoute,
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: iconColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(cardIcon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 12,
                      color: iconColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            if (status != 'active')
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: iconColor),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    final iconColor = isActive ? AppTheme.gold : AppTheme.muted;
    final bg = isActive
        ? AppTheme.gold.withValues(alpha: 0.14)
        : AppTheme.gold.withValues(alpha: 0.08);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
          color: isActive
              ? AppTheme.gold
              : (Theme.of(context).textTheme.bodyLarge?.color),
        ),
      ),
      subtitle: Text(
        subtitle,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontSize: 12,
          color: isActive ? AppTheme.gold.withValues(alpha: 0.85) : AppTheme.muted,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('عن التطبيق'),
        content: const Text('هنا يمكنك وضع معلومات عن التطبيق والمطور.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('حسناً')),
        ],
      ),
    );
  }

  void _showAdvancedStats(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إحصائيات متقدمة'),
        content: const Text('هذه الصفحة قيد التطوير. سيتم تفعيلها قريباً.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('حسناً')),
        ],
      ),
    );
  }

  void _rateApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('قيم التطبيق'),
        content: const Text('ميزة التقييم قيد التطوير.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('حسناً')),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('المساعدة والدعم'),
        content: const Text('يمكنك إضافة FAQ / معلومات تواصل هنا.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('حسناً')),
        ],
      ),
    );
  }

  Future<void> _logoutDefault(BuildContext context) async {
    final router = GoRouter.of(context);

    final ok = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('خروج')),
        ],
      ),
    );

    if (ok != true) return;

    await ApiService.clearAuth();
    router.refresh();
    router.go('/login');
  }
}
