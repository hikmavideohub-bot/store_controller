import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _busy = false;
  bool _obscure = true;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _persistAuth(String token, String storeId) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('auth_token', token);
    await sp.setString('storeId', storeId); // optional (nur für Anzeige/Legacy)
  }

  Future<void> _doLogin() async {
    final username = _userCtrl.text.trim();
    final password = _passCtrl.text;

    if (username.isEmpty || password.isEmpty) {
      _toast('اكتب اسم المستخدم وكلمة المرور');
      return;
    }

    setState(() => _busy = true);
    try {
      final res = await ApiService.login(username, password);
      if (!mounted) return;

      if (res == null) {
        setState(() => _busy = false);
        _toast('بيانات الدخول غير صحيحة');
        return;
      }

      await _persistAuth(res['token']!, res['storeId']!);
      if (!mounted) return;

      setState(() => _busy = false);
      context.go('/home');
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      _toast('حدث خطأ أثناء تسجيل الدخول');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'تسجيل الدخول',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _userCtrl,
                    enabled: !_busy,
                    textDirection: TextDirection.rtl,
                    decoration: const InputDecoration(
                      labelText: 'اسم المستخدم',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _passCtrl,
                    enabled: !_busy,
                    obscureText: _obscure,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: _busy ? null : () => setState(() => _obscure = !_obscure),
                        icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  ElevatedButton(
                    onPressed: _busy ? null : _doLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      _busy ? '... جاري المعالجة' : 'دخول',
                      textDirection: TextDirection.rtl,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ✅ Registrierung/Store-Erstellung läuft über Setup
                  OutlinedButton(
                    onPressed: _busy ? null : () => context.go('/setup'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'إنشاء متجر جديد',
                      textDirection: TextDirection.rtl,
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    'إذا نسيت البيانات، تواصل مع صاحب المتجر.',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
