import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:store_controller/widgets/app_page.dart';
import '../services/store_config_service.dart';
import '../app_theme_mode.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  final bool firstSetup;
  const SettingsScreen({super.key, required this.firstSetup});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Read-only (anzeigen)
  String _storeId = '';
  String _createdAt = '';

  // Edit/Setup
  final _storeName = TextEditingController();
  final _currency = TextEditingController(text: '€');

  final _pageDescription = TextEditingController();

  final _phone = TextEditingController();
  final _whatsapp = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _workingHours = TextEditingController();

  final _shippingPrice = TextEditingController();

  final _tiktok = TextEditingController();
  final _instagram = TextEditingController();
  final _facebook = TextEditingController();
  final _storeWebsite = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePass = true;


  bool _websiteActive = false;

  bool _shipping = false;
  bool _hasLogo = false;

  bool _loading = true;
  bool _saving = false;

  bool _refreshing = false;
  bool _editing = false;

  Map<String, dynamic>? _original;

  Future<void> _updateFromSheet() async {
    if (_saving) return;

    setState(() => _refreshing = true);
    try {
      final s = await StoreConfigService.refresh();

      debugPrint("STORE keys = ${StoreConfigService.store?.keys.toList()}");
      debugPrint("STORE snapshot = ${StoreConfigService.store}");
      if (kDebugMode) {
        print('REFRESH storeConfig = $s');
      }
      if (kDebugMode) {
        print('website_active=${s?['website_active']} store_website=${s?['store_website']}');
      }

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

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    if (!widget.firstSetup) {
      await StoreConfigService.load(allowNetworkIfEmpty: true);
      final s = StoreConfigService.store;
      if (s != null) _fill(s);
    }
    if (mounted) setState(() => _loading = false);
  }

  void _fill(Map<String, dynamic> s) {
    if (!mounted) return;

    setState(() {
      _original = Map<String, dynamic>.from(s);

      _storeId = (s['store_id'] ?? s['storeId'] ?? '').toString();
      _createdAt = (s['created_at'] ?? s['createdAt'] ?? '').toString();

      _storeName.text = (s['store_name'] ?? s['storeName'] ?? '').toString();
      _currency.text = (s['currency'] ?? '€').toString();

      _phone.text = (s['phone'] ?? '').toString();
      _whatsapp.text = (s['whatsapp'] ?? '').toString();
      _email.text = (s['email'] ?? '').toString();
      _address.text = (s['address'] ?? '').toString();
      _workingHours.text =
          (s['working_hours'] ?? s['workingHours'] ?? '').toString();

      _shipping = s['shipping'] == true ||
          s['shipping']?.toString().toLowerCase() == 'true';

      final sp = s['shipping_price'] ?? s['shippingPrice'];
      _shippingPrice.text = (sp ?? '').toString();

      _hasLogo = s['has_logo'] == true ||
          s['has_logo']?.toString().toLowerCase() == 'true' ||
          s['hasLogo']?.toString().toLowerCase() == 'true';

      _tiktok.text = (s['tiktok'] ?? '').toString();
      _instagram.text = (s['instagram'] ?? '').toString();
      _facebook.text = (s['facebook'] ?? '').toString();

      _storeWebsite.text = (s['store_website'] ?? s['storeWebsite'] ?? '').toString();
      _websiteActive = s['website_active'] == true ||
          s['website_active']?.toString().toLowerCase() == 'true' ||
          s['websiteActive']?.toString().toLowerCase() == 'true';
    });
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null;

  String? _phoneValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'مطلوب';
    final x = v.trim();
    final ok = RegExp(r'^\+?[0-9]{6,20}$').hasMatch(x);
    return ok ? null : 'رقم غير صحيح';
  }

  Map<String, dynamic> _collectForSave() {
    return {
      'store_name': _storeName.text.trim(),
      'currency': _currency.text.trim(),
      'page_description': _pageDescription.text.trim(),
      'phone': _phone.text.trim(),
      'whatsapp': _whatsapp.text.trim(),
      'email': _email.text.trim(),
      'address': _address.text.trim(),
      'working_hours': _workingHours.text.trim(),
      'shipping': _shipping,
      'shipping_price': double.tryParse(_shippingPrice.text.trim()) ?? 0,
      'has_logo': _hasLogo,
      'tiktok': _tiktok.text.trim(),
      'instagram': _instagram.text.trim(),
      'facebook': _facebook.text.trim(),
    };
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      if (widget.firstSetup) {
        final username = _usernameCtrl.text.trim();
        final password = _passwordCtrl.text;

        if (username.isEmpty || password.isEmpty) {
          _toast('اكتب اسم المستخدم وكلمة المرور');
          return;
        }
        if (password.length < 6) {
          _toast('كلمة المرور قصيرة (على الأقل 6 أحرف)');
          return;
        }

        final ok = await ApiService.registerFull(
          store: _collectForSave(),
          username: username,
          password: password,
        );

        if (!ok) {
          _toast('فشل إنشاء المتجر');
          return;
        }

        // ✅ Token + storeId lokal speichern
        await ApiService.persistAuthToPrefs();

        // Optional: StoreConfigService reload (nicht zwingend mehr nötig)
        // Wenn du es behalten willst:
        await StoreConfigService.load(allowNetworkIfEmpty: false);
        final s = StoreConfigService.store;
        if (s != null) _fill(s);

        if (!mounted) return;
        context.go('/home');
        return;
      }

      // -------- normal settings update --------
      final data = _collectForSave();
      data.remove('store_name');
      data.remove('page_description');

      final ok = await ApiService.updateStore(data);
      if (!ok) {
        _toast('فشل حفظ الإعدادات');
        return;
      }
      _toast('تم حفظ الإعدادات');
    } catch (e) {
      _toast('خطأ: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }


  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _storeName.dispose();
    _currency.dispose();
    _pageDescription.dispose();
    _phone.dispose();
    _whatsapp.dispose();
    _email.dispose();
    _address.dispose();
    _workingHours.dispose();
    _shippingPrice.dispose();
    _tiktok.dispose();
    _instagram.dispose();
    _facebook.dispose();
    super.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();

  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.firstSetup || _editing;
    final enabled = canEdit && !_saving;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return PopScope(
        canPop: !widget.firstSetup,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && widget.firstSetup) {
            context.go('/login');
          }
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
                padding: const EdgeInsets.all(16),
                children: [
                  // ✅ Theme-Schalter
                  _section('المظهر'),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.dark_mode_outlined),
                      title: const Text('الوضع'),
                      trailing: DropdownButton<AppThemeMode>(
                        value: MyApp.of(context)?.mode ?? AppThemeMode.system,
                        onChanged: (AppThemeMode? mode) {
                          if (mode != null) {
                            MyApp.of(context)?.setTheme(mode);
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: AppThemeMode.system,
                            child: Text('System'),
                          ),
                          DropdownMenuItem(
                            value: AppThemeMode.light,
                            child: Text('Light'),
                          ),
                          DropdownMenuItem(
                            value: AppThemeMode.dark,
                            child: Text('Dark'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (!widget.firstSetup) ...[
                    _readonlyRow('معرف المتجر', _storeId),
                    const SizedBox(height: 6),
                    _readonlyRow('تم الانشاء', _createdAt),
                    const SizedBox(height: 16),
                  ],
                  if (widget.firstSetup) ...[
                    const SizedBox(height: 16),

                    Text(
                      'بيانات الدخول',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      textDirection: TextDirection.rtl,
                    ),

                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _usernameCtrl,
                      enabled: enabled,
                      textDirection: TextDirection.rtl,
                      decoration: const InputDecoration(
                        labelText: 'اسم المستخدم',
                        hintText: 'يستخدم لتسجيل الدخول لاحقا',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                    ),

                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _passwordCtrl,
                      enabled: enabled,
                      obscureText: _obscurePass,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: enabled
                              ? () => setState(() => _obscurePass = !_obscurePass)
                              : null,
                          icon: Icon(
                            _obscurePass ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'مطلوب';
                        if (v.trim().length < 6) return 'على الأقل 6 أحرف';
                        return null;
                      },
                    ),
                  ],

                  _section('بيانات المتجر'),
                  TextFormField(
                    controller: _storeName,
                    enabled: enabled,
                    decoration: const InputDecoration(
                      labelText: 'اسم المتجر',
                      border: OutlineInputBorder(),
                    ),
                    validator: _req,
                  ),

                  if (widget.firstSetup) ...[
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _pageDescription,
                      maxLines: 3,
                      enabled: enabled,
                      decoration: const InputDecoration(
                        labelText: 'وصف الموقع المطلوب',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _currency,
                    enabled: enabled,
                    decoration: const InputDecoration(
                      labelText: 'العملة',
                      border: OutlineInputBorder(),
                    ),
                    validator: _req,
                  ),

                  const SizedBox(height: 16),

                  _section('التواصل'),
                  TextFormField(
                    controller: _phone,
                    enabled: enabled,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف',
                      border: OutlineInputBorder(),
                    ),
                    validator: _phoneValidator,
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _whatsapp,
                    enabled: enabled,
                    decoration: const InputDecoration(
                      labelText: 'واتساب',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _email,
                    enabled: enabled,
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _address,
                    enabled: enabled,
                    decoration: const InputDecoration(
                      labelText: 'العنوان',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _section('العمل والتوصيل'),
                  TextFormField(
                    controller: _workingHours,
                    maxLines: 2,
                    enabled: enabled,
                    decoration: const InputDecoration(
                      labelText: 'أوقات العمل',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SwitchListTile(
                    value: _shipping,
                    onChanged: enabled ? (v) => setState(() => _shipping = v) : null,
                    title: const Text('التوصيل متاح'),
                  ),

                  if (_shipping) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _shippingPrice,
                      enabled: enabled,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'سعر التوصيل',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),

                  SwitchListTile(
                    value: _hasLogo,
                    onChanged: enabled ? (v) => setState(() => _hasLogo = v) : null,
                    title: const Text('يوجد شعار'),
                  ),

                  const SizedBox(height: 16),

                  _section('السوشيال'),
                  TextFormField(
                    controller: _tiktok,
                    enabled: enabled,
                    decoration: const InputDecoration(
                      labelText: 'رابط التيك توك',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _instagram,
                    enabled: enabled,
                    decoration: const InputDecoration(
                      labelText: 'رابط إلانستغرام',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _facebook,
                    enabled: enabled,
                    decoration: const InputDecoration(
                      labelText: 'رابط الفيسبوك',
                      hintText: 'https://example.com',
                      border: OutlineInputBorder(),
                    ),
                  ),

// ✅ HIER Login-Daten (nur beim ersten Setup)


                  const SizedBox(height: 18),


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
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : Icon(
                        widget.firstSetup
                            ? Icons.check
                            : (_editing ? Icons.save : Icons.edit),
                      ),
                      label: Text(
                        _saving
                            ? '...'
                            : (widget.firstSetup ? 'إنشاء' : (_editing ? 'حفظ' : 'تعديل')),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (kDebugMode)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        onPressed: () async {
                          await StoreConfigService.clear();
                          await ApiService.clearStoreId();

                          if (!context.mounted) return;
                          context.go('/setup');
                        },
                        child: const Text('إعادة تعيين المتجر'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
    );
  }

  Widget _section(String t) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(t, style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: cs.onSurface,
      )),
    );
  }

  Widget _readonlyRow(String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Text(
              '$label: ',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              )
          ),
          Expanded(
              child: Text(
                value.isEmpty ? '-' : value,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: cs.onSurface),
              )
          ),
        ],
      ),
    );
  }
}