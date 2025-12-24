import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../config.dart';
import '../widgets/premium_app_bar.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class CommaDecimalFormatter extends TextInputFormatter {
  final int decimalDigits;
  CommaDecimalFormatter({this.decimalDigits = 2});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final raw = newValue.text;
    final sanitized = raw.replaceAll(RegExp(r'[^0-9,]'), '');
    if (sanitized.startsWith(',')) return oldValue;

    final parts = sanitized.split(',');
    if (parts.length > 2) return oldValue;

    if (parts.length == 2 && decimalDigits >= 0) {
      if (parts[1].length > decimalDigits) return oldValue;
    }

    return TextEditingValue(
      text: sanitized,
      selection: TextSelection.collapsed(offset: sanitized.length),
      composing: TextRange.empty,
    );
  }
}

class AddProductScreen extends StatefulWidget {
  final Product? productToEdit;
  const AddProductScreen({super.key, this.productToEdit});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _sizeValueController;
  late final TextEditingController _imageController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _percentController;
  late final TextEditingController _bundleQtyController;
  late final TextEditingController _bundlePriceController;
  late final TextEditingController _categoryController;

  final FocusNode _priceFocusNode = FocusNode();
  final FocusNode _weightFocusNode = FocusNode();
  final FocusNode _categoryFocusNode = FocusNode();
  final FocusNode _descFocusNode = FocusNode();

  String? _selectedCategory;
  List<String> _categories = [];
  bool _isLoadingCategories = true;
  bool _showNewCategoryField = false;
  bool _isSaving = false;

  String _selectedUnit = 'kg';
  final List<String> _unitOptions = ['l', 'ml', 'g', 'kg', 'pcs'];

  bool _productActive = true;
  bool _hasOffer = false;
  String _offerType = 'percent';
  bool _offerActive = true;
  bool _descSuggestionShown = false;

  late DateTime _offerStartDate;
  late DateTime _offerEndDate;

  // Premium Theme Colors
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _goldSoft = Color(0xFFC9B458);
  static const Color _activeGreen = Color(0xFF2E7D32);
  static const Color _inactiveGrey = Color(0xFF7A7A7A);
  static const Color _border = Color(0xFF2A2A2A);
  static const Color _errorBg = Color(0xFF3A1E1E);
  static const Color _successBg = Color(0xFF1E3D2B);

