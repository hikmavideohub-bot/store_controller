import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import '../../../core/access_manager.dart';
import '../../../widgets/emoji_picker_sheet.dart';
import '../settings_viewmodel.dart';

class SettingsHeader extends StatelessWidget {
  final SettingsViewModel vm;
  final bool compact;

  const SettingsHeader({super.key, required this.vm, this.compact = false});

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildLogoPicker(context);
    }

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary.withValues(alpha: 0.15),
            colors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          _buildLogoPicker(context),
          const SizedBox(height: 16),

          Text(
            vm.storeNameCtrl.text.isNotEmpty
                ? vm.storeNameCtrl.text
                : s.storeFallbackName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          Text(
            vm.emailLogin.isNotEmpty ? vm.emailLogin : s.noEmail,
            style: TextStyle(fontSize: 14, color: theme.hintColor),
          ),
          const SizedBox(height: 12),

          _buildStatusBadge(context),
        ],
      ),
    );
  }

  Widget _buildLogoPicker(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GestureDetector(
      onTap: () => _pickEmoji(context),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.5),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(vm.logoEmoji, style: const TextStyle(fontSize: 40)),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: colors.surface, width: 2),
            ),
            child: const Icon(Icons.edit, size: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    // Wir nutzen hier AccessManager direkt, da es globaler State ist
    final status = AccessManager.status;
    final daysRemaining = AccessManager.daysRemaining;
    final colors = Theme.of(context).colorScheme;
    final s = AppLocalizations.of(context)!;

    String label;
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case 'trial':
        label = daysRemaining != null
            ? s.statusTrialDays(daysRemaining)
            : s.statusTrial;
        bgColor = colors.tertiary.withValues(alpha: 0.1);
        textColor = colors.tertiary; // Gold
        icon = Icons.hourglass_top_rounded;
        break;
      case 'active':
        label = s.statusActive;
        bgColor = colors.primary.withValues(alpha: 0.1);
        textColor = colors.primary; // Teal
        icon = Icons.verified_rounded;
        break;
      case 'expired':
        label = s.statusExpired;
        bgColor = colors.error.withValues(alpha: 0.1);
        textColor = colors.error;
        icon = Icons.warning_amber_rounded;
        break;
      case 'suspended':
        label = s.statusSuspended;
        bgColor = colors.surfaceContainerHighest;
        textColor = colors.onSurfaceVariant;
        icon = Icons.block_rounded;
        break;
      default:
        label = s.statusUnknown;
        bgColor = colors.surfaceContainerHighest;
        textColor = colors.onSurfaceVariant;
        icon = Icons.help_outline_rounded;
    }

    return GestureDetector(
      onTap: () => context.push('/subscription'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickEmoji(BuildContext context) async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: const EmojiPickerSheet(selected: null, scrollController: null),
        );
      },
    );

    if (chosen != null && chosen.trim().isNotEmpty) {
      vm.setLogo(chosen.trim());
    }
  }
}
