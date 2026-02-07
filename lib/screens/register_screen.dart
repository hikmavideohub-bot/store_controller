import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import '../services/api_service.dart';
import '../storage/store_prefs.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _busy = false;
  bool _googleBusy = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  final bool _requireEmailVerify = false;

  /// Ermittelt die Textrichtung basierend auf dem ersten Buchstaben
  TextDirection? _getTextDirection(String text) {
    final trimmed = text.trimLeft();
    if (trimmed.isEmpty) return null;
    final firstChar = trimmed.codeUnitAt(0);
    final isArabic =
        (firstChar >= 0x0600 && firstChar <= 0x06FF) ||
        (firstChar >= 0x0750 && firstChar <= 0x077F) ||
        (firstChar >= 0x08A0 && firstChar <= 0x08FF);
    return isArabic ? TextDirection.rtl : TextDirection.ltr;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    if (!mounted) return;
    // Nutzt jetzt Primary Color (Teal) statt Standard-Grau
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w{2,}$').hasMatch(email);
  }

  String _errorToArabic(String? err, String? details) {
    final s = AppLocalizations.of(context)!;
    final combined = '${err ?? ''} ${details ?? ''}'.trim();
    if (combined.isEmpty) return s.registerFailedMsg;
    // ApiService Errors bleiben vorerst hardcoded oder werden separat behandelt
    return ApiService.mapFirebaseErrorToArabic(combined);
  }

  Future<void> _registerWithEmail() async {
    final s = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    setState(() => _busy = true);

    try {
      final result = await ApiService.registerFull(
        store: {
          'require_email_verify': _requireEmailVerify,
        },
        username: email,
        password: password,
      );

      if (!mounted) return;

      if (!result.ok) {
        _toast(_errorToArabic(result.error, result.details));
        setState(() => _busy = false);
        return;
      }

      final storeId = result.data?['storeId'] ?? '';
      if (storeId.isNotEmpty) {
        await StorePrefs.setStoreId(storeId);
        await ApiService.checkAndSetUserRegion();
      }

      if (!mounted) return;
      context.go('/verify-email', extra: {'storeId': storeId});
    } catch (e) {
      if (!mounted) return;
      _toast(s.errorOccurred(e.toString()));
      setState(() => _busy = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _googleBusy = true);
    debugPrint('🟢 Register: Starting Google sign-in...');

    try {
      // Direkt mit Google registrieren (ohne Store-Name - wird im Wizard abgefragt)
      final result = await ApiService.registerWithGoogle(
        storeName: '', // Leer - wird im Wizard ausgefüllt
        requireEmailVerify: _requireEmailVerify,
      );

      if (!mounted) return;

      if (!result.ok) {
        setState(() => _googleBusy = false);
        if (result.error != 'cancelled') {
          _toast(_errorToArabic(result.error, result.details));
        }
        return;
      }

      final storeId = result.data?['storeId'] ?? '';
      if (storeId.isNotEmpty) {
        await ApiService.checkAndSetUserRegion();
      }

      final isExisting = result.data?['existing'] == 'true';

      if (!mounted) return;
      setState(() => _googleBusy = false);

      if (isExisting) {
        context.go('/home');
      } else {
        // Direkt zum Setup-Wizard (Store-Name wird dort abgefragt)
        context.go('/setup');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _googleBusy = false);
      _toast(ApiService.mapFirebaseErrorToArabic(e));
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return _buildFullRegistrationUI(theme, isDark);
  }

  Widget _buildFullRegistrationUI(ThemeData theme, bool isDark) {
    final colors = theme.colorScheme;
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
                    Icon(
                      Icons.store_rounded,
                      size: 64,
                      color: colors.primary, // Teal
                    ),
                    const SizedBox(height: 16),
                    Text(
                      s.registerNewStoreTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.registerSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Google Sign-In Button
                    OutlinedButton.icon(
                      onPressed: (_busy || _googleBusy)
                          ? null
                          : _signInWithGoogle,
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
                        _googleBusy
                            ? s.googleRegistering
                            : s.googleRegisterButton,
                        style: TextStyle(color: colors.onSurface),
                      ),
                    ),

                    const SizedBox(height: 24),

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

                    // Email - dynamische Textrichtung
                    TextFormField(
                      controller: _emailCtrl,
                      enabled: !_busy && !_googleBusy,
                      keyboardType: TextInputType.emailAddress,
                      textDirection:
                          _getTextDirection(_emailCtrl.text) ??
                          TextDirection.ltr,
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

                    // Password - dynamische Textrichtung
                    TextFormField(
                      controller: _passwordCtrl,
                      enabled: !_busy && !_googleBusy,
                      obscureText: _obscurePass,
                      textDirection: _getTextDirection(_passwordCtrl.text),
                      onChanged: (_) =>
                          setState(() {}), // Rebuild für Richtungswechsel
                      decoration: InputDecoration(
                        labelText: s.passwordLabel,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscurePass = !_obscurePass),
                          icon: Icon(
                            _obscurePass
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return s.passwordRequired;
                        if (v.length < 6) return s.passwordTooShort;
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Confirm Password - dynamische Textrichtung
                    TextFormField(
                      controller: _confirmPassCtrl,
                      enabled: !_busy && !_googleBusy,
                      obscureText: _obscureConfirm,
                      textDirection: _getTextDirection(_confirmPassCtrl.text),
                      onChanged: (_) =>
                          setState(() {}), // Rebuild für Richtungswechsel
                      decoration: InputDecoration(
                        labelText: s.confirmPasswordLabel,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v != _passwordCtrl.text) return s.passwordsNotMatch;
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    const SizedBox(height: 16),

                    // Register Button
                    ElevatedButton(
                      onPressed: (_busy || _googleBusy)
                          ? null
                          : _registerWithEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary, // Teal
                        foregroundColor: colors.onPrimary,
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
                              s.createAccountButton,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                    ),

                    const SizedBox(height: 16),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          s.alreadyHaveAccount,
                          style: TextStyle(
                            color: colors.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        TextButton(
                          onPressed: (_busy || _googleBusy)
                              ? null
                              : () => context.go('/login'),
                          child: Text(
                            s.loginLink,
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
