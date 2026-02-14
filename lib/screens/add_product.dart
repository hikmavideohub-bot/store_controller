import 'dart:async';
import 'package:store_controller/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../config.dart';
import '../widgets/premium_app_bar.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/category_dictionary_service.dart';
import '../core/access_manager.dart';
import '../core/paywall_messages.dart';
import '../storage/store_prefs.dart';
import '../utils/cdn_helper.dart';

class CommaDecimalFormatter extends TextInputFormatter {
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

class AddProductScreen extends StatefulWidget {
  final Product? productToEdit;
  const AddProductScreen({super.key, this.productToEdit});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController,
      _priceController,
      _sizeValueController,
      _imageController,
      _descArController,
      _descDeController,
      _descEnController,
      _descTrController,
      _percentController,
      _discountedPriceController,
      _bundleQtyController,
      _bundlePriceController,
      _bulkQtyController,
      _bulkPriceController,
      _categoryController,
      _thumbController;
  final FocusNode _priceFocusNode = FocusNode(),
      _weightFocusNode = FocusNode(),
      _categoryFocusNode = FocusNode();

  // Bidirektionale Sync-Logik für Percent-Angebot
  bool _syncing = false;
  String _lastEdited = 'percent';

  /// Ermittelt die Textrichtung basierend auf dem ersten Buchstaben
  TextDirection? _getTextDirection(String text) {
    final trimmed = text.trimLeft();
    if (trimmed.isEmpty) return null; // Default verwenden
    final firstChar = trimmed.codeUnitAt(0);
    // Arabisch: U+0600–U+06FF, U+0750–U+077F, U+08A0–U+08FF
    final isArabic =
        (firstChar >= 0x0600 && firstChar <= 0x06FF) ||
        (firstChar >= 0x0750 && firstChar <= 0x077F) ||
        (firstChar >= 0x08A0 && firstChar <= 0x08FF);
    return isArabic ? TextDirection.rtl : TextDirection.ltr;
  }

  bool _uploadingImage = false,
      _isSaving = false,
      _productActive = true,
      _hasOffer = false,
      _offerActive = true,
      _showNewCategoryField = false,
      _isLoadingRecommendation = false,
      _autoTranslateUsed = false;
  String _selectedDescLang = 'de';
  String? _recommendedCategory;
  Timer? _nameDebounce;
  double _uploadProgress = 0.0;
  String _selectedUnit = 'kg', _offerType = 'percent', _uploadStatus = '';
  String? _selectedCategory, _previewImageUrl;
  List<String> _categories = [];
  final List<String> _unitOptions = ['l', 'ml', 'g', 'kg', 'pcs'];
  late DateTime _offerStartDate, _offerEndDate;

  late final String _draftProductId;

  bool _autoTranslateOnCreate = false;

// App-Sprache als “Source-Lang” fürs Auto-Translate
  String _primaryDescLang = 'de';
  bool _didInitDescLang = false;


  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;
    _draftProductId = p?.id ?? const Uuid().v4();

    final initialCat = p?.category.trim() ?? '';
    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController = TextEditingController(text: _formatNumToText(p?.price));
    _sizeValueController = TextEditingController(
      text: _formatNumToText(p?.sizeValue),
    );
    _imageController = TextEditingController(text: p?.image ?? '');
    _thumbController = TextEditingController(text: p?.thumb ?? '');
    _descArController = TextEditingController(text: p?.descriptionMap['ar'] ?? '');
    _descDeController = TextEditingController(text: p?.descriptionMap['de'] ?? '');
    _descEnController = TextEditingController(text: p?.descriptionMap['en'] ?? '');
    _descTrController = TextEditingController(text: p?.descriptionMap['tr'] ?? '');
    _autoTranslateUsed = p?.autoTranslateUsed ?? false;
    _percentController = TextEditingController(
      text: (p != null && p.percent > 0) ? _formatNumToText(p.percent) : '',
    );
    _discountedPriceController = TextEditingController();
    _bundleQtyController = TextEditingController(
      text: (p != null && p.bundleQty > 0) ? p.bundleQty.toString() : '',
    );
    _bundlePriceController = TextEditingController(
      text: (p != null && p.bundlePrice > 0)
          ? _formatNumToText(p.bundlePrice)
          : '',
    );
    _bulkQtyController = TextEditingController(
      text: (p != null && p.bulkQty > 0) ? p.bulkQty.toString() : '',
    );
    _bulkPriceController = TextEditingController(
      text: (p != null && p.bulkPrice > 0) ? _formatNumToText(p.bulkPrice) : '',
    );
    _categoryController = TextEditingController(text: initialCat);

    _selectedUnit = p?.sizeUnit ?? 'kg';

    if (initialCat.isNotEmpty) {
      _categories = [initialCat];
      _selectedCategory = initialCat;
    } else {
      _selectedCategory = null;
    }

    _productActive = p?.productActive ?? true;
    _hasOffer = p?.hasOffer ?? false;
    _offerActive = p?.offerActive ?? true;
    _offerType = (p != null && p.offerType.isNotEmpty)
        ? p.offerType
        : 'percent';

    _offerStartDate = _parseDateSafe(p?.offerStartDate, DateTime.now());
    _offerEndDate = _parseDateSafe(
      p?.offerEndDate,
      DateTime.now().add(const Duration(days: 5)),
    );

    _loadCategories();
    _nameController.addListener(_onNameChangedForRecommendation);

