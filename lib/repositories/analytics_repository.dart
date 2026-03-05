import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/store_config_service.dart';

class AnalyticsDaily {
  final String dayKey; // YYYY-MM-DD
  final int pageView;
  final int productView;
  final int addToCart;
  final int checkoutIntent;
  final int whatsappClick;

  AnalyticsDaily({
    required this.dayKey,
    required this.pageView,
    required this.productView,
    required this.addToCart,
    required this.checkoutIntent,
    required this.whatsappClick,
  });

  int get totalEvents =>
      pageView + productView + addToCart + checkoutIntent + whatsappClick;

  static int _asInt(dynamic v) => (v is num) ? v.toInt() : 0;

  factory AnalyticsDaily.fromDoc(String dayKey, Map<String, dynamic> data) {
    return AnalyticsDaily(
      dayKey: dayKey,
      pageView: _asInt(data['page_view']),
      productView: _asInt(data['product_view']),
      addToCart: _asInt(data['add_to_cart']),
      checkoutIntent: _asInt(data['checkout_intent']),
      whatsappClick: _asInt(data['whatsapp_click']),
    );
  }
}

class AnalyticsRepository {
  final FirebaseFirestore _db;
  AnalyticsRepository({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  String _storeId() {
    final s = StoreConfigService.store;
    return (s?['id'] ?? s?['store_id'] ?? 'unknown').toString();
  }

  Future<List<AnalyticsDaily>> fetchLastDays({int days = 30}) async {
    final storeId = _storeId();
    if (storeId == 'unknown') return [];

    final snap = await _db
        .collection('stores_private')
        .doc(storeId)
        .collection('analytics_daily')
        .orderBy(FieldPath.documentId, descending: true)
        .limit(days)
        .get();

    final docs = snap.docs
        .map((d) => AnalyticsDaily.fromDoc(d.id, d.data()))
        .toList()
        .reversed
        .toList();

    // fehlende Tage mit 0 auffüllen (für saubere Charts)
    return _fillMissingDays(docs, days);
  }

  List<AnalyticsDaily> _fillMissingDays(List<AnalyticsDaily> existing, int days) {
    if (existing.isEmpty) return existing;

    DateTime parseDay(String k) {
      final parts = k.split('-');
      return DateTime.utc(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }

    String toKey(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final map = {for (final e in existing) e.dayKey: e};

    final lastDay = parseDay(existing.last.dayKey);
    final start = lastDay.subtract(Duration(days: days - 1));

    final out = <AnalyticsDaily>[];
    for (int i = 0; i < days; i++) {
      final day = start.add(Duration(days: i));
      final key = toKey(day);
      out.add(map[key] ??
          AnalyticsDaily(
            dayKey: key,
            pageView: 0,
            productView: 0,
            addToCart: 0,
            checkoutIntent: 0,
            whatsappClick: 0,
          ));
    }
    return out;
  }
}