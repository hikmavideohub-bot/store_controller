import 'package:store_controller/l10n/generated/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../config.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../storage/store_prefs.dart';
import '../core/access_manager.dart';
import '../utils/cdn_helper.dart';
import 'base_viewmodel.dart';

/// ViewModel für AddProduct / EditProduct Screen
/// Enthält alle Business-Logik für Produkt-CRUD, Bild-Upload, Validierung
class AddProductViewModel extends BaseViewModel {
  final Product? productToEdit;

  AddProductViewModel({this.productToEdit}) {
    _initializeFromProduct();
  }

  // ===========================================
  // STATE
  // ===========================================

  // Produkt-Daten
  String _name = '';
  double _price = 0.0;
  double _sizeValue = 0.0;
  String _sizeUnit = 'kg';
  String _imageUrl = '';
  String _thumbUrl = '';
  String _description = '';
  String _category = '';
  bool _productActive = true;

  // Angebot
  bool _hasOffer = false;
  String _offerType = 'percent';
  double _percent = 0.0;
  int _bundleQty = 0;
  double _bundlePrice = 0.0;
  int _bulkQty = 0;
  double _bulkPrice = 0.0;
  DateTime _offerStartDate = DateTime.now();
  DateTime _offerEndDate = DateTime.now().add(const Duration(days: 5));
  bool _offerActive = true;

  // Kategorien
  List<String> _categories = [];
  bool _isLoadingCategories = true;
  bool _showNewCategoryField = false;
  String? _selectedCategory;

  // Upload
  bool _uploadingImage = false;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';
  String? _previewImageUrl;

  // Speichern
  bool _isSaving = false;

  // Draft-ID für neue Produkte
  String? _draftProductId;

  // ===========================================
  // GETTERS
  // ===========================================

  bool get isEditing => productToEdit != null;
  String get name => _name;
  double get price => _price;
  double get sizeValue => _sizeValue;
  String get sizeUnit => _sizeUnit;
  String get imageUrl => _imageUrl;
  String get thumbUrl => _thumbUrl;
  String get description => _description;
  String get category => _category;
  bool get productActive => _productActive;

  bool get hasOffer => _hasOffer;
  String get offerType => _offerType;
  double get percent => _percent;
  int get bundleQty => _bundleQty;
  double get bundlePrice => _bundlePrice;
  int get bulkQty => _bulkQty;
  double get bulkPrice => _bulkPrice;
  DateTime get offerStartDate => _offerStartDate;
  DateTime get offerEndDate => _offerEndDate;
  bool get offerActive => _offerActive;

  List<String> get categories => _categories;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get showNewCategoryField => _showNewCategoryField;
  String? get selectedCategory => _selectedCategory;

  bool get uploadingImage => _uploadingImage;
  double get uploadProgress => _uploadProgress;
  String get uploadStatus => _uploadStatus;
  String? get previewImageUrl => _previewImageUrl;

  bool get isSaving => _isSaving;

  /// Liste der verfügbaren Einheiten
  List<String> get unitOptions => const ['l', 'ml', 'g', 'kg', 'pcs'];

  /// Prüft ob User Produkte hinzufügen/bearbeiten darf
  bool get canAddProduct =>
      AccessManager.isLoaded &&
      (AccessManager.isActive || AccessManager.isTrial);

  String get effectiveProductId {
    final existing = productToEdit?.id.trim() ?? '';
    if (existing.isNotEmpty) return existing;
    return _draftProductId ??= const Uuid().v4();
  }

  // ===========================================
  // SETTERS (für UI-Binding)
  // ===========================================

  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setPrice(double value) {
    _price = value;
    notifyListeners();
  }

  void setSizeValue(double value) {
    _sizeValue = value;
    notifyListeners();
  }

  void setSizeUnit(String value) {
    _sizeUnit = value;
    notifyListeners();
  }

  void setImageUrl(String value) {
    _imageUrl = value;
    if (!_uploadingImage) {
      _previewImageUrl = null;
    }
    notifyListeners();
  }

