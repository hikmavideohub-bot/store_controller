import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
// افترضت وجود ملف الترجمة الخاص بك هنا
import 'package:store_controller/l10n/generated/app_localizations.dart';
import 'access_manager.dart';

class TrialWelcomeManager {
  static const String _shownKey = 'trial_welcome_shown_v2';
  static final ValueNotifier<bool> _hasBeenShown = ValueNotifier<bool>(false);

  static ValueNotifier<bool> get notifier => _hasBeenShown;

  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hasBeenShown.value = prefs.getBool(_shownKey) ?? false;
    } catch (_) {}
  }

  static Future<void> markAsShown() async {
    if (_hasBeenShown.value) return;
    _hasBeenShown.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_shownKey, true);
    } catch (_) {}
  }

  static bool get shouldShow {
    if (_hasBeenShown.value) return false;
    if (!AccessManager.isLoaded) return false;
    return AccessManager.status == 'trial' && AccessManager.stage == 0;
  }
}

class PaywallMessage {
  final String key;
  final String title;
  final String body;
  final String? ctaText;
  final IconData? icon;
  final Color? iconColor;
  final bool showFeatures;
  final bool showInFab;

  const PaywallMessage({
    required this.key,
    required this.title,
    required this.body,
    this.ctaText,
    this.icon,
    this.iconColor,
    this.showFeatures = false,
    this.showInFab = true,
  });
}

/// بناء الرسالة باستخدام BuildContext لجلب النصوص المترجمة
PaywallMessage? buildPaywallMessage(
  BuildContext context, {
  bool forFab = false,
}) {
  if (!AccessManager.isLoaded) return null;

  final l10n = AppLocalizations.of(context)!;
  final status = AccessManager.status;
  final stage = AccessManager.stage;

  if (status == 'active') return null;

  if (status == 'suspended') {
    return PaywallMessage(
      key: 'SUSPENDED',
      title: l10n.paywall_suspended_title,
      body: l10n.paywall_suspended_body,
      icon: Icons.support_agent_rounded,
      iconColor: Colors.redAccent,
      ctaText: null,
      showInFab: true,
    );
  }

  if (status == 'trial' && stage == 0) {
    return PaywallMessage(
      key: 'TRIAL_WELCOME',
      title: l10n.paywall_trial_welcome_title,
      body: l10n.paywall_trial_welcome_body,
      icon: Icons.celebration_rounded,
      iconColor: const Color(0xFFFFD700),
      ctaText: null,
      showInFab: false,
    );
  }

  if (status == 'expired') {
    if (stage == 1) {
      return PaywallMessage(
        key: 'EXPIRED_STAGE_1',
        title: l10n.paywall_expired_s1_title,
        body: l10n.paywall_expired_s1_body,
        ctaText: l10n.paywall_cta_activate_now,
        icon: Icons.price_change_rounded,
        iconColor: const Color(0xFFFFD700),
        showFeatures: true,
      );
    }

    if (stage == 2) {
      return PaywallMessage(
        key: 'EXPIRED_STAGE_2',
        title: l10n.paywall_expired_s2_title,
        body: l10n.paywall_expired_s2_body,
        ctaText: l10n.paywall_cta_activate_now,
        icon: Icons.image_not_supported_rounded,
        iconColor: const Color(0xFFFFD700),
        showFeatures: true,
      );
    }

    return PaywallMessage(
      key: 'EXPIRED_STAGE_3',
      title: l10n.paywall_expired_s3_title,
      body: l10n.paywall_expired_s3_body,
      ctaText: l10n.paywall_cta_activate_store,
      icon: Icons.lock_rounded,
      iconColor: Colors.redAccent,
      showFeatures: true,
    );
  }

  return null;
}

Future<void> showFabPaywallDialog(BuildContext context) async {
  final msg = buildPaywallMessage(context, forFab: true);
  if (msg == null) return;

  final l10n = AppLocalizations.of(context)!;
  final isPayment = msg.key.startsWith('EXPIRED');
  final accent = msg.iconColor ?? const Color(0xFFFFD700);

  final result = await showDialog<bool>(
    context: context,
    builder: (_) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Icon(msg.icon ?? Icons.payment_rounded, size: 44, color: accent),
        title: Text(msg.title, textAlign: TextAlign.right),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(msg.body, textAlign: TextAlign.right),
              if (msg.showFeatures) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 10),
                _buildFeaturesList(context),
              ],
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.common_later),
          ),
          if (isPayment && msg.ctaText != null)
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
              ),
              child: Text(msg.ctaText!),
            ),
          if (!isPayment)
            ElevatedButton(
              onPressed: () => Navigator.pop(context, false),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.common_ok),
            ),
        ],
      ),
    ),
  );

  if (!context.mounted) return;

  if (result == true && isPayment) {
    context.push(
      '/payment',
      extra: {'plan': 'premium_monthly', 'returnUrl': '/home'},
    );
  }
}

Widget _buildFeaturesList(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final items = <(IconData, String)>[
    (Icons.visibility_rounded, l10n.feature_show_prices),
    (Icons.image_rounded, l10n.feature_show_images),
    (Icons.edit_rounded, l10n.feature_edit_products),
    (Icons.support_agent_rounded, l10n.feature_faster_support),
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          l10n.paywall_features_header,
          style: const TextStyle(fontWeight: FontWeight.w800),
          textAlign: TextAlign.right,
        ),
      ),
      const SizedBox(height: 10),
      ...items.map(
        (e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(e.$1, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(e.$2, textAlign: TextAlign.right)),
            ],
          ),
        ),
      ),
    ],
  );
}

Future<void> showTrialWelcomePopup(BuildContext context) async {
  if (!TrialWelcomeManager.shouldShow) return;

  final l10n = AppLocalizations.of(context)!;

  // Zeige immer "فترة تجريبية مجانية" statt der verbleibenden Tage
  final String hint = l10n.freeTrial;

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        icon: const Icon(
          Icons.celebration_rounded,
          size: 44,
          color: Color(0xFFFFD700),
        ),
        title: Text(l10n.trial_popup_title, textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.trial_popup_body, textAlign: TextAlign.right),
            const SizedBox(height: 12),
            Text(
              '🎁 $hint',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
            ),
            child: Text(l10n.common_ok),
          ),
        ],
      ),
    ),
  );

  await TrialWelcomeManager.markAsShown();
}
