// lib/screens/settings.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../services/api_service.dart';
import '../services/store_config_service.dart';
import '../app_theme_mode.dart';
import '../main.dart';
import '../storage/store_prefs.dart';
import 'package:store_controller/widgets/app_page.dart';

import '../widgets/emoji_picker_sheet.dart';

typedef WorkingHours = Map<String, List<Map<String, dynamic>>>;

class SettingsScreen extends StatefulWidget {
  final bool firstSetup;
  const SettingsScreen({super.key, required this.firstSetup});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();

  // Read-only
  String _storeId = '';
  String _createdAtRaw = '';

  // Controllers
  final _storeName = TextEditingController();
  final _currency = TextEditingController(text: '€');
  final _pageDescription = TextEditingController();

  final _email = TextEditingController();
  final _address = TextEditingController();

  final _shippingPrice = TextEditingController();

  final _tiktok = TextEditingController();
  final _instagram = TextEditingController();
  final _facebook = TextEditingController();
  final _storeWebsite = TextEditingController();

  // Auth (first setup)
  final _authEmailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePass = true;

  // Phone + WhatsApp (code = dropdown, number = input)
  String _phoneCode = '+49';
  final _phoneNumber = TextEditingController();

  String _waCode = '+49';
  final _waNumber = TextEditingController();


  // WhatsApp autofill when identical to phone
  bool _waLinkedToPhone = true;     // keeps WA in sync until user changes it
  bool _syncingWaFromPhone = false; // guard to avoid feedback loops
  bool _phoneWaSyncLock = false;    // disabled while hydrating from storage
  // Flags
  bool _loading = true;
  bool _saving = false;
  bool _refreshing = false;
  bool _editing = false;

  bool _shipping = false;
  bool _requireEmailVerify = true;
  // Logo (emoji) stored in has_logo cell
  String _logoEmoji = '🏪';

  // Working hours JSON
  WorkingHours _wh = _emptyWeek();


  // ---------------------------
  // Lifecycle
  // ---------------------------

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _wirePhoneWhatsappSync();
    _boot();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _phoneNumber.removeListener(_onPhoneChanged);
    _waNumber.removeListener(_onWhatsAppChanged);


    _storeName.dispose();
    _currency.dispose();
    _pageDescription.dispose();
    _email.dispose();
    _address.dispose();

    _shippingPrice.dispose();
    _tiktok.dispose();
    _instagram.dispose();
    _facebook.dispose();
    _storeWebsite.dispose();

    _authEmailCtrl.dispose();
    _passwordCtrl.dispose();

    _phoneNumber.dispose();
    _waNumber.dispose();

