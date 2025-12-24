import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../widgets/premium_app_bar.dart';
import '../widgets/app_drawer.dart';
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late List<Product> _products;
  bool _busy = false;
  bool _loading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _products = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reload(silent: true);
    });
  }

  Future<bool> _confirmDeleteCategorySwipe(String name) async {
    final ctx = _scaffoldKey.currentContext;
    if (ctx == null) return false;

    return await showDialog<bool>(
      context: ctx,
      builder: (dctx) => AlertDialog(
        title: const Text('حذف الفئة'),
        content: Text('هل تريد حذف "$name" ؟ سيتم نقل المنتجات إلى "اخرى".'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dctx, false), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(dctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    ) ??
        false;
  }

  Future<void> _reload({bool silent = false}) async {
    bool showedCache = false;

    final cached = ApiService.cachedProducts;
    if (cached != null && cached.isNotEmpty) {
      showedCache = true;
      if (!mounted) return;
      setState(() {
        _products = cached;
        _loading = false;
        _busy = false;
      });
    } else {
      if (!silent) {
        if (!mounted) return;
        setState(() {
          _busy = true;
          _loading = true;
        });
      }
    }

    try {
      await ApiService.init();
      final data = await ApiService.fetchProducts();
      if (!mounted) return;
      setState(() {
        _products = data;
        _loading = false;
        _busy = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _busy = false;
      });

      if (!showedCache && _products.isEmpty) {
        final ctx = _scaffoldKey.currentContext;
        if (ctx == null) return;

        final messenger = ScaffoldMessenger.of(ctx);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: const Text('تعذر تحميل الفئات'),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      }
    }
  }


  Map<String, int> _counts() {
    final map = <String, int>{};
    for (final p in _products) {
      final c = p.category.trim();
      if (c.isEmpty) continue;
      map[c] = (map[c] ?? 0) + 1;
    }
    return map;
  }

  Future<String?> _askText({
    required String title,
    required String label,
    String initial = '',
  }) async {
    final ctrl = TextEditingController(text: initial);
    final BuildContext context = _scaffoldKey.currentContext!;

    return await showDialog<String>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Dialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: label,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.gold, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('إلغاء'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.gold,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('حفظ'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _renameCategory(String oldName) async {
    final newName = await _askText(
      title: 'تعديل الفئة',
      label: 'اسم الفئة الجديد',
      initial: oldName,
    );
    if (newName == null || newName == oldName) return;

    setState(() => _busy = true);
    try {
      final ok = await ApiService.renameCategory(oldName, newName);
      if (!mounted) return;

      if (ok) {
        await _reload(silent: true);
        if (mounted) {
          final messenger = ScaffoldMessenger.of(_scaffoldKey.currentContext!);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: const Text('تم تعديل الفئة بنجاح'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          final messenger = ScaffoldMessenger.of(_scaffoldKey.currentContext!);
          messenger.showSnackBar(
            SnackBar(
              content: const Text('فشل تعديل الفئة'),
              backgroundColor: AppTheme.danger,
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        final messenger = ScaffoldMessenger.of(_scaffoldKey.currentContext!);
        messenger.showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء تعديل الفئة')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteCategory(String name) async {
    const moveTo = 'اخرى';
    final BuildContext context = _scaffoldKey.currentContext!;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Dialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 40,
                ),
                const SizedBox(height: 16),
                Text(
                  'حذف الفئة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'سيتم نقل كل المنتجات من "$name" إلى "$moveTo". هل أنت متأكد؟',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withAlpha(150),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('إلغاء'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('حذف'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (ok != true) return;

    setState(() => _busy = true);

    try {
      final success = await ApiService.deleteCategory(name, moveToCategory: moveTo);
      if (!mounted) return;

      if (success) {
        await _reload(silent: true);
        if (mounted) {
          final messenger = ScaffoldMessenger.of(_scaffoldKey.currentContext!);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: const Text('تم حذف الفئة بنجاح'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          final messenger = ScaffoldMessenger.of(_scaffoldKey.currentContext!);
          messenger.showSnackBar(
            SnackBar(
              content: const Text('فشل حذف الفئة'),
              backgroundColor: AppTheme.danger,
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        final messenger = ScaffoldMessenger.of(_scaffoldKey.currentContext!);
        messenger.showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء حذف الفئة')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _openCategoryProducts(String category) {
    final items = _products
        .where((p) => p.category.trim() == category.trim())
        .toList();

    Navigator.push(
      _scaffoldKey.currentContext!,
      MaterialPageRoute(
        builder: (context) => CategoryProductsScreen(
          category: category,
          products: items,
        ),
      ),
    );
  }





  Widget _buildCategoryCard(String category, int count, int index) {
    final theme = Theme.of(_scaffoldKey.currentContext!);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Dismissible(
        key: ValueKey('cat_$category'),
        direction: _busy ? DismissDirection.none : DismissDirection.horizontal,

        // --- HINTERGRUND RECHTS (DELETE) ---
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red.withAlpha(25),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerLeft,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.delete_sweep_rounded, color: Colors.red, size: 28),
              Text('حذف', style: theme.textTheme.labelSmall?.copyWith(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
        ),

        // --- HINTERGRUND LINKS (EDIT) ---
        secondaryBackground: Container(
          decoration: BoxDecoration(
            color: AppTheme.gold.withAlpha(25),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerRight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mode_edit_outline_rounded, color: AppTheme.gold, size: 28),
              Text('تعديل', style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.gold, fontWeight: FontWeight.bold)),
            ],
          ),
        ),

        confirmDismiss: (direction) async {
          if (_busy) return false;
          if (direction == DismissDirection.startToEnd) {
            final ok = await _confirmDeleteCategorySwipe(category);
            if (ok) await _deleteCategory(category);
            return false;
          }
          if (direction == DismissDirection.endToStart) {
            await _renameCategory(category);
            return false;
          }
          return false;
        },

        // --- DIE KARTE ---
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.outline.withAlpha(40), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 50 : 15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _openCategoryProducts(category),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Icon-Container mit sanftem Gradient-Effekt
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.gold.withAlpha(40), AppTheme.gold.withAlpha(10)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.grid_view_rounded, color: AppTheme.gold, size: 26),
                    ),
                    const SizedBox(width: 16),

                    // Text-Bereich
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.black.withAlpha(10),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$count منتج',
                              style: TextStyle(fontSize: 12, color: AppTheme.muted, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action Buttons in kompakter Form
                    if (!_busy)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildActionCircle(
                            icon: Icons.edit_rounded,
                            color: AppTheme.gold,
                            onTap: () => _renameCategory(category),
                          ),
                          const SizedBox(width: 8),
                          _buildActionCircle(
                            icon: Icons.delete_outline_rounded,
                            color: Colors.redAccent,
                            onTap: () => _deleteCategory(category),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

// Hilfs-Widget für die kleinen runden Buttons auf der Karte
  Widget _buildActionCircle({required IconData icon, required Color color, required VoidCallback onTap}) {
    return Material(
      color: color.withAlpha(20),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    final counts = _counts();
    final cats = counts.keys.toList()..sort();

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        currentRoute: '/categories',
        headerSubtitle: 'إدارة الفئات',
        onSync: () async => _reload(silent: false),
      ),
      appBar: PremiumAnimatedAppBar(
        title: 'الفئات',
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
        onRefresh: () => _reload(silent: true),
        child: Stack(
          children: [
            ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                // إحصائيات سريعة
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.gold.withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.gold.withAlpha(100)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.grid_view_rounded, size: 16, color: AppTheme.gold),
                            const SizedBox(width: 6),
                            Text(
                              '${cats.length} فئة',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.surface2,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.outline),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.inventory_2_rounded, size: 16, color: AppTheme.muted),
                            const SizedBox(width: 6),
                            Text(
                              '${_products.length} منتج',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // زر إضافة فئة

                // قائمة الفئات
                if (cats.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.grid_view_rounded,
                          size: 60,
                          color: AppTheme.muted.withAlpha(100),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'لا توجد فئات بعد',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'قم بإضافة فئات جديدة لتنظيم منتجاتك',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.muted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ...List.generate(cats.length, (index) {
                    final category = cats[index];
                    final count = counts[category] ?? 0;
                    return _buildCategoryCard(category, count, index);
                  }),

                SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 20),
              ],
            ),

            if (_busy)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withAlpha(30),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.gold,
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CategoryProductsScreen extends StatelessWidget {
  final String category;
  final List<Product> products;

  const CategoryProductsScreen({
    super.key,
    required this.category,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PremiumAnimatedAppBar(
        title: category,
        showBackButton: true,
        showSettings: false,
      ),
      body: products.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 60,
              color: AppTheme.muted.withAlpha(100),
            ),
            const SizedBox(height: 20),
            const Text(
              'لا توجد منتجات في هذه الفئة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'يمكنك إضافة منتجات جديدة من الشاشة الرئيسية',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.muted,
              ),
            ),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final p = products[index];
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppTheme.outline, width: 1),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: p.image.isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  p.image,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, error, stackTrace) => Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.surface2,
                      borderRadius: BorderRadius.circular(12),
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.image_not_supported, color: AppTheme.muted),
              ),
              title: Text(
                p.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${p.price} € / ${p.sizeValue} ${p.sizeUnit}',
                style: TextStyle(color: AppTheme.muted, fontSize: 12),
              ),
              trailing: Icon(
                p.productActive ? Icons.check_circle : Icons.cancel,
                color: p.productActive ? Colors.green : Colors.red,
                size: 20,
              ),
              onTap: () => context.push('/edit/${p.id}', extra: p),
            ),
          );
        },
      ),
    );
  }
}