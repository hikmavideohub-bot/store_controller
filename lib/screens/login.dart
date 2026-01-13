import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _busy = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w{2,}$').hasMatch(email);
  }

  Future<void> _doLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    setState(() => _busy = true);
    try {
      final res = await ApiService.login(email, password);
      if (!mounted) return;

      if (res == null) {
        setState(() => _busy = false);
        _toast('البريد الإلكتروني أو كلمة المرور غير صحيحة');
        return;
      }

      // Firebase Auth speichert Token automatisch
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
              child: Form(
                key: _formKey,
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

                    TextFormField(
                      controller: _emailCtrl,
                      enabled: !_busy,
                      textDirection: TextDirection.ltr,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        hintText: 'example@email.com',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final email = v?.trim() ?? '';
                        if (email.isEmpty) return 'البريد الإلكتروني مطلوب';
                        if (!_isValidEmail(email)) return 'صيغة البريد الإلكتروني غير صحيحة';
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _passCtrl,
                      enabled: !_busy,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: _busy ? null : () => setState(() => _obscure = !_obscure),
                          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'كلمة المرور مطلوبة';
                        return null;
                      },
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
                    TextButton(
                      onPressed: _busy ? null : () => context.go('/forgot-password'),
                      child: const Text(
                        'نسيت كلمة المرور؟',
                        textDirection: TextDirection.rtl,
                      ),
                    ),

                    const SizedBox(height: 10),

                    OutlinedButton(
                      onPressed: _busy ? null : () => context.go('/register'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'تسجيل متجر جديد',
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
      ),
    );
  }
}