    // In edit mode, trigger recommendation lookup immediately
    if (p != null && p.name.isNotEmpty) {
      final editName = p.name;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchRecommendation(editName);
      });
    }

    _priceFocusNode.addListener(() {
      if (!_priceFocusNode.hasFocus) _normalizePriceText();
    });
    _weightFocusNode.addListener(() {
      if (!_weightFocusNode.hasFocus) _normalizeWeightText();
    });

    // Bidirektionale Listener für Percent-Angebot
    _percentController.addListener(_onPercentChanged);
    _discountedPriceController.addListener(_onDiscountedChanged);
    _priceController.addListener(_onRegularPriceChanged);

    // Initial discounted price berechnen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDiscountedPrice();
      _checkAccessOnLoad();
    });
  }

  void _initDiscountedPrice() {
    final regular = _getRegularPriceValue();
    final percent = _parseNum(_percentController.text);
    if (regular != null && regular > 0 && percent > 0) {
      final discounted = regular * (1 - percent / 100);
      _discountedPriceController.text = _fmtMoney(discounted);
    }
  }

  void _onPercentChanged() {
    if (_syncing || _offerType != 'percent') return;
    _lastEdited = 'percent';
    _syncFromPercent();
  }

  void _onDiscountedChanged() {
    if (_syncing || _offerType != 'percent') return;
    _lastEdited = 'discounted';
    _syncFromDiscounted();
  }

  void _onRegularPriceChanged() {
    if (_syncing || _offerType != 'percent') return;
    // Basierend auf lastEdited neu berechnen
    if (_lastEdited == 'percent') {
      _syncFromPercent();
    } else {
      _syncFromDiscounted();
    }
  }

  void _syncFromPercent() {
    final regular = _getRegularPriceValue();
    if (regular == null || regular <= 0) return;

    final percentText = _percentController.text;
    var percent = _parseNum(percentText).clamp(0.0, 99.99);

    final discounted = regular * (1 - percent / 100);

    _syncing = true;
    _discountedPriceController.text = _fmtMoney(discounted.clamp(0, regular));
    _syncing = false;
  }

  void _syncFromDiscounted() {
    final regular = _getRegularPriceValue();
    if (regular == null || regular <= 0) return;

    final discountedText = _discountedPriceController.text;
    var discounted = _parseNum(discountedText).clamp(0.0, regular);

    final percent = ((1 - discounted / regular) * 100).clamp(0.0, 99.99);

    _syncing = true;
    _percentController.text = _fmtPercent(percent);
    _syncing = false;
  }

  double _parseNum(String s) {
    if (s.isEmpty) return 0.0;
    return double.tryParse(s.replaceAll(',', '.').trim()) ?? 0.0;
  }

  String _fmtMoney(double v) {
    if (v == v.roundToDouble()) {
      return v.toStringAsFixed(0).replaceAll('.', ',');
    }
    return v.toStringAsFixed(2).replaceAll('.', ',');
  }

  String _fmtPercent(double v) {
    if (v == v.roundToDouble()) {
      return v.toStringAsFixed(0);
    }
    return v.toStringAsFixed(1).replaceAll('.', ',');
  }

  double? _getRegularPriceValue() {
    final s = _calculateRegularPrice();
    if (s == '—') return null;
    return _parseNum(s);
  }

  DateTime _parseDateSafe(String? s, DateTime fallback) {
    if (s == null || s.isEmpty) return fallback;
    try {
      if (s.contains('T')) return DateTime.parse(s);
      final parts = s.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
      return fallback;
    } catch (_) {
      return fallback;
    }
  }

  String _formatDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  Future<void> _waitForTranslationAndFill(String storeId, String productId) async {
    final ref = FirebaseFirestore.instance
        .collection('stores_public')
        .doc(storeId)
        .collection('products')
        .doc(productId);

    final snap = await ref.snapshots(includeMetadataChanges: false).firstWhere((s) {
      final d = s.data();
      if (d == null) return false;
      final st = (d['descTranslationStatus'] ?? '').toString();
      return st == 'ready' || st.startsWith('pending_');
    });

    final d = snap.data() ?? {};
    final raw = d['description'];

    if (raw is! Map) return;
    final desc = Map<String, dynamic>.from(raw);

    final ar = (desc['ar'] ?? '').toString();
    final de = (desc['de'] ?? '').toString();
    final en = (desc['en'] ?? '').toString();
    final tr = (desc['tr'] ?? '').toString();

    // ✅ nur leere Felder füllen (niemals User-Text überschreiben)
    if (_descArController.text.trim().isEmpty && ar.trim().isNotEmpty) _descArController.text = ar;
    if (_descDeController.text.trim().isEmpty && de.trim().isNotEmpty) _descDeController.text = de;
    if (_descEnController.text.trim().isEmpty && en.trim().isNotEmpty) _descEnController.text = en;
    if (_descTrController.text.trim().isEmpty && tr.trim().isNotEmpty) _descTrController.text = tr;

    if (mounted) setState(() {});
  }

  Future<void> _checkAccessOnLoad() async {
    if (!AccessManager.canWriteAdmin) {
      await showFabPaywallDialog(context);
      if (mounted) context.pop();
    }
  }

  @override
  void dispose() {
    _nameDebounce?.cancel();
    _nameController.removeListener(_onNameChangedForRecommendation);
    _percentController.removeListener(_onPercentChanged);
    _discountedPriceController.removeListener(_onDiscountedChanged);
    _priceController.removeListener(_onRegularPriceChanged);
    for (var c in [
      _nameController,
      _priceController,
      _sizeValueController,
      _imageController,
      _descArController,
      _descDeController,
      _descEnController,
      _descTrController,
      _percentController,
      _discountedPriceController,
      _bundleQtyController,
      _bundlePriceController,
      _bulkQtyController,
      _bulkPriceController,
      _categoryController,
      _thumbController,
    ]) {
      c.dispose();
    }
    _priceFocusNode.dispose();
    _weightFocusNode.dispose();
    _categoryFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitDescLang) return;

    final appLang = Localizations.localeOf(context).languageCode;
    const supported = {'ar', 'de', 'en', 'tr'};
    _primaryDescLang = supported.contains(appLang) ? appLang : 'de';

    // initiale Anzeige-Sprache = App-Sprache
    _selectedDescLang = _primaryDescLang;

    _didInitDescLang = true;
  }


  // CDN URLs werden über CdnHelper konstruiert (lib/utils/cdn_helper.dart)

  /// Löscht das aktuelle Bild aus Firebase Storage
  Future<void> _deleteCurrentImage() async {
    final currentImageUrl = _imageController.text;
    if (currentImageUrl.isEmpty) return;

    // UI sofort aktualisieren
    setState(() {
      _imageController.clear();
      _thumbController.clear();
      _previewImageUrl = null;
    });

    // Bild im Hintergrund aus Storage löschen
    try {
      final storeId = await StorePrefs.getStoreId();
      final productId = widget.productToEdit?.id;
      if (storeId == null || productId == null) return;
      // Nur CDN/Storage-Bilder löschen (bei externen Links NICHT in Storage eingreifen)
      if (!_isManagedCdnImage(currentImageUrl)) return;

      await _deleteImagesFromStorage(storeId, productId, currentImageUrl);
    } catch (e) {
      debugPrint('Error deleting image from storage: $e');
    }
  }

  /// Löscht Bilder aus Firebase Storage basierend auf der URL
  Future<void> _deleteImagesFromStorage(
    String storeId,
    String productId,
    String imageUrl,
  ) async {
    try {
      final storage = FirebaseStorage.instanceFor(
        bucket: 'gs://aldeebtech-1ec64.firebasestorage.app',
      );

      // Extrahiere den Dateinamen aus der URL (z.B. img_17065678123.jpg)
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      String? filename;

      // CDN URL Format: /images/stores/{storeId}/products/{productId}/{filename}
      if (pathSegments.isNotEmpty) {
        filename = pathSegments.last;
        // Entferne _1600x1600 oder _360x360 Suffix um den Basisnamen zu bekommen
        filename = filename
            .replaceAll('_1600x1600.jpeg', '')
            .replaceAll('_360x360.jpeg', '')
            .replaceAll('.jpg', '')
            .replaceAll('.jpeg', '');
      }

      if (filename == null || filename.isEmpty) return;

      final baseRef = storage.ref('stores/$storeId/products/$productId');

      // Alle möglichen Varianten löschen
      final filesToDelete = [
        '$filename.jpg',
        '$filename.jpeg',
        '${filename}_360x360.jpeg',
        '${filename}_1600x1600.jpeg',
      ];

      for (final file in filesToDelete) {
        try {
          await baseRef.child(file).delete();
          debugPrint('Deleted: $file');
        } catch (_) {
          // Datei existiert möglicherweise nicht
        }
      }
    } catch (e) {
      debugPrint('Error in _deleteImagesFromStorage: $e');
    }
  }

  Future<void> _pickAndUploadImage() async {
    final s = AppLocalizations.of(context)!;
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    final storeId = await StorePrefs.getStoreId();
    if (storeId == null) return;

    // Altes Bild merken für spätere Löschung
    final oldImageUrl = _imageController.text;

    setState(() {
      _uploadingImage = true;
      _uploadProgress = 0.0;
      _uploadStatus = s.uploading;
    });

    try {
      final productId = _draftProductId;
      final storage = FirebaseStorage.instanceFor(
        bucket: 'gs://aldeebtech-1ec64.firebasestorage.app',
      );
      final baseRef = storage.ref('stores/$storeId/products/$productId');

      // NEU: Zeitstempel generieren, damit der Cache beim Update invalidiert wird
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueName = 'img_$timestamp'; // z.B. img_17065678123

      final imageRef = baseRef.child('$uniqueName.jpg'); // Original

      // Bild hochladen
      final task = imageRef.putData(
        await file.readAsBytes(),
        SettableMetadata(
          contentType: 'image/jpeg',
          // WICHTIG: Cache-Control im Storage klein halten, CDN macht den Rest
          cacheControl: 'public, max-age=3600',
        ),
      );

      task.snapshotEvents.listen((s) {
        if (mounted) {
          setState(() => _uploadProgress = s.bytesTransferred / s.totalBytes);
        }
      });
      await task;

      if (mounted) setState(() => _uploadStatus = s.processing);

      // Warten auf Resize-Extension
      final thumbRef = baseRef.child('${uniqueName}_360x360.jpeg');
      final fullRef = baseRef.child('${uniqueName}_1600x1600.jpeg');

      final thumbExists = await _waitForResizedImage(thumbRef, maxAttempts: 15);
      final fullExists = await _waitForResizedImage(fullRef, maxAttempts: 20);

      final thumbFilename = thumbExists
          ? '${uniqueName}_360x360.jpeg'
          : '$uniqueName.jpg';
      final fullFilename = fullExists
          ? '${uniqueName}_1600x1600.jpeg'
          : '$uniqueName.jpg';

      final thumbCdnUrl = CdnHelper.buildUrl(
        storeId: storeId,
        productId: productId,
        filename: thumbFilename,
      );
      final fullCdnUrl = CdnHelper.buildUrl(
        storeId: storeId,
        productId: productId,
        filename: fullFilename,
      );

      if (mounted) {
        setState(() {
          _imageController.text = fullCdnUrl; // Speichert die CDN URL
          _thumbController.text = thumbCdnUrl;
          _previewImageUrl = thumbCdnUrl; // Zeigt Vorschau sofort an
          _uploadingImage = false;
        });

        // Altes Bild im Hintergrund löschen (falls vorhanden)
        if (oldImageUrl.isNotEmpty) {
          _deleteImagesFromStorage(storeId, productId, oldImageUrl);
        }
      }
    } catch (e) {
      debugPrint('Image upload error: $e');
      if (mounted) {
        setState(() {
          _uploadingImage = false;
          _uploadStatus = s.errorStatus;
        });
      }
    }
  }

  Future<bool> _waitForResizedImage(
    Reference ref, {
    int maxAttempts = 15,
  }) async {
    var delayMs = 600;
    for (var i = 0; i < maxAttempts; i++) {
      try {
        await ref.getDownloadURL();
        return true;
      } catch (e) {
        await Future.delayed(Duration(milliseconds: delayMs));
        delayMs = (delayMs * 1.3).round().clamp(600, 2500);
      }
    }
    return false;
  }

  void _onNameChangedForRecommendation() {
    _nameDebounce?.cancel();
    final text = _nameController.text.trim();
    if (text.length < 2) {
      if (_recommendedCategory != null) {
        setState(() => _recommendedCategory = null);
      }
      return;
    }
    _nameDebounce = Timer(const Duration(milliseconds: 500), () {
      _fetchRecommendation(text);
    });
  }

  Future<void> _fetchRecommendation(String name) async {
    if (!mounted) return;
    setState(() => _isLoadingRecommendation = true);
    try {
      final locale = Localizations.localeOf(context).languageCode;
      final result =
          await CategoryDictionaryService.instance.getBestRecommendation(name, locale);
      if (mounted) {
        setState(() {
          _recommendedCategory = result?.label;
          _isLoadingRecommendation = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingRecommendation = false);
      }
    }
  }

  void _applyRecommendedCategory() {
    final rec = _recommendedCategory;
    if (rec == null) return;
    setState(() {
      if (!_categories.contains(rec)) {
        _categories = [..._categories, rec]..sort();
      }
      _selectedCategory = rec;
      _categoryController.text = rec;
      _showNewCategoryField = false;
    });
  }

  void _loadCategories() async {
    try {
      final cats = await ApiService.fetchCategories();
      if (mounted) {
        setState(() {
          final current = _categoryController.text.trim();
          final all = <String>{...cats};
          if (current.isNotEmpty) all.add(current);
          _categories = all.toList()..sort();
          _selectedCategory = current.isNotEmpty ? current : null;
        });
      }
    } catch (_) {}
  }

  String _formatNumToText(dynamic v) =>
      v == null ? '' : v.toString().replaceAll('.', ',');
  double _parsePrice(String v) =>
      double.tryParse(v.replaceAll(',', '.')) ?? 0.0;
  void _normalizePriceText() {
    if (_priceController.text.isNotEmpty) {
      _priceController.text = _formatNumToText(
        _parsePrice(_priceController.text),
      );
    }
  }

  void _normalizeWeightText() {
    if (_sizeValueController.text.isNotEmpty) {
      _sizeValueController.text = _formatNumToText(
        _parsePrice(_sizeValueController.text),
      );
    }
  }

  Future<void> _selectOfferRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(
        start: _offerStartDate,
        end: _offerEndDate,
      ),
    );
    if (picked != null) {
      setState(() {
        _offerStartDate = picked.start;
        _offerEndDate = picked.end;
      });
    }
  }

  Future<void> _submit() async {
    final s = AppLocalizations.of(context)!;
    if (_isSaving) return;

    // Pflichtfelder prüfen und fehlende sammeln
    final missing = <String>[];
    if (_nameController.text.trim().isEmpty) missing.add(s.productNameLabel);
    if (_priceController.text.trim().isEmpty) missing.add(s.priceLabel);
    if (_categoryController.text.trim().isEmpty) missing.add(s.categoryLabel);
    if (_sizeValueController.text.trim().isEmpty) missing.add(s.sizeLabel);

    // Form-Validierung auslösen (zeigt rote Ränder bei leeren Feldern)
    _formKey.currentState?.validate();

    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            s.fieldsMissing(missing.join(', ')),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 1. Produktlimit prüfen (nur bei neuem Produkt)
    final isNew = widget.productToEdit == null;
    if (isNew &&
        ApiService.productsNotifier.value.length >= AppConfig.maxFreeProducts) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.productLimitReached),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      // Bild/Thumb Konsistenz
      final imgUrl = _imageController.text.trim();
      if (imgUrl.isEmpty) {
        _thumbController.clear();
      }

      final p = Product(
        id: _draftProductId,
        name: _nameController.text.trim(),
        price: _parsePrice(_priceController.text),
        sizeValue: _parsePrice(_sizeValueController.text),
        sizeUnit: _selectedUnit,
        image: _imageController.text.trim(),
        thumb: _thumbController.text.trim(),
        description: _descDeController.text.trim().isNotEmpty
            ? _descDeController.text.trim()
            : _descEnController.text.trim().isNotEmpty
                ? _descEnController.text.trim()
                : _descArController.text.trim().isNotEmpty
                    ? _descArController.text.trim()
                    : _descTrController.text.trim(),
        descriptionMap: {
          'ar': _descArController.text.trim(),
          'de': _descDeController.text.trim(),
          'en': _descEnController.text.trim(),
          'tr': _descTrController.text.trim(),
        },
        category: _categoryController.text.trim(),
        productActive: _productActive,
        hasOffer: _hasOffer,
        offerType: _hasOffer ? _offerType : '',
        percent: (_hasOffer && _offerType == 'percent')
            ? _parsePrice(_percentController.text)
            : 0,
        bundleQty: (_hasOffer && _offerType == 'bundle')
            ? (int.tryParse(_bundleQtyController.text) ?? 0)
            : 0,
        bundlePrice: (_hasOffer && _offerType == 'bundle')
            ? _parsePrice(_bundlePriceController.text)
            : 0,
        bulkQty: (_hasOffer && _offerType == 'bulk')
            ? (int.tryParse(_bulkQtyController.text) ?? 0)
            : 0,
        bulkPrice: (_hasOffer && _offerType == 'bulk')
            ? _parsePrice(_bulkPriceController.text)
            : 0,
        offerStartDate: _hasOffer ? _formatDate(_offerStartDate) : '',
        offerEndDate: _hasOffer ? _formatDate(_offerEndDate) : '',
        offerActive: _hasOffer ? _offerActive : false,
      );
      final success = widget.productToEdit != null
          ? await ApiService.updateProduct(p)
          : await ApiService.addProduct(
        p,
        descAutoTranslateRequested: _autoTranslateOnCreate,
        sourceHint: _primaryDescLang,
      );




      if (success && widget.productToEdit == null && _autoTranslateOnCreate) {
        final storeId = ApiService.storeId;
        if (storeId != null) {
          await _waitForTranslationAndFill(storeId, _draftProductId);
        }
      }

      if (mounted && success) {
        // Bestätigungsnachricht anzeigen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              s.productPublishedMsg,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        // Kurze Verzögerung damit der User die Message sieht
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) context.pop(p);
      }

    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Design Helper für saubere Inputs MIT 'X' CLEAR BUTTON
  InputDecoration _premiumInputDecoration(
    String label, {
    IconData? icon,
    bool isOptional = false,
    TextEditingController? controller,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;

    return InputDecoration(
      labelText: isOptional ? '$label ${s.optionalSuffix}' : label,
      labelStyle: TextStyle(
        color: theme.hintColor,
        fontWeight: FontWeight.w700,
      ),
      filled: true,
      fillColor: colors.surface,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.outline.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.primary, width: 1.6),
      ),
      prefixIcon: icon != null ? Icon(icon, color: colors.primary) : null,
      // Zeige X nur wenn Controller übergeben wurde und nicht leer ist
      suffixIcon: controller != null
          ? ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  color: theme.hintColor,
                  onPressed: () => controller.clear(),
                );
              },
            )
          : null,
    );
  }

  // Hilfsmethode zur Übersetzung der Einheiten
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;
    final isEditing = widget.productToEdit != null;

