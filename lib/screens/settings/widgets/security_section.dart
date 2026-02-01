import 'package:flutter/material.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import '../settings_viewmodel.dart';

class SecuritySection extends StatelessWidget {
  final SettingsViewModel vm;

  const SecuritySection({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;

    return Card(
      color: colors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colors.outline.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          s.securityTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: const Icon(Icons.shield_outlined),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          // Anzeige der Login-Email (Read-only Info)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.email_outlined, size: 20, color: theme.hintColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.loginEmailLabel,
                        style: TextStyle(fontSize: 12, color: theme.hintColor),
                      ),
                      Text(
                        vm.emailLogin.isNotEmpty ? vm.emailLogin : '-',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (vm.authProvider == 'google') ...[
            Text(
              s.googleAuthInfo,
              style: TextStyle(fontSize: 13, color: theme.hintColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                // Button deaktiviert, wenn beschäftigt oder gerade gesendet wird
                onPressed: (vm.busy || vm.sendingPasswordReset)
                    ? null
                    : () async {
                        final success = await vm.sendPasswordReset(s);
                        // Da der Screen nicht neu lädt, bleibt context.mounted true
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(s.passwordResetSent)),
                          );
                        }
                      },
                // Zeigt Lade-Spinner IM Button anstatt global
                icon: vm.sendingPasswordReset
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.email_outlined),
                label: Text(
                  vm.sendingPasswordReset
                      ? s.sendingStatus
                      : s.sendResetLinkButton,
                ),
              ),
            ),
          ] else ...[
            _PasswordField(
              controller: vm.currentPasswordCtrl,
              label: s.currentPasswordLabel,
              visible: vm.showCurrentPassword,
              onToggle: () {
                vm.showCurrentPassword = !vm.showCurrentPassword;
                vm.notifyListeners();
              },
            ),
            const SizedBox(height: 12),
            _PasswordField(
              controller: vm.newPasswordCtrl,
              label: s.newPasswordLabel,
              visible: vm.showNewPassword,
              onToggle: () {
                vm.showNewPassword = !vm.showNewPassword;
                vm.notifyListeners();
              },
            ),
            const SizedBox(height: 12),
            _PasswordField(
              controller: vm.confirmPasswordCtrl,
              label: s.confirmPasswordLabel,
              visible: false,
              showToggle: false,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: vm.busy
                    ? null
                    : () async {
                        final ok = await vm.changePassword(s);
                        if (ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(s.passwordChangedSuccess)),
                          );
                        }
                      },
                icon: const Icon(Icons.key_rounded),
                label: Text(s.changePasswordButton),
              ),
            ),
            TextButton(
              onPressed: vm.busy ? null : () => vm.sendPasswordReset(s),
              child: Text(s.forgotPasswordButton),
            ),
          ],
        ],
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool visible;
  final VoidCallback? onToggle;
  final bool showToggle;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.visible,
    this.onToggle,
    this.showToggle = true,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
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
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: !widget.visible,
      textDirection: _getTextDirection(widget.controller.text),
      onChanged: (_) => setState(() {}), // Rebuild für Richtungswechsel
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_outline),
        border: const OutlineInputBorder(),
        suffixIcon: widget.showToggle
            ? IconButton(
                icon: Icon(
                  widget.visible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: widget.onToggle,
              )
            : null,
      ),
    );
  }
}