  Color _a(Color c, double alpha01) => c.withAlpha((alpha01 * 255).toInt());

  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;

    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController = TextEditingController(text: _formatNumToText(p?.price));
    _sizeValueController = TextEditingController(text: _formatNumToText(p?.sizeValue));
    _imageController = TextEditingController(text: p?.image ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _percentController = TextEditingController(
      text: (p != null && (p.percent) > 0) ? _formatNumToText(p.percent) : '',
    );

    _bundleQtyController = TextEditingController(
      text: (p != null && p.bundleQty > 0) ? p.bundleQty.toString() : '',
    );

    _bundlePriceController = TextEditingController(
      text: (p != null && p.bundlePrice > 0) ? _formatNumToText(p.bundlePrice) : '',
    );

    _categoryController = TextEditingController(text: p?.category ?? '');

    _selectedUnit = (p?.sizeUnit.isNotEmpty == true) ? p!.sizeUnit : 'kg';
    _selectedCategory = (p?.category.isNotEmpty == true) ? p!.category : null;

    _productActive = p?.productActive ?? true;
    _hasOffer = p?.hasOffer ?? false;
    _offerActive = p?.offerActive ?? true;
    _offerType = (p?.offerType.isNotEmpty == true) ? p!.offerType : 'percent';

    _offerStartDate = (p?.offerStartDate.isNotEmpty == true)
        ? _parseDateSafe(p!.offerStartDate, DateTime.now())
        : DateTime.now();

    _offerEndDate = (p?.offerEndDate.isNotEmpty == true)
        ? _parseDateSafe(p!.offerEndDate, DateTime.now().add(const Duration(days: 30)))
        : DateTime.now().add(const Duration(days: 30));

    _loadCategories();

    _priceFocusNode.addListener(() {
      if (!_priceFocusNode.hasFocus) {
        _normalizePriceText();
      }
    });

    _weightFocusNode.addListener(() {
      if (!_weightFocusNode.hasFocus) {
        _normalizeWeightText();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _sizeValueController.dispose();
    _imageController.dispose();
    _descriptionController.dispose();
    _percentController.dispose();
    _bundleQtyController.dispose();
    _bundlePriceController.dispose();
    _categoryController.dispose();
    _priceFocusNode.dispose();
    _weightFocusNode.dispose();
    _categoryFocusNode.dispose();
    _descFocusNode.dispose();
    super.dispose();
  }

  DateTime _parseDateSafe(String s, DateTime fallback) {
    final v = s.trim();
    if (v.isEmpty) {
      return fallback;
    }

    final iso = DateTime.tryParse(v);
    if (iso != null) {
      return DateTime(iso.year, iso.month, iso.day);
    }

    final m = RegExp(r'^(\d{1,2})\.(\d{1,2})\.(\d{4})$').firstMatch(v);
    if (m != null) {
      final d = int.parse(m.group(1)!);
      final mo = int.parse(m.group(2)!);
      final y = int.parse(m.group(3)!);
      return DateTime(y, mo, d);
    }

    return fallback;
  }

  String _formatNumToText(dynamic value) {
    if (value == null) {
      return '';
    }

    if (value is int) {
      return value.toString();
    }

    try {
      final s = (value as num).toDouble().toStringAsFixed(2).replaceAll('.', ',');
      return s.endsWith(',00') ? s.substring(0, s.length - 3) : s;
    } catch (_) {
      return value.toString();
    }
  }

  void _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    final localCats = ApiService.categoriesFromCachedProducts();
    if (localCats.isNotEmpty) {
      if (!mounted) {
        return;
      }

      setState(() {
        _categories = localCats;
        _isLoadingCategories = false;

        final editingCat = widget.productToEdit?.category.trim() ?? '';
        if (editingCat.isNotEmpty && !_categories.contains(editingCat)) {
          _showNewCategoryField = true;
          _selectedCategory = null;
          _categoryController.text = editingCat;
        } else {
          _showNewCategoryField = false;
          _selectedCategory = editingCat.isNotEmpty ? editingCat : null;
          if (_selectedCategory != null) {
            _categoryController.text = _selectedCategory!;
          }
        }
      });
      return;
    }

    try {
      final List<String> categories = await ApiService.fetchCategories();
      if (!mounted) {
        return;
      }

      final unique = categories
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList();
      unique.sort();

      setState(() {
        _categories = unique;
        _isLoadingCategories = false;

        final editingCat = widget.productToEdit?.category.trim() ?? '';
        if (editingCat.isNotEmpty && !_categories.contains(editingCat)) {
          _showNewCategoryField = true;
          _selectedCategory = null;
          _categoryController.text = editingCat;
        } else {
          _showNewCategoryField = false;
          _selectedCategory = editingCat.isNotEmpty ? editingCat : null;
          if (_selectedCategory != null) {
            _categoryController.text = _selectedCategory!;
          }
        }
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingCategories = false;
        _categories = [];
        _showNewCategoryField = true;
      });

      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: _errorBg,
          content: const Text(
            'تعذر تحميل الفئات. يمكنك إضافة فئة جديدة.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'إعادة المحاولة',
            textColor: Colors.white,
            onPressed: _loadCategories,
          ),
        ),
      );
    }
  }

  double _parsePrice(String value) {
    final cleaned = value.replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0.0;
  }

  void _normalizePriceText() {
    final raw = _priceController.text.trim();
    if (raw.isEmpty) {
      return;
    }

    final sanitized = raw.replaceAll(RegExp(r'[^0-9,]'), '');
    if (sanitized.isEmpty || sanitized.startsWith(',')) {
      return;
    }

    final parts = sanitized.split(',');
    String integer = parts[0];
    String fraction = parts.length > 1 ? parts[1] : '';

    if (fraction.isEmpty) {
      fraction = '00';
    } else if (fraction.length == 1) {
      fraction = '${fraction}0';
    } else if (fraction.length > 2) {
      fraction = fraction.substring(0, 2);
    }

    final normalized = '$integer,$fraction';
    _priceController.value = _priceController.value.copyWith(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
      composing: TextRange.empty,
    );
  }