// Upload-Overlay liegt auf dunklem Scrim → Farbe muss immer gut sichtbar sein
    final uploadOverlayFg = theme.brightness == Brightness.dark
        ? colors.onSurface
        : colors.onPrimary;


    // Lokalisierte Vorschläge
    final List<String> descSuggestions = [
      s.descQuality,
      s.descFresh,
      s.descBestseller,
      s.descLimited,
      s.descHandmade,
      s.descNatural,
    ];

    String? validateRequired(String? v) =>
        (v == null || v.trim().isEmpty) ? s.requiredField : null;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: PremiumAnimatedAppBar(
        title: isEditing ? s.editProductTitle : s.addProductTitle,
        showBackButton: true,
      ),
      // --- STICKY PUBLISH BUTTON (Pillen-Form mit Icon) ---
      // Bleibt immer sichtbar, auch wenn Tastatur geöffnet ist
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
          child: ElevatedButton.icon(
            onPressed: _isSaving || _uploadingImage ? null : _submit,
            icon: _isSaving
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                value: _uploadProgress > 0 ? _uploadProgress : null,
                color: uploadOverlayFg,
                backgroundColor: uploadOverlayFg.withValues(alpha: 0.18),
              ),
            )
                : const Icon(Icons.rocket_launch, size: 20),
            label: Text(
              s.publishButton,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              elevation: 3,
              shadowColor: colors.primary.withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: const StadiumBorder(),
            ),
          ),
        ),
      ),
      // -------------------------------
      body: SingleChildScrollView(
        // Padding unten entfernt, da BottomBar jetzt Platz einnimmt
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _nameController,
                builder: (context, value, _) {
                  final dir = _getTextDirection(value.text) ?? Directionality.of(context);

                  return TextFormField(
                    controller: _nameController,
                    textDirection: dir,
                    onTap: () {
                      // Workaround: RTL-Cursor landet manchmal auf (len-1) statt len
                      if (dir != TextDirection.rtl) return;

                      Future.microtask(() {
                        final len = _nameController.text.length;
                        final sel = _nameController.selection;

                        if (len > 0 && sel.isCollapsed && sel.baseOffset == len - 1) {
                          _nameController.selection = TextSelection.collapsed(offset: len);
                        }
                      });
                    },
                    decoration: _premiumInputDecoration(
                      s.productNameLabel,
                      icon: Icons.shopping_bag,
                      controller: _nameController,
                    ),
                    validator: validateRequired,
                  );
                },
              ),
              const SizedBox(height: 16),

              // --- PREIS/GRÖßE (links) + KATEGORIE-EMPFEHLUNG/DROPDOWN (rechts) ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Linke Spalte: Preis → Size ──
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _priceController,
                          focusNode: _priceFocusNode,
                          textDirection: TextDirection.ltr,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [CommaDecimalFormatter()],
                          decoration: _premiumInputDecoration(
                            s.priceLabel,
                            icon: Icons.euro,
                          ),
                          validator: validateRequired,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _sizeValueController,
                          focusNode: _weightFocusNode,
                          textDirection: TextDirection.ltr,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [CommaDecimalFormatter()],
                          decoration: _premiumInputDecoration(
                            s.sizeLabel,
                            controller: _sizeValueController,
                          ).copyWith(
                            prefixIcon: Icon(Icons.scale, size: 20, color: colors.primary), // kleiner
                            prefixIconConstraints: const BoxConstraints(minWidth: 34, minHeight: 0), // optional
                          ),
                          validator: validateRequired,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // ── Rechte Spalte: Empfohlene Kategorie → Kategorie-Dropdown ──
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        InkWell(
                          onTap: _recommendedCategory != null && !_isLoadingRecommendation
                              ? _applyRecommendedCategory
                              : null,
                          borderRadius: BorderRadius.circular(14),
                          child: AbsorbPointer(
                            child: TextFormField(
                              readOnly: true,
                              decoration: _premiumInputDecoration(
                                s.recommendedCategoryLabel,
                                icon: Icons.auto_awesome,
                              ).copyWith(
                                suffixIcon: _isLoadingRecommendation
                                    ? Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      )
                                    : _recommendedCategory != null
                                        ? Icon(Icons.touch_app, size: 20, color: colors.primary)
                                        : null,
                              ),
                              controller: TextEditingController(
                                text: _isLoadingRecommendation
                                    ? ''
                                    : (_recommendedCategory ?? '—'),
                              ),
                              style: TextStyle(
                                color: _recommendedCategory != null
                                    ? colors.onSurface
                                    : colors.onSurface.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _showNewCategoryField
                            ? TextFormField(
                                controller: _categoryController,
                                focusNode: _categoryFocusNode,
                                textDirection: _getTextDirection(
                                  _categoryController.text,
                                ),
                                onChanged: (_) =>
                                    setState(() {}),
                                decoration:
                                    _premiumInputDecoration(
                                      s.newCategoryLabel,
                                      icon: Icons.add_box,
                                    ).copyWith(
                                      suffixIcon: IconButton(
                                        icon: const Icon(
                                          Icons.cancel,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _showNewCategoryField = false;
                                            _categoryController.text =
                                                _selectedCategory ?? '';
                                          });
                                        },
                                      ),
                                    ),
                                validator: validateRequired,
                              )
                            : DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue:
                                    _categories.contains(_selectedCategory)
                                    ? _selectedCategory
                                    : null,
                                decoration: _premiumInputDecoration(
                                  s.categoryLabel,
                                  icon: Icons.grid_view,
                                ),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? s.requiredField
                                    : null,
                                items: [
                                  ..._categories.map(
                                    (c) =>
                                        DropdownMenuItem(value: c, child: Text(c)),
                                  ),
                                  DropdownMenuItem(
                                    value: 'new',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.add_circle_outline,
                                          size: 20,
                                          color: colors.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          s.addNewCategory,
                                          style: TextStyle(
                                            color: colors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v == 'new') {
                                    setState(() {
                                      _showNewCategoryField = true;
                                      _categoryController.clear();
                                    });
                                    WidgetsBinding.instance.addPostFrameCallback(
                                      (_) => _categoryFocusNode.requestFocus(),
                                    );
                                  } else if (v != null) {
                                    setState(() {
                                      _selectedCategory = v;
                                      _categoryController.text = v;
                                    });
                                  }
                                },
                              ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  segments: _unitOptions
                      .map(
                        (u) => ButtonSegment(
                          value: u,
                          label: Text(
                            _getUnitLabel(u, s),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      )
                      .toList(),
                  selected: {_selectedUnit},
                  onSelectionChanged: (newSet) =>
                      setState(() => _selectedUnit = newSet.first),
                  showSelectedIcon: false,
                  style: SegmentedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),

              // ---------------------------------------------------------------
              const SizedBox(height: 24),

              // MODERNER BILD UPLOAD BEREICH
              _buildImageSection(theme, colors),

              // Toggle nur beim Erstellen
              if (widget.productToEdit == null) ...[
                SwitchListTile.adaptive(
                  value: _autoTranslateOnCreate,
                  title: Text(s.autoTranslateOnCreateTitle),
                  subtitle: _autoTranslateOnCreate
                      ? Text(
                    s.autoTranslateOnCreateHint,
                    style: const TextStyle(fontSize: 12),
                  )
                      : null,
                  onChanged: (v) => setState(() => _autoTranslateOnCreate = v),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
              ],



              const SizedBox(height: 24),

              // DESCRIPTION — Language Tabs
              _buildDescriptionSection(s, colors, descSuggestions),

              const SizedBox(height: 24),

              // PRODUCT ACTIVE SWITCH (Modern Style)
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.outline.withValues(alpha: 0.1),
                  ),
                ),
                child: SwitchListTile.adaptive(
                  title: Text(
                    s.productAvailable,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    _productActive
                        ? s.visibleToCustomers
                        : s.hiddenFromCustomers,
                    style: TextStyle(fontSize: 12, color: theme.hintColor),
                  ),
                  value: _productActive,
                  activeTrackColor: colors.primary,
                  onChanged: (v) => setState(() => _productActive = v),
                ),
              ),
              const SizedBox(height: 16),

              // OFFER CONTAINER (Verbessert & Parallel)
              _buildOfferSection(theme, colors),

              const SizedBox(height: 32),

              // HIER WAR VORHER DER SAVE BUTTON - JETZT GELÖSCHT
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Description section with language tabs
  // ---------------------------------------------------------------------------

  TextEditingController _descControllerFor(String lang) {
    switch (lang) {
      case 'ar': return _descArController;
      case 'de': return _descDeController;
      case 'en': return _descEnController;
      case 'tr': return _descTrController;
      default:   return _descDeController;
    }
  }

  String _descHint(AppLocalizations s, String lang) {
    switch (lang) {
      case 'ar': return s.descriptionHintAr;
      case 'de': return s.descriptionHintDe;
      case 'en': return s.descriptionHintEn;
      case 'tr': return s.descriptionHintTr;
      default:   return s.descriptionLabel;
    }
  }

  Widget _buildDescriptionSection(
    AppLocalizations s,
    ColorScheme colors,
    List<String> descSuggestions,
  ) {
    final langLabels = {
      'ar': s.descLangAr,
      'de': s.descLangDe,
      'en': s.descLangEn,
      'tr': s.descLangTr,
    };

    final orderedLangs = <String>[
      _primaryDescLang,
      ...['ar', 'de', 'en', 'tr'].where((l) => l != _primaryDescLang),
    ];

    final ctrl = _descControllerFor(_selectedDescLang);

// Limit nur für Create + Toggle true + Source-Feld (Primary)
    final limitAuto = widget.productToEdit == null &&
        _autoTranslateOnCreate &&
        _selectedDescLang == _primaryDescLang;


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Language selector
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<String>(
            segments: orderedLangs
                .map((k) => ButtonSegment<String>(value: k, label: Text(langLabels[k]!)))
                .toList(),
            selected: {_selectedDescLang},
            onSelectionChanged: (newSet) => setState(() => _selectedDescLang = newSet.first),
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Description field for selected language
        TextFormField(
          key: ValueKey('desc_$_selectedDescLang'),
          controller: ctrl,
          maxLines: 3,
          maxLength: limitAuto ? 300 : null,
          inputFormatters: limitAuto ? [LengthLimitingTextInputFormatter(300)] : null,
          textDirection: _selectedDescLang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          onChanged: (_) => setState(() {}),
          decoration: _premiumInputDecoration(
            _descHint(s, _selectedDescLang),
            icon: Icons.description,
            controller: ctrl,
          ),
        ),

        // Suggestion chips
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: descSuggestions.length,
            separatorBuilder: (ctx, i) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) {
              return ActionChip(
                label: Text(
                  descSuggestions[i],
                  style: TextStyle(fontSize: 12, color: colors.onSurface),
                ),
                backgroundColor: colors.surfaceContainer,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onPressed: () {
                  final text = ctrl.text;
                  final toAdd = descSuggestions[i];
                  ctrl.text = text.isEmpty ? toAdd : '$text\n$toAdd';
                },
              );
            },
          ),
        ),

        if (_autoTranslateUsed && widget.productToEdit != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: colors.primary),
              const SizedBox(width: 6),
              Text(
                s.autoTranslateUsed,
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ],
    );
  }


  Widget _buildImageSection(ThemeData theme, ColorScheme colors) {
    final s = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.productImageLabel,
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.hintColor),
        ),
        const SizedBox(height: 8),
        _buildUploadCard(theme, colors),
      ],
    );
  }

  Widget _buildUploadCard(ThemeData theme, ColorScheme colors, {Key? key}) {
    final s = AppLocalizations.of(context)!;
    final imageUrl = _previewImageUrl ?? _imageController.text;
    final hasImage = imageUrl.trim().isNotEmpty;

    return InkWell(
      key: key,
      onTap: _uploadingImage ? null : _pickAndUploadImage,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: hasImage
              ? null
              : Border.all(color: colors.outline.withValues(alpha: 0.3)),
          boxShadow: hasImage
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
          image: hasImage
              ? DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (!hasImage && !_uploadingImage)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 48,
                    color: colors.primary.withValues(alpha: 0.55),
                  ),
                  const SizedBox(height: 8),
                  Text(s.tapToUpload, style: TextStyle(color: theme.hintColor)),
                ],
              ),

            // Upload Overlay
            if (_uploadingImage)
              Container(
                decoration: BoxDecoration(
                  color: colors.scrim.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        value: _uploadProgress > 0 ? _uploadProgress : null,
                        color: theme.brightness == Brightness.dark ? colors.onSurface : colors.onPrimary,
                        backgroundColor: (theme.brightness == Brightness.dark ? colors.onSurface : colors.onPrimary)
                            .withValues(alpha:0.18),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: theme.brightness == Brightness.dark ? colors.onSurface : colors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _uploadStatus,
                        style: TextStyle(
                          color: (theme.brightness == Brightness.dark ? colors.onSurface : colors.onPrimary)
                              .withValues(alpha:0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Edit/Delete Buttons wenn Bild da ist
            if (hasImage && !_uploadingImage)
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: colors.scrim.withValues(alpha: 0.6),
                      child: IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: colors.onPrimary,
                          size: 20,
                        ),
                        onPressed: _pickAndUploadImage,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: colors.error.withValues(alpha: 0.85),
                      child: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: colors.onError,
                          size: 20,
                        ),
                        onPressed: () => _deleteCurrentImage(),
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

  bool _isManagedCdnImage(String url) {
    try {
      final u = Uri.parse(url.trim());
      final host = (u.host).toLowerCase();
      final path = (u.path).toLowerCase();
      // Heuristik: eigene CDN/Storage-URLs erkennen
      if (host.contains('aldeebtech') || host.contains('firebasestorage')) {
        return true;
      }
      if (path.contains('/images/stores/') || path.contains('/stores/')) {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Berechnet den Normalpreis basierend auf Angebotstyp
  String _calculateRegularPrice() {
    final unitPrice = _parsePrice(_priceController.text);
    if (unitPrice <= 0) return '—';

    switch (_offerType) {
      case 'percent':
        // Normaler Preis = Stückpreis
        return _formatNumToText(unitPrice);
      case 'bundle':
        // Normaler Preis = Stückpreis × Menge
        final qty = int.tryParse(_bundleQtyController.text) ?? 0;
        if (qty <= 0) return '—';
        return _formatNumToText(unitPrice * qty);
      case 'bulk':
        // Normaler Preis = Stückpreis
        return _formatNumToText(unitPrice);
      default:
        return '—';
    }
  }

  Widget _buildOfferSection(ThemeData theme, ColorScheme colors) {
    final s = AppLocalizations.of(context)!;

    InputDecoration tinyLabel({
      required String labelText,
      IconData? icon,
      String? hintText,
      Widget? suffixIcon,
      bool readOnly = false,
    }) {
      return InputDecoration(
        label: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            labelText,
            maxLines: 1,
            softWrap: false,
            style: TextStyle(
              color: theme.hintColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: theme.hintColor.withValues(alpha: 0.55),
          fontSize: 11,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: readOnly
            ? colors.surfaceContainerHighest.withValues(alpha: 0.65)
            : colors.surfaceContainerHighest.withValues(alpha: 0.45),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.outline.withValues(alpha: 0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.primary, width: 1.6),
        ),
        prefixIcon: icon == null ? null : Icon(icon, color: theme.hintColor),
        suffixIcon: suffixIcon,
      );
    }

    Widget clearButton(TextEditingController ctrl) {
      return ValueListenableBuilder<TextEditingValue>(
        valueListenable: ctrl,
        builder: (context, v, _) => v.text.isEmpty
            ? const SizedBox.shrink()
            : IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: ctrl.clear,
              ),
      );
    }

    Widget infoChip(String label, String value, {Color? valueColor}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colors.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: ',
              style: TextStyle(fontSize: 11, color: theme.hintColor),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: valueColor ?? colors.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _hasOffer
              ? colors.tertiary.withValues(alpha: 0.55)
              : colors.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          // ══════════════════════════════════════════════════════════════════
          // HEADER: Zwei Switches parallel (hasOffer + offerActive)
          // ══════════════════════════════════════════════════════════════════
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: Row(
              children: [
                // Switch: hasOffer
                Expanded(
                  child: Row(
                    children: [
                      Switch.adaptive(
                        value: _hasOffer,
                        activeTrackColor: colors.tertiary,
                        onChanged: (v) => setState(() {
                          _hasOffer = v;
                          if (v) {
                            _offerActive = true;
                            _initDiscountedPrice();
                          }
                        }),
                      ),
                      Expanded(
                        child: Text(
                          s.specialOfferAvailable,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: _hasOffer ? colors.tertiary : colors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Switch: offerActive (nur sichtbar wenn hasOffer)
                if (_hasOffer)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 8),
                      Container(
                        height: 24,
                        width: 1,
                        color: colors.outline.withValues(alpha: 0.2),
                      ),
                      const SizedBox(width: 8),
                      Switch.adaptive(
                        value: _offerActive,
                        activeTrackColor: Colors.green,
                        onChanged: (v) => setState(() => _offerActive = v),
                      ),
                      Icon(
                        _offerActive ? Icons.visibility : Icons.visibility_off,
                        size: 18,
                        color: _offerActive ? Colors.green : theme.hintColor,
                      ),
                    ],
                  ),
              ],
            ),
          ),

          if (_hasOffer) ...[
            const Divider(height: 1, indent: 12, endIndent: 12),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Column(
                children: [
                  // ════════════════════════════════════════════════════════════
                  // ANGEBOTSTYP DROPDOWN
                  // ════════════════════════════════════════════════════════════
                  DropdownButtonFormField<String>(
                    value: _offerType,
                    items: [
                      DropdownMenuItem(value: 'percent', child: Text(s.offerTypePercent)),
                      DropdownMenuItem(value: 'bundle', child: Text(s.offerTypeBundle)),
                      DropdownMenuItem(value: 'bulk', child: Text(s.offerTypeBulk)),
                    ],
                    onChanged: (v) {
                      setState(() => _offerType = v!);
                      if (v == 'percent') _initDiscountedPrice();
                    },
                    decoration: tinyLabel(
                      labelText: s.offerTypeLabel,
                      icon: Icons.local_offer_outlined,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ════════════════════════════════════════════════════════════
                  // PERCENT OFFER
                  // ════════════════════════════════════════════════════════════
                  if (_offerType == 'percent') ...[
                    ListenableBuilder(
                      listenable: Listenable.merge([
                        _priceController,
                        _percentController,
                        _discountedPriceController,
                      ]),
                      builder: (context, _) {
                        final regular = _getRegularPriceValue();
                        final regularDisplay = regular != null ? _fmtMoney(regular) : '—';

                        return LayoutBuilder(
                          builder: (context, c) {
                            final narrow = c.maxWidth < 380;

                            final regularField = TextFormField(
                              readOnly: true,
                              initialValue: regularDisplay,
                              key: ValueKey('reg_$regularDisplay'),
                              textDirection: TextDirection.ltr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.hintColor,
                              ),
                              decoration: tinyLabel(
                                labelText: s.regularPriceLabel,
                                icon: Icons.euro,
                                readOnly: true,
                              ),
                            );

                            final discountedField = TextFormField(
                              controller: _discountedPriceController,
                              textDirection: TextDirection.ltr,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [CommaDecimalFormatter()],
                              decoration: tinyLabel(
                                labelText: s.discountedPriceLabel,
                                icon: Icons.sell_outlined,
                                suffixIcon: clearButton(_discountedPriceController),
                              ),
                            );

                            if (narrow) {
                              return Column(
                                children: [
                                  regularField,
                                  const SizedBox(height: 10),
                                  discountedField,
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(child: regularField),
                                const SizedBox(width: 12),
                                Expanded(child: discountedField),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _percentController,
                      textDirection: TextDirection.ltr,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [CommaDecimalFormatter()],
                      decoration: tinyLabel(
                        labelText: s.percentageLabel,
                        icon: Icons.percent,
                        suffixIcon: clearButton(_percentController),
                      ),
                    ),
                  ],

                  // ════════════════════════════════════════════════════════════
                  // BUNDLE OFFER
                  // ════════════════════════════════════════════════════════════
                  if (_offerType == 'bundle') ...[
                    ListenableBuilder(
                      listenable: Listenable.merge([
                        _priceController,
                        _bundleQtyController,
                        _bundlePriceController,
                      ]),
                      builder: (context, _) {
                        final unitPrice = _parsePrice(_priceController.text);
                        final qty = int.tryParse(_bundleQtyController.text) ?? 0;
                        final bundleTotal = _parseNum(_bundlePriceController.text);
                        final regularTotal = unitPrice * qty;

                        // Berechnete Werte
                        final effectiveUnitPrice = qty > 0 ? bundleTotal / qty : 0.0;
                        final effectiveDiscount = (regularTotal > 0 && bundleTotal > 0)
                            ? ((1 - bundleTotal / regularTotal) * 100).clamp(0.0, 100.0)
                            : 0.0;

                        return LayoutBuilder(
                          builder: (context, c) {
                            final narrow = c.maxWidth < 380;

                            final qtyField = TextFormField(
                              controller: _bundleQtyController,
                              textDirection: TextDirection.ltr,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: tinyLabel(
                                labelText: s.quantityLabel,
                                icon: Icons.confirmation_number_outlined,
                                suffixIcon: clearButton(_bundleQtyController),
                              ),
                            );

                            final priceField = TextFormField(
                              controller: _bundlePriceController,
                              textDirection: TextDirection.ltr,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [CommaDecimalFormatter()],
                              decoration: tinyLabel(
                                labelText: s.totalPriceLabel,
                                icon: Icons.euro,
                                hintText: regularTotal > 0 ? '(${s.regularPriceLabel}: ${_fmtMoney(regularTotal)})' : null,
                                suffixIcon: clearButton(_bundlePriceController),
                              ),
                            );

                            final fields = narrow
                                ? Column(children: [qtyField, const SizedBox(height: 10), priceField])
                                : Row(children: [
                                    Expanded(child: qtyField),
                                    const SizedBox(width: 12),
                                    Expanded(child: priceField),
                                  ]);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                fields,
                                if (qty > 0 && bundleTotal > 0) ...[
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      infoChip(s.effectiveUnitPriceLabel, _fmtMoney(effectiveUnitPrice)),
                                      if (effectiveDiscount > 0)
                                        infoChip(
                                          s.effectiveDiscountLabel,
                                          '${_fmtPercent(effectiveDiscount)}%',
                                          valueColor: Colors.green.shade700,
                                        ),
                                    ],
                                  ),
                                ],
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],

                  // ════════════════════════════════════════════════════════════
                  // BULK OFFER
                  // ════════════════════════════════════════════════════════════
                  if (_offerType == 'bulk') ...[
                    ListenableBuilder(
                      listenable: Listenable.merge([
                        _priceController,
                        _bulkQtyController,
                        _bulkPriceController,
                      ]),
                      builder: (context, _) {
                        final unitPrice = _parsePrice(_priceController.text);
                        final bulkPrice = _parseNum(_bulkPriceController.text);

                        final effectiveDiscount = (unitPrice > 0 && bulkPrice > 0)
                            ? ((1 - bulkPrice / unitPrice) * 100).clamp(0.0, 100.0)
                            : 0.0;

                        return LayoutBuilder(
                          builder: (context, c) {
                            final narrow = c.maxWidth < 380;

                            final qtyField = TextFormField(
                              controller: _bulkQtyController,
                              textDirection: TextDirection.ltr,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: tinyLabel(
                                labelText: s.quantityStartLabel,
                                icon: Icons.exposure_plus_1,
                                suffixIcon: clearButton(_bulkQtyController),
                              ),
                            );

                            final priceField = TextFormField(
                              controller: _bulkPriceController,
                              textDirection: TextDirection.ltr,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [CommaDecimalFormatter()],
                              decoration: tinyLabel(
                                labelText: s.pricePerPieceLabel,
                                icon: Icons.euro,
                                hintText: unitPrice > 0 ? '(${s.regularPriceLabel}: ${_fmtMoney(unitPrice)})' : null,
                                suffixIcon: clearButton(_bulkPriceController),
                              ),
                            );

                            final fields = narrow
                                ? Column(children: [qtyField, const SizedBox(height: 10), priceField])
                                : Row(children: [
                                    Expanded(child: qtyField),
                                    const SizedBox(width: 12),
                                    Expanded(child: priceField),
                                  ]);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                fields,
                                if (effectiveDiscount > 0) ...[
                                  const SizedBox(height: 10),
                                  infoChip(
                                    s.effectiveDiscountLabel,
                                    '${_fmtPercent(effectiveDiscount)}%',
                                    valueColor: Colors.green.shade700,
                                  ),
                                ],
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 14),

                  // ════════════════════════════════════════════════════════════
                  // DATE RANGE PICKER
                  // ════════════════════════════════════════════════════════════
                  InkWell(
                    onTap: () => _selectOfferRange(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                      decoration: BoxDecoration(
                        color: colors.tertiary.withValues(alpha: 0.10),
                        border: Border.all(color: colors.tertiary.withValues(alpha: 0.28)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.date_range, color: colors.tertiary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.offerDurationLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 10, color: colors.tertiary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${_offerStartDate.day}/${_offerStartDate.month} - ${_offerEndDate.day}/${_offerEndDate.month}/${_offerEndDate.year}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: colors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
