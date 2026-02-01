import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import '../../viewmodels/base_viewmodel.dart';
import '../../services/api_service.dart';
import '../../services/store_config_service.dart';
import '../../services/geocoding_service.dart';
import '../../storage/store_prefs.dart';
import '../../core/access_manager.dart';
import '../../utils/working_hours.dart';

class SettingsViewModel extends BaseViewModel {
  // ===========================================================================
  // CONTROLLER & STATE
  // ===========================================================================

  final storeNameCtrl = TextEditingController();
  final currencyCtrl = TextEditingController(text: '€');
  final pageDescCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final storeWebsiteCtrl = TextEditingController();
  String? selectedCountry;
  String logoEmoji = '🏪';

  // Store/Website Sprache (für die öffentliche Web-App)
  String storeLang = 'ar'; // Standard: Arabisch

  // Admin-App Sprache (für E-Mail-Benachrichtigungen)
  // Wird automatisch aus der aktuellen App-Locale gesetzt
  String adminAppLang = 'ar';

  // ... andere Variablen
  double? latitude;
  double? longitude;

  // Separate saving state (für UI Unterscheidung)
  bool _saving = false;
  bool get saving => _saving;

  // Neuer Status speziell für Passwort-Reset
  bool _sendingPasswordReset = false;
  bool get sendingPasswordReset => _sendingPasswordReset;

  final phoneCtrl = TextEditingController();
  String phoneCode = '+49';

  final waCtrl = TextEditingController();
  String waCode = '+49';
  bool waLinkedToPhone = true;
  bool _phoneWaSyncLock = false;

  final tiktokCtrl = TextEditingController();
  final instagramCtrl = TextEditingController();
  final facebookCtrl = TextEditingController();
  final emailSupportCtrl = TextEditingController();

  bool shippingEnabled = false;
  final shippingPriceCtrl = TextEditingController();

  String emailLogin = '';
  String authProvider = 'email';
  String createdAtRaw = '';
  String storeId = '';

  WorkingHours workingHours = {};

  // Passwort-Controller
  final currentPasswordCtrl = TextEditingController();
  final newPasswordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  bool showCurrentPassword = false;
  bool showNewPassword = false;

  // ===========================================================================
  // INIT & LADEN
  // ===========================================================================

  void init() {
    phoneCtrl.addListener(_onPhoneChanged);
    loadData();
  }

  Future<void> loadData() async {
    await runBusyAction(() async {
      await StoreConfigService.load(allowNetworkIfEmpty: true);
      var s = StoreConfigService.store;

      // Falls keine Daten oder store_name fehlt, frisch vom Server laden
      if (s == null || (s['store_name']?.toString().trim().isEmpty ?? true)) {
        final fresh = await ApiService.fetchStoreConfig();
        if (fresh != null) {
          await StoreConfigService.set(fresh);
          s = fresh;
        }
      }

      if (s != null) {
        _fillFromMap(s);
      }

      if (emailLogin.isEmpty) {
        final user = FirebaseAuth.instance.currentUser;
        emailLogin = user?.email ?? '';
      }
    });
  }

