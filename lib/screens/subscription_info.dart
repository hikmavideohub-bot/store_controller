import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import '../core/access_manager.dart';
import '../services/store_config_service.dart';

class SubscriptionInfoScreen extends StatelessWidget {
  const SubscriptionInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(s.subscriptionInfoTitle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListenableBuilder(
        listenable: AccessManager(),
        builder: (context, _) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatusHeader(context),
                const SizedBox(height: 24),
                _buildPlanDetailsCard(context),
                const SizedBox(height: 24),
                _buildBenefitsCard(context),
                const SizedBox(height: 24),
                if (AccessManager.status != 'active') _buildStagesCard(context),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: AccessManager.status != 'active'
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _buildUpgradeButton(context),
              ),
            )
          : null,
    );
  }

  Widget _buildStatusHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;
    final status = AccessManager.status;
    final days = AccessManager.daysRemaining;

    Color statusColor;
    IconData statusIcon;
    String statusTitle;
    String statusSubtitle;

    switch (status) {
      case 'active':
        statusColor = Colors.green;
        statusIcon = Icons.verified_rounded;
        statusTitle = s.activePremiumTitle;
        statusSubtitle = s.activePremiumSubtitle;
        break;
      case 'trial':
        statusColor = colors.tertiary; // Gold für Trial/Premium
        statusIcon = Icons.auto_awesome_rounded;
        statusTitle = s.trialPeriodTitle;
        statusSubtitle = s.freeTrial; // Immer "فترة تجريبية مجانية" anzeigen
        break;
      case 'expired':
        statusColor = colors.error;
        statusIcon = Icons.error_outline_rounded;
        statusTitle = s.subscriptionExpiredTitle;
        statusSubtitle = s.subscriptionExpiredSubtitle;
        break;
      default:
        statusColor = theme.disabledColor;
        statusIcon = Icons.help_outline_rounded;
        statusTitle = s.accountStatus;
        statusSubtitle = s.contactSupport;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withValues(alpha: 0.15),
            statusColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
              Icon(statusIcon, color: statusColor, size: 60),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            statusTitle,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            statusSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.6),
            ),
          ),
          if (status == 'trial' && days != null) ...[
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: days / 14,
                minHeight: 8,
                backgroundColor: statusColor.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanDetailsCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final s = AppLocalizations.of(context)!;
    final access = AccessManager.access;
    final store = StoreConfigService.store;
    final status = AccessManager.status;

    // Daten aus der 'access' Map
    final activatedAt = access?['activated_at']?.toString() ?? '';
    final subscriptionEndAt = access?['subscription_end_at']?.toString() ?? '';
    final trialStartAt = access?['trial_start_at']?.toString() ?? '';
    final trialEndAt = access?['trial_end_at']?.toString() ?? '';

    // Basis-Daten aus dem Store
    final createdAt = store?['created_at']?.toString() ?? '';

    return _cardWrapper(
      context,
      title: s.planDetailsCardTitle,
      icon: Icons.calendar_month_rounded,
      child: Column(
        children: [
          _infoRow(
            context,
            Icons.storefront,
            s.storeLabel,
            store?['store_name'] ?? s.storeFallbackName,
          ),
          _divider(context),
          _infoRow(
            context,
            Icons.info_outline,
            s.subscriptionTypeLabel,
            status == 'active' ? s.premiumYearly : s.trialFree,
          ),

          if (createdAt.isNotEmpty) ...[
            _divider(context),
            _infoRow(
              context,
              Icons.add_circle_outline,
              s.creationDate,
              _formatDate(createdAt),
            ),
          ],

          // Anzeige basierend auf Status
          if (status == 'active') ...[
            if (activatedAt.isNotEmpty) ...[
              _divider(context),
              _infoRow(
                context,
                Icons.verified_rounded,
                s.activatedAt,
                _formatDate(activatedAt),
                valueColor: Colors.green,
              ),
            ],
            if (subscriptionEndAt.isNotEmpty) ...[
              _divider(context),
              _infoRow(
                context,
                Icons.event_available_rounded,
                s.subscriptionEndsAt,
                _formatDate(subscriptionEndAt),
                valueColor: colors.tertiary,
              ),
            ],
          ] else if (status == 'trial') ...[
            if (trialStartAt.isNotEmpty) ...[
              _divider(context),
              _infoRow(
                context,
                Icons.play_arrow_rounded,
                s.trialStartedAt,
                _formatDate(trialStartAt),
              ),
            ],
            if (trialEndAt.isNotEmpty) ...[
              _divider(context),
              _infoRow(
                context,
                Icons.timer_outlined,
                s.trialEndsAt,
                _formatDate(trialEndAt),
                valueColor: colors.tertiary,
              ),
            ],
          ] else if (status == 'expired') ...[
            if (subscriptionEndAt.isNotEmpty) ...[
              _divider(context),
              _infoRow(
                context,
                Icons.event_busy_rounded,
                s.subscriptionEndedAt,
                _formatDate(subscriptionEndAt),
                valueColor: colors.error,
              ),
            ] else if (trialEndAt.isNotEmpty) ...[
              _divider(context),
              _infoRow(
                context,
                Icons.timer_off_outlined,
                s.trialEndedAt,
                _formatDate(trialEndAt),
                valueColor: colors.error,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildBenefitsCard(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    return _cardWrapper(
      context,
      title: s.currentBenefitsTitle,
      icon: Icons.star_rounded,
      child: Column(
        children: [
          _benefitItem(context, s.benefitUnlimitedProducts, true),
          _benefitItem(
            context,
            s.benefitHighQualityImages,
            AccessManager.canShowImagesPublic,
          ),
          _benefitItem(
            context,
            s.benefitShowPrices,
            AccessManager.canShowPricesPublic,
          ),
          _benefitItem(
            context,
            s.benefitFullControl,
            AccessManager.canWriteAdmin,
          ),
          _benefitItem(
            context,
            s.benefitDirectSupport,
            AccessManager.status == 'active',
          ),
        ],
      ),
    );
  }

  Widget _buildStagesCard(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    return _cardWrapper(
      context,
      title: s.restrictionStagesTitle,
      icon: Icons.layers_outlined,
      iconColor: Colors.blue,
      child: Column(
        children: [
          _stageItem(context, 1, s.restrictionStage1, AccessManager.stage >= 1),
          _stageItem(context, 2, s.restrictionStage2, AccessManager.stage >= 2),
          _stageItem(context, 3, s.restrictionStage3, AccessManager.stage >= 3),
        ],
      ),
    );
  }

  Widget _cardWrapper(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, size: 20, color: iconColor ?? colors.tertiary),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.hintColor.withValues(alpha: 0.7)),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: theme.hintColor, fontSize: 14)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefitItem(BuildContext context, String text, bool enabled) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: enabled
                  ? Colors.green.withValues(alpha: 0.1)
                  : colors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              enabled ? Icons.check_rounded : Icons.lock_outline_rounded,
              color: enabled
                  ? Colors.green
                  : colors.error.withValues(alpha: 0.5),
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: enabled ? null : Theme.of(context).disabledColor,
                decoration: enabled ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stageItem(
    BuildContext context,
    int number,
    String text,
    bool reached,
  ) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: reached
                  ? colors.error.withValues(alpha: 0.1)
                  : Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: reached ? colors.error : Colors.blue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                fontWeight: reached ? FontWeight.bold : FontWeight.normal,
                color: reached ? colors.error.withValues(alpha: 0.8) : null,
              ),
            ),
          ),
          if (reached)
            Icon(Icons.warning_amber_rounded, size: 16, color: colors.error),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) => Divider(
    height: 1,
    thickness: 0.5,
    color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
  );

  Widget _buildUpgradeButton(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final s = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          context.push(
            '/payment',
            extra: {'plan': 'premium_yearly', 'returnUrl': '/home'},
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
        child: Text(
          s.renewSubscriptionButton,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    final s = raw.trim();
    if (s.isEmpty || s == '-') return '-';

    DateTime? dt;

    // 1. Firestore Timestamp Format (als Fallback für rohe Strings)
    final timestampMatch = RegExp(r'Timestamp\(seconds=(\d+)').firstMatch(s);
    if (timestampMatch != null) {
      final seconds = int.tryParse(timestampMatch.group(1) ?? '');
      if (seconds != null) {
        dt = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      }
    }

    // 2. Standard ISO Format
    dt ??= DateTime.tryParse(s);
    dt ??= DateTime.tryParse(s.replaceFirst(' ', 'T'));

    if (dt == null) {
      if (s.length >= 10 &&
          RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(s.substring(0, 10))) {
        return s.substring(0, 10);
      }
      return s;
    }

    final y = dt.year.toString();
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y/$m/$d';
  }
}
