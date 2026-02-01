import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../config.dart';
import '../widgets/premium_app_bar.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../core/access_manager.dart';
import '../core/paywall_messages.dart';
import '../storage/store_prefs.dart';
import '../utils/cdn_helper.dart';

class CommaDecimalFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final sanitized = newValue.text.replaceAll(RegExp(r'[^0-9,]'), '');
    if (sanitized.startsWith(',')) return oldValue;
    if (sanitized.split(',').length > 2) return oldValue;
    return TextEditingValue(text: sanitized, selection: TextSelection.collapsed(offset: sanitized.length));
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
      _descriptionController,
      _percentController,
      _bundleQtyController,
      _bundlePriceController,
      _bulkQtyController,
      _bulkPriceController,
      _categoryController,
      _thumbController;
  final FocusNode _priceFocusNode = FocusNode(), _weightFocusNode = FocusNode(), _categoryFocusNode = FocusNode();

  /// Ermittelt die Textrichtung basierend auf dem ersten Buchstaben
  TextDirection? _getTextDirection(String text) {
    final trimmed = text.trimLeft();
    if (trimmed.isEmpty) return null; // Default verwenden
    final firstChar = trimmed.codeUnitAt(0);
    // Arabisch: U+0600–U+06FF, U+0750–U+077F, U+08A0–U+08FF
    final isArabic = (firstChar >= 0x0600 && firstChar <= 0x06FF) ||
        (firstChar >= 0x0750 && firstChar <= 0x077F) ||
        (firstChar >= 0x08A0 && firstChar <= 0x08FF);
    return isArabic ? TextDirection.rtl : TextDirection.ltr;
  }

  bool _uploadingImage = false, _isSaving = false, _productActive = true, _hasOffer = false, _offerActive = true, _showNewCategoryField = false;
  double _uploadProgress = 0.0;
  String _selectedUnit = 'kg', _offerType = 'percent', _uploadStatus = '';
  String? _selectedCategory, _previewImageUrl;
  List<String> _categories = [];
  final List<String> _unitOptions = ['l', 'ml', 'g', 'kg', 'pcs'];
  late DateTime _offerStartDate, _offerEndDate;

  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;

    final initialCat = p?.category.trim() ?? '';
    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController = TextEditingController(text: _formatNumToText(p?.price));
    _sizeValueController = TextEditingController(text: _formatNumToText(p?.sizeValue));
    _imageController = TextEditingController(text: p?.image ?? '');
    _thumbController = TextEditingController(text: p?.thumb ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _percentController = TextEditingController(text: (p != null && p.percent > 0) ? _formatNumToText(p.percent) : '');
    _bundleQtyController = TextEditingController(text: (p != null && p.bundleQty > 0) ? p.bundleQty.toString() : '');
    _bundlePriceController = TextEditingController(text: (p != null && p.bundlePrice > 0) ? _formatNumToText(p.bundlePrice) : '');
    _bulkQtyController = TextEditingController(text: (p != null && p.bulkQty > 0) ? p.bulkQty.toString() : '');
    _bulkPriceController = TextEditingController(text: (p != null && p.bulkPrice > 0) ? _formatNumToText(p.bulkPrice) : '');
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
    _offerType = (p != null && p.offerType.isNotEmpty) ? p.offerType : 'percent';

    _offerStartDate = _parseDateSafe(p?.offerStartDate, DateTime.now());
    _offerEndDate = _parseDateSafe(p?.offerEndDate, DateTime.now().add(const Duration(days: 5)));

    _loadCategories();
    _priceFocusNode.addListener(() {
      if (!_priceFocusNode.hasFocus) _normalizePriceText();
    });
    _weightFocusNode.addListener(() {
      if (!_weightFocusNode.hasFocus) _normalizeWeightText();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAccessOnLoad());
  }

  DateTime _parseDateSafe(String? s, DateTime fallback) {
    if (s == null || s.isEmpty) return fallback;
    try {
      if (s.contains('T')) return DateTime.parse(s);
      final parts = s.split('-');
      if (parts.length == 3) return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      return fallback;
    } catch (_) {
      return fallback;
    }
  }

  String _formatDate(DateTime d) => "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  Future<void> _checkAccessOnLoad() async {
    if (!AccessManager.canWriteAdmin) {
      await showFabPaywallDialog(context);
      if (mounted) context.pop();
    }
  }

  @override
  void dispose() {
    for (var c in [
      _nameController,
      _priceController,
      _sizeValueController,
      _imageController,
      _descriptionController,
      _percentController,
      _bundleQtyController,
      _bundlePriceController,
      _bulkQtyController,
      _bulkPriceController,
      _categoryController,
      _thumbController
    ]) {
      c.dispose();
    }
    _priceFocusNode.dispose();
    _weightFocusNode.dispose();
    _categoryFocusNode.dispose();
    super.dispose();
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
  Future<void> _deleteImagesFromStorage(String storeId, String productId, String imageUrl) async {
    try {
      final storage = FirebaseStorage.instanceFor(bucket: 'gs://aldeebtech-1ec64.firebasestorage.app');

      // Extrahiere den Dateinamen aus der URL (z.B. img_17065678123.jpg)
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      String? filename;

      // CDN URL Format: /images/stores/{storeId}/products/{productId}/{filename}
      if (pathSegments.isNotEmpty) {
        filename = pathSegments.last;
        // Entferne _1600x1600 oder _360x360 Suffix um den Basisnamen zu bekommen
        filename = filename.replaceAll('_1600x1600.jpeg', '').replaceAll('_360x360.jpeg', '').replaceAll('.jpg', '').replaceAll('.jpeg', '');
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
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
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
      final productId = widget.productToEdit?.id ?? const Uuid().v4();
      final storage = FirebaseStorage.instanceFor(bucket: 'gs://aldeebtech-1ec64.firebasestorage.app');
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
        if (mounted) setState(() => _uploadProgress = s.bytesTransferred / s.totalBytes);
      });
      await task;

      if (mounted) setState(() => _uploadStatus = s.processing);

      // Warten auf Resize-Extension
      final thumbRef = baseRef.child('${uniqueName}_360x360.jpeg');
      final fullRef = baseRef.child('${uniqueName}_1600x1600.jpeg');

      final thumbExists = await _waitForResizedImage(thumbRef, maxAttempts: 15);
      final fullExists = await _waitForResizedImage(fullRef, maxAttempts: 20);

      final thumbFilename = thumbExists ? '${uniqueName}_360x360.jpeg' : '$uniqueName.jpg';
      final fullFilename = fullExists ? '${uniqueName}_1600x1600.jpeg' : '$uniqueName.jpg';

      final thumbCdnUrl = CdnHelper.buildUrl(storeId: storeId, productId: productId, filename: thumbFilename);
      final fullCdnUrl = CdnHelper.buildUrl(storeId: storeId, productId: productId, filename: fullFilename);

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

  Future<bool> _waitForResizedImage(Reference ref, {int maxAttempts = 15}) async {
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

  String _formatNumToText(dynamic v) => v == null ? '' : v.toString().replaceAll('.', ',');
  double _parsePrice(String v) => double.tryParse(v.replaceAll(',', '.')) ?? 0.0;
  void _normalizePriceText() {
    if (_priceController.text.isNotEmpty) _priceController.text = _formatNumToText(_parsePrice(_priceController.text));
  }

  void _normalizeWeightText() {
    if (_sizeValueController.text.isNotEmpty) _sizeValueController.text = _formatNumToText(_parsePrice(_sizeValueController.text));
  }

  Future<void> _selectOfferRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _offerStartDate, end: _offerEndDate),
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
    if (_isSaving || _formKey.currentState?.validate() != true) return;

    // 1. Produktlimit prüfen (nur bei neuem Produkt)
    final isNew = widget.productToEdit == null;
    if (isNew && ApiService.productsNotifier.value.length >= AppConfig.maxFreeProducts) {
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
        id: widget.productToEdit?.id ?? '',
        name: _nameController.text.trim(),
        price: _parsePrice(_priceController.text),
        sizeValue: _parsePrice(_sizeValueController.text),
        sizeUnit: _selectedUnit,
        image: _imageController.text.trim(),
        thumb: _thumbController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim(),
        productActive: _productActive,
        hasOffer: _hasOffer,
        offerType: _hasOffer ? _offerType : '',
        percent: (_hasOffer && _offerType == 'percent') ? _parsePrice(_percentController.text) : 0,
        bundleQty: (_hasOffer && _offerType == 'bundle') ? (int.tryParse(_bundleQtyController.text) ?? 0) : 0,
        bundlePrice: (_hasOffer && _offerType == 'bundle') ? _parsePrice(_bundlePriceController.text) : 0,
        bulkQty: (_hasOffer && _offerType == 'bulk') ? (int.tryParse(_bulkQtyController.text) ?? 0) : 0,
        bulkPrice: (_hasOffer && _offerType == 'bulk') ? _parsePrice(_bulkPriceController.text) : 0,
        offerStartDate: _hasOffer ? _formatDate(_offerStartDate) : '',
        offerEndDate: _hasOffer ? _formatDate(_offerEndDate) : '',
        offerActive: _hasOffer ? _offerActive : false,
      );
      final success = widget.productToEdit != null ? await ApiService.updateProduct(p) : await ApiService.addProduct(p);

      if (mounted && success) {
        // Bestätigungsnachricht anzeigen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.productPublishedMsg, style: const TextStyle(fontWeight: FontWeight.bold)),
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
  InputDecoration _premiumInputDecoration(String label, {IconData? icon, bool isOptional = false, TextEditingController? controller}) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;

    return InputDecoration(
      labelText: isOptional ? '$label ${s.optionalSuffix}' : label,
      labelStyle: TextStyle(color: theme.hintColor, fontWeight: FontWeight.w700),
      filled: true,
      fillColor: colors.surface,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: colors.outline.withValues(alpha:0.2))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: colors.primary, width: 1.6)),
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
      case 'kg': return s.unitKg;
      case 'g': return s.unitG;
      case 'l': return s.unitL;
      case 'ml': return s.unitMl;
      case 'pcs': return s.unitPcs;
      default: return unit;
    }
  }

  String _getPluralPieces(int count, AppLocalizations s) {
    if (count == 1) return s.pcs1;
    if (count == 2) return s.pcs2;
    if (count >= 3 && count <= 10) return s.pcs3to10(count.toString());
    return s.pcsOver10(count.toString());
  }

  Widget _buildCustomerPreview() {
    if (!_hasOffer) return const SizedBox.shrink();

    final s = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListenableBuilder(
      listenable: Listenable.merge([
        _nameController,
        _sizeValueController,
        _priceController,
        _imageController,
        _percentController,
        _bundleQtyController,
        _bundlePriceController,
        _bulkQtyController,
        _bulkPriceController,
      ]),
      builder: (context, _) {
        const currency = "€";

        final name = _nameController.text.trim();
        final unitPrice = _parsePrice(_priceController.text);
        final sizeValue = _parsePrice(_sizeValueController.text);
        final imageUrl = (_previewImageUrl ?? _imageController.text).trim();

        // ---------- Offer computation (aligned with web product.dart) ----------
        String badgeText = "";
        String overlayText = "";
        String? detailText;
        double? oldPrice;
        double? newPrice;

        if (_offerType == 'percent') {
          final p = _parsePrice(_percentController.text).clamp(0, 100);
          if (p > 0 && unitPrice > 0) {
            badgeText = s.offerBadgePercent(p.toStringAsFixed(0));
            oldPrice = unitPrice;
            newPrice = unitPrice * (1 - p / 100);
          }
        } else if (_offerType == 'bundle') {
          final qty = int.tryParse(_bundleQtyController.text) ?? 0;
          final bPrice = _parsePrice(_bundlePriceController.text);

          if (qty > 0 && bPrice > 0 && unitPrice > 0) {
            // Pay-Get detection (same idea as in web product.dart)
            const eps = 0.10;
            final payQtyGuess = (bPrice / unitPrice).round();
            final isPayGet = payQtyGuess >= 1 &&
                payQtyGuess < qty &&
                (bPrice - payQtyGuess * unitPrice).abs() < eps;

            overlayText = s.bundleOverlay(currency, _formatNumToText(bPrice), _getPluralPieces(qty, s));

            if (isPayGet) {
              final freeQty = (qty - payQtyGuess).clamp(0, qty);
              if (freeQty > 0) badgeText = s.freeQtyBadge(_getPluralPieces(freeQty, s));
              detailText = s.bundleDetailPayOnly(payQtyGuess.toString(), _getPluralPieces(qty, s));
            } else {
              badgeText = _getPluralPieces(qty, s);
              detailText = s.bundleDetail(_formatNumToText(bPrice), _getPluralPieces(qty, s));
            }
          }
        } else if (_offerType == 'bulk') {
          final qty = int.tryParse(_bulkQtyController.text) ?? 0;
          final bPrice = _parsePrice(_bulkPriceController.text);

          if (qty > 0) {
            badgeText = s.bulkBadge;
            overlayText = s.bulkOverlay(qty.toString(), _getPluralPieces(qty, s));

            // Optional: show the "new" per-piece price like customers usually see it
            if (bPrice > 0 && unitPrice > 0 && bPrice < unitPrice) {
              oldPrice = unitPrice;
              newPrice = bPrice;
            }
          }
        }

        if (badgeText.isEmpty && overlayText.isEmpty && detailText == null && oldPrice == null) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(top: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.outline.withValues(alpha: 0.10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.remove_red_eye, size: 18, color: colors.primary),
                  const SizedBox(width: 8),
                  Text(
                    s.previewForCustomer,
                    style: TextStyle(fontWeight: FontWeight.bold, color: colors.primary, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Mini product card preview (customer-like)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.outline.withValues(alpha: 0.08)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: colors.surface,
                        border: Border.all(color: colors.outline.withValues(alpha: 0.12)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: imageUrl.isEmpty
                          ? Icon(Icons.image_outlined, color: colors.primary.withValues(alpha: 0.5))
                          : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.broken_image_outlined, color: theme.hintColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.isEmpty ? '—' : name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          if (sizeValue > 0)
                            Text(
                              '${_formatNumToText(sizeValue)} ${_getUnitLabel(_selectedUnit, s)}',
                              style: TextStyle(fontSize: 12, color: theme.hintColor),
                            ),
                          const SizedBox(height: 8),

                          // Offer chips
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (badgeText.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: colors.error,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    badgeText,
                                    style: TextStyle(
                                      color: colors.onError,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              if (overlayText.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: colors.tertiary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    overlayText,
                                    style: TextStyle(
                                      color: colors.onTertiary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          // Price line (for percent + optional bulk)
                          if (oldPrice != null && newPrice != null) ...[
                            const SizedBox(height: 10),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${_formatNumToText(oldPrice)} $currency',
                                    style: TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: theme.hintColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${_formatNumToText(newPrice)} $currency',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: colors.error,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          if (detailText != null) ...[
                            const SizedBox(height: 10),
                            Text(detailText, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;
    final isEditing = widget.productToEdit != null;
    final dropdownValue = (_categories.contains(_selectedCategory)) ? _selectedCategory : null;

    // Lokalisierte Vorschläge
    final List<String> descSuggestions = [
      s.descQuality,
      s.descFresh,
      s.descBestseller,
      s.descLimited,
      s.descHandmade,
      s.descNatural,
    ];

    String? validateRequired(String? v) => (v == null || v.trim().isEmpty) ? s.requiredField : null;

    return Scaffold(
      appBar: PremiumAnimatedAppBar(title: isEditing ? s.editProductTitle : s.addProductTitle, showBackButton: true),
      // --- STICKY PUBLISH BUTTON (Pillen-Form mit Icon) ---
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
          child: ElevatedButton.icon(
            onPressed: _isSaving || _uploadingImage ? null : _submit,
            icon: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.rocket_launch, size: 20),
            label: Text(s.publishButton, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
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
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TextFormField(
              controller: _nameController,
              textDirection: _getTextDirection(_nameController.text),
              onChanged: (_) => setState(() {}), // Rebuild für Richtungswechsel
              decoration: _premiumInputDecoration(s.productNameLabel, icon: Icons.shopping_bag, controller: _nameController),
              validator: validateRequired,
            ),
            const SizedBox(height: 16),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                flex: 2, // Preis bekommt mehr Platz (Verhältnis 2 zu 1)
                child: TextFormField(
                  controller: _priceController,
                  focusNode: _priceFocusNode,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [CommaDecimalFormatter()],
                  // FIX: 'controller' weggelassen, damit das 'X' (Clear-Button) verschwindet
                  decoration: _premiumInputDecoration(s.priceLabel, icon: Icons.euro),
                  validator: validateRequired,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _showNewCategoryField
                    ? TextFormField(
                  controller: _categoryController,
                  focusNode: _categoryFocusNode,
                  textDirection: _getTextDirection(_categoryController.text),
                  onChanged: (_) => setState(() {}), // Rebuild für Richtungswechsel
                  decoration: _premiumInputDecoration(
                    s.newCategoryLabel,
                    icon: Icons.add_box,
                  ).copyWith(
                    // DER "FLUCHT-KNOPF": Bringt den User zurück zum Dropdown
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.redAccent),
                      onPressed: () {
                        setState(() {
                          _showNewCategoryField = false;
                          // Setze den Controller auf die vorher gewählte Kategorie zurück
                          _categoryController.text = _selectedCategory ?? '';
                        });
                      },
                    ),
                  ),
                  validator: validateRequired,
                )
                    : DropdownButtonFormField<String>(
                  // WICHTIG: Nutze 'value' statt 'initialValue' für Reaktivität
                  initialValue: _categories.contains(_selectedCategory) ? _selectedCategory : null,
                  decoration: _premiumInputDecoration(s.categoryLabel, icon: Icons.grid_view),
                  items: [
                    ..._categories.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                    DropdownMenuItem(
                      value: 'new',
                      child: Row(
                        children: [
                          Icon(Icons.add_circle_outline, size: 20, color: colors.primary),
                          const SizedBox(width: 8),
                          Text(s.addNewCategory, style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
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
                      // Focus wird erst im nächsten Frame gesetzt, wenn das Feld gerendert ist
                      WidgetsBinding.instance.addPostFrameCallback((_) => _categoryFocusNode.requestFocus());
                    } else if (v != null) {
                      setState(() {
                        _selectedCategory = v;
                        _categoryController.text = v;
                      });
                    }
                  },
                ),
              ),
            ]),
            const SizedBox(height: 16),

            // --- GEWICHT + EINHEIT (Einheit unter dem Feld für mehr Platz) ---
            TextFormField(
              controller: _sizeValueController,
              focusNode: _weightFocusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [CommaDecimalFormatter()],
              decoration: _premiumInputDecoration(s.sizeLabel, icon: Icons.scale, controller: _sizeValueController),
              validator: validateRequired,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: _unitOptions.map((u) => ButtonSegment(value: u, label: Text(_getUnitLabel(u, s), style: const TextStyle(fontSize: 13)))).toList(),
                selected: {_selectedUnit},
                onSelectionChanged: (newSet) => setState(() => _selectedUnit = newSet.first),
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

            const SizedBox(height: 24),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              textDirection: _getTextDirection(_descriptionController.text),
              onChanged: (_) => setState(() {}), // Rebuild für Richtungswechsel
              decoration: _premiumInputDecoration(s.descriptionLabel, icon: Icons.description, controller: _descriptionController),
            ),

            // Beschreibungsvorschläge
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: descSuggestions.length,
                separatorBuilder: (ctx, i) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  return ActionChip(
                    label: Text(descSuggestions[i], style: TextStyle(fontSize: 12, color: colors.onSurface)),
                    backgroundColor: colors.surfaceContainer,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onPressed: () {
                      final text = _descriptionController.text;
                      final toAdd = descSuggestions[i];
                      _descriptionController.text = text.isEmpty ? toAdd : '$text\n$toAdd';
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // PRODUCT ACTIVE SWITCH (Modern Style)
            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
              ),
              child: SwitchListTile.adaptive(
                  title: Text(s.productAvailable, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(_productActive ? s.visibleToCustomers : s.hiddenFromCustomers, style: TextStyle(fontSize: 12, color: theme.hintColor)),
                  value: _productActive,
                  activeColor: colors.primary,
                  onChanged: (v) => setState(() => _productActive = v)
              ),
            ),
            const SizedBox(height: 16),

            // OFFER CONTAINER (Verbessert & Parallel)
            _buildOfferSection(theme, colors),

            // KUNDENVORSCHAU
            _buildCustomerPreview(),

            const SizedBox(height: 32),

            // HIER WAR VORHER DER SAVE BUTTON - JETZT GELÖSCHT
          ]),
        ),
      ),
    );
  }

  Widget _buildImageSection(ThemeData theme, ColorScheme colors) {
    final s = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.productImageLabel, style: TextStyle(fontWeight: FontWeight.bold, color: theme.hintColor)),
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
          border: hasImage ? null : Border.all(color: colors.outline.withValues(alpha: 0.3)),
          boxShadow: hasImage
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 10, offset: const Offset(0, 4))]
              : null,
          image: hasImage ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover) : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (!hasImage && !_uploadingImage)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 48, color: colors.primary.withValues(alpha: 0.55)),
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
                      CircularProgressIndicator(value: _uploadProgress > 0 ? _uploadProgress : null, color: colors.onPrimary),
                      const SizedBox(height: 12),
                      Text('${(_uploadProgress * 100).toStringAsFixed(0)}%', style: TextStyle(color: colors.onPrimary, fontWeight: FontWeight.bold)),
                      Text(_uploadStatus, style: TextStyle(color: colors.onPrimary.withValues(alpha: 0.8), fontSize: 12)),
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
                        icon: Icon(Icons.edit, color: colors.onPrimary, size: 20),
                        onPressed: _pickAndUploadImage,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: colors.error.withValues(alpha: 0.85),
                      child: IconButton(
                        icon: Icon(Icons.delete, color: colors.onError, size: 20),
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
      if (path.contains('/images/stores/') || path.contains('/stores/')) return true;
      return false;
    } catch (_) {
      return false;
    }
  }

  Widget _buildOfferSection(ThemeData theme, ColorScheme colors) {
    final s = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(color: _hasOffer ? colors.tertiary.withValues(alpha: 0.5) : colors.outline.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(16)
      ),
      child: Column(children: [
        SwitchListTile.adaptive(
            title: Text(s.specialOfferAvailable, style: TextStyle(fontWeight: FontWeight.bold, color: _hasOffer ? colors.tertiary : colors.onSurface)),
            subtitle: Text(s.specialOfferSubtitle, style: TextStyle(fontSize: 12, color: theme.hintColor)),
            value: _hasOffer,
            activeColor: colors.tertiary,
            onChanged: (v) => setState(() {
              _hasOffer = v;
              if (v) _offerActive = true; // Dies ist die Lösung für das Datenbank-Problem
            })
        ),

        if (_hasOffer) ...[
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                    initialValue: _offerType,
                    items: [
                      DropdownMenuItem(value: 'percent', child: Text(s.offerTypePercent)),
                      DropdownMenuItem(value: 'bundle', child: Text(s.offerTypeBundle)),
                      DropdownMenuItem(value: 'bulk', child: Text(s.offerTypeBulk)),
                    ],
                    onChanged: (v) => setState(() => _offerType = v!),
                    decoration: _premiumInputDecoration(s.offerTypeLabel, icon: Icons.local_offer_outlined)),
                const SizedBox(height: 12),

                if (_offerType == 'percent')
                  TextFormField(
                    controller: _percentController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [CommaDecimalFormatter()],
                    decoration: _premiumInputDecoration(s.percentageLabel, controller: _percentController),
                  ),

                if (_offerType == 'bundle') Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _bundleQtyController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: _premiumInputDecoration(s.quantityLabel, controller: _bundleQtyController),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _bundlePriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [CommaDecimalFormatter()],
                      decoration: _premiumInputDecoration(s.totalPriceLabel, controller: _bundlePriceController),
                    ),
                  )
                ]),

                if (_offerType == 'bulk') Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _bulkQtyController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: _premiumInputDecoration(s.quantityStartLabel, controller: _bulkQtyController),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _bulkPriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [CommaDecimalFormatter()],
                      decoration: _premiumInputDecoration(s.pricePerPieceLabel, controller: _bulkPriceController),
                    ),
                  )
                ]),

                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectOfferRange(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                        color: colors.tertiary.withValues(alpha: 0.1),
                        border: Border.all(color: colors.tertiary.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(12)
                    ),
                    child: Row(children: [
                      Icon(Icons.date_range, color: colors.tertiary, size: 20),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.offerDurationLabel, style: TextStyle(fontSize: 10, color: colors.tertiary)),
                          Text("${_offerStartDate.day}/${_offerStartDate.month} - ${_offerEndDate.day}/${_offerEndDate.month}/${_offerEndDate.year}", style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface)),
                        ],
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          )
        ]
      ]),
    );
  }
}