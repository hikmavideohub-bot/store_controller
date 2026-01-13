import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../widgets/premium_app_bar.dart';
import '../config.dart';
import '../services/store_config_service.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';
import '../storage/store_prefs.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  // =======================
  // STATE (LOGIC)
  // =======================
  List<Product> _products = [];
  bool _loading = true;
  bool _actionBusy = false;
  String? _storeId;
  bool _missingStore = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  final NumberFormat _moneyFmt = NumberFormat("#,##0.00", "en");
  final NumberFormat _sizeFmt = NumberFormat("#,##0.##", "en");

  String _catFilter = 'all';
  String _offerFilter = 'all';
  String _stockFilter = 'all';

  // =======================
  // CACHED HANDLES (NO context across async gaps)
  // =======================
  ScaffoldMessengerState? _messenger;
  GoRouter? _router;

  // =======================
  // ✅ REV BUNDLE / v= (FIX B)
  // =======================
  // Das ist der Query-Parameter der in /s/data/<slug>.json?v=<...> genutzt wird.
  // Idealerweise ist das rev.bundle aus dem Bundle (vom Worker/Script).
  // Fallback: Zeitstempel (damit Cache immer gebustet werden kann, selbst wenn rev.bundle noch nicht genutzt wird).
  String? _revBundle;
  String _vParam = '';

  // (optional) wenn du dafür schon einen StorePrefs key hast:
  // - wenn nicht, bleibt es einfach leer und wir nutzen fallback.
  Future<void> _initVParam() async {
    // Wenn du rev.bundle bereits irgendwo speicherst, z.B. in StorePrefs:
    // final saved = await StorePrefs.getRevBundle();
    // _revBundle = saved;

    _revBundle = null; // <-- lässt sich ohne StorePrefs-Methoden nicht sicher lesen
    _vParam = (_revBundle != null && _revBundle!.trim().isNotEmpty)
        ? _revBundle!.trim()
        : DateTime.now().millisecondsSinceEpoch.toString();
  }

  void _bustVParam() {
    // Nach jeder Mutation (delete/update/toggle) setzen wir v neu,
    // damit der nächste fetch garantiert frisch ist.
    _vParam = (_revBundle != null && _revBundle!.trim().isNotEmpty)
        ? _revBundle!.trim()
        : DateTime.now().millisecondsSinceEpoch.toString();
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

  String _offerUntilText(Product p) {
    if (!_isOfferInDateRange(p)) return '';

    final end = _parseDateSafe(p.offerEndDate, DateTime.now());

    final dd = end.day.toString().padLeft(2, '0');
    final mm = end.month.toString().padLeft(2, '0');
    final yy = end.year.toString();

    return 'حتى $dd/$mm/$yy';
  }

  String _offerText(Product p) {
    if (p.offerType == 'percent') {
      return 'خصم ${_sizeFmt.format(p.percent)}%';
    }
    if (p.offerType == 'bundle') {
      final cur = _currency();
      return '${_sizeFmt.format(p.bundleQty)} بـ ${_moneyFmt.format(p.bundlePrice)} $cur';
    }
    return 'عرض';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messenger = ScaffoldMessenger.of(context);
    _router = GoRouter.of(context);
  }

  // =======================
  // BRAND THEME
  // =======================
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _goldSoft = Color(0xFFC9B458);
  static const Color _activeGreen = Color(0xFF2E7D32);
  static const Color _inactiveGrey = Color(0xFF7A7A7A);
  static const Color _successBg = Color(0xFF1E3D2B);
  static const Color _warnBg = Color(0xFF3A331A);
  static const Color _errorBg = Color(0xFF3A1E1E);
  static const Color _textDisabled = Color(0xFF6F6F6F);
  static const Color _border = Color(0xFF2A2A2A);

  Color _a(Color c, double alpha01) => c.withValues(alpha: alpha01);

  void _snack(String msg, Color bg) {
    final m = _messenger;
    if (m == null) return;
    m.hideCurrentSnackBar();
    m.showSnackBar(
      SnackBar(
        backgroundColor: bg,
        content: Text(
          msg,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // =======================
  // ACTION WRAPPER (LOGIC)
  // =======================
  Future<T?> _runAction<T>(Future<T> Function() fn) async {
    if (_actionBusy) return null;

    setState(() => _actionBusy = true);
    try {
      return await fn();
    } finally {
      if (mounted) setState(() => _actionBusy = false);
    }
  }

  // =======================
  // DATA (LOGIC)
  // =======================
  Future<void> _boot() async {
    await _initVParam();

    final id = await StorePrefs.getStoreId();
    if (!mounted) return;

    if (id == null) {
      setState(() {
        _missingStore = true;
        _loading = false;
      });
      return;
    }

    _storeId = id;

    await _loadProducts();
  }

  Future<void> _loadProducts({bool silent = false}) async {
    bool showedCache = false;

    final cached = ApiService.cachedProducts;
    if (cached != null && cached.isNotEmpty) {
      showedCache = true;
      if (!mounted) return;
      setState(() {
        _products = cached;
        _loading = false;
      });
    } else {
      if (!silent) {
        if (!mounted) return;
        setState(() => _loading = true);
      }
    }

    final messenger = _messenger;

    try {
      // ✅ FIX B: v= Parameter benutzen (rev.bundle / fallback timestamp)
      // Voraussetzung: ApiService.fetchProducts hat optional {String? v}
      final data = await ApiService.fetchProducts(v: _vParam);

      if (!mounted) return;

      setState(() {
        _products = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      if (!showedCache && _products.isEmpty && messenger != null) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          const SnackBar(
            backgroundColor: _errorBg,
            content: Text(
              'تعذر تحميل المنتجات',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        );
      }
    }
  }

  Future<void> _toggleActive(Product p) async {
    final messenger = _messenger;

    final newValue = !p.productActive;

    setState(() {
      final i = _products.indexWhere((x) => x.id == p.id);
      if (i != -1) _products[i] = _products[i].copyWith(productActive: newValue);
    });

    final success = await ApiService.updateProduct(p.copyWith(productActive: newValue));
    if (!mounted) return;

    if (!success) {
      setState(() {
        final i = _products.indexWhere((x) => x.id == p.id);
        if (i != -1) _products[i] = _products[i].copyWith(productActive: p.productActive);
      });

      if (messenger != null) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          const SnackBar(
            backgroundColor: _errorBg,
            content: Text(
              'فشل تحديث حالة المنتج',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        );
      }
      return;
    }

    // ✅ Nach erfolgreicher Mutation: v neu (damit nächster Fetch garantiert frisch)
    _bustVParam();
  }

  Future<void> _toggleOffer(Product p) async {
    final messenger = _messenger;

    final newValue = !p.offerActive;

    setState(() {
      final i = _products.indexWhere((x) => x.id == p.id);
      if (i != -1) _products[i] = _products[i].copyWith(offerActive: newValue);
    });

    final success = await ApiService.updateProduct(p.copyWith(offerActive: newValue));
    if (!mounted) return;

    if (!success) {
      setState(() {
        final i = _products.indexWhere((x) => x.id == p.id);
        if (i != -1) _products[i] = _products[i].copyWith(offerActive: p.offerActive);
      });

      if (messenger != null) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          const SnackBar(
            backgroundColor: _errorBg,
            content: Text(
              'فشل تحديث العرض',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        );
      }
      return;
    }

    // ✅
    _bustVParam();
  }

  // =======================
  // DELETE FUNCTIONS (FIXED - SINGLE DELETE FLOW)
  // =======================
  Future<bool> _deleteProductNow(Product p) async {
    final success = await ApiService.deleteProduct(p.id);
    if (!mounted) return false;

    if (success) {
      setState(() => _products.removeWhere((x) => x.id == p.id));
      _snack('تم حذف المنتج بنجاح', _warnBg);
      _bustVParam();
      return true;
    } else {
      _snack('فشل حذف المنتج', _errorBg);
      return false;
    }
  }

  Future<bool> _confirmDelete(Product p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        final dialogNav = Navigator.of(dialogCtx);
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: _a(_border, 0.90)),
          ),
          title: Text(
            'حذف المنتج',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            'هل تريد حذف "${p.name}"؟',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => dialogNav.pop(false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => dialogNav.pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: Colors.redAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                side: BorderSide(color: _a(Colors.redAccent, 0.35)),
              ),
              child: const Text('حذف', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );

    if (ok != true) return false;

    // FIX: Verwende _runAction mit korrektem Return-Wert
    final deleted = await _runAction(() => _deleteProductNow(p));
    return deleted == true;
  }

  // =======================
  // UI helpers (LOGIC)
  // =======================
  String _priceLine(Product p) {
    final price = _moneyFmt.format(p.price);
    final size = _sizeFmt.format(p.sizeValue);

    final settings = StoreConfigService.store;
    final currency = settings?['currency']?.toString() ?? '€';
    final priceWithCurrency = '$price $currency';

    final unit = AppConfig.unitLabel(p.sizeUnit);
    return '$priceWithCurrency / $size $unit';
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

  Widget _statusChip(Product p) {
    final isActive = p.productActive == true;

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
          Icon(isActive ? Icons.check_circle : Icons.cancel, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            isActive ? 'نشط' : 'غير نشط',
            style: TextStyle(color: fg, fontWeight: FontWeight.w900, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _offerChip(Product p) {
    if (!_isOfferInDateRange(p)) return const SizedBox.shrink();

    final label = _offerUntilText(p);

    const purpleColor = Color(0xFFFF9800);

    return Container(
      decoration: BoxDecoration(
        color: purpleColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        // FIX: Border.all() statt BorderSide()
        border: Border.all(color: purpleColor.withValues(alpha: 0.4), width: 1.1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today, size: 13, color: purpleColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: purpleColor,
              fontWeight: FontWeight.w900,
              fontSize: 11.5,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // =======================
  // FILTER SHEET
  // =======================
  void _openFiltersSheet(List<String> categories) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        side: BorderSide(color: _a(_gold, 0.20)),
      ),
      builder: (sheetCtx) {
        String cat = _catFilter;
        String offer = _offerFilter;
        String stock = _stockFilter;

        InputDecoration deco(String label) => InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w700,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _a(_border, 0.95)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _a(_gold, 0.55), width: 1.4),
          ),
        );

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 10,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom +
                MediaQuery.of(sheetCtx).viewPadding.bottom +
                20,
          ),
          child: StatefulBuilder(
            builder: (localCtx, setLocal) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'الفلترة',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    key: ValueKey('cat-$cat'),
                    initialValue: cat,
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    iconEnabledColor: _gold,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: deco('التصنيف'),
                    items: [
                      const DropdownMenuItem(value: 'all', child: Text('الكل')),
                      ...categories.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                    ],
                    onChanged: (v) => setLocal(() => cat = v ?? 'all'),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    key: ValueKey('offer-$offer'),
                    initialValue: offer,
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    iconEnabledColor: _gold,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: deco('العروض'),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('الكل')),
                      DropdownMenuItem(value: 'with', child: Text('مع عرض')),
                      DropdownMenuItem(value: 'without', child: Text('بدون عرض')),
                    ],
                    onChanged: (v) => setLocal(() => offer = v ?? 'all'),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    key: ValueKey('stock-$stock'),
                    initialValue: stock,
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    iconEnabledColor: _gold,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: deco('الحالة'),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('الكل')),
                      DropdownMenuItem(value: 'active', child: Text('متوفر / نشط')),
                      DropdownMenuItem(value: 'inactive', child: Text('غير متوفر / غير نشط')),
                    ],
                    onChanged: (v) => setLocal(() => stock = v ?? 'all'),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _catFilter = 'all';
                              _offerFilter = 'all';
                              _stockFilter = 'all';
                            });
                            Navigator.of(sheetCtx).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            side: BorderSide(color: _a(_border, 0.95)),
                            foregroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          child: const Text('إعادة ضبط', style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _catFilter = cat;
                              _offerFilter = offer;
                              _stockFilter = stock;
                            });
                            Navigator.of(sheetCtx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            foregroundColor: _gold,
                            side: BorderSide(color: _a(_gold, 0.40)),
                          ),
                          child: const Text('تطبيق', style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // =======================
  // PRODUCT ACTIONS SHEET
  // =======================
  void _openProductActions(Product p) {
    // FIX: messenger-Variable entfernt, da nicht verwendet
    final router = _router;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        side: BorderSide(color: _a(_gold, 0.20)),
      ),
      builder: (sheetCtx) {
        final sheetNav = Navigator.of(sheetCtx);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(
                  'ID: ${p.id}',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                ),
              ),
              Divider(height: 1, color: _a(_border, 0.90)),

              ListTile(
                enabled: !_actionBusy,
                leading: _actionBusy
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.2, color: _gold),
                )
                    : Icon(
                  p.productActive ? Icons.check_circle : Icons.cancel,
                  color: p.productActive ? _activeGreen : _inactiveGrey,
                ),
                title: Text(
                  p.productActive ? 'تعطيل المنتج' : 'تفعيل المنتج',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: _actionBusy
                    ? null
                    : () async {
                  sheetNav.pop();
                  await _runAction(() => _toggleActive(p));
                  if (!mounted) return;
                },
              ),

              ListTile(
                enabled: !_actionBusy,
                leading: _actionBusy
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.2, color: _gold),
                )
                    : const Icon(Icons.local_offer, color: _goldSoft),
                title: Text(
                  p.offerActive ? 'إيقاف العرض' : 'تفعيل العرض',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: _actionBusy
                    ? null
                    : () async {
                  sheetNav.pop();
                  await _runAction(() => _toggleOffer(p));
                  if (!mounted) return;
                },
              ),

              ListTile(
                enabled: !_actionBusy,
                leading: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                title: Text(
                  'تعديل',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: _actionBusy
                    ? null
                    : () async {
                  sheetNav.pop();
                  if (router == null) return;

                  final result = await router.push('/edit/${p.id}', extra: p);

                  if (!mounted) return;
                  if (result is Product) {
                    setState(() {
                      final i = _products.indexWhere((x) => x.id == result.id);
                      if (i != -1) _products[i] = result;
                    });
                    _snack('تم تحديث المنتج بنجاح', _successBg);

                    // ✅
                    _bustVParam();
                  }
                },
              ),

              ListTile(
                enabled: !_actionBusy,
                leading: const Icon(Icons.delete, color: Colors.redAccent),
                title: const Text(
                  'حذف',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w800),
                ),
                onTap: _actionBusy
                    ? null
                    : () async {
                  sheetNav.pop();
                  await _confirmDelete(p);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // =======================
  // PRODUCT LIST BUILDER
  // =======================
  List<Product> _getFilteredProducts() {
    final products = List<Product>.from(_products);

    products.sort((a, b) {
      final act = (b.productActive ? 1 : 0).compareTo(a.productActive ? 1 : 0);
      if (act != 0) return act;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    final q = _query.trim().toLowerCase();

    return products.where((p) {
      final name = p.name.toLowerCase();
      final id = p.id.toLowerCase();
      final matchesSearch = q.isEmpty || name.contains(q) || id.contains(q);

      final matchesCat = (_catFilter == 'all') || (p.category == _catFilter);

      final hasActiveOfferToday = _isOfferInDateRange(p);

      final matchesOffer = (_offerFilter == 'all') ||
          (_offerFilter == 'with' && hasActiveOfferToday) ||
          (_offerFilter == 'without' && !hasActiveOfferToday);

      final matchesStock = (_stockFilter == 'all') ||
          (_stockFilter == 'active' && p.productActive == true) ||
          (_stockFilter == 'inactive' && p.productActive == false);

      return matchesSearch && matchesCat && matchesOffer && matchesStock;
    }).toList();
  }

  Widget _buildProductCard(Product p, BuildContext context) {
    final router = _router;
    final messenger = _messenger;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final hasOfferToday = _isOfferInDateRange(p);
    final offerLine = hasOfferToday ? _offerText(p) : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Dismissible(
        key: ValueKey(p.id),
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 24),
          decoration: BoxDecoration(
            color: _a(_gold, 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _a(_gold, 0.35)),
          ),
          child: Row(
            children: [
              Icon(Icons.delete, color: _gold, size: 26),
              SizedBox(width: 12),
              Text('حذف', style: TextStyle(color: _gold, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: _a(Colors.blueGrey, 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _a(Colors.blueGrey, 0.35)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('تعديل', style: TextStyle(color: Colors.blueGrey[800], fontWeight: FontWeight.w900)),
              SizedBox(width: 12),
              Icon(Icons.edit, color: Colors.blueGrey[800], size: 24),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          if (_actionBusy) return false;

          if (direction == DismissDirection.startToEnd) {
            // ✅ FIX: Wir löschen selbst per setState, also Dismissible NICHT automatisch dismissen lassen
            await _confirmDelete(p);
            return false;
          }

          if (direction == DismissDirection.endToStart) {
            if (router != null) {
              final result = await router.push('/edit/${p.id}', extra: p);
              if (!mounted) return false;
              if (result is Product) {
                setState(() {
                  final i = _products.indexWhere((x) => x.id == result.id);
                  if (i != -1) _products[i] = result;
                });
                _snack('تم تحديث المنتج بنجاح', _successBg);
                _bustVParam();
              }
            }
            return false;
          }

          return false;
        },
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: theme.colorScheme.surface,
              border: Border.all(color: _a(Colors.grey[300]!, 0.4)),
              boxShadow: [
                BoxShadow(
                  color: isDark ? _a(Colors.black, 0.25) : _a(Colors.grey[200]!, 0.6),
                  blurRadius: 15,
                  spreadRadius: 0.5,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                InkWell(
                  onLongPress: () {
                    if (_actionBusy) return;
                    _openProductActions(p);
                  },
                  onTap: () async {
                    if (_actionBusy) return;
                    if (router == null) return;

                    final result = await router.push('/edit/${p.id}', extra: p);

                    if (!mounted) return;
                    if (result is Product) {
                      setState(() {
                        final i = _products.indexWhere((x) => x.id == result.id);
                        if (i != -1) _products[i] = result;
                      });
                      _snack('تم تحديث المنتج بنجاح', _successBg);

                      // ✅
                      _bustVParam();
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
                                color: isDark ? Colors.grey[900] : Colors.grey[100],
                                border: Border.all(color: _a(Colors.grey[400]!, 0.25)),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: (p.thumb.isNotEmpty || p.image.isNotEmpty)
                                    ? Image.network(
                                  (p.thumb.isNotEmpty ? p.thumb : p.image),
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, error, stackTrace) {
                                    return Center(
                                      child: Icon(Icons.image_not_supported,
                                          color: Colors.grey[500],
                                          size: 28
                                      ),
                                    );
                                  },
                                )
                                    : Center(
                                  child: Icon(Icons.image_not_supported,
                                      color: Colors.grey[500],
                                      size: 28
                                  ),
                                ),
                              ),
                            ),

                            if (hasOfferToday)
                              Positioned(
                                top: 6,
                                left: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: _a(Colors.orange[400]!, 0.95),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _a(Colors.orange[600]!, 0.6), width: 1),
                                  ),
                                  child: Icon(Icons.local_offer, size: 14, color: Colors.white),
                                ),
                              ),
                          ],
                        ),

                        SizedBox(width: 14),

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
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              SizedBox(height: 6),

                              Text(
                                _priceLine(p),
                                style: TextStyle(
                                  fontSize: 14.8,
                                  color: Colors.teal[800],
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.2,
                                ),
                              ),

                              if (offerLine != null) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.history_toggle_off, size: 16, color: Color(0xFFFF9800)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        offerLine,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFFFF9800),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              SizedBox(height: 10),

                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _statusChip(p),
                                  if (p.hasOffer && p.offerActive) _offerChip(p),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  top: 10,
                  left: 10,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: _actionBusy ? null : () => _runAction(() => _toggleActive(p)),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: 52,
                          height: 28,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: p.productActive ? Colors.green[50] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: p.productActive
                                  ? Colors.green[400]!.withValues(alpha: 0.7)
                                  : Colors.grey[400]!.withValues(alpha: 0.7),
                              width: 1.2,
                            ),
                          ),
                          child: Stack(
                            children: [
                              AnimatedAlign(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.fastOutSlowIn,
                                alignment: p.productActive ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: p.productActive
                                          ? [Colors.green[500]!, Colors.green[700]!]
                                          : [Colors.grey[500]!, Colors.grey[700]!],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      IconButton(
                        tooltip: 'حذف',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () async {
                          await _confirmDelete(p);
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _a(Colors.red[50]!, 0.9),
                            shape: BoxShape.circle,
                            border: Border.all(color: _a(Colors.red[300]!, 0.4)),
                          ),
                          child: Icon(Icons.delete_outline, size: 18, color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductList(BuildContext context) {
    final filtered = _getFilteredProducts();

    if (_products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: _textDisabled),
            SizedBox(height: 16),
            Text(
              'لا توجد أي منتجات',
              style: TextStyle(fontSize: 18, color: _textDisabled, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
    }

    if (filtered.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: _textDisabled),
            SizedBox(height: 16),
            Text('لا توجد نتائج', style: TextStyle(color: _textDisabled, fontWeight: FontWeight.w700)),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        20 + MediaQuery.of(context).viewPadding.bottom,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final p = filtered[index];
        return _buildProductCard(p, context);
      },
    );
  }

  // =======================
  // BUILD
  // =======================
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: _gold)),
      );
    }

    if (_missingStore) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.store, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'لم يتم العثور على متجر',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'قد تكون بيانات التطبيق قد حُذفت.\nيرجى تسجيل الدخول أو إعداد المتجر من جديد.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => context.go('/setup'),
                  child: const Text('إعداد المتجر'),
                ),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('تسجيل الدخول من جديد'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final categories = _products
        .map((p) => p.category.trim())
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return Scaffold(
      key: _scaffoldKey,
      appBar: PremiumAnimatedAppBar(
        title: 'المنتجات',
        showSettings: true,
        hasSearch: true,
        searchController: _searchCtrl,
        onSearchChanged: (v) => setState(() => _query = v),
        onSearchCleared: () {
          _searchCtrl.clear();
          setState(() => _query = '');
        },
        onFiltersPressed: () => _openFiltersSheet(categories),
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      drawer: AppDrawer(
        currentRoute: '/products',
        headerSubtitle: 'إدارة المنتجات',
        onSync: () async => _loadProducts(silent: false),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _gold))
          : RefreshIndicator(
        color: _gold,
        backgroundColor: Theme.of(context).colorScheme.surface,
        onRefresh: () => _loadProducts(silent: true),
        child: _buildProductList(context),
      ),
    );
  }
}