  void _fillFromMap(Map<String, dynamic> s) {
    _phoneWaSyncLock = true;

    storeId = (s['store_id'] ?? s['storeId'] ?? '').toString();
    createdAtRaw = (s['created_at'] ?? s['createdAt'] ?? '').toString();
    storeNameCtrl.text = (s['store_name'] ?? s['storeName'] ?? '').toString();
    currencyCtrl.text = (s['currency'] ?? '€').toString();
    pageDescCtrl.text = (s['page_description'] ?? s['pageDescription'] ?? '')
        .toString();
    addressCtrl.text = (s['address'] ?? '').toString();
    selectedCountry = s['address_country']?.toString();
    if (selectedCountry?.isEmpty ?? false) selectedCountry = null;
    storeWebsiteCtrl.text = (s['public_store_url'] ?? '').toString();

    shippingEnabled =
        s['shipping'] == true ||
        s['shipping']?.toString().toLowerCase() == 'true';
    shippingPriceCtrl.text = (s['shipping_price'] ?? s['shippingPrice'] ?? '')
        .toString();

    tiktokCtrl.text = (s['tiktok'] ?? '').toString();
    instagramCtrl.text = (s['instagram'] ?? '').toString();
    facebookCtrl.text = (s['facebook'] ?? '').toString();
    emailSupportCtrl.text = (s['email_support'] ?? '').toString();
    emailLogin = (s['email_login'] ?? s['owner_email'] ?? '').toString();
    authProvider = (s['auth_provider'] ?? 'email').toString();
    // Koordinaten laden
    latitude = double.tryParse((s['latitude'] ?? '').toString());
    longitude = double.tryParse((s['longitude'] ?? '').toString());

    final rawLogo = s['has_logo'] ?? s['hasLogo'];
    if (rawLogo is String && rawLogo.trim().isNotEmpty) {
      logoEmoji = rawLogo.trim();
    }

    // Store/Website Sprache laden
    final rawStoreLang = s['store_lang']?.toString();
    if (rawStoreLang != null && rawStoreLang.isNotEmpty) {
      storeLang = rawStoreLang;
    }

    // Admin-App Sprache laden
    final rawAdminLang = s['admin_app_lang']?.toString();
    if (rawAdminLang != null && rawAdminLang.isNotEmpty) {
      adminAppLang = rawAdminLang;
    }

    _parsePhone((s['phone'] ?? '').toString(), (code, number) {
      phoneCode = code;
      phoneCtrl.text = number;
    });

    _parsePhone((s['whatsapp'] ?? '').toString(), (code, number) {
      waCode = code;
      waCtrl.text = number;
    });

    final fullPhone = '$phoneCode${phoneCtrl.text.trim()}';
    final fullWa = '$waCode${waCtrl.text.trim()}';
    waLinkedToPhone = waCtrl.text.trim().isEmpty || (fullWa == fullPhone);

    if (waCtrl.text.trim().isEmpty && phoneCtrl.text.trim().isNotEmpty) {
      waCode = phoneCode;
      waCtrl.text = phoneCtrl.text;
    }

    final rawWh = (s['working_hours'] ?? s['workingHours'] ?? '').toString();
    workingHours = workingHoursFromJson(rawWh);

    _phoneWaSyncLock = false;
    notifyListeners();
  }

  void _parsePhone(String s, Function(String code, String phoneNumber) onFound) {
    if (s.isEmpty) return;
    if (s.contains('Closure') ||
        s.contains('Function') ||
        s.contains('Instance of')) {
      return;
    }

    // Bereinige den String von Leerzeichen und ungültigen Zeichen
    String clean = s.replaceAll(RegExp(r'[\s\-]'), '');

    // Regex, die versucht den Ländercode (+ gefolgt von 1-4 Ziffern) zu finden
    // und den Rest als Nummer zu behandeln.
    final m = RegExp(r'^(\+\d{1,4})(.*)$').firstMatch(clean);

    if (m != null) {
      String code = m.group(1)!;
      String number = m.group(2)!;

      // Falls die Nummer selbst noch mit + anfängt oder den Code wiederholt, rekursiv bereinigen
      if (number.startsWith('+') || number.contains('+')) {
        _parsePhone(number, onFound);
        return;
      }

      onFound(code, number);
    } else {
      // Fallback: Falls kein + vorhanden ist, nehmen wir +49 an,
      // aber filtern alle nicht-Ziffern aus dem Rest.
      onFound('+49', clean.replaceAll(RegExp(r'\D'), ''));
    }
  }

  // ===========================================================================
  // ACTIONS
  // ===========================================================================

  void setLogo(String emoji) {
    logoEmoji = emoji;
    notifyListeners();
  }

  void setCountry(String? code) {
    selectedCountry = code;
    notifyListeners();
  }

  void setCurrency(String curr) {
    currencyCtrl.text = curr;
    notifyListeners();
  }

  void setStoreLang(String lang) {
    storeLang = lang;
    notifyListeners();
  }

  void setPhoneCode(String code) {
    phoneCode = code;
    _onPhoneChanged();
    notifyListeners();
  }

  void setWaCode(String code) {
    waCode = code;
    notifyListeners();
  }

  void setLatitude(double? lat) {
    latitude = lat;
    notifyListeners();
  }

  void setLongitude(double? lng) {
    longitude = lng;
    notifyListeners();
  }

  void toggleShipping(bool v) {
    shippingEnabled = v;
    notifyListeners();
  }

  void toggleWaSync(bool v) {
    waLinkedToPhone = v;
    if (v) _syncWa(force: true);
    notifyListeners();
  }

  void updateWorkingHours(WorkingHours newWh) {
    workingHours = newWh;
    notifyListeners();
  }

  void _onPhoneChanged() {
    if (_phoneWaSyncLock || !waLinkedToPhone) return;
    _syncWa(force: true);
  }