  void setThumbUrl(String value) {
    _thumbUrl = value;
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void setCategory(String value) {
    _category = value;
    notifyListeners();
  }

  void setProductActive(bool value) {
    _productActive = value;
    notifyListeners();
  }

  void setHasOffer(bool value) {
    _hasOffer = value;
    notifyListeners();
  }

  void setOfferType(String value) {
    _offerType = value;
    notifyListeners();
  }

  void setPercent(double value) {
    _percent = value;
    notifyListeners();
  }

  void setBundleQty(int value) {
    _bundleQty = value;
    notifyListeners();
  }

  void setBundlePrice(double value) {
    _bundlePrice = value;
    notifyListeners();
  }

  void setBulkQty(int value) {
    _bulkQty = value;
    notifyListeners();
  }

  void setBulkPrice(double value) {
    _bulkPrice = value;
    notifyListeners();
  }

  void setOfferStartDate(DateTime value) {
    _offerStartDate = value;
    notifyListeners();
  }

  void setOfferEndDate(DateTime value) {
    _offerEndDate = value;
    notifyListeners();
  }

  void setOfferActive(bool value) {
    _offerActive = value;
    notifyListeners();
  }

  void setSelectedCategory(String? value) {
    _selectedCategory = value;
    if (value != null) {
      _category = value;
      _showNewCategoryField = false;
    }
    notifyListeners();
  }

  void setShowNewCategoryField(bool value) {
    _showNewCategoryField = value;
    if (value) {
      _selectedCategory = null;
    }
    notifyListeners();
  }

  // ===========================================
  // INITIALIZATION
  // ===========================================

  void _initializeFromProduct() {
    final p = productToEdit;
    if (p == null) return;

    _name = p.name;
    _price = p.price;
    _sizeValue = p.sizeValue;
    _sizeUnit = p.sizeUnit.isNotEmpty ? p.sizeUnit : 'kg';
    _imageUrl = p.image;
    _thumbUrl = p.thumb;
    _description = p.description;
    _category = p.category;
    _productActive = p.productActive;
    _hasOffer = p.hasOffer;
    _offerType = p.offerType.isNotEmpty ? p.offerType : 'percent';
    _percent = p.percent;
    _bundleQty = p.bundleQty;
    _bundlePrice = p.bundlePrice;
    _bulkQty = p.bulkQty;
    _bulkPrice = p.bulkPrice;
    _offerActive = p.offerActive;

    if (p.offerStartDate.isNotEmpty) {
      _offerStartDate = _parseDateSafe(p.offerStartDate, DateTime.now());
    }
    if (p.offerEndDate.isNotEmpty) {
      _offerEndDate = _parseDateSafe(
        p.offerEndDate,
        DateTime.now().add(const Duration(days: 5)),
      );
    }

    if (p.category.isNotEmpty) {
      _selectedCategory = p.category;
    }
  }

  // ===========================================
  // KATEGORIEN LADEN
  // ===========================================

  Future<void> loadCategories(AppLocalizations s) async {
    _isLoadingCategories = true;
    notifyListeners();

    // Zuerst aus Cache
    final localCats = ApiService.categoriesFromCachedProducts();
    if (localCats.isNotEmpty) {
      _categories = localCats;
      _isLoadingCategories = false;
      _updateCategorySelection();
      notifyListeners();
      return;
    }

    // Dann aus API
    try {
      final fetched = await ApiService.fetchCategories();
      final unique = fetched
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList();
      unique.sort();

      _categories = unique;
      _isLoadingCategories = false;
      _updateCategorySelection();
    } catch (e) {
      _isLoadingCategories = false;
      _categories = [];
      _showNewCategoryField = true;
      setError(s.categoriesLoadError);
    }
    notifyListeners();
  }

  void _updateCategorySelection() {
    final editingCat = productToEdit?.category.trim() ?? '';
    if (editingCat.isNotEmpty && !_categories.contains(editingCat)) {
      _showNewCategoryField = true;
      _selectedCategory = null;
      _category = editingCat;
    } else {
      _showNewCategoryField = false;
      _selectedCategory = editingCat.isNotEmpty ? editingCat : null;
      if (_selectedCategory != null) {
        _category = _selectedCategory!;
      }
    }
  }

  // ===========================================
  // BILD-UPLOAD
  // ===========================================

  Future<ImageUploadResult> pickAndUploadImage(
    ImageSource source,
    AppLocalizations s,
  ) async {
    final picker = ImagePicker();

    final XFile? file = await picker.pickImage(
      source: source,
      imageQuality: 95,
      maxWidth: 2200,
    );
    if (file == null) {
      return ImageUploadResult(success: false, cancelled: true);
    }

    final storeId = await StorePrefs.getStoreId();
    if (storeId == null || storeId.trim().isEmpty) {
      return ImageUploadResult(success: false, error: s.uploadStoreIdMissing);
    }

    final productId = effectiveProductId;

    _uploadingImage = true;
    _uploadProgress = 0.0;
    _uploadStatus = s.uploadPreparing;
    _previewImageUrl = null;
    notifyListeners();

    final oldFullUrl = _imageUrl;
    final oldThumbUrl = _thumbUrl;

    try {
      // Bucket mit Resize-Extension verwenden
      final storage = FirebaseStorage.instanceFor(
        bucket: 'gs://aldeebtech-1ec64.firebasestorage.app',
      );

      final baseRef = storage.ref('stores/$storeId/products/$productId');
      final imageRef = baseRef.child('image.jpg');

      // Extension outputs
      final thumbRef = baseRef.child('image_360x360.jpeg');
      final fullRef = baseRef.child('image_1600x1600.jpeg');

      await _deleteProductImageSet(storeId: storeId, productId: productId);

      _uploadStatus = s.uploading;
      notifyListeners();

      final meta = SettableMetadata(contentType: 'image/jpeg');
      final bytes = await file.readAsBytes();
      final task = imageRef.putData(bytes, meta);

      task.snapshotEvents.listen((evt) {
        final total = evt.totalBytes;
        if (total > 0) {
          final progress = evt.bytesTransferred / total;
          _uploadProgress = progress;
          _uploadStatus = s.uploadingProgress((progress * 100).toInt());
          notifyListeners();
        }
      });

      await task;

      _uploadProgress = 1.0;
      _uploadStatus = s.uploadProcessing;
      notifyListeners();

      // Warte auf Resize-Extension
      final thumbExists = await _waitForResizedFile(thumbRef, maxAttempts: 15);
      final fullExists = await _waitForResizedFile(fullRef, maxAttempts: 20);

      // CDN URLs konstruieren (NICHT getDownloadURL!)
      final thumbFilename = thumbExists ? 'image_360x360.jpeg' : 'image.jpg';
      final fullFilename = fullExists ? 'image_1600x1600.jpeg' : 'image.jpg';

      final finalThumb = CdnHelper.buildUrl(
        storeId: storeId,
        productId: productId,
        filename: thumbFilename,
      );
      final finalFull = CdnHelper.buildUrl(
        storeId: storeId,
        productId: productId,
        filename: fullFilename,
      );

      _previewImageUrl = finalThumb;
      notifyListeners();

      // Alte Bilder löschen
      if (oldFullUrl.isNotEmpty && oldFullUrl != finalFull) {
        await _deleteOldImageIfFirebase(oldFullUrl, newUrl: finalFull);
      }
      if (oldThumbUrl.isNotEmpty && oldThumbUrl != finalThumb) {
        await _deleteOldImageIfFirebase(oldThumbUrl, newUrl: finalThumb);
      }

      _imageUrl = finalFull;
      _thumbUrl = finalThumb;
      _previewImageUrl = finalThumb.isNotEmpty ? finalThumb : finalFull;
      _uploadStatus = s.uploadDone;
      notifyListeners();

      return ImageUploadResult(
        success: true,
        imageUrl: finalFull,
        thumbUrl: finalThumb,
      );
    } catch (e) {
      return ImageUploadResult(success: false, error: e.toString());
    } finally {
      _uploadingImage = false;
      _uploadStatus = '';
      notifyListeners();
    }
  }

  /// Wartet bis die Resize-Extension die Datei erstellt hat
  Future<bool> _waitForResizedFile(
    Reference ref, {
    int maxAttempts = 15,
  }) async {
    var delayMs = 500;
    for (var i = 0; i < maxAttempts; i++) {
      try {
        await ref.getDownloadURL();
        return true;
      } catch (_) {
        await Future.delayed(Duration(milliseconds: delayMs));
        delayMs = (delayMs * 1.3).round().clamp(500, 2000);
      }
    }
    return false;
  }

  bool _isFirebaseStorageUrl(String url) {
    final u = url.trim();
    return u.contains('firebasestorage.googleapis.com') ||
        u.startsWith('gs://') ||
        u.contains('.firebasestorage.app');
  }

  Future<void> _deleteOldImageIfFirebase(
    String oldUrl, {
    String? newUrl,
  }) async {
    final old = oldUrl.trim();
    if (old.isEmpty) return;
    if (!_isFirebaseStorageUrl(old)) return;

    final next = (newUrl ?? '').trim();
    if (next.isNotEmpty && _isFirebaseStorageUrl(next)) {
      try {
        final oldRef = FirebaseStorage.instance.refFromURL(old);
        final newRef = FirebaseStorage.instance.refFromURL(next);
        if (oldRef.bucket == newRef.bucket &&
            oldRef.fullPath == newRef.fullPath) {
          return;
        }
      } catch (_) {}
    }

    try {
      await FirebaseStorage.instance.refFromURL(old).delete();
    } catch (_) {}
  }

  Future<void> _deleteProductImageSet({
    required String storeId,
    required String productId,
  }) async {
    final storage = FirebaseStorage.instanceFor(
      bucket: 'gs://aldeebtech-1ec64.firebasestorage.app',
    );

    final base = storage.ref('stores/$storeId/products/$productId');
    final legacy = storage.ref('stores/$storeId/products/$productId.jpg');

    final refs = <Reference>[
      base.child('image.jpg'),
      base.child('image.jpeg'),
      base.child('image_360x360.jpg'),
      base.child('image_360x360.jpeg'),
      base.child('image_1600x1600.jpg'),
      base.child('image_1600x1600.jpeg'),
      legacy,
    ];

    for (final r in refs) {
      try {
        await r.delete();
      } catch (_) {}
    }
  }

  // ===========================================
  // PRODUKT SPEICHERN
  // ===========================================

  Future<ProductSaveResult> saveProduct(AppLocalizations s) async {
    if (_isSaving) {
      return ProductSaveResult(success: false, error: s.alreadySaving);
    }

    // Validierung
    if (_name.trim().isEmpty) {
      return ProductSaveResult(
        success: false,
        error: s.validationEnterStoreName,
      ); // Reuse from settings or create generic
    }
    if (_price <= 0) {
      return ProductSaveResult(
        success: false,
        error: s.validationEnterPriceValid,
      );
    }
    if (_category.trim().isEmpty) {
      return ProductSaveResult(
        success: false,
        error: s.validationSelectCategory,
      );
    }

    // Product Limit Check (Only for new products)
    if (!isEditing &&
        ApiService.productsNotifier.value.length >= AppConfig.maxFreeProducts) {
      return ProductSaveResult(success: false, error: s.productLimitReached);
    }

    // Access-Check
    if (!canAddProduct) {
      return ProductSaveResult(success: false, needsPaywall: true);
    }

    _isSaving = true;
    notifyListeners();

    try {
      final productToSave = Product(
        id: isEditing ? productToEdit!.id : '',
        name: _name.trim(),
        price: _price,
        sizeValue: _sizeValue,
        sizeUnit: _sizeUnit,
        image: _imageUrl.trim(),
        thumb: _thumbUrl.trim(),
        description: _description.trim(),
        category: _category.trim(),
        productActive: _productActive,
        hasOffer: _hasOffer,
        offerType: _hasOffer ? _offerType : '',
        percent: (_hasOffer && _offerType == 'percent') ? _percent : 0,
        bundleQty: (_hasOffer && _offerType == 'bundle') ? _bundleQty : 0,
        bundlePrice: (_hasOffer && _offerType == 'bundle') ? _bundlePrice : 0,
        bulkQty: (_hasOffer && _offerType == 'bulk') ? _bulkQty : 0,
        bulkPrice: (_hasOffer && _offerType == 'bulk') ? _bulkPrice : 0,
        offerStartDate: _hasOffer ? _formatDate(_offerStartDate) : '',
        offerEndDate: _hasOffer ? _formatDate(_offerEndDate) : '',
        offerActive: _hasOffer ? _offerActive : false,
      );

      // Altes Bild löschen wenn geändert
      final oldUrl = productToEdit?.image.trim() ?? '';
      final newUrl = _imageUrl.trim();
      if (isEditing && oldUrl.isNotEmpty && oldUrl != newUrl) {
        await _deleteOldImageIfFirebase(oldUrl, newUrl: newUrl);
      }

      final bool success = isEditing
          ? await ApiService.updateProduct(productToSave)
          : await ApiService.addProduct(productToSave);

      if (success) {
        // Kategorie zur Liste hinzufügen
        if (!_categories.contains(_category.trim())) {
          _categories.add(_category.trim());
          _categories = _categories.toSet().toList();
          _categories.sort();
        }
        _selectedCategory = _category.trim();
        _showNewCategoryField = false;

        return ProductSaveResult(success: true, product: productToSave);
      } else {
        return ProductSaveResult(success: false, error: s.saveProductError);
      }
    } catch (e) {
      return ProductSaveResult(success: false, error: e.toString());
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ===========================================
  // PRODUKT LÖSCHEN
  // ===========================================

  Future<bool> deleteProduct() async {
    if (productToEdit == null) return false;

    _isSaving = true;
    notifyListeners();

    try {
      final success = await ApiService.deleteProduct(productToEdit!.id);
      return success;
    } catch (e) {
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ===================
  // HELPERS
  // ===================

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

  String _formatDate(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }
}

// ===========================================
// RESULT WRAPPERS
// ===========================================

class ImageUploadResult {
  final bool success;
  final bool cancelled;
  final String? error;
  final String? imageUrl;
  final String? thumbUrl;

  ImageUploadResult({
    required this.success,
    this.cancelled = false,
    this.error,
    this.imageUrl,
    this.thumbUrl,
  });
}

class ProductSaveResult {
  final bool success;
  final String? error;
  final Product? product;
  final bool needsPaywall;

  ProductSaveResult({
    required this.success,
    this.error,
    this.product,
    this.needsPaywall = false,
  });
}