  void _normalizeWeightText() {
    final raw = _sizeValueController.text.trim();
    if (raw.isEmpty) {
      return;
    }

    final sanitized = raw.replaceAll(RegExp(r'[^0-9,]'), '');
    if (sanitized.isEmpty || sanitized.startsWith(',')) {
      return;
    }

    final parts = sanitized.split(',');
    String integer = parts[0];
    String fraction = parts.length > 1 ? parts[1] : '';

    if (fraction.isEmpty) {
      fraction = '00';
    } else if (fraction.length == 1) {
      fraction = '${fraction}0';
    } else if (fraction.length > 2) {
      fraction = fraction.substring(0, 2);
    }

    final normalized = '$integer,$fraction';
    _sizeValueController.value = _sizeValueController.value.copyWith(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
      composing: TextRange.empty,
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _selectOfferRange(BuildContext context) async {
    final initialStart = _offerStartDate;
    final initialEnd = _offerEndDate.isBefore(_offerStartDate)
        ? _offerStartDate
        : _offerEndDate;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
      locale: const Locale('ar', 'AR'),
      helpText: 'اختر فترة العرض',
      saveText: 'حفظ',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
    );

    if (picked != null && mounted) {
      setState(() {
        _offerStartDate = DateTime(picked.start.year, picked.start.month, picked.start.day);
        _offerEndDate = DateTime(picked.end.year, picked.end.month, picked.end.day);
      });
    }
  }


  Future<void> _showDescriptionSuggestion() async {
    if (_descSuggestionShown) {
      return;
    }

    if (_descriptionController.text.trim().isNotEmpty) {
      return;
    }

    _descSuggestionShown = true;

    final suggestion = _localDescriptionSuggestion();
    final currentContext = context;

    final ok = await showDialog<bool>(
      context: currentContext,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(ctx).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: _a(_border, 0.90)),
          ),
          title: Text(
            'اقتراح وصف',
            style: TextStyle(
              color: Theme.of(ctx).colorScheme.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _a(_gold, 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _a(_gold, 0.15)),
              ),
              child: Text(
                suggestion,
                style: TextStyle(
                  color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha:0.8),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx, false);
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.onSurface.withValues(alpha:0.7),
              ),
              child: const Text('لا، سأكتب بنفسي'),
            ),
            ElevatedButton(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                Navigator.pop(ctx, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('استخدام الاقتراح', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (ok == true) {
      setState(() {
        _descriptionController.text = suggestion;
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _descFocusNode.requestFocus();
      });
    }
  }

  Future<void> _confirmAndDelete() async {
    if (widget.productToEdit == null) {
      return;
    }

    final p = widget.productToEdit!;
    final currentContext = context;

    final ok = await showDialog<bool>(
      context: currentContext,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(ctx).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: _a(_border, 0.90)),
          ),
          title: Text(
            'حذف المنتج',
            style: TextStyle(
              color: Theme.of(ctx).colorScheme.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            'هل تريد حذف "${p.name}" نهائيًا؟',
            style: TextStyle(
              color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha:0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx, false);
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.onSurface.withValues(alpha:0.7),
              ),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                Navigator.pop(ctx, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.surface,
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

    if (ok != true) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final success = await ApiService.deleteProduct(p.id);
      if (!mounted) {
        return;
      }

      if (success) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            backgroundColor: _successBg,
            content: const Text(
              'تم حذف المنتج بنجاح',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        );
        context.pop(true);
      } else {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            backgroundColor: _errorBg,
            content: const Text(
              'فشل حذف المنتج',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (_isSaving) {
      return;
    }

    _normalizePriceText();
    _normalizeWeightText();

    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final categoryToUse = _categoryController.text.trim();
    if (categoryToUse.isEmpty) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: _errorBg,
          content: const Text(
            'الرجاء اختيار فئة أو إدخال فئة جديدة',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final isEditing = widget.productToEdit != null;
    final String action = isEditing ? 'تحديث' : 'حفظ';

    setState(() {
      _isSaving = true;
    });

    try {
      final productToSave = Product(
        id: isEditing ? widget.productToEdit!.id : '',
        name: _nameController.text.trim(),
        price: _parsePrice(_priceController.text),
        sizeValue: _parsePrice(_sizeValueController.text),
        sizeUnit: _selectedUnit,
        image: _imageController.text.trim(),
        description: _descriptionController.text.trim(),
        category: categoryToUse,
        productActive: _productActive,
        hasOffer: _hasOffer,
        offerType: _hasOffer ? _offerType : '',
        percent: (_hasOffer && _offerType == 'percent')
            ? (double.tryParse(_percentController.text.trim()) ?? 0)
            : 0,

        bundleQty: (_hasOffer && _offerType == 'bundle')
            ? (int.tryParse(_bundleQtyController.text.trim()) ?? 0)
            : 0,

        bundlePrice: (_hasOffer && _offerType == 'bundle')
            ? (double.tryParse(_bundlePriceController.text.trim()) ?? 0)
            : 0,

        offerStartDate: _hasOffer ? _formatDate(_offerStartDate) : '',
        offerEndDate: _hasOffer ? _formatDate(_offerEndDate) : '',
        offerActive: _hasOffer ? _offerActive : false,
      );

      final bool success = isEditing
          ? await ApiService.updateProduct(productToSave)
          : await ApiService.addProduct(productToSave);

      if (!mounted) {
        return;
      }

      if (success) {
        if (!_categories.contains(categoryToUse)) {
          setState(() {
            _categories.add(categoryToUse);
            _categories = _categories.toSet().toList();
            _categories.sort();
            _selectedCategory = categoryToUse;
            _showNewCategoryField = false;
          });
        }

        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            backgroundColor: _successBg,
            content: Text(
              'تم $action المنتج بنجاح!',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        context.pop(productToSave);
      } else {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            backgroundColor: _errorBg,
            content: Text(
              'حدث خطأ أثناء ال$action',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            backgroundColor: _errorBg,
            content: Text(
              'حدث خطأ غير متوقع: $e',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  DateTime _todayOnly() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  bool _isPastRange(DateTime? start, DateTime? end) {
    if (end == null) {
      return false;
    }

    final t = _todayOnly();
    final e = DateTime(end.year, end.month, end.day);
    return e.isBefore(t);
  }

  String _localDescriptionSuggestion() {
    final name = _nameController.text.trim();
    final cat = _categoryController.text.trim();
    final size = _sizeValueController.text.trim();
    final unit = _selectedUnit.trim();
    final price = _priceController.text.trim();

    final parts = <String>[];

    if (name.isNotEmpty) {
      parts.add('منتج: $name');
    }

    if (cat.isNotEmpty) {
      parts.add('التصنيف: $cat');
    }

    if (size.isNotEmpty) {
      parts.add('الحجم/الوزن: $size $unit');
    }

    if (price.isNotEmpty) {
      parts.add('السعر: $price €');
    }

    final base = parts.isEmpty
        ? 'منتج عالي الجودة مناسب للاستخدام اليومي.'
        : parts.join(' • ');

    final snippets = ApiService.descriptionSnippets(max: 30);
    snippets.shuffle();

    final extras = snippets.isNotEmpty
        ? snippets.take(3).join('\n')
        : 'منتج غذائي عالي الجودة، تم اختياره بعناية ليناسب الاستهلاك اليومي.\n'
        'يتميز بمذاق جيد وقيمة مناسبة، ويلبي احتياجات العائلة.';

    return '$base\n\n$extras';
  }

  InputDecoration _premiumInputDecoration(String label, {IconData? icon, bool isOptional = false}) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: isOptional ? '$label (اختياري)' : label,
      labelStyle: TextStyle(
        color: theme.colorScheme.onSurface.withValues(alpha:0.7),
        fontWeight: FontWeight.w700,
      ),
      filled: true,
      fillColor: theme.colorScheme.surface,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _a(_border, 0.95)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _a(_gold, 0.55), width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _a(Colors.red, 0.6)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _a(Colors.red, 0.8), width: 1.4),
      ),
      prefixIcon: icon != null ? Icon(icon, color: _gold) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productToEdit != null;
    final theme = Theme.of(context);

    final uniqueCategories = _categories
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    uniqueCategories.sort();

    const offerTypes = ['percent', 'bundle'];
    final safeOfferType = offerTypes.contains(_offerType) ? _offerType : 'percent';

    final safeCategory = (uniqueCategories.contains(_categoryController.text.trim()))
        ? _categoryController.text.trim()
        : null;

    final uniqueUnits = _unitOptions
        .map((u) => u.trim())
        .where((u) => u.isNotEmpty)
        .toSet()
        .toList();

    final safeUnit = uniqueUnits.contains(_selectedUnit.trim())
        ? _selectedUnit.trim()
        : (uniqueUnits.isNotEmpty ? uniqueUnits.first : 'kg');

    return Scaffold(
      appBar: PremiumAnimatedAppBar(
        title: isEditing ? 'تعديل المنتج' : 'إضافة منتج',
        showBackButton: true,
        showSettings: false,
        actions: isEditing
            ? [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: _isSaving ? null : _confirmAndDelete,
            tooltip: 'حذف المنتج',
          ),
        ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.of(context).viewPadding.bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // اسم المنتج
              TextFormField(
                controller: _nameController,
                decoration: _premiumInputDecoration('اسم المنتج', icon: Icons.shopping_bag),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'مطلوب';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // السعر والتصنيف
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // السعر
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      focusNode: _priceFocusNode,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [CommaDecimalFormatter(decimalDigits: 2)],
                      decoration: _premiumInputDecoration('السعر', icon: Icons.euro),
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        if (value.isEmpty) {
                          return 'مطلوب';
                        }

                        final reg = RegExp(r'^\d+(?:[.,]\d{1,2})?$');
                        if (!reg.hasMatch(value.replaceAll('.', ','))) {
                          return 'الرجاء إدخال رقم بصيغة 00,00';
                        }

                        final price = _parsePrice(value);
                        if (price <= 0) {
                          return 'السعر يجب أن يكون أكبر من صفر';
                        }

                        return null;
                      },
                      onFieldSubmitted: (_) {
                        _normalizePriceText();
                      },
                      textInputAction: TextInputAction.next,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // التصنيف
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isLoadingCategories)
                          LinearProgressIndicator(
                            color: _gold,
                            backgroundColor: _a(_gold, 0.1),
                          ),

                        if (!_isLoadingCategories)
                          _showNewCategoryField
                              ? TextFormField(
                            controller: _categoryController,
                            focusNode: _categoryFocusNode,
                            autofocus: true,
                            decoration: InputDecoration(
                              labelText: 'التصنيف الجديد',
                              labelStyle: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w700,
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surface,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: Colors.green.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: Colors.green.shade500, width: 1.4),
                              ),
                              prefixIcon: Icon(Icons.add_box, color: Colors.green.shade500),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.cancel, color: Colors.red.shade400),
                                onPressed: () {
                                  setState(() {
                                    _showNewCategoryField = false;
                                    final cur = _selectedCategory?.trim();
                                    if (cur != null && cur.isNotEmpty) {
                                      _categoryController.text = cur;
                                    } else {
                                      _categoryController.clear();
                                    }
                                  });
                                },
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'مطلوب';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                              : DropdownButtonFormField<String>(
                            key: const ValueKey('dd_category'),
                            value: safeCategory,
                            isExpanded: true,
                            dropdownColor: theme.colorScheme.surface,
                            iconEnabledColor: _gold,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _premiumInputDecoration('التصنيف', icon: Icons.grid_view),
                            items: [
                              ...uniqueCategories.map((category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Row(
                                    children: [
                                      Icon(Icons.folder, size: 16, color: _gold),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          category,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              DropdownMenuItem<String>(
                                value: '__NEW__',
                                child: Row(
                                  children: [
                                    Icon(Icons.add, size: 16, color: Colors.green.shade500),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'إضافة تصنيف جديد',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.green.shade500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == '__NEW__') {
                                setState(() {
                                  _showNewCategoryField = true;
                                  _selectedCategory = null;
                                  _categoryController.clear();
                                });

                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (!mounted) return;
                                  _categoryFocusNode.requestFocus();
                                });

                                return;
                              } else {
                                final v = value?.trim();
                                setState(() {
                                  _selectedCategory = v;
                                  _showNewCategoryField = false;
                                  if (v != null) _categoryController.text = v;
                                });
                              }
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'مطلوب';
                              }
                              return null;
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // الوزن/الحجم والوحدة
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sizeValueController,
                      focusNode: _weightFocusNode,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [CommaDecimalFormatter(decimalDigits: 2)],
                      decoration: _premiumInputDecoration('الوزن / الحجم', icon: Icons.scale),
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        if (value.isEmpty) {
                          return 'مطلوب';
                        }

                        final reg = RegExp(r'^\d+(?:[.,]\d{1,2})?$');
                        if (!reg.hasMatch(value.replaceAll('.', ','))) {
                          return 'الرجاء إدخال رقم بصيغة 00,00';
                        }

                        final size = _parsePrice(value);
                        if (size <= 0) {
                          return 'القيمة يجب أن تكون أكبر من صفر';
                        }

                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      key: const ValueKey('dd_sizeUnit'),
                      value: safeUnit,
                      dropdownColor: theme.colorScheme.surface,
                      iconEnabledColor: theme.colorScheme.primary,
                      style: theme.textTheme.bodyLarge, // selected value
                      items: uniqueUnits.map((u) {
                        return DropdownMenuItem(
                          value: u,
                          child: Row(
                            children: [
                              Icon(Icons.straighten, size: 16, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                AppConfig.unitLabel(u),
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setState(() => _selectedUnit = (v ?? safeUnit).trim());
                      },
                      decoration: const InputDecoration(
                        labelText: 'الوحدة',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.straighten),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // رابط الصورة
              TextFormField(
                controller: _imageController,
                decoration: _premiumInputDecoration('رابط الصورة', icon: Icons.image, isOptional: true),
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) {
                    return null;
                  }

                  final uri = Uri.tryParse(value);
                  if (uri == null || !uri.isAbsolute) {
                    return 'الرجاء إدخال رابط صحيح';
                  }

                  if (!uri.scheme.startsWith('http')) {
                    return 'الرابط يجب أن يبدأ بـ http:// أو https://';
                  }

                  return null;
                },
                textInputAction: TextInputAction.next,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              // الوصف
              TextFormField(
                controller: _descriptionController,
                focusNode: _descFocusNode,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'الوصف',
                  labelStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                    fontWeight: FontWeight.w700,
                  ),
                  hintText: 'اكتب وصفًا مختصرًا للمنتج أو استخدم اقتراحًا',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha:0.4),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: _a(_border, 0.95)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: _a(_gold, 0.55), width: 1.4),
                  ),
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description, color: _gold),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.auto_fix_high, color: _gold),
                    tooltip: 'اقتراح وصف',
                    onPressed: _showDescriptionSuggestion,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                textInputAction: TextInputAction.next,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              // المنتج نشط
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _productActive ? _a(_activeGreen, 0.05) : _a(_inactiveGrey, 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _productActive ? _a(_activeGreen, 0.2) : _a(_inactiveGrey, 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _productActive ? Icons.check_circle : Icons.remove_circle,
                      color: _productActive ? _activeGreen : _inactiveGrey,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'المنتج نشط',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'يمكن للعملاء رؤية المنتج إذا كان نشطًا',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _productActive,
                      activeThumbColor: _activeGreen,
                      activeTrackColor: _a(_activeGreen, 0.3),
                      inactiveThumbColor: _inactiveGrey,
                      inactiveTrackColor: _a(_inactiveGrey, 0.3),
                      onChanged: (v) {
                        setState(() {
                          _productActive = v;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // عرض خاص
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _a(_gold, 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _a(_gold, 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_offer, color: _gold, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'يوجد عرض خاص',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'تفعيل عرض خاص لهذا المنتج',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _hasOffer,
                          activeThumbColor: _gold,
                          activeTrackColor: _a(_gold, 0.3),
                          inactiveThumbColor: _inactiveGrey,
                          inactiveTrackColor: _a(_inactiveGrey, 0.3),
                          onChanged: (v) {
                            setState(() {
                              _hasOffer = v;
                            });
                          },
                        ),
                      ],
                    ),

                    if (_hasOffer) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        key: const ValueKey('dd_offerType'),
                        value: safeOfferType,
                        dropdownColor: theme.colorScheme.surface,
                        iconEnabledColor: _gold,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: _premiumInputDecoration('نوع العرض'),
                        items: const [
                          DropdownMenuItem(
                            value: 'percent',
                            child: Row(
                              children: [
                                Icon(Icons.percent, size: 16, color: Colors.orange),
                                SizedBox(width: 8),
                                Text('نسبة مئوية'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'bundle',
                            child: Row(
                              children: [
                                Icon(Icons.all_inbox, size: 16, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('حزمة'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (v) {
                          setState(() {
                            _offerType = (v ?? 'percent').trim();
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      if (_offerType == 'percent')
                        TextFormField(
                          controller: _percentController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [CommaDecimalFormatter(decimalDigits: 2)],
                          decoration: _premiumInputDecoration('النسبة (%)'),
                          validator: (v) {
                            if (!_hasOffer) {
                              return null;
                            }

                            final value = v?.trim() ?? '';
                            if (value.isEmpty) {
                              return 'مطلوب';
                            }

                            final numVal = _parsePrice(value);
                            if (numVal <= 0 || numVal > 100) {
                              return 'أدخل نسبة صحيحة بين 0 و 100';
                            }

                            return null;
                          },
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                      if (_offerType == 'bundle') ...[
                        TextFormField(
                          controller: _bundleQtyController,
                          keyboardType: TextInputType.number,
                          decoration: _premiumInputDecoration('كمية الحزمة'),
                          validator: (v) {
                            if (!_hasOffer) {
                              return null;
                            }

                            final value = v?.trim() ?? '';
                            if (value.isEmpty) {
                              return 'مطلوب';
                            }

                            final intVal = int.tryParse(value);
                            if (intVal == null || intVal <= 0) {
                              return 'أدخل عددًا صحيحًا أكبر من صفر';
                            }

                            return null;
                          },
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _bundlePriceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [CommaDecimalFormatter(decimalDigits: 2)],
                          decoration: _premiumInputDecoration('سعر الحزمة'),
                          validator: (v) {
                            if (!_hasOffer) {
                              return null;
                            }

                            final value = v?.trim() ?? '';
                            if (value.isEmpty) {
                              return 'مطلوب';
                            }

                            final numVal = _parsePrice(value);
                            if (numVal <= 0) {
                              return 'السعر يجب أن يكون أكبر من صفر';
                            }

                            return null;
                          },
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _a(_border, 0.8)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'بداية العرض',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(_offerStartDate),
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _a(_border, 0.8)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'نهاية العرض',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(_offerEndDate),
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.calendar_today, color: _gold),
                            onPressed: () {
                              _selectOfferRange(context);
                            },
                            tooltip: 'تحديد التواريخ',
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            _offerActive ? Icons.check_circle : Icons.cancel,
                            color: _offerActive ? _activeGreen : _inactiveGrey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'العرض نشط',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: _offerActive,
                            activeThumbColor: _activeGreen,
                            activeTrackColor: _a(_activeGreen, 0.3),
                            inactiveThumbColor: _inactiveGrey,
                            inactiveTrackColor: _a(_inactiveGrey, 0.3),
                            onChanged: (v) {
                              if (v == true) {
                                if (_isPastRange(_offerStartDate, _offerEndDate)) {
                                  final messenger = ScaffoldMessenger.of(context);
                                  messenger.showSnackBar(
                                    SnackBar(
                                      backgroundColor: _errorBg,
                                      content: const Text(
                                        'تواريخ العرض قديمة، عدّل التاريخ إلى اليوم أو المستقبل',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  );
                                  return;
                                }
                              }
                              setState(() {
                                _offerActive = v;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // حفظ/تحديث زر
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _gold,
                    foregroundColor: Colors.black,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.black,
                    ),
                  )
                      : Text(
                    isEditing ? 'تحديث المنتج' : 'حفظ المنتج',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}