  void _syncWa({bool force = false}) {
    waCode = phoneCode;
    if (phoneCtrl.text.isEmpty && force) {
      waCtrl.clear();
    } else if (waCtrl.text != phoneCtrl.text) {
      waCtrl.text = phoneCtrl.text;
    }
  }

  // GPS Logik - Web-kompatibel
  bool _fetchingLocation = false;
  bool get fetchingLocation => _fetchingLocation;

  Future<void> useCurrentLocation(AppLocalizations s) async {
    if (_fetchingLocation) return; // Verhindere doppelte Aufrufe

    _fetchingLocation = true;
    notifyListeners();

    try {
      // 1. GPS-Berechtigung prüfen
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw GeocodingException('Standortberechtigung verweigert');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw GeocodingException(
          'Standortberechtigung dauerhaft verweigert. Bitte in den Einstellungen aktivieren.',
        );
      }

      // 2. GPS-Position holen
      GeocodingService.debugLog('📍 GPS-Position wird abgerufen...');
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      GeocodingService.debugLog(
        '📍 Position: ${pos.latitude}, ${pos.longitude}',
      );

      // Koordinaten speichern
      latitude = pos.latitude;
      longitude = pos.longitude;

      // 3. Reverse Geocoding (Web-kompatibel!)
      GeocodingService.debugLog('🌍 Reverse Geocoding startet...');
      final result = await GeocodingService.getAddressFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      // 4. Adresse in TextField schreiben
      addressCtrl.text = result.address;
      if (result.countryCode != null && result.countryCode!.isNotEmpty) {
        selectedCountry = result.countryCode;
      }

      GeocodingService.debugLog('✅ Adresse gesetzt: ${result.address}');
      notifyListeners();
    } on GeocodingException catch (e) {
      GeocodingService.debugLog('❌ Geocoding-Fehler: $e');
      setError(s.locationFetchError(e.message));
    } catch (e) {
      GeocodingService.debugLog('❌ Allgemeiner Fehler: $e');
      setError(s.locationFetchError(e.toString()));
    } finally {
      _fetchingLocation = false;
      notifyListeners();
    }
  }

  // Passwort Logik
  Future<bool> changePassword(AppLocalizations s) async {
    final cur = currentPasswordCtrl.text.trim();
    final n = newPasswordCtrl.text.trim();
    final conf = confirmPasswordCtrl.text.trim();

    if (cur.isEmpty || n.isEmpty || conf.isEmpty) {
      setError(s.fillAllFieldsError);
      return false;
    }
    if (n != conf) {
      setError(s.passwordsNotMatch);
      return false;
    }
    if (n.length < 6) {
      setError(s.passwordTooShort);
      return false;
    }

    return await runBusyAction(() async {
          try {
            final user = FirebaseAuth.instance.currentUser!;
            final cred = EmailAuthProvider.credential(
              email: user.email!,
              password: cur,
            );
            await user.reauthenticateWithCredential(cred);
            await user.updatePassword(n);
            currentPasswordCtrl.clear();
            newPasswordCtrl.clear();
            confirmPasswordCtrl.clear();
            return true;
          } catch (e) {
            setError(s.generalError(e.toString()));
            return false;
          }
        }) ??
        false;
  }

  // GEÄNDERT: Nutzt nicht mehr runBusyAction, um UI-Reload zu vermeiden
  Future<bool> sendPasswordReset(AppLocalizations s) async {
    if (emailLogin.isEmpty) return false;

    _sendingPasswordReset = true;
    notifyListeners(); // Button zeigt Ladeindikator, aber Screen bleibt stabil

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailLogin);
      _sendingPasswordReset = false;
      notifyListeners();
      return true;
    } catch (e) {
      _sendingPasswordReset = false;
      setError(e.toString());
      notifyListeners();
      return false;
    }
  }

  String get createdAtDateOnly {
    final s = createdAtRaw.trim();
    if (s.isEmpty) return '-';

    if (s.startsWith('Timestamp')) {
      final match = RegExp(r'seconds=(\d+)').firstMatch(s);
      if (match != null) {
        final seconds = int.tryParse(match.group(1)!);
        if (seconds != null) {
          final dt = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
          return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
        }
      }
    }

    final dt = DateTime.tryParse(s.replaceFirst(' ', 'T'));
    if (dt == null) return s;
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  /// Setzt die Admin-App-Sprache (wird für E-Mail-Benachrichtigungen verwendet)
  void setAdminAppLang(String lang) {
    adminAppLang = lang;
    notifyListeners();
  }

  Future<bool> save(
    AppLocalizations s, {
    bool checkPaywall = true,
    bool isFirstSetup = false,
    String? currentLocale,
  }) async {
    if (storeNameCtrl.text.trim().isEmpty) {
      setError(s.storeNameRequired);
      return false;
    }
    if (checkPaywall && !AccessManager.canWriteAdmin) {
      setError(s.noEditPermission);
      return false;
    }

    _saving = true;
    notifyListeners();

    // Aktualisiere die Admin-App-Sprache auf die aktuelle Locale
    if (currentLocale != null &&
        ['ar', 'en', 'de', 'tr'].contains(currentLocale)) {
      adminAppLang = currentLocale;
    }

    final result =
        await runBusyAction<bool>(() async {
          final phoneFull = phoneCtrl.text.isNotEmpty
              ? '$phoneCode${phoneCtrl.text.trim()}'
              : '';
          var waFull = waCtrl.text.isNotEmpty
              ? '$waCode${waCtrl.text.trim()}'
              : '';
          if (waFull.isEmpty && phoneFull.isNotEmpty) waFull = phoneFull;

          final data = {
            'store_name': storeNameCtrl.text.trim(),
            'currency': currencyCtrl.text.trim(),
            'page_description': pageDescCtrl.text.trim(),
            'address': addressCtrl.text.trim(),
            'address_country': selectedCountry,
            'phone': phoneFull,
            'whatsapp': waFull,
            'email_support': emailSupportCtrl.text.trim(),
            'shipping': shippingEnabled,
            'shipping_price':
                double.tryParse(shippingPriceCtrl.text.trim()) ?? 0.0,
            'has_logo': logoEmoji,
            'tiktok': tiktokCtrl.text.trim(),
            'instagram': instagramCtrl.text.trim(),
            'facebook': facebookCtrl.text.trim(),
            'working_hours': workingHoursToJson(workingHours),
            'store_lang': storeLang,
            'admin_app_lang':
                adminAppLang, // Sprache für E-Mail-Benachrichtigungen
            'latitude': latitude,
            'longitude': longitude,
          };

          if (isFirstSetup) {
            data['setup_complete'] = true;
          }

          final success = await ApiService.updateStore(data);
          if (success) await StoreConfigService.refresh();
          return success;
        }) ??
        false;

    _saving = false;
    notifyListeners();
    return result;
  }

  // Diese Methode nimmt das Ergebnis der Karte entgegen und füllt automatisch Stadt, Land und Adresse aus.
  // Web-kompatibel durch GeocodingService
  Future<void> updateLocationFromMap(double lat, double lng) async {
    latitude = lat;
    longitude = lng;
    notifyListeners();

    try {
      // Reverse Geocoding (Web-kompatibel!)
      GeocodingService.debugLog('🗺️ Karten-Koordinaten: $lat, $lng');
      final result = await GeocodingService.getAddressFromCoordinates(lat, lng);

      // Adresse setzen
      addressCtrl.text = result.address;

      // Land setzen
      if (result.countryCode != null && result.countryCode!.isNotEmpty) {
        selectedCountry = result.countryCode;
      }

      GeocodingService.debugLog('✅ Karten-Adresse gesetzt: ${result.address}');
      notifyListeners();
    } on GeocodingException catch (e) {
      // Fehler loggen, aber Koordinaten behalten
      GeocodingService.debugLog('⚠️ Geocoding-Fehler (Karte): $e');
      // Optional: Fehlermeldung anzeigen
      setError('Adresse konnte nicht ermittelt werden: ${e.message}');
    } catch (e) {
      // Allgemeiner Fehler
      GeocodingService.debugLog('⚠️ Allgemeiner Fehler (Karte): $e');
      setError('Adresse konnte nicht ermittelt werden');
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await StorePrefs.clearAll();
  }

  bool get canWriteAdmin => AccessManager.canWriteAdmin;

  @override
  void dispose() {
    phoneCtrl.removeListener(_onPhoneChanged);
    storeNameCtrl.dispose();
    currencyCtrl.dispose();
    pageDescCtrl.dispose();
    addressCtrl.dispose();
    storeWebsiteCtrl.dispose();
    phoneCtrl.dispose();
    waCtrl.dispose();
    tiktokCtrl.dispose();
    instagramCtrl.dispose();
    facebookCtrl.dispose();
    emailSupportCtrl.dispose();
    shippingPriceCtrl.dispose();
    currentPasswordCtrl.dispose();
    newPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.dispose();
  }
}
