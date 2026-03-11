// models/product.dart

class Product {
  String id;
  String name;
  double price;
  double sizeValue;
  String sizeUnit;
  String image;
  String thumb;
  String description;
  Map<String, String> descriptionMap;
  bool autoTranslateUsed;
  String category;
  bool productActive;

  // Moderation (read-only, server managed)
  bool moderationAutoBlocked;
  bool moderationManualBlocked;
  String? moderationMessageKey;

  bool get isBlocked => moderationAutoBlocked || moderationManualBlocked;


  // Offer Fields
  bool hasOffer;
  String offerType;
  double percent;
  int bundleQty;
  double bundlePrice;
  int bulkQty;
  double bulkPrice;
  String offerStartDate;
  String offerEndDate;
  bool offerActive;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.sizeValue,
    required this.sizeUnit,
    required this.image,
    this.thumb = '',
    required this.description,
    this.descriptionMap = const {'ar': '', 'de': '', 'en': '', 'tr': ''},
    this.autoTranslateUsed = false,
    required this.category,
    required this.productActive,
    required this.hasOffer,
    required this.offerType,
    required this.percent,
    required this.bundleQty,
    required this.bundlePrice,
    required this.bulkQty,
    required this.bulkPrice,
    required this.offerStartDate,
    required this.offerEndDate,
    required this.offerActive,

    // moderation defaults (server fills)
    this.moderationAutoBlocked = false,
    this.moderationManualBlocked = false,
    this.moderationMessageKey,
  });


  // ===============================================
  // Helpers
  // ===============================================

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    final s = v.toString().trim().replaceAll(',', '.');
    return double.tryParse(s) ?? 0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString().trim()) ?? 0;
  }

  static bool _toBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v != 0;

    final s = v.toString().trim().toLowerCase();
    return s == 'true' || s == '1' || s == 'yes' || s == 'y' || s == 'on';
  }

  static String _normalizeDate(dynamic v) {
    if (v == null) return '';
    final s = v.toString().trim();
    if (s.isEmpty) return '';

    final dt = DateTime.tryParse(s);
    if (dt != null) {
      final local = dt.toLocal();
      return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
    }
    return s;
  }

  // ===============================================
  // Firebase Serialization
  // ===============================================
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "price": price,
      "size_value": sizeValue,
      "size_unit": sizeUnit,
      "image": image,
      "thumb": thumb,
      'description': {
        'ar': descriptionMap['ar'] ?? '',
        'de': descriptionMap['de'] ?? '',
        'en': descriptionMap['en'] ?? '',
        'tr': descriptionMap['tr'] ?? '',
      },

      "category": category,
      "product_active": productActive,
      "has_offer": hasOffer,
      "offer_type": offerType,
      "percent": percent,
      "bundle_qty": bundleQty,
      "bundle_price": bundlePrice,
      "bulk_qty": bulkQty,
      "bulk_price": bulkPrice,
      "offer_start_date": offerStartDate,
      "offer_end_date": offerEndDate,
      "offer_active": offerActive,
    };
  }

  static Map<String, String> _parseDescriptionMap(dynamic raw) {
      const empty = {'ar': '', 'de': '', 'en': '', 'tr': ''};
      if (raw == null || raw is! Map) return empty;
      return {
        'ar': (raw['ar'] ?? '').toString(),
        'de': (raw['de'] ?? '').toString(),
        'en': (raw['en'] ?? '').toString(),
        'tr': (raw['tr'] ?? '').toString(),
      };
    }

  static String _descriptionFallback(dynamic raw) {
    if (raw == null) return '';
    if (raw is Map) {
      // ✅ Keine Fallback-Sprache mehr. Nur "de" als Preview (oder leer).
      final v = (raw['de'] ?? '').toString().trim();
      return v; // bleibt leer, wenn de leer ist
    }
    return raw.toString();
  }


  factory Product.fromMap(Map<String, dynamic> data) {
      final modRaw = data['moderation'];
      final mod = (modRaw is Map)
          ? Map<String, dynamic>.from(modRaw)
          : const <String, dynamic>{};

      return Product(
        id: (data['id'] ?? '').toString(),
        name: (data['name'] ?? '').toString(),
        price: _toDouble(data['price']),
        sizeValue: _toDouble(data['size_value']),
        sizeUnit: (data['size_unit'] ?? '').toString(),
        image: (data['image'] ?? '').toString(),
        thumb: (data['thumb'] ?? '').toString(),

        description: _descriptionFallback(data['description']),
        descriptionMap: _parseDescriptionMap(data['description']),

        autoTranslateUsed: _toBool(
          data['description_meta'] is Map
              ? data['description_meta']['autoTranslateUsed']
              : null,
        ),

        category: (data['category'] ?? '').toString(),
        productActive: _toBool(data['product_active']),
        hasOffer: _toBool(data['has_offer']),
        offerType: (data['offer_type'] ?? '').toString(),
        percent: _toDouble(data['percent']),
        bundleQty: _toInt(data['bundle_qty']),
        bundlePrice: _toDouble(data['bundle_price']),
        bulkQty: _toInt(data['bulk_qty']),
        bulkPrice: _toDouble(data['bulk_price']),
        offerStartDate: _normalizeDate(data['offer_start_date']),
        offerEndDate: _normalizeDate(data['offer_end_date']),
        offerActive: _toBool(data['offer_active']),

        moderationAutoBlocked: mod['autoBlocked'] == true,
        moderationManualBlocked: mod['manualBlocked'] == true,
        moderationMessageKey: mod['messageKey']?.toString(),
      );
    }


  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, category: $category, active: $productActive)';
  }

  Product copyWith({
    String? id,
    String? name,
    double? price,
    double? sizeValue,
    String? sizeUnit,
    String? image,
    String? thumb,
    String? description,
    Map<String, String>? descriptionMap,
    bool? autoTranslateUsed,
    String? category,
    bool? productActive,
    bool? hasOffer,
    String? offerType,
    double? percent,
    int? bundleQty,
    double? bundlePrice,
    int? bulkQty,
    double? bulkPrice,
    String? offerStartDate,
    String? offerEndDate,
    bool? offerActive,

    bool? moderationAutoBlocked,
    bool? moderationManualBlocked,
    String? moderationMessageKey,
  }) {

    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      sizeValue: sizeValue ?? this.sizeValue,
      sizeUnit: sizeUnit ?? this.sizeUnit,
      image: image ?? this.image,
      thumb: thumb ?? this.thumb,
      description: description ?? this.description,
      descriptionMap: descriptionMap ?? this.descriptionMap,
      autoTranslateUsed: autoTranslateUsed ?? this.autoTranslateUsed,
      category: category ?? this.category,
      productActive: productActive ?? this.productActive,
      hasOffer: hasOffer ?? this.hasOffer,
      offerType: offerType ?? this.offerType,
      percent: percent ?? this.percent,
      bundleQty: bundleQty ?? this.bundleQty,
      bundlePrice: bundlePrice ?? this.bundlePrice,
      bulkQty: bulkQty ?? this.bulkQty,
      bulkPrice: bulkPrice ?? this.bulkPrice,
      offerStartDate: offerStartDate ?? this.offerStartDate,
      offerEndDate: offerEndDate ?? this.offerEndDate,
      offerActive: offerActive ?? this.offerActive,

      moderationAutoBlocked: moderationAutoBlocked ?? this.moderationAutoBlocked,
      moderationManualBlocked: moderationManualBlocked ?? this.moderationManualBlocked,
      moderationMessageKey: moderationMessageKey ?? this.moderationMessageKey,
    );
  }
}
