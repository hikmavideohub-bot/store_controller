import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:store_controller/models/subscription_plan.dart';

/// Repository zum Laden der Pläne aus Firestore
class PricingRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Lädt nur die Pläne (Legacy-Methode für Rückwärtskompatibilität)
  Future<List<SubscriptionPlan>> fetchPlans() async {
    final config = await fetchSubscriptionConfig();
    return config.plans;
  }

  /// Lädt die komplette Subscription-Config aus einem einzigen Dokument
  /// Struktur: { syria_contact_phone, plans: { plan_id: { ... } } }
  Future<SubscriptionConfig> fetchSubscriptionConfig() async {
    try {
      final configDoc = await _db.doc('pricing/subscription_config').get();

      final data = configDoc.data() ?? {};
      return SubscriptionConfig.fromMap(data);
    } catch (e) {
      debugPrint('Fehler beim Laden der Subscription-Config: $e');
      rethrow;
    }
  }
}
