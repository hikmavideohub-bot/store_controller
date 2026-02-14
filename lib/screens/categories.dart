import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'package:go_router/go_router.dart';
import '../config.dart';
import '../services/store_config_service.dart';
import '../widgets/premium_app_bar.dart';
import '../widgets/app_drawer.dart';
import '../core/access_manager.dart';
import '../core/paywall_messages.dart';

class _CommaFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final sanitized = newValue.text.replaceAll(RegExp(r'[^0-9,]'), '');
    if (sanitized.startsWith(',')) return oldValue;
    if (sanitized.split(',').length > 2) return oldValue;
    return TextEditingValue(
      text: sanitized,
      selection: TextSelection.collapsed(offset: sanitized.length),
    );
  }
}

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

  bool get _canWrite => AccessManager.canWriteAdmin;

  Future<bool> _checkWriteAccess() async {
    if (_canWrite) return true;
    final ctx = _scaffoldKey.currentContext;
    if (ctx != null) {
      await showFabPaywallDialog(ctx);
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _products = [];
    ApiService.productsNotifier.addListener(_onProductsChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reload(silent: true);
    });
  }

  @override
  void dispose() {
    ApiService.productsNotifier.removeListener(_onProductsChanged);
    super.dispose();
  }

  void _onProductsChanged() {
    if (!mounted) return;
    final updated = ApiService.productsNotifier.value;
    if (updated.isNotEmpty) {
      setState(() => _products = updated);
    }
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
        if (!mounted) return;

        final messenger = ScaffoldMessenger.of(context);
        final colors = Theme.of(context).colorScheme;
        final s = AppLocalizations.of(context)!;

        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text(s.categoriesLoadError),
            backgroundColor: colors.error,
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
    final s = AppLocalizations.of(context)!;

    return await showDialog<String>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colors = theme.colorScheme;

        return Dialog(
          backgroundColor: colors.surface,
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
                      borderSide: BorderSide(color: colors.primary, width: 2),
      ),
      ),
      ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(s.cancel),
      ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
      ),
      ),
                      child: Text(s.save),
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
    // Capture context and all context-dependent values BEFORE async
    final ctx = _scaffoldKey.currentContext;
    if (ctx == null) return;
    final s = AppLocalizations.of(ctx)!;
    final errorColor = Theme.of(ctx).colorScheme.error;
    final messenger = ScaffoldMessenger.of(ctx);

    if (!await _checkWriteAccess()) return;
    if (!mounted || !ctx.mounted) return;

    final newName = await _askText(
      title: s.categoryRenameTitle,
      label: s.categoryRenameLabel,
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
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text(s.categoryRenameSuccess),
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
          messenger.showSnackBar(
            SnackBar(
              content: Text(s.categoryRenameFail),
              backgroundColor: errorColor,
      ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(s.categoryRenameError)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteCategory(String name) async {
    // Capture context and all context-dependent values BEFORE async
    final ctx = _scaffoldKey.currentContext;
    if (ctx == null) return;
    final s = AppLocalizations.of(ctx)!;
    final errorColor = Theme.of(ctx).colorScheme.error;
    final messenger = ScaffoldMessenger.of(ctx);
    const moveTo = 'اخرى';

    if (!await _checkWriteAccess()) return;
    if (!mounted || !ctx.mounted) return;

    final ok = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) {
        final theme = Theme.of(dialogCtx);
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
                  s.deleteCategoryTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
      ),
      ),
                const SizedBox(height: 12),
                Text(
                  s.deleteCategoryConfirmMsg(name, moveTo),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogCtx, false),
                      child: Text(s.cancel),
      ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogCtx, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
      ),
      ),
                      child: Text(s.delete),
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
      final success = await ApiService.deleteCategory(
        name,
        moveToCategory: moveTo,
      );
      if (!mounted) return;

      if (success) {
        await _reload(silent: true);
        if (mounted) {
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text(s.categoryDeleteSuccess),
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
          messenger.showSnackBar(
            SnackBar(
              content: Text(s.categoryDeleteFail),
              backgroundColor: errorColor,
      ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(s.categoryDeleteError)));
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
        builder: (context) =>
            CategoryProductsScreen(category: category, products: items),
      ),
    );
  }

  bool _categoryHasFullOffer(String category) {
    final items = _products
        .where((p) => p.category.trim() == category.trim())
        .toList();
    if (items.isEmpty) return false;
    return items.every((p) => p.hasOffer && p.offerActive);
  }

  void _showCategoryActionSheet(String category, int productCount) {
    final ctx = _scaffoldKey.currentContext!;
    final colors = Theme.of(ctx).colorScheme;
    final hasFullOffer = _categoryHasFullOffer(category);
    final s = AppLocalizations.of(ctx)!;

    showModalBottomSheet(
      context: ctx,
      backgroundColor: colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              30 + MediaQuery.of(sheetCtx).viewPadding.bottom,
      ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
      ),
                      child: Icon(
                        Icons.category_rounded,
                        color: colors.primary,
                        size: 26,
      ),
      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
      ),
      ),
                          Text(
                            s.productsCount(productCount),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
      ),
      ),
                        ],
      ),
      ),
                  ],
      ),
                const SizedBox(height: 24),

                _buildActionTile(
                  icon: Icons.list_alt_rounded,
                  iconColor: Colors.blue,
                  title: s.viewProductsAction,
                  subtitle: s.viewProductsSubtitle,
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    _openCategoryProducts(category);
                  },
      ),

                const SizedBox(height: 12),

                _buildActionTile(
                  icon: Icons.local_offer_rounded,
                  iconColor: colors.tertiary,
                  title: s.applyCategoryOfferAction,
                  subtitle: s.applyCategoryOfferSubtitle,
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    _showApplyOfferDialog(category);
                  },
      ),

                if (hasFullOffer) ...[
                  const SizedBox(height: 12),
                  _buildActionTile(
                    icon: Icons.power_settings_new_rounded,
                    iconColor: Colors.red,
                    title: s.stopCategoryOffersAction,
                    subtitle: s.stopCategoryOffersSubtitle,
                    onTap: () async {
                      Navigator.pop(sheetCtx);
                      await _disableCategoryOffers(category);
                    },
      ),
                ],
              ],
      ),
          );
        },
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: iconColor.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: iconColor.withValues(alpha: 0.15)),
      ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
      ),
      ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
                  ],
      ),
      ),
              Icon(
                Icons.chevron_right_rounded,
                color: iconColor.withValues(alpha: 0.5),
      ),
            ],
      ),
      ),
      ),
    );
  }

  void _showApplyOfferDialog(String category) async {
    // Capture context and all context-dependent values BEFORE async
    final ctx = _scaffoldKey.currentContext;
    if (ctx == null) return;
    final colors = Theme.of(ctx).colorScheme;
    final s = AppLocalizations.of(ctx)!;
    final percentCtrl = TextEditingController();
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 5));

    if (!await _checkWriteAccess()) return;
    if (!mounted || !ctx.mounted) return;

    final sp = await SharedPreferences.getInstance();
    if (!mounted || !ctx.mounted) return;
    final defaultDays = sp.getInt('default_offer_days') ?? 5;
    endDate = startDate.add(Duration(days: defaultDays));

    showModalBottomSheet(
      context: ctx,
      backgroundColor: colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              30 +
                  MediaQuery.of(sheetCtx).viewInsets.bottom +
                  MediaQuery.of(sheetCtx).viewPadding.bottom,
      ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.tertiary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
      ),
                      child: Icon(
                        Icons.bolt_rounded,
                        color: colors.tertiary,
                        size: 26,
      ),
      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.categoryFullOfferTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
      ),
      ),
                          Text(
                            s.applyToCategorySubtitle(category),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
      ),
      ),
                        ],
      ),
      ),
                  ],
      ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: percentCtrl,
                  inputFormatters: [_CommaFormatter()],
                  decoration: InputDecoration(
                    labelText: s.percentageLabel,
                    prefixIcon: const Icon(Icons.percent_rounded),
                    hintText: s.percentageHint,
      ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
      ),
      ),
                const SizedBox(height: 16),

                InkWell(
                  onTap: () async {
                    final res = await showDateRangePicker(
                      context: sheetCtx,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDateRange: DateTimeRange(
                        start: startDate,
                        end: endDate,
      ),
                    );
                    if (res != null) {
                      setSheetState(() {
                        startDate = res.start;
                        endDate = res.end;
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Theme.of(sheetCtx).dividerColor,
      ),
      ),
                    child: Row(
                      children: [
                        Icon(Icons.date_range_rounded, color: colors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.offerValidityLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(sheetCtx).hintColor,
      ),
      ),
                              Text(
                                '${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
      ),
      ),
                            ],
      ),
      ),
                        const Icon(Icons.edit_calendar_rounded, size: 20),
                      ],
      ),
      ),
      ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetCtx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
      ),
      ),
                        child: Text(s.cancel),
      ),
      ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          final val =
                              double.tryParse(
                                percentCtrl.text.replaceAll(',', '.'),
                              ) ??
                              0;
                          if (val <= 0) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(s.invalidPercentageError),
                                backgroundColor: Colors.orange,
                                behavior: SnackBarBehavior.floating,
      ),
                            );
                            return;
                          }
                          Navigator.pop(sheetCtx);
                          await _applyCategoryOffer(
                            category,
                            val,
                            startDate,
                            endDate,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
      ),
      ),
                        child: Text(
                          s.applyOfferButton,
                          style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      ),
      ),
                  ],
      ),
              ],
      ),
          );
        },
      ),
    );
  }

  Future<void> _applyCategoryOffer(
    String category,
    double percent,
    DateTime start,
    DateTime end,
  ) async {
    setState(() => _busy = true);
    final s = AppLocalizations.of(context)!;
    try {
      final success = await ApiService.updateCategoryOffers(category, {
        'has_offer': true,
        'offer_active': true,
        'offer_type': 'percent',
        'percent': percent,
        'bundle_price': 0,
        'bundle_qty': 0,
        'offer_start_date':
            "${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}",
        'offer_end_date':
            "${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}",
      });
      if (mounted) {
        if (success) {
          await _reload(silent: true);
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(s.categoryOfferAppliedMsg(category)),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
      ),
          );
        } else {
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(s.categoryOfferApplyFail),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
      ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disableCategoryOffers(String category) async {
    setState(() => _busy = true);
    final s = AppLocalizations.of(context)!;
    try {
      final success = await ApiService.updateCategoryOffers(category, {
        'offer_active': false,
      });
      if (mounted) {
        if (success) {
          await _reload(silent: true);
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(s.categoryOffersDisabledMsg(category)),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
      ),
          );
        } else {
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(s.categoryOffersDisableFail),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
      ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _buildCategoryCard(String category, int count, int index) {
    final theme = Theme.of(_scaffoldKey.currentContext!);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final s = AppLocalizations.of(_scaffoldKey.currentContext!)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors.outline.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _showCategoryActionSheet(category, count),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colors.primary.withValues(alpha: 0.15),
                          colors.primary.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.grid_view_rounded,
                      color: colors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white10
                                : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            s.productsCount(count),
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.hintColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (!_busy)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionCircle(
                          icon: Icons.edit_rounded,
                          color: colors.primary,
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
    );
  }


  Widget _buildActionCircle({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withValues(alpha: 0.1),
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final counts = _counts();
    final cats = counts.keys.toList()..sort();
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        currentRoute: '/categories',
        headerSubtitle: s.manageCategories,
        onSync: () async => _reload(silent: false),
      ),
      appBar: PremiumAnimatedAppBar(
        title: s.categoriesTitle,
        showSettings: false,
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: colors.primary,
                strokeWidth: 2.5,
      ),
            )
          : RefreshIndicator(
              color: colors.primary,
              backgroundColor: colors.surface,
              onRefresh: () => _reload(silent: true),
              child: Stack(
                children: [
                  ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
      ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
      ),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: colors.primary.withValues(alpha: 0.3),
      ),
      ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.grid_view_rounded,
                                    size: 16,
                                    color: colors.primary,
      ),
                                  const SizedBox(width: 6),
                                  Text(
                                    s.categoriesCountLabel(cats.length),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: colors.primary,
      ),
      ),
                                ],
      ),
      ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
      ),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: colors.outline.withValues(alpha: 0.2),
      ),
      ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.inventory_2_rounded,
                                    size: 16,
                                    color: theme.hintColor,
      ),
                                  const SizedBox(width: 6),
                                  Text(
                                    s.productsCount(_products.length),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: theme.hintColor,
      ),
      ),
                                ],
      ),
      ),
                          ],
      ),
      ),

                      const SizedBox(height: 16),

                      if (cats.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.grid_view_rounded,
                                size: 60,
                                color: theme.hintColor.withValues(alpha: 0.3),
      ),
                              const SizedBox(height: 20),
                              Text(
                                s.noCategoriesTitle,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
      ),
      ),
                              const SizedBox(height: 8),
                              Text(
                                s.noCategoriesSubtitle,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.hintColor,
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

                      SizedBox(
                        height: 140 + MediaQuery.of(context).viewPadding.bottom,
      ),
                    ],
      ),

                  if (_busy)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.1),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: colors.primary,
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

