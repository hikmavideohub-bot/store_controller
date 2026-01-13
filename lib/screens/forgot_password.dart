import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _userCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    super.dispose();
  }

  void _goToLogin() {
    if (!mounted) return;
    context.go('/login');
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, textDirection: TextDirection.rtl)),
    );
  }

  Future<void> _sendCode() async {
    final username = _userCtrl.text.trim();
    if (username.isEmpty) {
      _snack('أدخل اسم المستخدم');
      return;
    }

    setState(() => _busy = true);
    try {
      final ok = await ApiService.startPasswordReset(username);

      if (ok) {
        _snack('إذا كان الحساب موجودًا، تم إرسال رمز.');
        if (mounted) {
          context.go('/reset-password', extra: {'username': username});
        }
      } else {
        _snack('تعذر الإرسال الآن. حاول لاحقًا.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نسيت كلمة المرور', textDirection: TextDirection.rtl),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _userCtrl,
              enabled: !_busy,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                labelText: 'اسم المستخدم',
                border: OutlineInputBorder(),
              ),
            ),
            TextButton(
              onPressed: _busy ? null : _goToLogin,
              child: const Text(
                'العودة إلى تسجيل الدخول',
                textDirection: TextDirection.rtl,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _busy ? null : _sendCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  _busy ? '... جاري المعالجة' : 'إرسال الرمز',
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
