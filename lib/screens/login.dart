import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import '../services/api_service.dart';
import '../storage/store_prefs.dart';
import '../main.dart' show SessionMessageHelper, MyApp;
import 'package:firebase_auth/firebase_auth.dart';


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
  bool _googleBusy = false;
  bool _obscure = true;

  /// Ermittelt die Textrichtung basierend auf dem ersten Buchstaben
  TextDirection? _getTextDirection(String text) {
    final trimmed = text.trimLeft();
    if (trimmed.isEmpty) return null; // Default verwenden
    final firstChar = trimmed.codeUnitAt(0);
    // Arabisch: U+0600–U+06FF, U+0750–U+077F, U+08A0–U+08FF
    final isArabic =
        (firstChar >= 0x0600 && firstChar <= 0x06FF) ||
        (firstChar >= 0x0750 && firstChar <= 0x077F) ||
        (firstChar >= 0x08A0 && firstChar <= 0x08FF);
    return isArabic ? TextDirection.rtl : TextDirection.ltr;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPendingSessionMessage();
    });
  }





  void _showPendingSessionMessage() {
    final msg = SessionMessageHelper.consumeMessage();
    if (msg != null && mounted) {
      _toast(msg, isError: true);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _toast(String msg, {bool isError = false}) {
    final colors = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        // Fehler = Rot, Info = Teal (Primary)
        backgroundColor: isError ? colors.error : colors.primary,
        duration: Duration(seconds: isError ? 5 : 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w{2,}$').hasMatch(email);
  }

  Future<void> _doLogin() async {
    final s = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    setState(() => _busy = true);
    try {
      final res = await ApiService.login(email, password);
      if (!mounted) return;

      if (res == null) {
        setState(() => _busy = false);
        _toast(s.loginEmailOrPassError, isError: true);
        return;
      }

      final storeId = res['storeId'];

      if (storeId != null && storeId.isNotEmpty) {
        final exists = await ApiService.storeDocumentExists(storeId);
        if (!exists) {
          await ApiService.clearAuth();
          if (!mounted) return;
          setState(() => _busy = false);
          _showNoStoreDialog();
          return;
        }

        final verifyStatus = await ApiService.checkVerificationStatus(storeId);
        if (verifyStatus == 'expired') {
          // SECURE: Wir löschen nicht mehr client-side!
          // Der Server-Cronjob (cleanupExpiredAccounts) räumt abgelaufene Accounts auf.
          await ApiService.clearAuth();
          if (!mounted) return;
          setState(() => _busy = false);
          _toast(s.sessionExpired, isError: true);
          return;
        }

        await StorePrefs.setStoreId(storeId);
      }

      if (!mounted) return;
      setState(() => _busy = false);
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      // ApiService gibt hier vermutlich harten arabischen Text zurück.
      // Da wir ApiService nicht bearbeiten, belassen wir es dabei.
      _toast(ApiService.mapFirebaseErrorToArabic(e), isError: true);
    }
  }

  void _showNoStoreDialog({
    bool isNewUser = false,
    String? uid,
    String? email,
    String? displayName,
  }) {
    final colors = Theme.of(context).colorScheme;
    final s = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(
          s.noStoreTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(s.noStoreMessage),
            if (email != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.account_circle, color: colors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        email,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actionsAlignment: MainAxisAlignment.start,
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              debugPrint('🟢 Login: User cancelled registration');
              await ApiService.cancelPendingGoogleRegistration();
            },
            child: Text(s.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              debugPrint(
                '🟢 Login: User wants to register, going to /register',
              );
              if (mounted) context.go('/register');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
            ),
            child: Text(s.createStore),
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    final s = AppLocalizations.of(context)!;
    setState(() => _googleBusy = true);
    debugPrint('🟢 Login: Starting Google Sign-In...');

    try {
      final result = await ApiService.signInWithGoogle(s);
      debugPrint('🟢 Login: Got result - ok=${result.ok}, error=${result.error}');

      if (!mounted) return;

      // ✅ Web-Redirect gestartet -> Seite lädt neu, hier nur zurück
      if (result.ok && result.data?['redirecting'] == true) {
        return;
      }

      if (!result.ok) {
        setState(() => _googleBusy = false);

        if (result.error == 'cancelled') return;

        if (result.error == 'no_store') {
          final isNewUser = result.data?['isNewUser'] == true;
          final uid = result.data?['uid'] as String?;
          final email = result.data?['email'] as String?;
          final displayName = result.data?['displayName'] as String?;
          _showNoStoreDialog(
            isNewUser: isNewUser,
            uid: uid,
            email: email,
            displayName: displayName,
          );
          return;
        }

        if (result.error == 'expired') {
          _toast(result.details ?? s.sessionExpired, isError: true);
          return;
        }

        if (result.error == 'permission-denied') {
          _toast(result.details ?? s.loginNoPermission, isError: true);
          return;
        }

        _toast(result.details ?? s.googleLoginFailed, isError: true);
        return;
      }

      // ✅ NEU: wenn Login ok ist, aber noch kein Store existiert -> /register bzw. Wizard
      final hasStore = result.data?['hasStore'] == true;
      if (!hasStore) {
        setState(() => _googleBusy = false);

        final isNewUser = result.data?['isNewUser'] == true;
        final uid = (result.data?['uid'] ?? result.data?['storeId'] ?? '').toString();
        final email = (result.data?['email'] ?? '').toString();
        final displayName = (result.data?['displayName'] ?? '').toString();

        _showNoStoreDialog(
          isNewUser: isNewUser,
          uid: uid.isEmpty ? null : uid,
          email: email.isEmpty ? null : email,
          displayName: displayName.isEmpty ? null : displayName,
        );
        return;
      }

      final storeId = (result.data?['storeId'] ?? '').toString();
      if (storeId.isEmpty) {
        setState(() => _googleBusy = false);
        _toast(s.unexpectedError, isError: true);
        return;
      }

      await StorePrefs.setStoreId(storeId);

      if (!mounted) return;
      setState(() => _googleBusy = false);
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      setState(() => _googleBusy = false);
      _toast(ApiService.mapFirebaseErrorToArabic(e, s), isError: true);
    }
  }


  Future<void> _handleLoginResult(
      ApiResult<Map<String, dynamic>> result,
      AppLocalizations s,
      ) async {
    if (!mounted) return;

    if (!result.ok) {
      setState(() => _googleBusy = false);

      if (result.error == 'cancelled') return;

      if (result.error == 'no_store') {
        final isNewUser = result.data?['isNewUser'] == true;
        final uid = result.data?['uid'] as String?;
        final email = result.data?['email'] as String?;
        final displayName = result.data?['displayName'] as String?;
        _showNoStoreDialog(
          isNewUser: isNewUser,
          uid: uid,
          email: email,
          displayName: displayName,
        );
        return;
      }

      if (result.error == 'expired') {
        _toast(result.details ?? s.sessionExpired, isError: true);
        return;
      }

      if (result.error == 'permission-denied') {
        _toast(result.details ?? s.loginNoPermission, isError: true);
        return;
      }

      _toast(result.details ?? s.googleLoginFailed, isError: true);
      return;
    }

    // ✅ Sonderfall: Web-Redirect gestartet (Seite lädt neu)
    if (result.data?['redirecting'] == true) {
      return;
    }

    final storeId = result.data?['storeId'] ?? '';

    if (storeId.isEmpty) {
      setState(() => _googleBusy = false);
      _toast(s.unexpectedError, isError: true);
      return;
    }

    await StorePrefs.setStoreId(storeId);

    if (!mounted) return;
    setState(() => _googleBusy = false);

    context.go('/home');
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isAnyBusy = _busy || _googleBusy;
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Language Picker
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: _LanguagePickerButton(),
                    ),
                    const SizedBox(height: 8),

                    // Header
                    Icon(
                      Icons.store_rounded,
                      size: 64,
                      color: colors.primary, // Teal
                    ),
                    const SizedBox(height: 16),
                    Text(
                      s.loginTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.loginSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Google Sign-In Button
                    OutlinedButton.icon(
                      onPressed: isAnyBusy ? null : _signInWithGoogle,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: colors.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      icon: _googleBusy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Image.asset(
                              'assets/icon/google_logo.png',
                              width: 20,
                              height: 20,
                            ),

                      label: Text(
                        _googleBusy ? s.googleSigningIn : s.googleSignIn,
                        style: TextStyle(color: colors.onSurface),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: theme.dividerColor)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            s.orSeparator,
                            style: TextStyle(
                              color: colors.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: theme.dividerColor)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Email Field - dynamische Textrichtung
                    TextFormField(
                      controller: _emailCtrl,
                      enabled: !isAnyBusy,
                      textDirection:
                          _getTextDirection(_emailCtrl.text) ??
                          TextDirection.ltr,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      onChanged: (_) =>
                          setState(() {}), // Rebuild für Richtungswechsel
                      decoration: InputDecoration(
                        labelText: s.emailLabel,
                        hintText: s.emailHint,
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (v) {
                        final email = v?.trim() ?? '';
                        if (email.isEmpty) return s.emailRequired;
                        if (!_isValidEmail(email)) return s.emailInvalid;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field - dynamische Textrichtung
                    TextFormField(
                      controller: _passCtrl,
                      enabled: !isAnyBusy,
                      obscureText: _obscure,
                      textDirection: _getTextDirection(_passCtrl.text),
                      onChanged: (_) =>
                          setState(() {}), // Rebuild für Richtungswechsel
                      decoration: InputDecoration(
                        labelText: s.passwordLabel,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          onPressed: isAnyBusy
                              ? null
                              : () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return s.passwordRequired;
                        return null;
                      },
                    ),

                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: isAnyBusy
                            ? null
                            : () => context.go('/forgot-password'),
                        child: Text(
                          s.forgotPassword,
                          style: TextStyle(color: colors.primary), // Teal
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Login Button
                    ElevatedButton(
                      onPressed: isAnyBusy ? null : _doLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary, // Teal
                        foregroundColor: colors.onPrimary, // White
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              s.signInButton,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                    ),

                    const SizedBox(height: 24),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          s.noAccount,
                          style: TextStyle(
                            color: colors.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        TextButton(
                          onPressed: isAnyBusy
                              ? null
                              : () => context.go('/register'),
                          child: Text(
                            s.createNewStore,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ],
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

/// Kompakter Language-Picker für den Login-Screen
class _LanguagePickerButton extends StatelessWidget {
  const _LanguagePickerButton();

  static const _languages = [
    (locale: Locale('ar'), flag: '🇸🇦', name: 'العربية'),
    (locale: Locale('en'), flag: '🇺🇸', name: 'English'),
    (locale: Locale('de'), flag: '🇩🇪', name: 'Deutsch'),
    (locale: Locale('tr'), flag: '🇹🇷', name: 'Türkçe'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final currentLocale = MyApp.localeOf(context) ?? const Locale('ar');
    final currentLang = _languages.firstWhere(
      (l) => l.locale.languageCode == currentLocale.languageCode,
      orElse: () => _languages.first,
    );

    return PopupMenuButton<Locale>(
      tooltip: '',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: const Offset(0, 40),
      onSelected: (locale) => MyApp.setLocaleOf(context, locale),
      itemBuilder: (_) => _languages
          .map(
            (lang) => PopupMenuItem<Locale>(
              value: lang.locale,
              child: Row(
                children: [
                  Text(lang.flag, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 12),
                  Text(lang.name),
                  if (lang.locale.languageCode ==
                      currentLocale.languageCode) ...[
                    const Spacer(),
                    Icon(Icons.check, size: 18, color: colors.primary),
                  ],
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(currentLang.flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              currentLang.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 18, color: colors.onSurface),
          ],
        ),
      ),
    );
  }
}
