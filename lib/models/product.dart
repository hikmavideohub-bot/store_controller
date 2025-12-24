// models/product.dart

class Product {
  String id;
  String name;
  double price;
  double sizeValue;
  String sizeUnit;
  String image;
  String description;
  String category;
  bool productActive;

  // Offer Fields
  bool hasOffer;
  String offerType;
  double percent;
  int bundleQty;
  double bundlePrice;
  String offerStartDate;
  String offerEndDate;
  bool offerActive;

  static String _normalizeDate(dynamic v) {
    if (v == null) return '';

    // Google Sheets kann auch Zahlen liefern (Seriennummer)
    if (v is num) {
      // Google Sheets Date serial: days since 1899-12-30
      final base = DateTime(1899, 12, 30);
      final dt = base.add(Duration(days: v.round()));
      return _fmtYmd(dt);
    }

    final s = v.toString().trim();
    if (s.isEmpty) return '';

    // 1) ISO / Timestamp versuchen
    final dt = DateTime.tryParse(s);
    if (dt != null) {
      // ✅ entscheidend: erst local machen, dann Datum nehmen
      return _fmtYmd(dt.toLocal());
    }

    // 2) Wenn nur "yyyy-MM-dd..." kommt
    final mIso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(s);
    if (mIso != null) {
      return '${mIso.group(1)}-${mIso.group(2)}-${mIso.group(3)}';
    }

    // 3) dd.MM.yyyy unterstützen
    final mDe = RegExp(r'^(\d{1,2})\.(\d{1,2})\.(\d{4})$').firstMatch(s);
    if (mDe != null) {
      final d = int.parse(mDe.group(1)!);
      final mo = int.parse(mDe.group(2)!);
      final y = int.parse(mDe.group(3)!);
      return _fmtYmd(DateTime(y, mo, d));
    }

    // fallback: 그대로
    return s;
  }

  static String _fmtYmd(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }


  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.sizeValue,
    required this.sizeUnit,
    required this.image,
    required this.description,
    required this.category,
    required this.productActive,
    required this.hasOffer,
    required this.offerType,
    required this.percent,
    required this.bundleQty,
    required this.bundlePrice,
    required this.offerStartDate,
    required this.offerEndDate,
    required this.offerActive,
  });

  // ===============================================
  // Helpers (robustes Parsing)
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

  /// Nimmt zuerst camelCase (Apps Script Response),
  /// fallback auf snake_case (Sheet / ältere Responses).
  static dynamic _pick(Map<String, dynamic> row, String camel, String snake) {
    if (row.containsKey(camel) && row[camel] != null) return row[camel];
    if (row.containsKey(snake) && row[snake] != null) return row[snake];
    return null;
  }

  // ===============================================
  // API: toJson (Senden -> snake_case wie im Sheet)
  // ===============================================
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "price": price,
      "sizevalue": sizeValue, // lowercase (wie in Sheet)
      "sizeunit": sizeUnit,   // lowercase (wie in Sheet)
      "image": image,
      "description": description,
      "category": category,

      // ✅ snake_case wie in Sheet
      "product_active": productActive,
      "has_offer": hasOffer,
      "offer_type": offerType,
      "percent": percent,
      "bundle_qty": bundleQty,
      "bundle_price": bundlePrice,
      "offer_start_date": offerStartDate,
      "offer_end_date": offerEndDate,

      // ✅ dein Sheet-Tippfehler bleibt unterstützt
      "offer_aktive": offerActive,
    };
  }

  // ===============================================
  // API: fromMap (Lesen <- camelCase ODER snake_case)
  // ===============================================
  static Product fromMap(Map<String, dynamic> row) {
    return Product(
      id: (_pick(row, 'id', 'id'))?.toString() ?? '',
      name: (_pick(row, 'name', 'name'))?.toString() ?? '',
      price: _toDouble(_pick(row, 'price', 'price')),

      // Apps Script macht aus "sizevalue" -> "sizevalue" (bleibt gleich),
      // aber wir lassen trotzdem camel/snake Pattern drin
      sizeValue: _toDouble(_pick(row, 'sizevalue', 'sizevalue')),
      sizeUnit: (_pick(row, 'sizeunit', 'sizeunit'))?.toString() ?? '',

      image: (_pick(row, 'image', 'image'))?.toString() ?? '',
      description: (_pick(row, 'description', 'description'))?.toString() ?? '',
      category: (_pick(row, 'category', 'category'))?.toString() ?? '',

      // ✅ HIER war dein Bug: Script liefert productActive, du hast product_active gelesen
      productActive: _toBool(_pick(row, 'productActive', 'product_active')),

      hasOffer: _toBool(_pick(row, 'hasOffer', 'has_offer')),
      offerType: (_pick(row, 'offerType', 'offer_type'))?.toString() ?? '',
      percent: _toDouble(_pick(row, 'percent', 'percent')),
      bundleQty: _toInt(_pick(row, 'bundleQty', 'bundle_qty')),
      bundlePrice: _toDouble(_pick(row, 'bundlePrice', 'bundle_price')),
      offerStartDate: _normalizeDate(_pick(row, 'offerStartDate', 'offer_start_date')),
      offerEndDate: _normalizeDate(_pick(row, 'offerEndDate', 'offer_end_date')),



      // ✅ Tippfehler im Sheet + mögliches camelCase aus Script
      offerActive: _toBool(row['offerActive'] ?? row['offerAktive'] ?? row['offer_aktive']),

    );
  }

  // ===============================================
  // Debug
  // ===============================================
  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, category: $category, '
        'productActive: $productActive, hasOffer: $hasOffer, offerType: $offerType, offerActive: $offerActive)';
  }

  // ===============================================
  // copyWith
  // ===============================================
  Product copyWith({
    String? id,
    String? name,
    double? price,
    double? sizeValue,
    String? sizeUnit,
    String? image,
    String? description,
    String? category,
    bool? productActive,
    bool? hasOffer,
    String? offerType,
    double? percent,
    int? bundleQty,
    double? bundlePrice,
    String? offerStartDate,
    String? offerEndDate,
    bool? offerActive,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      sizeValue: sizeValue ?? this.sizeValue,
      sizeUnit: sizeUnit ?? this.sizeUnit,
      image: image ?? this.image,
      description: description ?? this.description,
      category: category ?? this.category,
      productActive: productActive ?? this.productActive,
      hasOffer: hasOffer ?? this.hasOffer,
      offerType: offerType ?? this.offerType,
      percent: percent ?? this.percent,
      bundleQty: bundleQty ?? this.bundleQty,
      bundlePrice: bundlePrice ?? this.bundlePrice,
      offerStartDate: offerStartDate ?? this.offerStartDate,
      offerEndDate: offerEndDate ?? this.offerEndDate,
      offerActive: offerActive ?? this.offerActive,
    );
  }
}
