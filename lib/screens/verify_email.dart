import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
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
  bool _checking = false;
  Timer? _autoCheckTimer;
  int _resendCountdown = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    // Automatisch alle 3 Sekunden prüfen
    _startAutoCheck();
  }

  @override
  void dispose() {
    _autoCheckTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startAutoCheck() {
    _autoCheckTimer?.cancel();
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkVerificationStatus();
    });
  }

  Future<void> _checkVerificationStatus() async {
    if (_checking) return;
    final s = AppLocalizations.of(context)!;

    setState(() => _checking = true);

    try {
      // Firebase User neu laden um aktuellen Status zu bekommen
      await ApiService.reloadUser();

      if (ApiService.isEmailVerified) {
        _autoCheckTimer?.cancel();

        // SECURE: Store-Verifizierung über Cloud Function
        // Server prüft nochmal Firebase Auth und setzt erst dann is_verified
        await ApiService.confirmEmailVerificationSecure();

        // Store-Daten laden damit der Wizard den Namen hat
        await ApiService.fetchStoreConfig();

        if (mounted) {
          _toast(s.emailVerifiedSuccess);
          // Kurz warten damit der User die Nachricht sieht
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            context.go('/setup');
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking verification: $e');
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _resendVerification() async {
    if (_resendCountdown > 0) return;
    final s = AppLocalizations.of(context)!;

    setState(() => _checking = true);

    try {
      await ApiService.sendEmailVerification();
      _toast(s.verificationLinkSent);
      _startCountdown();
    } catch (e) {
      // ApiService Error Mapping kann hier erhalten bleiben oder durch generische Nachricht ersetzt werden
      _toast(s.verificationLinkSendFail(ApiService.mapFirebaseErrorToArabic(e)));
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  void _startCountdown() {
    setState(() => _resendCountdown = 60);
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown <= 1) {
        timer.cancel();
        if (mounted) setState(() => _resendCountdown = 0);
      } else {
        if (mounted) setState(() => _resendCountdown--);
      }
    });
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.center),
        backgroundColor: Theme.of(context).colorScheme.primary, // Teal statt Gold
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _logout() async {
    _autoCheckTimer?.cancel();
    await ApiService.clearAuth();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;
    final email = widget.username ?? ApiService.currentUserEmail ?? s.defaultEmailPlaceholder;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.verifyEmailTitle),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
            tooltip: s.logoutTooltip,
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_unread_rounded,
                  size: 80,
                  color: colors.primary,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                s.checkYourEmailTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                s.sentLinkTo,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.hintColor,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Email
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  // Nutzt Surface Container für besseren Kontrast in beiden Modes
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
                ),
                child: Text(
                  email,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ),

              const SizedBox(height: 24),

              // Instructions
              Text(
                s.verifyEmailInstructions,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.hintColor,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Check Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _checking ? null : _checkVerificationStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: _checking
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.onPrimary,
                    ),
                  )
                      : const Icon(Icons.refresh_rounded),
                  label: Text(
                    _checking ? s.checkingStatus : s.checkNowButton,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Resend Button
              TextButton(
                onPressed: (_resendCountdown > 0 || _checking) ? null : _resendVerification,
                child: Text(
                  _resendCountdown > 0
                      ? s.resendCountdown(_resendCountdown)
                      : s.resendButton,
                  style: TextStyle(
                    color: _resendCountdown > 0 ? theme.disabledColor : colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const Spacer(),

              // Help Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05), // Info bleibt blau, aber dezent
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: Colors.blue[400],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        s.spamFolderHint,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.hintColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}