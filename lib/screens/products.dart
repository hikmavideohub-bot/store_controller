import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:url_launcher/url_launcher.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import '../widgets/premium_app_bar.dart';
import '../services/store_config_service.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';
import '../storage/store_prefs.dart';
import '../core/access_manager.dart';
import '../core/paywall_messages.dart';
import '../services/products_export_service.dart';
import 'package:store_controller/widgets/responsive_center.dart';
import 'package:flutter/services.dart';

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
  bool _missingStore = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  // .00# bedeutet: Zeige IMMER 2 Nachkommastellen (z.B. 2,50),
  // aber falls eine 3. da ist, zeige diese auch an (z.B. 2,555).
  final NumberFormat _moneyFmt = NumberFormat("#,##0.00#", "en");

  // .### bedeutet: Zeige bis zu 3 Nachkommastellen an, aber lass überflüssige Nullen weg.
  final NumberFormat _sizeFmt = NumberFormat("#,##0.###", "en");

  String _catFilter = 'all';
  String _offerFilter = 'all';
  String _stockFilter = 'all';

  // =======================
  // CACHED HANDLES
  // =======================
  ScaffoldMessengerState? _messenger;
  GoRouter? _router;

  // =======================
  // ACCESS CHECK
  // =======================
  bool get _canWrite => AccessManager.canWriteAdmin;

  Future<bool> _checkWriteAccess() async {
    if (_canWrite) return true;
    await showFabPaywallDialog(context);
    return false;
  }

  // =======================
  // V-PARAM
  // =======================
  String? _revBundle;
  String _vParam = '';

  Future<void> _initVParam() async {
    _revBundle = null;
    _vParam = (_revBundle != null && _revBundle!.trim().isNotEmpty)
        ? _revBundle!.trim()
        : DateTime.now().millisecondsSinceEpoch.toString();
  }

  void _bustVParam() {
    _vParam = (_revBundle != null && _revBundle!.trim().isNotEmpty)
        ? _revBundle!.trim()
        : DateTime.now().millisecondsSinceEpoch.toString();
  }

  String _currency() {
    final settings = StoreConfigService.store;
    final useReferencePrice = settings?['use_reference_price'] == true;

    String code = '';
    if (useReferencePrice) {
      code = settings?['reference_currency']?.toString() ?? 'USD';
    } else {
      code = settings?['currency']?.toString() ?? 'EUR';
    }

    return switch (code) {
    // Arabische Währungen
      'SYP' => 'ل.س',
      'AED' => 'د.إ',
      'BHD' => 'د.ب',
      'DZD' => 'د.ج',
      'EGP' => 'ج.م',
      'IQD' => 'ع.د',
      'JOD' => 'د.أ',
      'KWD' => 'د.ك',
      'LBP' => 'ل.ل',
      'LYD' => 'د.ل',
      'MAD' => 'د.م.',
      'OMR' => 'ر.ع.',
      'QAR' => 'ر.ق',
      'SAR' => '﷼',
      'SDG' => 'ج.س',
      'DJF' => 'Fdj',
      'TND' => 'د.ت',
      'YER' => 'ر.ي',
      'MRU' => 'UM',
      'SOS' => 'Sh',
      'KMF' => 'CF',

    // Weltwährungen
      'USD' => '\$',
      'EUR' => '€',
      'TRY' => '₺',
      'GBP' => '£',
      'CHF' => 'CHF',
      'AUD' => 'A\$',
      'CAD' => 'C\$',
      'BRL' => 'R\$',
      'CNY' => '¥',
      'JPY' => '¥',
      'RUB' => '₽',
      'SEK' => 'kr',
      _ => code, // Fallback, falls kein Symbol definiert ist
    };
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
    final s = AppLocalizations.of(context)!;
    final end = _parseDateSafe(p.offerEndDate, DateTime.now());
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
        cur,
        _moneyFmt.format(p.bundlePrice),
        _sizeFmt.format(p.bundleQty),
      );
    }
    if (p.offerType == 'bulk') {
      return s.offerTypeBulk;
    }
    return s.offerLabel;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messenger = ScaffoldMessenger.of(context);
    _router = GoRouter.of(context);
  }

  // =======================
  // THEME COLORS
  // =======================
  static const Color _activeGreen = Color(0xFF2E7D32);
  static const Color _inactiveGrey = Color(0xFF7A7A7A);
  static const Color _successBg = Color(0xFF1E3D2B);
  static const Color _warnBg = Color(0xFF3A331A);
  static const Color _errorBg = Color(0xFF3A1E1E);

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
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }


  @override
  void initState() {
    super.initState();
    _boot();
    ApiService.productsNotifier.addListener(_onProductsChanged);
  }

  @override
  void dispose() {
    ApiService.productsNotifier.removeListener(_onProductsChanged);
    // Bildschirm wird verlassen → Tastatur schließen & Suche aufräumen
    FocusManager.instance.primaryFocus?.unfocus();
    _searchCtrl.clear();
    _searchCtrl.dispose();
    super.dispose();
  }


  void _onProductsChanged() {
    if (!mounted) return;
    final updated = ApiService.productsNotifier.value;
    if (updated.isNotEmpty) {
      setState(() => _products = updated);
    }
  }

  Future<T?> _runAction<T>(Future<T> Function() fn) async {
    if (_actionBusy) return null;
    setState(() => _actionBusy = true);
    try {
      return await fn();
    } finally {
      if (mounted) setState(() => _actionBusy = false);
    }
  }

  Future<void> _boot() async {
    await _initVParam();
    String? id = await StorePrefs.getStoreId();
    if (id == null || id.isEmpty) {
      id = ApiService.storeId;
      if (id != null && id.isNotEmpty) {
        await StorePrefs.setStoreId(id);
      }
    }
    if (!mounted) return;
    if (id == null || id.isEmpty) {
      setState(() {
        _missingStore = true;
        _loading = false;
      });
      return;
    }
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
        final s = AppLocalizations.of(context)!;
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            backgroundColor: _errorBg,
            content: Text(
              s.productsLoadError,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }
    }
  }

  Future<void> _toggleActive(Product p) async {
    final allowed = await _checkWriteAccess();
    if (!allowed) return;
    if (!mounted) return;

    final s = AppLocalizations.of(context)!;
    final messenger = _messenger;
    final newValue = !p.productActive;

    setState(() {
      final i = _products.indexWhere((x) => x.id == p.id);
      if (i != -1) {
        _products[i] = _products[i].copyWith(productActive: newValue);
      }
    });

    final success = await ApiService.updateProduct(
      p.copyWith(productActive: newValue),
    );
    if (!mounted) return;

    if (!success) {
      setState(() {
        final i = _products.indexWhere((x) => x.id == p.id);
        if (i != -1) {
          _products[i] = _products[i].copyWith(productActive: p.productActive);
        }
      });
      if (messenger != null) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            backgroundColor: _errorBg,
            content: Text(
              s.productUpdateStatusFail,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }
      return;
    }
    _bustVParam();
  }

  Future<void> _toggleOffer(Product p) async {
    final allowed = await _checkWriteAccess();
    if (!allowed) return;
    if (!mounted) return;

    final s = AppLocalizations.of(context)!;
    final messenger = _messenger;
    final newValue = !p.offerActive;

    setState(() {
      final i = _products.indexWhere((x) => x.id == p.id);
      if (i != -1) _products[i] = _products[i].copyWith(offerActive: newValue);
    });

    final success = await ApiService.updateProduct(
      p.copyWith(offerActive: newValue),
    );
    if (!mounted) return;

    if (!success) {
      setState(() {
        final i = _products.indexWhere((x) => x.id == p.id);
        if (i != -1) {
          _products[i] = _products[i].copyWith(offerActive: p.offerActive);
        }
      });
      if (messenger != null) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            backgroundColor: _errorBg,
            content: Text(
              s.offerUpdateFail,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }
      return;
    }
    _bustVParam();
  }

  Future<bool> _deleteProductNow(Product p) async {
    if (!_canWrite) return false;
    if (!mounted) return false;
    final s = AppLocalizations.of(context)!;

    final success = await ApiService.deleteProduct(p.id);
    if (!mounted) return false;

    if (success) {
      setState(() => _products.removeWhere((x) => x.id == p.id));
      _snack(s.productDeleteSuccess, _warnBg);
      _bustVParam();
      return true;
    } else {
      _snack(s.productDeleteFail, _errorBg);
      return false;
    }
  }

  Future<bool> _confirmDelete(Product p) async {
    final allowed = await _checkWriteAccess();
    if (!allowed) return false;
    if (!mounted) return false;

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        final dialogNav = Navigator.of(dialogCtx);
        return AlertDialog(
          backgroundColor: colors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colors.outline.withValues(alpha: 0.2)),
          ),
          title: Text(
            s.deleteProductTitle,
            style: TextStyle(
              color: colors.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            s.deleteProductConfirmMsg(p.name),
            style: TextStyle(
              color: colors.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => dialogNav.pop(false),
              child: Text(s.cancel),
            ),
            ElevatedButton(
              onPressed: () => dialogNav.pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                s.delete,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) return false;
    if (ok != true) return false;

    final deleted = await _runAction(() => _deleteProductNow(p));
    return deleted == true;
  }
  // =======================
  // UI HELPERS
  // =======================
  String _priceLine(Product p) {
    final price = _moneyFmt.format(p.price);
    final size = _sizeFmt.format(p.sizeValue);
    final currency = _currency(); // Nutzt jetzt unsere dynamische Methode von oben!
    final s = AppLocalizations.of(context)!;
    final unit = _getUnitLabel(p.sizeUnit, s);
    return '$price $currency / $size $unit';
  }

  String _getUnitLabel(String unit, AppLocalizations s) {
    switch (unit) {
      case 'kg':
        return s.unitKg;
      case 'g':
        return s.unitG;
      case 'l':
        return s.unitL;
      case 'ml':
        return s.unitMl;
      case 'pcs':
        return s.unitPcs;
      default:
        return unit;
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

  // =======================
  // EXCEL EXPORT DIALOG
  // =======================
  void _showExportDialog(AppLocalizations s) {
    final colors = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Icon(Icons.download_rounded, color: colors.primary, size: 36),
        title: Text(s.xlsExportDialogTitle),
        content: Text(
          s.xlsExportDialogMsg,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.onSurface.withValues(alpha: 0.7)),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.laterButton, style: TextStyle(color: colors.outline)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.download_rounded, size: 18),
            onPressed: () {
              Navigator.pop(ctx);
              final sid = ApiService.storeId;
              if (sid == null) return;
              ProductsExportService.instance.exportStoreProductsToXlsx(
                context: context,
                storeId: sid,
              );
            },
            label: Text(s.xlsExportDialogConfirm),
          ),
        ],
      ),
    );
  }

  // MODERATION DIALOG
  // =======================
  void _showModerationDialog(Product p) async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;

    final storeId = ApiService.storeId ?? 'unknown';
    final productId = p.id;
    final productName = p.name;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: colors.surface,
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.policy_rounded,
                color: colors.onPrimaryContainer,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  s.productPolicyMismatchTitle,
                  style: TextStyle(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.productPolicyMismatchBody,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              s.productPolicyMismatchSubtext,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            // --- EMAIL BUTTON ---
            FilledButton.icon(
              icon: const Icon(Icons.forward_to_inbox_rounded, size: 22),
              label: Text(
                s.productPolicyMismatchCta,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);

                final subject = Uri.encodeComponent(s.productPolicyEmailSubject);
                final body = Uri.encodeComponent(
                  '${s.productPolicyEmailBodyIntro}\n\n'
                      'StoreId: $storeId\n'
                      'ProductId: $productId\n'
                      'ProductName: $productName\n',
                );

                final mailUrl =
                    'mailto:contact.aldeebtech@gmail.com?subject=$subject&body=$body';

                final uri = Uri.parse(mailUrl);

                final ok = await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );

                if (!ok && context.mounted) {
                  // Fallback: Email kopieren
                  await Clipboard.setData(const ClipboardData(text: 'contact.aldeebtech@gmail.com'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(s.contactEmailCopied)), // ARB Key
                  );
                }
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              s.closeButton,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  // FILTER SHEET
  // =======================
  void _openFiltersSheet(List<String> categories) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        side: BorderSide(color: colors.outline.withValues(alpha: 0.2)),
      ),
      builder: (sheetCtx) {
        String cat = _catFilter;
        String offer = _offerFilter;
        String stock = _stockFilter;

        InputDecoration deco(String label) => InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: theme.hintColor,
            fontWeight: FontWeight.w700,
          ),
          filled: true,
          fillColor: colors.surface,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: colors.outline.withValues(alpha: 0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colors.primary, width: 1.4),
          ),
        );

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 10,
            bottom:
                MediaQuery.of(sheetCtx).viewPadding.bottom +
                20,
          ),
          child: StatefulBuilder(
            builder: (localCtx, setLocal) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    s.filterTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: cat,
                    dropdownColor: colors.surface,
                    iconEnabledColor: colors.primary,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: deco(s.categoryLabel),
                    items: [
                      DropdownMenuItem(value: 'all', child: Text(s.filterAll)),
                      ...categories.map(
                        (c) => DropdownMenuItem(value: c, child: Text(c)),
                      ),
                    ],
                    onChanged: (v) => setLocal(() => cat = v ?? 'all'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: offer,
                    dropdownColor: colors.surface,
                    iconEnabledColor: colors.primary,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: deco(s.offersLabel),
                    items: [
                      DropdownMenuItem(value: 'all', child: Text(s.filterAll)),
                      DropdownMenuItem(
                        value: 'with',
                        child: Text(s.filterWithOffer),
                      ),
                      DropdownMenuItem(
                        value: 'without',
                        child: Text(s.filterWithoutOffer),
                      ),
                    ],
                    onChanged: (v) => setLocal(() => offer = v ?? 'all'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: stock,
                    dropdownColor: colors.surface,
                    iconEnabledColor: colors.primary,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: deco(s.stockStatusLabel),
                    items: [
                      DropdownMenuItem(value: 'all', child: Text(s.filterAll)),
                      DropdownMenuItem(
                        value: 'active',
                        child: Text(s.filterActive),
                      ),
                      DropdownMenuItem(
                        value: 'inactive',
                        child: Text(s.filterInactive),
                      ),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            side: BorderSide(
                              color: colors.outline.withValues(alpha: 0.3),
                            ),
                            foregroundColor: theme.hintColor,
                          ),
                          child: Text(
                            s.filterReset,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                          ),
                          child: Text(
                            s.filterApply,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
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
    _dismissKeyboard();
    final router = _router;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        side: BorderSide(color: colors.outline.withValues(alpha: 0.2)),
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
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(
                  'ID: ${p.id}',
                  style: TextStyle(color: theme.hintColor),
                ),
              ),
              Divider(height: 1, color: theme.dividerColor),
              ListTile(
                enabled: !_actionBusy,
                leading: _actionBusy
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: colors.primary,
                        ),
                      )
                    : Icon(
                        p.productActive ? Icons.check_circle : Icons.cancel,
                        color: p.productActive ? _activeGreen : _inactiveGrey,
                      ),
                title: Text(
                  p.productActive ? s.disableProduct : s.enableProduct,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: _actionBusy
                    ? null
                    : () async {
                        sheetNav.pop();
                        await _runAction(() => _toggleActive(p));
                      },
              ),
              ListTile(
                enabled: !_actionBusy,
                leading: _actionBusy
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: colors.primary,
                        ),
                      )
                    : Icon(Icons.local_offer, color: colors.tertiary),
                title: Text(
                  p.offerActive ? s.disableOffer : s.enableOffer,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: _actionBusy
                    ? null
                    : () async {
                        sheetNav.pop();
                        await _runAction(() => _toggleOffer(p));
                      },
              ),
              ListTile(
                enabled: !_actionBusy,
                leading: Icon(Icons.edit, color: theme.hintColor),
                title: Text(
                  s.edit,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: _actionBusy
                    ? null
                    : () async {
                        sheetNav.pop();
                        if (router == null) return;
                        final result = await router.push(
                          '/edit/${p.id}',
                          extra: p,
                        );
                        if (!mounted) return;
                        if (result is Product) {
                          setState(() {
                            final i = _products.indexWhere(
                              (x) => x.id == result.id,
                            );
                            if (i != -1) _products[i] = result;
                          });
                          _snack(s.productUpdateSuccess, _successBg);
                          _bustVParam();
                        }
                      },
              ),
              ListTile(
                enabled: !_actionBusy,
                leading: const Icon(Icons.delete, color: Colors.redAccent),
                title: Text(
                  s.delete,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w800,
                  ),
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
      final matchesOffer =
          (_offerFilter == 'all') ||
          (_offerFilter == 'with' && hasActiveOfferToday) ||
          (_offerFilter == 'without' && !hasActiveOfferToday);
      final matchesStock =
          (_stockFilter == 'all') ||
          (_stockFilter == 'active' && p.productActive == true) ||
          (_stockFilter == 'inactive' && p.productActive == false);
      return matchesSearch && matchesCat && matchesOffer && matchesStock;
    }).toList();
  }

  Widget _buildProductCard(Product p, BuildContext context) {
    final router = _router;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hasOfferToday = _isOfferInDateRange(p);
    final offerLine = hasOfferToday ? _offerText(p) : null;
    final currentDirection = Directionality.of(context);
    final s = AppLocalizations.of(context)!;
    final blocked = p.isBlocked;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: blocked ? colors.errorContainer.withValues(alpha: 0.35) : colors.surface,
            border: Border.all(
              color: blocked
                  ? colors.error.withValues(alpha: 0.35)
                  : colors.outline.withValues(alpha: 0.2),
            ),
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
                onLongPress: () {
                  _dismissKeyboard();
                  if (!_actionBusy) _openProductActions(p);
                },
                onTap: () async {
                  _dismissKeyboard();
                  if (_actionBusy || router == null) return;
                  final result = await router.push('/edit/${p.id}', extra: p);
                  if (!mounted) return;
                  if (result is Product) {
                    setState(() {
                      final i = _products.indexWhere((x) => x.id == result.id);
                      if (i != -1) _products[i] = result;
                    });
                    _snack(s.productUpdateSuccess, _successBg);
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
                                      errorBuilder: (_, _, _) => Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: theme.hintColor,
                                          size: 28,
                                        ),
                                      ),
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
                          // Moderation warning icon
                          if (p.isBlocked)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: GestureDetector(
                                onTap: () => _showModerationDialog(p),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: colors.error,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.priority_high,
                                    size: 14,
                                    color: Colors.white,
                                  ),
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
              Positioned.directional(
                textDirection: currentDirection,
                end: 10,
                top: 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                    onTap: _actionBusy
                          ? null
                          : () => _runAction(() => _toggleActive(p)),
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
                    const SizedBox(height: 6),
                    IconButton(
                      tooltip: s.delete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () async => await _confirmDelete(p),
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
      ),
    );
  }

  Widget _buildProductList(BuildContext context) {
    final filtered = _getFilteredProducts();
    final theme = Theme.of(context);
    final s = AppLocalizations.of(context)!;

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: theme.disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              s.noProductsFound,
              style: TextStyle(
                fontSize: 18,
                color: theme.disabledColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: theme.disabledColor),
            const SizedBox(height: 16),
            Text(
              s.noSearchResults,
              style: TextStyle(
                color: theme.disabledColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        0,
        16,
        0,
        20 + MediaQuery.of(context).viewPadding.bottom,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) =>
          _buildProductCard(filtered[index], context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final s = AppLocalizations.of(context)!;

    if (_loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: colors.primary)),
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
                Text(
                  s.noStoreFound,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(s.noStoreMsg, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => context.go('/setup'),
                  child: Text(s.setupStoreButton),
                ),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(s.reloginButton),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final categories =
        _products
            .map((p) => p.category.trim())
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: PremiumAnimatedAppBar(
        title: s.productsTitle,
        showSettings: true,
        hasSearch: true,
        searchController: _searchCtrl,
        onSearchChanged: (v) => setState(() => _query = v),
        onSearchCleared: () {
          _searchCtrl.clear();
          setState(() => _query = '');
        },
        onFiltersPressed: () {
          _dismissKeyboard();
          _openFiltersSheet(categories);
        },
        onMenuPressed: () {
          _dismissKeyboard();
          _scaffoldKey.currentState?.openDrawer();
        },

        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.download_rounded),
                tooltip: s.xlsExportButton,
                onPressed: () {
                  _dismissKeyboard();
                  _showExportDialog(s);
                },

              ),
              Positioned(
                right: 2,
                bottom: 4,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'xlsx',
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onPrimary,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: AppDrawer(
        currentRoute: '/products',
        headerSubtitle: s.manageProducts,
        onSync: () async => _loadProducts(silent: false),
      ),
        body: ResponsiveCenter(
          maxWidth: 1200,
          child: _loading

              ? Center(child: CircularProgressIndicator(color: colors.primary))
          : RefreshIndicator(
              color: colors.primary,
              backgroundColor: colors.surface,
              onRefresh: () => _loadProducts(silent: true),
              child: _buildProductList(context),
            ),
          ),
    );
  }
}
