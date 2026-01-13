import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

class EmailVerifyScreen extends StatefulWidget {
  final String storeId;
  final String? username;

  const EmailVerifyScreen({
    super.key,
    required this.storeId,
    this.username,
  });

  @override
  State<EmailVerifyScreen> createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState extends State<EmailVerifyScreen> {
  bool _busy = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Automatisch alle 3 Sekunden prüfen, ob der User den Link geklickt hat
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkVerificationStatus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerificationStatus() async {
    await ApiService.confirmEmailVerifyRaw(storeId: widget.storeId, otp: '');
    if (ApiService.isEmailVerified) {
      _timer?.cancel();
      if (mounted) {
        context.go('/home');
      }
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, textDirection: TextDirection.rtl)),
    );
  }

  Future<void> _resendEmail() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final res = await ApiService.startEmailVerify(widget.storeId);
      if (res.ok) {
        _snack('تم إعادة إرسال رابط التحقق إلى بريدك الإلكتروني.');
      } else {
        _snack('فشل الإرسال: ${res.error}');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _logout() async {
    await ApiService.clearAuth();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تأكيد البريد الإلكتروني', textDirection: TextDirection.rtl),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_unread_outlined, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            const Text(
              'يرجى تأكيد بريدك الإلكتروني',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'لقد أرسلنا رابط تحقق إلى بريدك الإلكتروني. يرجى الضغط على الرابط في الرسالة لتفعيل حسابك.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            if (_busy)
              const CircularProgressIndicator()
            else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _checkVerificationStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('لقد قمت بالتأكيد بالفعل'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _resendEmail,
                child: const Text('إعادة إرسال البريد الإلكترoni'),
              ),
            ],
            const Spacer(),
            TextButton(
              onPressed: _logout,
              child: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
