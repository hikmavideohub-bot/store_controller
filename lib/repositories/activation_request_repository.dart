import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Model für eine Aktivierungsanfrage (Daten-Container)
class ActivationRequest {
  final String? id;
  final String storeId;
  final String storeName;
  final String userId;
  final String planId;
  final double amount;
  final String currency;
  final String transferAccountName;
  final String paymentMethod;
  final String status;
  final DateTime? createdAt;
  final String contactInfo;

  ActivationRequest({
    this.id,
    required this.storeId,
    required this.storeName,
    required this.userId,
    required this.planId,
    required this.amount,
    required this.currency,
    required this.transferAccountName,
    this.paymentMethod = 'manual_syria',
    this.status = 'pending',
    this.createdAt,
    required this.contactInfo,
  });

  // Wandelt Objekt in Map für Firestore um
  Map<String, dynamic> toMap() {
    return {
      'store_id': storeId, // WICHTIG: In Firestore heißt das Feld 'store_id'
      'store_name': storeName,
      'user_id': userId,
      'plan_id': planId,
      'amount': amount,
      'currency': currency,
      'transfer_account_name': transferAccountName,
      'payment_method': paymentMethod,
      'status': status,
      'created_at': FieldValue.serverTimestamp(),
      'contact_info': contactInfo,
    };
  }

  // Erstellt Objekt aus Firestore Map
  factory ActivationRequest.fromMap(String id, Map<String, dynamic> map) {
    return ActivationRequest(
      id: id,
      storeId: map['store_id'] ?? '',
      storeName: map['store_name'] ?? '',
      userId: map['user_id'] ?? '',
      planId: map['plan_id'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      currency: map['currency'] ?? '',
      transferAccountName: map['transfer_account_name'] ?? '',
      paymentMethod: map['payment_method'] ?? 'manual_syria',
      status: map['status'] ?? 'pending',
      createdAt: (map['created_at'] as Timestamp?)?.toDate(),
      contactInfo: map['contact_info'] ?? '',
    );
  }
}

/// Repository: Hier findet die Datenbank-Kommunikation statt
class ActivationRequestRepository {
  // Hier definieren wir die Datenbank-Instanz
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Erstellt eine neue Aktivierungsanfrage
  Future<String> createActivationRequest(ActivationRequest request) async {
    try {
      final docRef = await _firestore
          .collection('activation_requests')
          .add(request.toMap());
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Prüft, ob bereits eine offene Anfrage für diesen Store existiert
  Future<bool> hasPendingRequest(String storeId) async {
    try {
      final snapshot = await _firestore
          .collection('activation_requests')
          .where(
            'store_id',
            isEqualTo: storeId,
          ) // WICHTIG: store_id muss matchen mit toMap
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Fehler beim Prüfen auf offene Anfragen: $e');
      return false;
    }
  }

  /// Lädt alle Anfragen für einen Store (Optional)
  Future<List<ActivationRequest>> getRequestsForStore(String storeId) async {
    try {
      final snapshot = await _firestore
          .collection('activation_requests')
          .where('store_id', isEqualTo: storeId)
          .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ActivationRequest.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
