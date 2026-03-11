import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../icon_a2h/pwa_service.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';

class PwaInstallButton extends StatelessWidget {
  final Color? color;
  const PwaInstallButton({super.key, this.color});

  void _showAppleInstructions(BuildContext context, AppLocalizations s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.apple, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                s.installAppAppleTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.ios_share_rounded, color: Colors.blue),
              title: Text(s.installAppAppleStep1, style: const TextStyle(fontSize: 14)),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.add_box_outlined, color: Colors.grey),
              title: Text(s.installAppAppleStep2, style: const TextStyle(fontSize: 14)),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.check_circle_outline, color: Colors.green),
              title: Text(s.installAppAppleStep3, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.gotItButton),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Wenn es keine Web-App ist (z.B. native APK/iOS), zeigen wir nichts an
    if (!kIsWeb) return const SizedBox.shrink();

    final activeColor = color ?? Theme.of(context).colorScheme.primary;

    return ValueListenableBuilder<bool>(
      valueListenable: PwaService.instance.canInstall,
      builder: (context, canInstall, child) {
        // 1. FALL: Android / Chrome -> Der automatische Prompt ist verfügbar
        if (canInstall) {
          return IconButton(
            icon: const Icon(Icons.install_mobile_rounded),
            color: activeColor,
            onPressed: () => PwaService.instance.promptInstall(),
          );
        }

        // 2. FALL: Apple iOS (Safari) -> Zeigt stattdessen unser erklärendes Popup
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          return IconButton(
            icon: const Icon(Icons.install_mobile_rounded),
            color: activeColor,
            onPressed: () => _showAppleInstructions(context, AppLocalizations.of(context)!),
          );
        }

        // 3. FALL: App ist bereits installiert oder Browser unterstützt es nicht
        return const SizedBox.shrink();
      },
    );
  }
}