    super.dispose();
  }

  // ---------------------------
  // Boot / Refresh
  // ---------------------------

  Future<void> _boot() async {
    if (!widget.firstSetup) {
      await StoreConfigService.load(allowNetworkIfEmpty: true);
      final s = StoreConfigService.store;
      if (s != null) _fill(s);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _updateFromSheet() async {
    if (_saving) return;
    setState(() => _refreshing = true);
    try {
      final s = await StoreConfigService.refresh();
      if (kDebugMode) debugPrint("REFRESH storeConfig = $s");
      if (s != null) {
        _fill(s);
        _toast('تم التحديث');
      } else {
        _toast('فشل التحديث');
      }
    } catch (e) {
      _toast('خطأ: $e');
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  void _fill(Map<String, dynamic> s) {
    if (!mounted) return;

    _phoneWaSyncLock = true;
    setState(() {
      _storeId = (s['store_id'] ?? s['storeId'] ?? '').toString();
      _createdAtRaw = (s['created_at'] ?? s['createdAt'] ?? '').toString();

      _storeName.text = (s['store_name'] ?? s['storeName'] ?? '').toString();
      _currency.text = (s['currency'] ?? '€').toString();
      _pageDescription.text = (s['page_description'] ?? s['pageDescription'] ?? '').toString();

      _email.text = (s['email'] ?? '').toString();
      _address.text = (s['address'] ?? '').toString();

      _storeWebsite.text = (s['public_store_url'] ?? '').toString();
      s['website_active']?.toString().toLowerCase() == 'true';

      _shipping = s['shipping'] == true ||
          s['shipping']?.toString().toLowerCase() == 'true';

      final sp = s['shipping_price'] ?? s['shippingPrice'];
      _shippingPrice.text = (sp ?? '').toString();

      _tiktok.text = (s['tiktok'] ?? '').toString();
      _instagram.text = (s['instagram'] ?? '').toString();
      _facebook.text = (s['facebook'] ?? '').toString();

      _requireEmailVerify = s['require_email_verify'] == true ||
          s['require_email_verify']?.toString().toLowerCase() == 'true';

      // Logo emoji under has_logo
      final rawLogo = s['has_logo'] ?? s['hasLogo'];
      if (rawLogo is String && rawLogo.trim().isNotEmpty) {
        _logoEmoji = rawLogo.trim();
      } else if (rawLogo == true || rawLogo?.toString().toLowerCase() == 'true') {
        _logoEmoji = '🏪';
      }

      // Phone split
      final rawPhone = (s['phone'] ?? '').toString().trim();
      final p = _splitInternational(rawPhone);
      if (p != null) {
        _phoneCode = p.$1;
        _phoneNumber.text = p.$2;
      } else {
        // if stored without +code, keep number only
        if (!rawPhone.startsWith('+')) _phoneNumber.text = rawPhone;
      }

      // WhatsApp split
      final rawWa = (s['whatsapp'] ?? '').toString().trim();
      final w = _splitInternational(rawWa);
      if (w != null) {
        _waCode = w.$1;
        _waNumber.text = w.$2;
      } else {
        if (!rawWa.startsWith('+')) _waNumber.text = rawWa;
      }



      // إذا كان الواتساب فارغاً: استخدم رقم الهاتف تلقائياً (واتساب مطلوب)
      final fullPhone = '$_phoneCode${_phoneNumber.text.trim()}';
      final fullWa = '$_waCode${_waNumber.text.trim()}';
      _waLinkedToPhone = _waNumber.text.trim().isEmpty || (fullWa == fullPhone);
      if (_waNumber.text.trim().isEmpty && _phoneNumber.text.trim().isNotEmpty) {
        _waCode = _phoneCode;
        _waNumber.text = _phoneNumber.text;
      }
// Working hours JSON
      final rawWh = (s['working_hours'] ?? s['workingHours'] ?? '').toString();
      _wh = workingHoursFromJson(rawWh);
    });
    _phoneWaSyncLock = false;
  }

  (String, String)? _splitInternational(String raw) {
    if (raw.isEmpty) return null;
    final r = raw.trim();
    if (!r.startsWith('+')) return null;
    final m = RegExp(r'^(\+\d{1,4})(\d+)$').firstMatch(r);
    if (m == null) return null;
    return (m.group(1)!, m.group(2)!);
  }

  // ---------------------------
  // Phone ⇄ WhatsApp sync
  // ---------------------------

  void _wirePhoneWhatsappSync() {
    _phoneNumber.addListener(_onPhoneChanged);
    _waNumber.addListener(_onWhatsAppChanged);
  }

  String _fullPhone() {
    final n = _phoneNumber.text.trim();
    if (n.isEmpty) return '';
    return '$_phoneCode$n';
  }

  String _fullWhatsApp() {
    final n = _waNumber.text.trim();
    if (n.isEmpty) return '';
    return '$_waCode$n';
  }

  void _onPhoneChanged() {
    if (_phoneWaSyncLock) return;
    if (!_waLinkedToPhone) return;
    _syncWhatsAppFromPhone(force: true);
  }

  void _onWhatsAppChanged() {
    if (_phoneWaSyncLock) return;
    if (_syncingWaFromPhone) return;

    // عند إلغاء الربط يظل الخيار بيد المستخدم (لا نفعّل الربط تلقائياً).
    if (_waLinkedToPhone) return;
  }

  void _syncWhatsAppFromPhone({bool force = false}) {
    final phNumber = _phoneNumber.text;

    _syncingWaFromPhone = true;
    try {
      // keep code in sync too
      _waCode = _phoneCode;

      if (phNumber.trim().isEmpty) {
        if (force && _waNumber.text.isNotEmpty) {
          _waNumber.text = '';
          _waNumber.selection = const TextSelection.collapsed(offset: 0);
        }
      } else {
        if (_waNumber.text != phNumber) {
          _waNumber.text = phNumber;
          _waNumber.selection = TextSelection.collapsed(offset: _waNumber.text.length);
        }
      }
    } finally {
      _syncingWaFromPhone = false;
    }

    // update code UI if needed
    if (mounted) setState(() {});
  }



  // ---------------------------
  // Validators
  // ---------------------------

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null;

  String? _emailValidator(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'مطلوب';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s);
    return ok ? null : 'بريد غير صحيح';
  }

  String? _digitsValidator(String? v, {bool required = true}) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return required ? 'مطلوب' : null;
    return RegExp(r'^[0-9]{6,20}$').hasMatch(s) ? null : 'رقم غير صحيح';
  }

  // ---------------------------
  // Save
  // ---------------------------

  bool get _canEdit => widget.firstSetup || _editing;
  bool get _enabled => _canEdit && !_saving;

  Map<String, dynamic> _collectForSave() {
    final phone = _phoneNumber.text.trim().isNotEmpty
        ? '$_phoneCode${_phoneNumber.text.trim()}'
        : '';

    var whatsapp = _waNumber.text.trim().isNotEmpty
        ? '$_waCode${_waNumber.text.trim()}'
        : '';
    // واتساب مطلوب: إذا كان فارغاً نستخدم رقم الهاتف
    if (whatsapp.isEmpty && phone.isNotEmpty) whatsapp = phone;


    return {
      'store_name': _storeName.text.trim(),
      'currency': _currency.text.trim(),
      'page_description': _pageDescription.text.trim(),

      'phone': phone,
      'whatsapp': whatsapp,

      'email': _email.text.trim(),
      'address': _address.text.trim(),

      // JSON string
      'working_hours': workingHoursToJson(_wh),

      'shipping': _shipping,
      'shipping_price': double.tryParse(_shippingPrice.text.trim()) ?? 0,

      // keep same sheet key name
      'has_logo': _logoEmoji,

      'tiktok': _tiktok.text.trim(),
      'instagram': _instagram.text.trim(),
      'facebook': _facebook.text.trim(),

      'require_email_verify': _requireEmailVerify,
    };
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      if (widget.firstSetup) {
        final username = _authEmailCtrl.text.trim();
        final password = _passwordCtrl.text;

        if (username.isEmpty || password.isEmpty) {
          _toast('اكتب البريد الإلكتروني وكلمة المرور');
          return;
        }
        if (password.length < 6) {
          _toast('كلمة المرور قصيرة (على الأقل 6 أحرف)');
          return;
        }

        final reg = await ApiService.registerFull(
          store: _collectForSave(),
          username: username,
          password: password,
        );

        if (!reg.ok) {
          _toast(_registerErrorToArabic(reg.error, reg.details));
          return;
        }

        // ✅ Option A: هنا لا يوجد token، فقط storeId
        final storeIdFromResp = (reg.data?['storeId'] ?? '').trim();
        final storeId = storeIdFromResp.isNotEmpty ? storeIdFromResp : (ApiService.storeId ?? '').trim();

        if (storeId.isEmpty) {
          _toast('حدث خطأ داخلي: لم يصل معرف المتجر من السيرفر');
          return;
        }

        await StorePrefs.setStoreId(storeId);

        if (!mounted) return;
        context.go('/verify-email', extra: {'storeId': storeId});
        return;
      }

      final ok = await ApiService.updateStore(_collectForSave());
      if (!ok) {
        _toast('فشل حفظ الإعدادات');
        return;
      }

      _toast('تم حفظ الإعدادات');
      await StoreConfigService.refresh();
    } catch (e) {
      _toast('خطأ: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _registerErrorToArabic(String? err, String? details) {
    final e = (err ?? '').toLowerCase().trim();
    final d = (details ?? '').trim();

    if (e.contains('missing username/password')) return 'اكتب البريد الإلكتروني وكلمة المرور';
    if (e.contains('password too short')) return 'كلمة المرور قصيرة (على الأقل 6 أحرف)';

    // Firebase Auth errors
    if (e.contains('email-already-in-use') || e.contains('username_exists') || e.contains('username already exists')) {
      return 'البريد الإلكتروني مستخدم بالفعل. استخدم بريدًا آخر';
    }
    if (e.contains('invalid-email') || e.contains('badly formatted')) {
      return 'صيغة البريد الإلكتروني غير صحيحة';
    }
    if (e.contains('weak-password')) {
      return 'كلمة المرور ضعيفة. استخدم 6 أحرف على الأقل';
    }

    if (e.contains('store_name required') || e.contains('store_name is required')) {
      return 'اسم المتجر مطلوب';
    }

    if (e.contains('email required')) return 'البريد الإلكتروني مطلوب';
    if (e.contains('email invalid')) return 'البريد الإلكتروني غير صحيح';

    if (e.contains('email_send_failed')) return 'فشل إرسال رمز التحقق. حاول مرة أخرى';

    if (d.isNotEmpty) return 'فشل إنشاء المتجر: $d';
    return 'فشل إنشاء المتجر. حاول مرة أخرى';
  }


  // ---------------------------
  // Location (GPS -> Text Address)
  // ---------------------------

  Future<void> _useCurrentLocationForAddress() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _toast('فعّل خدمة الموقع (GPS) أولاً');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        _toast('تم رفض إذن الموقع');
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        _toast('إذن الموقع مرفوض نهائياً. فعّله من الإعدادات');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );


      String? formatted;
      try {
        final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;

          final parts = <String>[
            if ((p.street ?? '').trim().isNotEmpty) p.street!.trim(),
            if ((p.subLocality ?? '').trim().isNotEmpty) p.subLocality!.trim(),
            if ((p.locality ?? '').trim().isNotEmpty) p.locality!.trim(),
            if ((p.administrativeArea ?? '').trim().isNotEmpty) p.administrativeArea!.trim(),
            if ((p.postalCode ?? '').trim().isNotEmpty) p.postalCode!.trim(),
            if ((p.country ?? '').trim().isNotEmpty) p.country!.trim(),
          ];

          formatted = parts.where((x) => x.isNotEmpty).join(', ');
        }
      } catch (_) {
        // ignore, we fallback below
      }

      formatted ??= 'https://maps.google.com/?q=${pos.latitude},${pos.longitude}';

      if (!mounted) return;
      setState(() => _address.text = formatted!);
      _toast('تم تحديد العنوان');
    } catch (e) {
      _toast('خطأ في الموقع: $e');
    }
  }

  // ---------------------------
  // Emoji picker
  // ---------------------------

  Future<void> _pickLogoEmoji() async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.92,
          minChildSize: 0.60,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return EmojiPickerSheet(
              selected: _logoEmoji,
              scrollController: scrollController, // 👈 wichtig
            );
          },
        );
      },
    );

    if (!mounted) return;

    if (chosen != null && chosen.trim().isNotEmpty) {
      setState(() => _logoEmoji = chosen.trim());
    }
  }


  // ---------------------------
  // UI helpers (Theme-based)
  // ---------------------------

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String get _createdAtDateOnly {
    final s = _createdAtRaw.trim();
    if (s.isEmpty) return '-';

    DateTime? dt = DateTime.tryParse(s);
    dt ??= DateTime.tryParse(s.replaceFirst(' ', 'T'));

    if (dt == null) {
      if (s.length >= 10 && RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(s.substring(0, 10))) {
        return s.substring(0, 10);
      }
      return s;
    }

    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Widget _sectionTitle(String title) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Text(
        title,
        textDirection: TextDirection.rtl,
        style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _card(Widget child) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }

  InputDecoration _dec(String label, {String? hint, Widget? suffix, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: const OutlineInputBorder(),
      prefixIcon: icon == null ? null : Icon(icon),
      suffixIcon: suffix,
    );
  }

  Widget _ltrField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
    int maxLines = 1,
    IconData? icon,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
      decoration: _dec(label, hint: hint, icon: icon, suffix: suffix),
      validator: validator,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
    );
  }

  Widget _rtlField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
    int maxLines = 1,
    IconData? icon,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      decoration: _dec(label, hint: hint, icon: icon, suffix: suffix),
      validator: validator,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
    );
  }

  // ---------------------------
  // Auto text direction (Arabic ⇄ Latin)
  // ---------------------------

  static final RegExp _arabicRe = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]');

  TextDirection _dirFor(String text, {TextDirection empty = TextDirection.rtl}) {
    final s = text.trimLeft();
    if (s.isEmpty) return empty;

    // Find first "strong" letter-like char
    for (final rune in s.runes) {
      final ch = String.fromCharCode(rune);

      // Skip common neutrals
      if (ch.trim().isEmpty) continue;

      // Arabic -> RTL
      if (_arabicRe.hasMatch(ch)) return TextDirection.rtl;

      // Basic Latin letters -> LTR
      final cu = ch.codeUnitAt(0);
      final isAsciiLetter = (cu >= 0x41 && cu <= 0x5A) || (cu >= 0x61 && cu <= 0x7A);
      final isDigit = (cu >= 0x30 && cu <= 0x39);
      if (isAsciiLetter || isDigit) return TextDirection.ltr;

      // Fallback: keep RTL UI
      return empty;
    }
    return empty;
  }

  Widget _autoDirField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
    int maxLines = 1,
    IconData? icon,
    Widget? suffix,
    TextDirection emptyDirection = TextDirection.rtl,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final dir = _dirFor(controller.text, empty: emptyDirection);
        return TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textDirection: dir,
          textAlign: dir == TextDirection.rtl ? TextAlign.right : TextAlign.left,
          decoration: _dec(label, hint: hint, icon: icon, suffix: suffix),
          validator: validator,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
        );
      },
    );
  }

  // ---------------------------
  // Currency dropdown (presets + free input)
  // ---------------------------

  static const List<(String symbol, String label)> _currencyPresets = [
    ('ل.س', 'ل.س  SYP (Syrian Pound)'),
    ('د.أ', 'د.أ  JOD (Jordanian Dinar)'),
    ('€', '€  EUR'),
    ('\$', '\$  USD'),
    ('₺', '₺  TRY (Turkish Lira)'),
    ('ر.ع.', 'ر.ع.  OMR (Omani Rial)'),
    ('د.إ', 'د.إ  AED (UAE Dirham)'),
    ('﷼', '﷼  SAR (Saudi Riyal)'),
    ('د.ك', 'د.ك  KWD (Kuwaiti Dinar)'),
    ('ر.ق', 'ر.ق  QAR (Qatar Riyal)'),
  ];

  Widget _currencyField({required bool enabled}) {
    return TextFormField(
      controller: _currency,
      enabled: enabled,
      maxLines: 1,
      keyboardType: TextInputType.text,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
      decoration: _dec(
        'العملة المستخدمة*',
        icon: Icons.currency_exchange,
        suffix: PopupMenuButton<String>(
          tooltip: 'اختر العملة',
          enabled: enabled,
          onSelected: (v) => setState(() => _currency.text = v),
          itemBuilder: (ctx) => _currencyPresets
              .map(
                (e) => PopupMenuItem<String>(
              value: e.$1,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Text(e.$2),
              ),
            ),
          )
              .toList(),
          icon: const Icon(Icons.arrow_drop_down),
        ),
      ),
      validator: _req,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
    );
  }





  // ---------------------------
  // Country code picker
  // ---------------------------

  static const List<(String name, String code)> _codes = [
    // Arabische Länder (alphabetisch sortiert)
    ('اردن', '+962'),                      // Jordan
    ('امارات', '+971'),                   // UAE
    ('بحرين', '+973'),                    // Bahrain
    ('تونس', '+216'),                     // Tunisia
    ('جزائر', '+213'),                    // Algeria
    ('جزر القمر', '+269'),                // Comoros
    ('جيبوتي', '+253'),                   // Djibouti
    ('سعودية', '+966'),                   // Saudi Arabia
    ('سودان', '+249'),                    // Sudan
    ('سوريا', '+963'),                    // Syria
    ('صومال', '+252'),                    // Somalia
    ('عراق', '+964'),                     // Iraq
    ('عمان', '+968'),                     // Oman
    ('فلسطين', '+970'),                   // Palestine
    ('قطر', '+974'),                      // Qatar
    ('كويت', '+965'),                     // Kuwait
    ('لبنان', '+961'),                    // Lebanon
    ('ليبيا', '+218'),                    // Libya
    ('مغرب', '+212'),                     // Morocco
    ('مصر', '+20'),                       // Egypt
    ('موريتانيا', '+222'),                // Mauritania
    ('يمن', '+967'),                      // Yemen

    // Andere Länder (alphabetisch sortiert)
    ('أذربيجان', '+994'),                    // Azerbaijan
    ('أرمينيا', '+374'),                     // Armenia
    ('أستراليا', '+61'),                     // Australia
    ('أفغانستان', '+93'),                    // Afghanistan
    ('ألبانيا', '+355'),                     // Albania
    ('ألمانيا', '+49'),                      // Germany
    ('أنغولا', '+244'),                      // Angola
    ('أندورا', '+376'),                      // Andorra
    ('أندونيسيا', '+62'),                    // Indonesia
    ('أوروغواي', '+598'),                    // Uruguay
    ('أوزبكستان', '+998'),                   // Uzbekistan
    ('أوكرانيا', '+380'),                    // Ukraine
    ('إثيوبيا', '+251'),                     // Ethiopia
    ('إريتريا', '+291'),                     // Eritrea
    ('إسبانيا', '+34'),                      // Spain
    ('إسواتيني', '+268'),                    // Eswatini
    ('إكوادور', '+593'),                     // Ecuador
    ('إيران', '+98'),                        // Iran
    ('إيطاليا', '+39'),                      // Italy
    ('الأرجنتين', '+54'),                    // Argentina
    ('البرازيل', '+55'),                     // Brazil
    ('البرتغال', '+351'),                    // Portugal
    ('البوسنة والهرسك', '+387'),             // Bosnia and Herzegovina
    ('التشيك', '+420'),                      // Czech Republic
    ('الدنمارك', '+45'),                     // Denmark
    ('السويد', '+46'),                       // Sweden
    ('الصين', '+86'),                        // China
    ('الفلبين', '+63'),                      // Philippines
    ('الفنلندية', '+358'),                   // Finland
    ('الكاميرون', '+237'),                   // Cameroon
    ('المجر', '+36'),                        // Hungary
    ('المملكة المتحدة', '+44'),              // United Kingdom
    ('النيجر', '+227'),                      // Niger
    ('النيوزلندية', '+64'),                  // New Zealand
    ('الهند', '+91'),                        // India
    ('اليابان', '+81'),                      // Japan
    ('اليونان', '+30'),                      // Greece
    ('بنغلاديش', '+880'),                    // Bangladesh
    ('بنما', '+507'),                        // Panama
    ('بولندا', '+48'),                       // Poland
    ('بوليفيا', '+591'),                     // Bolivia
    ('بوتسوانا', '+267'),                    // Botswana
    ('تايلاند', '+66'),                      // Thailand
    ('تركيا', '+90'),                        // Turkey
    ('تركمانستان', '+993'),                  // Turkmenistan
    ('تشاد', '+235'),                        // Chad
    ('تشيلي', '+56'),                        // Chile
    ('تنزانيا', '+255'),                     // Tanzania
    ('توغو', '+228'),                        // Togo
    ('جورجيا', '+995'),                      // Georgia
    ('جنوب أفريقيا', '+27'),                 // South Africa
    ('جواتيمالا', '+502'),                   // Guatemala
    ('روسيا', '+7'),                         // Russia
    ('رومانيا', '+40'),                      // Romania
    ('ساحل العاج', '+225'),                  // Ivory Coast
    ('سريلانكا', '+94'),                     // Sri Lanka
    ('سلوفاكيا', '+421'),                    // Slovakia
    ('سلوفينيا', '+386'),                    // Slovenia
    ('سنغافورة', '+65'),                     // Singapore
    ('سويسرا', '+41'),                       // Switzerland
    ('صربيا', '+381'),                       // Serbia
    ('فرنسا', '+33'),                        // France
    ('فنزويلا', '+58'),                      // Venezuela
    ('فنلندا', '+358'),                      // Finland
    ('فييتنام', '+84'),                      // Vietnam
    ('كازاخستان', '+7'),                     // Kazakhstan
    ('كندا', '+1'),                          // Canada
    ('كوبا', '+53'),                         // Cuba
    ('كولومبيا', '+57'),                     // Colombia
    ('كوريا الجنوبية', '+82'),               // South Korea
    ('كوريا الشمالية', '+850'),              // North Korea
    ('كينيا', '+254'),                       // Kenya
    ('لاتفيا', '+371'),                      // Latvia
    ('لوكسمبورغ', '+352'),                   // Luxembourg
    ('ليتوانيا', '+370'),                    // Lithuania
    ('مالي', '+223'),                        // Mali
    ('ماليزيا', '+60'),                      // Malaysia
    ('مدغشقر', '+261'),                      // Madagascar
    ('مقدونيا', '+389'),                     // North Macedonia
    ('ملاوي', '+265'),                       // Malawi
    ('منغوليا', '+976'),                     // Mongolia
    ('موزمبيق', '+258'),                     // Mozambique
    ('مولدوفا', '+373'),                     // Moldova
    ('ميانمار', '+95'),                      // Myanmar
    ('ناميبيا', '+264'),                     // Namibia
    ('نيبال', '+977'),                       // Nepal
    ('نيجيريا', '+234'),                     // Nigeria
    ('نيوزيلندا', '+64'),                    // New Zealand
    ('هولندا', '+31'),                       // Netherlands
    ('هونغ كونغ', '+852'),                   // Hong Kong
    ('هنغاريا', '+36'),                      // Hungary
    ('واتيكان', '+379'),                     // Vatican
    ('وسط أفريقيا', '+236'),                 // Central African Republic
    ('النمسا', '+43'),                       // Austria
    ('النرويج', '+47'),                      // Norway
    ('الولايات المتحدة', '+1'),              // United States
    ('باكستان', '+92'),                      // Pakistan
    ('بيرو', '+51'),                         // Peru
    ('جمهورية الدومينيكان', '+1'),          // Dominican Republic
    ('جمهورية الكونغو', '+242'),             // Republic of the Congo
    ('جمهورية الكونغو الديمقراطية', '+243'), // Democratic Republic of the Congo
    ('جنوب السودان', '+211'),                // South Sudan
    ('زامبيا', '+260'),                      // Zambia
  ];

  Future<void> _pickCode({
    required String title,
    required String current,
    required void Function(String) onPick,
  }) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,     // ✅ wichtig
      useSafeArea: true,            // ✅ wichtig
      showDragHandle: true,
      builder: (ctx) {
        final query = ValueNotifier('');

        return Padding(
          // ✅ schiebt den Inhalt hoch, sobald die Tastatur erscheint
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  TextField(
                    autofocus: true, // ✅ optional, aber angenehm
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search country or code',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => query.value = v.trim().toLowerCase(),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ValueListenableBuilder<String>(
                      valueListenable: query,
                      builder: (context, q, child) {
                        final list = _codes.where((e) {
                          final n = e.$1.toLowerCase();
                          final c = e.$2.toLowerCase();
                          return q.isEmpty || n.contains(q) || c.contains(q);
                        }).toList();

                        return ListView.separated(
                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, // ✅ nice
                          itemCount: list.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final item = list[i];
                            final selected = item.$2 == current;
                            return ListTile(
                              title: Text('${item.$1}  (${item.$2})', textDirection: TextDirection.ltr),
                              trailing: selected ? const Icon(Icons.check) : null,
                              onTap: () => Navigator.pop(ctx, item.$2),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (picked != null && picked.startsWith('+')) {
      onPick(picked);
      setState(() {});
    }
  }

  Widget _phoneRow({
    required String label,
    required String code,
    VoidCallback? onPickCode,
    required TextEditingController numberCtrl,
    required bool enabled,
    bool requiredNumber = true,
  }) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, textDirection: TextDirection.rtl, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              SizedBox(
                width: 140,
                child: InkWell(
                  onTap: (enabled && onPickCode != null) ? onPickCode : null,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Code',
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(code, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w800)),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: numberCtrl,
                  enabled: enabled,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  decoration: const InputDecoration(
                    labelText: 'Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => _digitsValidator(v, required: requiredNumber),
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------
  // Working hours (JSON) editor
  // ---------------------------

  static const List<String> _weekKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  static const Map<String, String> _weekAr = {
    'mon': 'الاثنين',
    'tue': 'الثلاثاء',
    'wed': 'الأربعاء',
    'thu': 'الخميس',
    'fri': 'الجمعة',
    'sat': 'السبت',
    'sun': 'الأحد',
  };

  static WorkingHours _emptyWeek() => {for (final k in _weekKeys) k: <Map<String, dynamic>>[]};

  WorkingHours workingHoursFromJson(String? raw) {
    if (raw == null) return _emptyWeek();
    final t = raw.trim();
    if (t.isEmpty) return _emptyWeek();
    try {
      final obj = jsonDecode(t);
      if (obj is! Map) return _emptyWeek();

      final out = _emptyWeek();
      for (final k in out.keys) {
        final v = obj[k];
        if (v is List) {
          out[k] = v.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
        }
      }
      return out;
    } catch (_) {
      return _emptyWeek();
    }
  }

  String workingHoursToJson(WorkingHours wh) {
    final out = <String, dynamic>{};
    for (final k in _weekKeys) {
      out[k] = wh[k] ?? [];
    }
    return jsonEncode(out);
  }

  bool _dayIsClosed(String dayKey) {
    final p = _wh[dayKey] ?? const [];
    if (p.isEmpty) return true;
    if (p.any((x) => x['closed'] == true)) return true;
    return false;
  }

  void _setDayClosed(String dayKey, bool closed) {
    setState(() {
      if (closed) {
        _wh[dayKey] = <Map<String, dynamic>>[];
      } else {
        _wh[dayKey] = [
          {'start': '09:00', 'end': '18:00'}
        ];
      }
    });
  }

  Future<String?> _pickTimeHHmm(BuildContext context, String? current) async {
    TimeOfDay initial = const TimeOfDay(hour: 9, minute: 0);
    if (current != null && current.contains(':')) {
      final parts = current.split(':');
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h != null && m != null) initial = TimeOfDay(hour: h, minute: m);
    }

    final t = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (t == null) return null;
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  int _toMin(String hhmm) {
    final p = hhmm.split(':');
    return (int.parse(p[0]) * 60) + int.parse(p[1]);
  }

  bool _validPeriod(String start, String end) {
    if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(start)) return false;
    if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(end)) return false;
    return _toMin(start) != _toMin(end);
  }

  Widget _workingHoursEditor({required bool enabled}) {
    final tt = Theme.of(context).textTheme;

    return Column(
      children: _weekKeys.map((dayKey) {
        final closed = _dayIsClosed(dayKey);
        final periods = _wh[dayKey] ?? <Map<String, dynamic>>[];

        return Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: !closed,
                  onChanged: enabled ? (v) => _setDayClosed(dayKey, !v) : null,
                  title: Text(_weekAr[dayKey] ?? dayKey, textDirection: TextDirection.rtl),
                ),
                if (!closed) ...[
                  const SizedBox(height: 8),
                  Column(
                    children: List.generate(periods.length, (i) {
                      final p = periods[i];
                      final start = (p['start'] ?? '09:00').toString();
                      final end = (p['end'] ?? '18:00').toString();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: enabled
                                    ? () async {
                                  final t = await _pickTimeHHmm(context, start);
                                  if (t == null) return;
                                  setState(() => periods[i]['start'] = t);
                                }
                                    : null,
                                icon: const Icon(Icons.schedule),
                                label: Text('Start: $start', textDirection: TextDirection.ltr),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: enabled
                                    ? () async {
                                  final t = await _pickTimeHHmm(context, end);
                                  if (t == null) return;
                                  setState(() => periods[i]['end'] = t);
                                }
                                    : null,
                                icon: const Icon(Icons.schedule),
                                label: Text('End: $end', textDirection: TextDirection.ltr),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: 'Remove',
                              onPressed: enabled
                                  ? () {
                                setState(() {
                                  periods.removeAt(i);
                                  if (periods.isEmpty) _wh[dayKey] = <Map<String, dynamic>>[];
                                });
                              }
                                  : null,
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: enabled
                              ? () {
                            setState(() {
                              _wh[dayKey] = (periods..add({'start': '09:00', 'end': '18:00'}));
                            });
                          }
                              : null,
                          icon: const Icon(Icons.add),
                          label: const Text('إضافة فترة', textDirection: TextDirection.rtl),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Builder(builder: (_) {
                    final invalid = periods.any((p) {
                      final s = (p['start'] ?? '').toString();
                      final e = (p['end'] ?? '').toString();
                      return !_validPeriod(s, e);
                    });
                    if (!invalid) return const SizedBox.shrink();
                    return Text(
                      'تحقق من الوقت: لا تجعل البداية = النهاية',
                      textDirection: TextDirection.rtl,
                      style: tt.bodySmall,
                    );
                  }),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------------------------
  // Build
  // ---------------------------

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final enabled = _enabled;
    final tt = Theme.of(context).textTheme;

    return PopScope(
      canPop: !widget.firstSetup,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && widget.firstSetup) context.go('/login');
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.firstSetup ? 'إعداد المتجر' : 'الإعدادات'),
          centerTitle: true,
          leading: widget.firstSetup
              ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/login'),
          )
              : null,
          actions: [
            if (!widget.firstSetup)
              IconButton(
                tooltip: 'Refresh',
                onPressed: _refreshing ? null : _updateFromSheet,
                icon: _refreshing
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh),
              ),
          ],
        ),
        body: AppPage(
          child: RefreshIndicator(
            onRefresh: _updateFromSheet,
            child: AbsorbPointer(
              absorbing: _saving,
              child: Form(
                key: _formKey,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom), // ✅ wichtig
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, // ✅ optional
                  children: [
                    _sectionTitle('المظهر'),
                    _card(
                      ListTile(
                        leading: const Icon(Icons.dark_mode_outlined),
                        title: const Text('الوضع', textDirection: TextDirection.rtl),
                        trailing: DropdownButton<AppThemeMode>(
                          value: MyApp.themeOf(context) ?? AppThemeMode.system,
                          onChanged: (mode) {
                            if (mode != null) MyApp.setThemeOf(context, mode);
                          },
                          items: const [
                            DropdownMenuItem(value: AppThemeMode.system, child: Text('تلقائي')),
                            DropdownMenuItem(value: AppThemeMode.light, child: Text('نهاري')),
                            DropdownMenuItem(value: AppThemeMode.dark, child: Text('ليلي')),
                          ],
                        ),
                      ),
                    ),

                    if (!widget.firstSetup) ...[
                      _sectionTitle('معلومات المتجر'),
                      _card(
                        Column(
                          children: [
                            _infoRow('معرف المتجر', _storeId),
                            const Divider(height: 16),
                            _infoRow('تم الانشاء', _createdAtDateOnly),
                          ],
                        ),
                      ),
                    ],

                    _sectionTitle('بيانات المتجر'),
                    _card(
                      Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(child: Text(_logoEmoji, style: tt.titleMedium)),
                            title: const Text('أيقونة المتجر', textDirection: TextDirection.rtl),
                            subtitle: const Text('اختر رمز واحد مثل واتساب', textDirection: TextDirection.rtl),
                            trailing: OutlinedButton(
                              onPressed: enabled ? _pickLogoEmoji : null,
                              child: const Text('اختيار'),
                            ),
                          ),
                          const SizedBox(height: 10),

                          _autoDirField(
                            controller: _storeName,
                            enabled: enabled,
                            label: 'اسم المتجر*',
                            validator: _req,
                            icon: Icons.storefront,
                          ),
                          const SizedBox(height: 10),
                          _autoDirField(
                            controller: _pageDescription,
                            enabled: enabled,
                            label: 'وصف المتجر',
                            hint: 'جودة عالية وأسعار مناسبة',
                            maxLines: 3,
                            icon: Icons.description_outlined,
                          ),
                          const SizedBox(height: 10),
                          _currencyField(enabled: enabled),
                        ],
                      ),
                    ),

                    _sectionTitle('التواصل'),
                    _card(
                      Column(
                        children: [
                          _ltrField(
                            controller: _email,
                            enabled: enabled,
                            label: 'البريد الإلكتروني*',
                            keyboardType: TextInputType.emailAddress,
                            validator: widget.firstSetup ? _emailValidator : null,
                            icon: Icons.email_outlined,
                          ),
                          const SizedBox(height: 12),

                          _phoneRow(
                            label: 'رقم الهاتف*',
                            code: _phoneCode,
                            enabled: enabled,
                            numberCtrl: _phoneNumber,
                            onPickCode: () => _pickCode(
                              title: 'Pick phone country code',
                              current: _phoneCode,
                              onPick: (v) { _phoneCode = v; _onPhoneChanged(); },
                            ),
                            requiredNumber: true,
                          ),
                          const SizedBox(height: 12),

                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _waLinkedToPhone,
                            onChanged: enabled
                                ? (v) {
                              setState(() => _waLinkedToPhone = v);
                              if (v) _syncWhatsAppFromPhone(force: true);
                            }
                                : null,
                            title: const Text('واتساب نفس رقم الهاتف', textDirection: TextDirection.rtl),
                          ),
                          const SizedBox(height: 8),

                          _phoneRow(
                            label: 'رقم واتساب*',
                            code: _waCode,
                            enabled: enabled && !_waLinkedToPhone,
                            numberCtrl: _waNumber,
                            onPickCode: (enabled && !_waLinkedToPhone)
                                ? () => _pickCode(
                              title: 'Pick WhatsApp country code',
                              current: _waCode,
                              onPick: (v) { _waCode = v; },
                            )
                                : null,
                            requiredNumber: true,
                          ),
                          const SizedBox(height: 12),

                          _autoDirField(
                            controller: _address,
                            enabled: enabled,
                            label: 'العنوان',
                            hint: 'يمكنك كتابة العنوان أو استخدام الموقع',
                            icon: Icons.location_on_outlined,
                            suffix: IconButton(
                              tooltip: 'Use current location',
                              onPressed: enabled ? _useCurrentLocationForAddress : null,
                              icon: const Icon(Icons.my_location),
                            ),
                          ),
                        ],
                      ),
                    ),

                    _sectionTitle('أوقات العمل'),
                    _workingHoursEditor(enabled: enabled),

                    _sectionTitle('التوصيل'),
                    _card(
                      Column(
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _shipping,
                            onChanged: enabled ? (v) => setState(() => _shipping = v) : null,
                            title: const Text('التوصيل متاح', textDirection: TextDirection.rtl),
                          ),
                          if (_shipping) ...[
                            const SizedBox(height: 10),
                            _ltrField(
                              controller: _shippingPrice,
                              enabled: enabled,
                              label: 'سعر التوصيل',
                              keyboardType: TextInputType.number,
                              icon: Icons.local_shipping_outlined,
                            ),
                          ],
                        ],
                      ),
                    ),

                    _sectionTitle('السوشيال'),
                    _card(
                      Column(
                        children: [
                          _ltrField(
                            controller: _tiktok,
                            enabled: enabled,
                            label: 'رابط التيك توك',
                            icon: Icons.link,
                          ),
                          const SizedBox(height: 10),
                          _ltrField(
                            controller: _instagram,
                            enabled: enabled,
                            label: 'رابط إنستغرام',
                            icon: Icons.link,
                          ),
                          const SizedBox(height: 10),
                          _ltrField(
                            controller: _facebook,
                            enabled: enabled,
                            label: 'رابط فيسبوك',
                            icon: Icons.link,
                          ),
                          const SizedBox(height: 10),
                          if (!widget.firstSetup)
                            _ltrField(
                              controller: _storeWebsite,
                              enabled: false,
                              label: 'رابط المتجر (قراءة فقط)',
                              icon: Icons.public,
                            ),
                        ],
                      ),
                    ),

                    if (widget.firstSetup) ...[
                      _sectionTitle('بيانات الدخول'),
                      _card(
                        Column(
                          children: [
                            TextFormField(
                              controller: _authEmailCtrl,
                              enabled: enabled,
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.left,
                              decoration: _dec(
                                '*البريد الإلكتروني',
                                hint: 'example@email.com',
                                icon: Icons.email_outlined,
                              ),
                              validator: (v) {
                                final email = v?.trim() ?? '';
                                if (email.isEmpty) return 'البريد الإلكتروني مطلوب';
                                if (!RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w{2,}$').hasMatch(email)) {
                                  return 'صيغة البريد الإلكتروني غير صحيحة';
                                }
                                return null;
                              },
                              onTapOutside: (_) => FocusScope.of(context).unfocus(),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _passwordCtrl,
                              enabled: enabled,
                              obscureText: _obscurePass,
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.left,
                              decoration: _dec(
                                '*كلمة المرور',
                                icon: Icons.lock_outline,
                                suffix: IconButton(
                                  onPressed: enabled ? () => setState(() => _obscurePass = !_obscurePass) : null,
                                  icon: Icon(_obscurePass ? Icons.visibility : Icons.visibility_off),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'مطلوب';
                                if (v.trim().length < 6) return 'على الأقل 6 أحرف';
                                return null;
                              },
                              onTapOutside: (_) => FocusScope.of(context).unfocus(),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saving
                            ? null
                            : () async {
                          if (!widget.firstSetup && !_editing) {
                            setState(() => _editing = true);
                            return;
                          }
                          await _save();
                          if (!mounted) return;
                          if (!widget.firstSetup) setState(() => _editing = false);
                        },
                        icon: _saving
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : Icon(widget.firstSetup ? Icons.check : (_editing ? Icons.save : Icons.edit)),
                        label: Text(_saving ? '...' : (widget.firstSetup ? 'إنشاء' : (_editing ? 'حفظ' : 'تعديل'))),
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (kDebugMode)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () async {
                            await StoreConfigService.clear();
                            await ApiService.clearStoreId();
                            if (!context.mounted) return;
                            context.go('/setup');
                          },
                          child: const Text('إعادة تعيين المتجر'),
                        ),
                      ),

                      const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Text('$label: ', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w800)),
        Expanded(
          child: Text(
            value.isEmpty ? '-' : value,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.ltr,
          ),
        ),
      ],
    );
  }
}
