import 'package:flutter/material.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import '../settings_viewmodel.dart';

/// Standalone Card (wird ggf. noch extern genutzt, z.B. im Wizard)
class SocialLinksCard extends StatelessWidget {
  final SettingsViewModel vm;

  const SocialLinksCard({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.socialLinksTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            SocialLinksContent(vm: vm),
          ],
        ),
      ),
    );
  }
}

/// Nur der Inhalt (ohne Card-Wrapper) – für die Einbettung in ContactSection
class SocialLinksContent extends StatelessWidget {
  final SettingsViewModel vm;

  const SocialLinksContent({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // E-Mail (Zuerst)
        _SocialField(
          controller: vm.emailSupportCtrl,
          label: s.supportEmailLabel,
          icon: Icons.email_outlined,
          hint: s.supportEmailHint,
        ),

        const SizedBox(height: 12),
        const Divider(height: 24),

        // Social Media
        _SocialField(
          controller: vm.tiktokCtrl,
          label: s.socialTiktok,
          icon: Icons.music_note,
        ),
        const SizedBox(height: 12),
        _SocialField(
          controller: vm.instagramCtrl,
          label: s.socialInstagram,
          icon: Icons.camera_alt,
        ),
        const SizedBox(height: 12),
        _SocialField(
          controller: vm.facebookCtrl,
          label: s.socialFacebook,
          icon: Icons.facebook,
        ),
      ],
    );
  }
}

class _SocialField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;

  const _SocialField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textDirection: TextDirection.ltr, // E-Mails und Links immer LTR
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