// ==============================================================================
//  UPDATED CATEGORY PRODUCTS SCREEN
// ==============================================================================

class CategoryProductsScreen extends StatefulWidget {
  final String category;
  final List<Product> products;

  const CategoryProductsScreen({
    super.key,
    required this.category,
    required this.products,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  late List<Product> _items;
  bool _actionBusy = false;

  final NumberFormat _moneyFmt = NumberFormat("#,##0.00", "en");
  final NumberFormat _sizeFmt = NumberFormat("#,##0.##", "en");

  static const Color _activeGreen = Color(0xFF2E7D32);
  static const Color _inactiveGrey = Color(0xFF7A7A7A);

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.products);
  }

  String _currency() {
    final settings = StoreConfigService.store;
    return settings?['currency']?.toString() ?? '€';
  }

  DateTime _parseDateSafe(String? value, DateTime fallback) {
    if (value == null || value.isEmpty) return fallback;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return fallback;
    }
  }

  bool _isOfferInDateRange(Product p) {
    if (!p.hasOffer || !p.offerActive) return false;

    final now = DateTime.now();
    final start = DateTime.tryParse(p.offerStartDate);
    final end = DateTime.tryParse(p.offerEndDate);

    if (start == null || end == null) return true;

    final today = DateTime(now.year, now.month, now.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);

    return !today.isBefore(s) && !today.isAfter(e);
  }

  String _offerUntilText(Product p) {
    if (!_isOfferInDateRange(p)) return '';
    final end = _parseDateSafe(p.offerEndDate, DateTime.now());
    final s = AppLocalizations.of(context)!;
    final dateStr =
        "${end.day.toString().padLeft(2, '0')}/${end.month.toString().padLeft(2, '0')}/${end.year}";
    return s.offerUntilDate(dateStr);
  }

  String _offerText(Product p) {
    final s = AppLocalizations.of(context)!;
    if (p.offerType == 'percent') {
      return s.discountPercent(_sizeFmt.format(p.percent));
    }
    if (p.offerType == 'bundle') {
      final cur = _currency();
      return s.bundleOfferLabel(
        _sizeFmt.format(p.bundleQty),
        _moneyFmt.format(p.bundlePrice),
        cur,
      );
    }
    return s.offerLabel;
  }

  String _priceLine(Product p) {
    final price = _moneyFmt.format(p.price);
    final size = _sizeFmt.format(p.sizeValue);

    final settings = StoreConfigService.store;
    final currency = settings?['currency']?.toString() ?? '€';
    final priceWithCurrency = '$price $currency';

    final s = AppLocalizations.of(context)!;
    final unit = AppConfig.unitLabel(p.sizeUnit, s);
    return '$priceWithCurrency / $size $unit';
  }

  Color _a(Color c, double alpha01) => c.withValues(alpha: alpha01);

  Widget _statusChip(Product p) {
    final isActive = p.productActive == true;
    final s = AppLocalizations.of(context)!;

    final bg = isActive ? _a(_activeGreen, 0.18) : _a(_inactiveGrey, 0.15);
    final br = isActive ? _a(_activeGreen, 0.45) : _a(_inactiveGrey, 0.45);
    final fg = isActive ? _activeGreen : _inactiveGrey;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: br, width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: fg,
      ),
          const SizedBox(width: 6),
          Text(
            isActive ? s.availableStatus : s.unavailableStatus,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w900,
              fontSize: 12,
      ),
      ),
        ],
      ),
    );
  }

  Widget _offerChip(Product p) {
    if (!_isOfferInDateRange(p)) return const SizedBox.shrink();

    final label = _offerUntilText(p);
    final accentColor = Theme.of(context).colorScheme.tertiary;

    return Container(
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.4),
          width: 1.1,
      ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: 13, color: accentColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.w900,
              fontSize: 11.5,
              letterSpacing: 0.2,
      ),
      ),
        ],
      ),
    );
  }

  Future<void> _toggleActive(Product p) async {
    if (!AccessManager.canWriteAdmin) {
      await showFabPaywallDialog(context);
      return;
    }

    setState(() => _actionBusy = true);
    final s = AppLocalizations.of(context)!;

    final newValue = !p.productActive;
    setState(() {
      final i = _items.indexWhere((x) => x.id == p.id);
      if (i != -1) _items[i] = _items[i].copyWith(productActive: newValue);
    });

    final success = await ApiService.updateProduct(
      p.copyWith(productActive: newValue),
    );

    if (!mounted) return;
    setState(() => _actionBusy = false);

    if (!success) {
      setState(() {
        final i = _items.indexWhere((x) => x.id == p.id);
        if (i != -1) {
          _items[i] = _items[i].copyWith(productActive: p.productActive);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.updateFail), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _confirmDelete(Product p) async {
    if (!AccessManager.canWriteAdmin) {
      await showFabPaywallDialog(context);
      return;
    }

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(s.deleteProductTitle),
        content: Text(s.deleteProductConfirmMsg(p.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
      ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
      ),
            child: Text(s.delete),
      ),
        ],
      ),
    );

    if (ok == true) {
      setState(() => _actionBusy = true);
      final success = await ApiService.deleteProduct(p.id);
      if (!mounted) return;
      setState(() => _actionBusy = false);

      if (success) {
        setState(() => _items.removeWhere((x) => x.id == p.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.deleteSuccess),
            backgroundColor: Colors.green,
      ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.deleteFail), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildProductCard(Product p) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;

    final hasOfferToday = _isOfferInDateRange(p);
    final offerLine = hasOfferToday ? _offerText(p) : null;

    return Padding(
      // Padding reduziert für breitere Karte
      padding: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: colors.surface,
          border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
      ),
          ],
      ),
        child: Stack(
          children: [
            InkWell(
              onTap: () async {
                if (_actionBusy) return;
                final result = await context.push('/edit/${p.id}', extra: p);
                if (result is Product && mounted) {
                  setState(() {
                    final i = _items.indexWhere((x) => x.id == result.id);
                    if (i != -1) _items[i] = result;
                  });
                }
              },
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 74,
                          height: 74,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: colors.surfaceContainerHighest,
                            border: Border.all(
                              color: colors.outline.withValues(alpha: 0.1),
      ),
      ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: (p.thumb.isNotEmpty || p.image.isNotEmpty)
                                ? Image.network(
                                    (p.thumb.isNotEmpty ? p.thumb : p.image),
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: theme.hintColor,
                                          size: 28,
      ),
                                      );
                                    },
                                  )
                                : Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: theme.hintColor,
                                      size: 28,
      ),
      ),
      ),
      ),
                        if (hasOfferToday)
                          Positioned(
                            top: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
      ),
                              decoration: BoxDecoration(
                                color: colors.tertiary,
                                borderRadius: BorderRadius.circular(12),
      ),
                              child: const Icon(
                                Icons.local_offer,
                                size: 14,
                                color: Colors.black,
      ),
      ),
      ),
                      ],
      ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.2,
                              color: colors.onSurface,
      ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
      ),
                          const SizedBox(height: 6),
                          Text(
                            _priceLine(p),
                            style: TextStyle(
                              fontSize: 14.8,
                              color: colors.primary,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.2,
      ),
      ),
                          if (offerLine != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.history_toggle_off,
                                  size: 16,
                                  color: colors.tertiary,
      ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    offerLine,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w900,
                                      color: colors.tertiary,
      ),
      ),
      ),
                              ],
      ),
                          ],
                          const SizedBox(height: 10),
                          // HIER GEÄNDERT: Row mit ScrollView falls es zu breit wird
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _statusChip(p),
                                if (p.hasOffer && p.offerActive) ...[
                                  const SizedBox(width: 8),
                                  _offerChip(p),
                                ],
                              ],
      ),
      ),
                        ],
      ),
      ),
                  ],
      ),
      ),
      ),
            // ACTION BUTTONS POSITIONED (Overlay, damit sie keinen Platz wegnehmen)
            Positioned(
              top: 10,
              left: 10,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _actionBusy ? null : () => _toggleActive(p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: 52,
                      height: 28,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: p.productActive
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: p.productActive ? Colors.green : Colors.grey,
                          width: 1.2,
      ),
      ),
                      child: Stack(
                        children: [
                          AnimatedAlign(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.fastOutSlowIn,
                            alignment: p.productActive
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: p.productActive
                                    ? Colors.green
                                    : Colors.grey,
      ),
      ),
      ),
                        ],
      ),
      ),
      ),
                  const SizedBox(height: 12),
                  IconButton(
                    tooltip: s.delete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _actionBusy ? null : () => _confirmDelete(p),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colors.error.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.error.withValues(alpha: 0.3),
      ),
      ),
                      child: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: colors.error,
      ),
      ),
      ),
                ],
      ),
      ),
          ],
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    if (_items.isEmpty) {
      return Scaffold(
        appBar: PremiumAnimatedAppBar(
          title: widget.category,
          showBackButton: true,
          showSettings: false,
      ),
        body: Center(child: Text(s.noProducts)),
      );
    }

    return Scaffold(
      appBar: PremiumAnimatedAppBar(
        title: widget.category,
        showBackButton: true,
        showSettings: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 16, bottom: 20),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final p = _items[index];
          return _buildProductCard(p);
        },
      ),
    );
  }
}
