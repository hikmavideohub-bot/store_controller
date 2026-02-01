import 'package:flutter/material.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import '../settings_viewmodel.dart';

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

            // 1. HIER IST JETZT DIE E-MAIL (Zuerst)
            _SocialField(
              controller: vm.emailSupportCtrl,
              label: s.supportEmailLabel,
              icon: Icons.email_outlined,
              hint: s.supportEmailHint,
            ),

            // 2. TRENNLINIE (Trennt wichtiges von Social Media)
            const SizedBox(height: 12),
            const Divider(height: 24),

            // 3. SOCIAL MEDIA (Danach)
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
        ),
      ),
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
