import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';

class ResetPasswordScreen extends StatelessWidget {
  final String username;
  const ResetPasswordScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    // الوصول إلى ألوان السمة الحالية
    final colors = Theme.of(context).colorScheme;
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.resetPasswordTitle),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // استخدام اللون الأساسي (Teal) بدلاً من الأخضر الصلب
            Icon(Icons.mark_email_read_outlined, size: 80, color: colors.primary),
            const SizedBox(height: 24),
            Text(
              s.resetLinkSentTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              s.checkEmailForResetMsg(username),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary, // Teal بدلاً من الأسود
                  foregroundColor: colors.onPrimary, // أبيض
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(s.backToLoginButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}