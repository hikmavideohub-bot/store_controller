import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme.dart';
import '../services/api_service.dart';
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
            // ===== Header (wie HomeDrawer) =====
            Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.gold.withValues(alpha: 0.90),
                    AppTheme.gold2.withValues(alpha: 0.70),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                    const Text(
                      'Al-Deeb Store',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      headerSubtitle,
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
                  // ===== Navigation (wie Products/Categories Drawer) =====
                  _drawerItem(
                    context: context,
                    icon: Icons.home_outlined,
                    title: 'الرئيسية',
                    subtitle: _isActive('/home') ? 'أنت هنا' : 'العودة للصفحة الرئيسية',
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
                    subtitle: _isActive('/products') ? 'أنت هنا' : 'عرض وإدارة المنتجات',
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
                    subtitle: _isActive('/categories') ? 'أنت هنا' : 'إدارة فئات المنتجات',
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

                  // ===== Extra-Funktionen (wie HomeDrawer) =====
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
                          const SnackBar(content: Text('لا توجد مزامنة في هذه الصفحة')),
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

                  // ===== Version (wie HomeDrawer) =====
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        Icon(Icons.phone_android_outlined, size: 18, color: AppTheme.muted),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'الإصدار 2.1.0',
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

            // ===== Logout (aktiv) =====
            Padding(
              padding: const EdgeInsets.all(20),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('تسجيل الخروج', style: TextStyle(fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.40)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  await _logoutDefault(context);
                },

              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Drawer Item (einheitlich, wie bei dir) =====
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
        style: TextStyle(
          fontSize: 15,
          fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
          color: isActive ? AppTheme.gold : (Theme.of(context).textTheme.bodyLarge?.color),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isActive
              ? AppTheme.gold.withValues(alpha: 0.85)
              : AppTheme.muted,
        ),
      ),
      onTap: onTap,
    );
  }

  // ===== Dialogs / Placeholders (wie HomeDrawer) =====
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('عن التطبيق'),
        content: const Text('هنا يمكنك وضع معلومات عن التطبيق والمطور.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسناً')),
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسناً')),
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسناً')),
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسناً')),
        ],
      ),
    );
  }

  void _snack(BuildContext context, String msg, {required bool isError}) {
    final m = ScaffoldMessenger.of(context);
    m.hideCurrentSnackBar();
    m.showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError
            ? Colors.redAccent.withValues(alpha: 0.85)
            : Colors.black.withValues(alpha: 0.85),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ===== Default Logout (dein aktiver Logout) =====
  Future<void> _logoutDefault(BuildContext context) async {
    final router = GoRouter.of(context);

    final ok = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('خروج')),
        ],
      ),
    );

    if (ok != true) return;

    // ✅ Logout = nur Auth löschen
    await ApiService.clearAuth();

    // ✅ Router/Redirect neu prüfen und zu Login
    router.refresh();
    router.go('/login');
  }





}
