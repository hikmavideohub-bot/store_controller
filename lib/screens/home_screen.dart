import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import '../widgets/premium_app_bar.dart';
import '../widgets/app_drawer.dart';
import '../viewmodels/home_viewmodel.dart';
import '../models/product.dart';
import '../services/store_config_service.dart';
import 'package:store_controller/widgets/responsive_center.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent();

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;

    if (vm.loading) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: PremiumAnimatedAppBar(
          title: s.homeTitle,
          onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        body: Center(child: CircularProgressIndicator(color: colors.primary)),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        currentRoute: '/home',
        headerSubtitle: s.dashboardTitle,
        onSync: () => vm.syncAllData(s),
      ),
      appBar: PremiumAnimatedAppBar(
        title: s.dashboardTitle,
        showSettings: false,
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
        body: ResponsiveCenter(
          maxWidth: 1300,
          child: RefreshIndicator(
          onRefresh: () => vm.syncAllData(s),
        color: colors.primary,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            140 + MediaQuery.of(context).viewPadding.bottom,
          ),
          children: [
            _buildHeader(context, s),
            const SizedBox(height: 24),

            // 1. STATISTIKEN ZUERST
            _sectionHeader(context, s.liveStatsTitle),
            _buildStatisticsGrid(context, vm, s),

            const SizedBox(height: 24),

            // 2. KUNDENNACHRICHT
            _buildCustomerMessagePreview(context, vm, s),

            const SizedBox(height: 16),

            // 3. STORE LINK
            _buildStoreLinkCard(context, vm, s),
          ],
        ),
      ),
        ),
    );

  }

  Widget _buildHeader(BuildContext context, AppLocalizations s) {
    // ✅ ValueListenableBuilder für sofortige Updates bei Store-Name-Änderungen
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: StoreConfigService.storeNotifier,
      builder: (context, _, __) {
        final displayName = StoreConfigService.storeName.isNotEmpty
            ? StoreConfigService.storeName
            : s.defaultStoreName;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.welcomeStoreName(displayName),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              s.dashboardSubtitle,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStoreLinkCard(
    BuildContext context,
    HomeViewModel vm,
    AppLocalizations s,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final url = vm.publicStoreUrl ?? s.noLinkYet;

    return _PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.link_rounded,
                  color: colors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                s.publicStoreLink,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    url,
                    style: TextStyle(
                      fontSize: 13,
                      color: vm.publicStoreUrl != null
                          ? colors.primary
                          : theme.hintColor,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (vm.publicStoreUrl != null) ...[
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    onPressed: () async {
                      final ok = await vm.copyToClipboard(url);
                      if (ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(s.copyLinkSuccess),
                            backgroundColor: colors.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    tooltip: s.copyLinkSuccess,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  IconButton(
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    onPressed: () => vm.openExternalUrl(url),
                    tooltip: s.viewProductsAction,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: vm.publicStoreUrl != null
                  ? () => vm.shareStore(s)
                  : null,
              icon: const Icon(Icons.share_rounded, size: 18),
              label: Text(s.shareStoreInvite),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerMessagePreview(
      BuildContext context,
      HomeViewModel vm,
      AppLocalizations s,
      ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Hole den aktuellen Sprachcode der App (z.B. 'de', 'ar', 'en')
    final langCode = Localizations.localeOf(context).languageCode;
    final msg = vm.getLocalizedCustomerMessage(langCode);
    final hasMsg = msg.isNotEmpty;

    return GestureDetector(
      // HIER IST DER FIX: await push -> dann refreshMessage
      onTap: () async {
        await context.push('/customer-message');
        vm.refreshMessage(); // Aktualisiert sofort wenn du zurückkommst
      },
      child: _PremiumCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.campaign_rounded, color: colors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.customerMessageTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasMsg ? msg : s.customerMessagePlaceholder,
                    style: TextStyle(
                      fontSize: 12,
                      color: hasMsg ? colors.onSurface : theme.hintColor,
                      fontStyle: hasMsg ? FontStyle.normal : FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: theme.hintColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  void _showProductsByFilter(
    BuildContext context,
    String title,
    List<Product> list,
    AppLocalizations s,
  ) {
    if (list.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.noProductsFoundTitle(title)),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            _FilteredProductsScreen(title: title, products: list),
      ),
    );
  }

  void _showCategoriesWithOffers(
    BuildContext context,
    HomeViewModel vm,
    AppLocalizations s,
  ) {
    final cats = vm.categoriesWithFullOffersList;
    if (cats.isEmpty) return;

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = colors.tertiary;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final currentCats = vm.categoriesWithFullOffersList;
          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              20 + MediaQuery.of(ctx).viewPadding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.categoryOffersTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            s.categoryOffersSubtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (currentCats.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        s.noCategoryOffers,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...currentCats.map(
                    (cat) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.2),
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          final products = vm.getProductsByCategory(cat);
                          Navigator.pop(context);
                          _showProductsByFilter(
                            context,
                            s.filterCategoryPrefix(cat),
                            products,
                            s,
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.category_rounded,
                                color: accent,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  cat,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (dctx) => AlertDialog(
                                      title: Text(s.stopOfferAction),
                                      content: Text(s.stopCategoryOfferConfirm),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(dctx, false),
                                          child: Text(s.cancelButton),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(dctx, true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: Text(s.stopOfferAction),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm != true) return;

                                  final success = await vm
                                      .disableOffersForCategory(s, cat);
                                  if (ctx.mounted) {
                                    if (success) {
                                      setSheetState(() {});
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            s.categoryOffersDisabledMsg(cat),
                                          ),
                                          backgroundColor: Colors.green,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            s.categoryOffersDisableFail,
                                          ),
                                          backgroundColor: Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(
                                  Icons.power_settings_new_rounded,
                                  size: 18,
                                ),
                                label: Text(s.stopOfferAction),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticsGrid(
    BuildContext context,
    HomeViewModel vm,
    AppLocalizations s,
  ) {
    final colors = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive Anpassung: max 3 Spalten auf Handys, mehr auf Tablets/Desktop
    int crossAxisCount = 3;
    if (screenWidth >= 600 && screenWidth < 900) {
      crossAxisCount = 4; // kleine Tablets
    } else if (screenWidth >= 900) {
      crossAxisCount = 6; // große Tablets / Desktop
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9, // leicht angepasst für bessere Optik
      ),
      itemCount: 7,
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return _StatCard(
              title: s.statsTotalProducts,
              value: '${vm.totalProducts}',
              icon: Icons.inventory_2_rounded,
              iconColor: colors.primary,
              onTap: () => _showProductsByFilter(
                context,
                s.filterAllProducts,
                vm.products,
                s,
              ),
            );
          case 1:
            return _StatCard(
              title: s.statsAvailable,
              value: '${vm.activeProducts}',
              icon: Icons.check_circle_rounded,
              iconColor: Colors.green,
              onTap: () => _showProductsByFilter(
                context,
                s.filterAvailable,
                vm.getActiveProducts(),
                s,
              ),
            );
          case 2:
            return _StatCard(
              title: s.statsUnavailable,
              value: '${vm.inactiveProducts}',
              icon: Icons.pause_circle_rounded,
              iconColor: Colors.orange,
              onTap: () => _showProductsByFilter(
                context,
                s.filterUnavailable,
                vm.getInactiveProducts(),
                s,
              ),
            );
          case 3:
            return _StatCard(
              title: s.statsOffers,
              value: '${vm.productsWithOffer}',
              icon: Icons.local_offer_rounded,
              iconColor: Colors.purple,
              onTap: () => _showProductsByFilter(
                context,
                s.filterActiveOffers,
                vm.getProductsWithOffer(),
                s,
              ),
            );
          case 4:
            return _StatCard(
              title: s.statsCategoryOffers,
              value: '${vm.categoriesWithFullOffers}',
              icon: Icons.bolt_rounded,
              iconColor: Colors.deepOrange,
              onTap: vm.categoriesWithFullOffers > 0
                  ? () => _showCategoriesWithOffers(context, vm, s)
                  : null,
            );
          case 5:
            return _StatCard(
              title: s.statsNoImage,
              value: '${vm.productsWithoutImage}',
              icon: Icons.no_photography_rounded,
              iconColor: Colors.blueGrey,
              onTap: () => _showProductsByFilter(
                context,
                s.filterNoImage,
                vm.getProductsWithoutImage(),
                s,
              ),
            );
        }
        return null;
      },
    );
  }
}

class _PremiumCard extends StatelessWidget {
  final Widget child;

  const _PremiumCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colors.outline.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.3 : 0.1,
                ),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(height: 10),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.hintColor,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilteredProductsScreen extends StatelessWidget {
  final String title;
  final List<Product> products;

  const _FilteredProductsScreen({required this.title, required this.products});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: PremiumAnimatedAppBar(
        title: title,
        showBackButton: true,
        showSettings: false,
      ),
        body: ResponsiveCenter(
          maxWidth: 1000,
          child: ListView.builder(

          padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final p = products[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: p.image.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          p.image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.image_not_supported),
                        ),
                      )
                    : const Icon(Icons.image_not_supported),
              ),
              title: Text(
                p.name,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(
                '${p.price} € / ${p.sizeValue} ${p.sizeUnit}',
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () => context.push('/edit/${p.id}', extra: p),
            ),
          );
        },
      ),
        ),
    );
  }
}
