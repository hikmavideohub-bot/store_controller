import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geocoding/geocoding.dart' as native_geocoding;
import 'package:cloud_functions/cloud_functions.dart';

/// Plattformübergreifender Geocoding-Service
/// - Web & Native: Cloud Function (reverseGeocode) - sicher, ohne Client-API-Key
/// - Native Fallback: geocoding Package (Android/iOS) bei Fehler
class GeocodingService {
  /// Reverse Geocoding: Koordinaten -> Adresse
  /// Nutzt primär die Cloud Function (sicher, kein API-Key im Client)
  static Future<GeocodingResult> getAddressFromCoordinates(
    double latitude,
    double longitude, {
    String language = 'de',
  }) async {
    debugLog('🌍 [Geocoding] Anfrage: $latitude, $longitude (lang: $language)');

    try {
      // Primär: Cloud Function verwenden (funktioniert auf allen Plattformen)
      return await _getAddressViaCloudFunction(latitude, longitude, language);
    } catch (e) {
      debugLog('⚠️ [Geocoding] Cloud Function fehlgeschlagen: $e');

      // Fallback nur für Native (Android/iOS)
      if (!kIsWeb) {
        debugLog('📱 [Geocoding] Versuche Native-Fallback...');
        try {
          return await _getAddressFromCoordinatesNative(latitude, longitude);
        } catch (nativeError) {
          debugLog(
            '❌ [Geocoding] Native-Fallback auch fehlgeschlagen: $nativeError',
          );
        }
      }

      // Kein Fallback möglich -> Fehler weiterwerfen
      rethrow;
    }
  }

  /// Cloud Function Implementierung (sicher, API-Key serverseitig)
  static Future<GeocodingResult> _getAddressViaCloudFunction(
    double latitude,
    double longitude,
    String language,
  ) async {
    debugLog('☁️ [Cloud Function] reverseGeocode aufrufen...');

    final functions = FirebaseFunctions.instanceFor(region: 'europe-west3');
    final callable = functions.httpsCallable('reverseGeocode');

    final result = await callable.call<Map<String, dynamic>>({
      'lat': latitude,
      'lng': longitude,
      'language': language,
    });

    final data = result.data;

    if (data['success'] != true) {
      throw GeocodingException(
        data['message']?.toString() ?? 'Unbekannter Fehler',
      );
    }

    final address = data['formattedAddress']?.toString() ?? '';
    final countryCode = data['countryCode']?.toString();
    final fullAddress = data['fullAddress']?.toString();
    final city = data['city']?.toString();

    if (address.isEmpty) {
      throw GeocodingException('Keine Adresse gefunden');
    }

    debugLog(
      '✅ [Cloud Function] Ergebnis: $address (Land: $countryCode, Stadt: $city)',
    );

    return GeocodingResult(
      address: address,
      countryCode: countryCode,
      fullAddress: fullAddress,
      city: city,
    );
  }

  /// Native Implementierung via geocoding Package (nur als Fallback)
  static Future<GeocodingResult> _getAddressFromCoordinatesNative(
    double latitude,
    double longitude,
  ) async {
    debugLog('📱 [Native Geocoding] Anfrage: $latitude, $longitude');

    final placemarks = await native_geocoding.placemarkFromCoordinates(
      latitude,
      longitude,
    );

    if (placemarks.isEmpty) {
      throw GeocodingException('Keine Adresse gefunden');
    }

    final p = placemarks.first;

    // Adresse bauen
    final parts = [
      p.street,
      p.subLocality,
      p.locality,
      p.administrativeArea,
    ].where((x) => x != null && x.isNotEmpty).toSet().toList();

    final address = parts.join(', ');

    debugLog(
      '✅ [Native Geocoding] Ergebnis: $address (Land: ${p.isoCountryCode})',
    );

    return GeocodingResult(
      address: address,
      countryCode: p.isoCountryCode,
      fullAddress: '$address, ${p.country ?? ''}',
      city: p.locality,
    );
  }

  /// Debug-Logging (nur im Debug-Modus)
  static void debugLog(String message) {
    assert(() {
      // ignore: avoid_print
      print(message);
      return true;
    }());
  }
}

/// Ergebnis des Geocoding
class GeocodingResult {
  final String address;
  final String? countryCode;
  final String? fullAddress;
  final String? city;

  GeocodingResult({
    required this.address,
    this.countryCode,
    this.fullAddress,
    this.city,
  });

  @override
  String toString() =>
      'GeocodingResult(address: $address, countryCode: $countryCode)';
}

/// Geocoding-Fehler mit Details
class GeocodingException implements Exception {
  final String message;
  final String? details;

  GeocodingException(this.message, {this.details});

  @override
  String toString() => details != null ? '$message: $details' : message;
}
