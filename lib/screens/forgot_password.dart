import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _goToLogin() {
    if (!mounted) return;
    context.go('/login');
  }

  void _toast(String msg) {
    if (!mounted) return;
    // Nutzt jetzt die Primärfarbe statt Gold
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Future<void> _sendResetEmail() async {
    final s = AppLocalizations.of(context)!;
    final email = _emailCtrl.text.trim();

    if (email.isEmpty) {
      _toast(s.enterEmailValidation);
      return;
    }

    if (!RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w{2,}$').hasMatch(email)) {
      _toast(s.invalidEmailFormat);
      return;
    }

    setState(() => _busy = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      _toast(s.resetLinkSentMsg);
      if (mounted) {
        Future.delayed(const Duration(seconds: 2), () => _goToLogin());
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _toast(s.emailNotRegistered);
      } else {
        _toast(s.generalError(e.message ?? ''));
      }
    } catch (e) {
      _toast(s.generalSendError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(s.forgotPasswordTitle), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_reset_rounded,
                  size: 80,
                  color: colors.primary,
                ), // Teal statt Gold
                const SizedBox(height: 24),
                Text(
                  s.restorePasswordHeadline,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  s.restorePasswordDesc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 32),

                TextField(
                  controller: _emailCtrl,
                  enabled: !_busy,
                  textDirection: TextDirection.ltr,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: s.emailLabel,
                    hintText: s.emailHint,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _busy ? null : _sendResetEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary, // Teal
                      foregroundColor: colors.onPrimary, // Weiß
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _busy
                        ? CircularProgressIndicator(color: colors.onPrimary)
                        : Text(
                            s.sendLinkButton,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: _busy ? null : _goToLogin,
                  child: Text(s.backToLogin),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
