// lib/core/paywall_messages.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'access_manager.dart';

const int _kTrialDays = 30;

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

  /// ✅ Fix für HomeShell: msg.iconColor
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

DateTime _serverNowUtc() {
  final raw = AccessManager.access?['server_time'];
  if (raw is String && raw.isNotEmpty) {
    final dt = DateTime.tryParse(raw);
    if (dt != null) return dt.toUtc();
  }
  return DateTime.now().toUtc();
}

DateTime? _parseIso(dynamic v) {
  if (v is! String) return null;
  final s = v.trim();
  if (s.isEmpty) return null;
  return DateTime.tryParse(s);
}

int? _daysUntil(DateTime? target, DateTime nowUtc) {
  if (target == null) return null;
  final sec = target.toUtc().difference(nowUtc).inSeconds;
  if (sec <= 0) return 0;
  return (sec / 86400).ceil();
}

String _arabicDays(int d) {
  if (d <= 0) return 'اليوم';
  if (d == 1) return 'يوم واحد';
  if (d == 2) return 'يومين';
  if (d >= 3 && d <= 10) return '$d أيام';
  return '$d يوم';
}

int? _trialDaysRemaining(DateTime nowUtc) {
  // bevorzugt admin-date (wenn vorhanden), sonst fallback daysRemaining vom Server
  final start = _parseIso(AccessManager.access?['trial_start_at']);
  if (start == null) return AccessManager.daysRemaining;
  final end = start.toUtc().add(const Duration(days: _kTrialDays));
  return _daysUntil(end, nowUtc);
}

/// Kern: Status + Stage + DaysRemaining => Message
PaywallMessage? buildPaywallMessage({bool forFab = false}) {
  if (!AccessManager.isLoaded) return null;

  final status = AccessManager.status;
  final stage = AccessManager.stage;
  final nowUtc = _serverNowUtc();

  // Active: keine Paywall
  if (status == 'active') return null;

  // Suspended: KEIN Payment-CTA (sonst würdest du /payment öffnen)
  if (status == 'suspended') {
    return const PaywallMessage(
      key: 'SUSPENDED',
      title: '⚠️ المتجر موقوف مؤقتاً',
      body:
      'تم إيقاف المتجر مؤقتاً.\n'
          'إذا كنت تعتقد أن ذلك خطأ، تواصل مع الدعم وسنساعدك بسرعة.',
      icon: Icons.support_agent_rounded,
      iconColor: Colors.redAccent,
      ctaText: null,
      showFeatures: false,
      showInFab: true,
    );
  }

  // Trial (stage 0): friendly, ohne Druck
  if (status == 'trial' && stage == 0) {
    final left = _trialDaysRemaining(nowUtc);
    final hint = (left == null) ? '' : '⏳ متبقي: ${_arabicDays(left)}';
    final suffix = hint.isEmpty ? '' : '\n\n$hint';

    return PaywallMessage(
      key: 'TRIAL_WELCOME',
      title: '🎁 أهلاً بك! التجربة مفعّلة',
      body:
      'ابدأ بإضافة منتجاتك ومشاركة رابط متجرك مع الزبائن.\n'
          'نصيحة: أضف 5–10 منتجات كبداية ليظهر متجرك بشكل رائع.$suffix',
      icon: Icons.celebration_rounded,
      iconColor: const Color(0xFFFFD700),
      ctaText: null,
      showFeatures: false,
      showInFab: false, // لا نزعج المستخدم بزر الإضافة
    );
  }

  // Expired: kundenfreundlich + Nutzen + klare CTA
  if (status == 'expired') {
    if (stage == 1) {
      return const PaywallMessage(
        key: 'EXPIRED_STAGE_1',
        title: 'انتهت التجربة المجانية',
        body:
        'متجرك ما زال ظاهرًا للزبائن، لكن الأسعار والمقاسات مخفية مؤقتاً.\n\n'
            'فعّل الاشتراك لتعود جميع المزايا فوراً.',
        ctaText: 'تفعيل الآن',
        icon: Icons.price_change_rounded,
        iconColor: Color(0xFFFFD700),
        showFeatures: true,
        showInFab: true,
      );
    }

    if (stage == 2) {
      return const PaywallMessage(
        key: 'EXPIRED_STAGE_2',
        title: 'الصور متوقفة مؤقتاً',
        body:
        'متجرك ما زال ظاهرًا للزبائن، لكن صور المنتجات مخفية مؤقتاً.\n\n'
            'فعّل الاشتراك لتعود الصور وباقي المزايا فوراً.',
        ctaText: 'تفعيل الآن',
        icon: Icons.image_not_supported_rounded,
        iconColor: Color(0xFFFFD700),
        showFeatures: true,
        showInFab: true,
      );
    }

    return const PaywallMessage(
      key: 'EXPIRED_STAGE_3',
      title: 'المتجر غير نشط حالياً',
      body:
      'تم تقييد بعض الميزات مؤقتاً بعد انتهاء التجربة.\n\n'
          'فعّل الاشتراك لاستمرار العمل وعرض المتجر بشكل كامل.',
      ctaText: 'تفعيل المتجر',
      icon: Icons.lock_rounded,
      iconColor: Colors.redAccent,
      showFeatures: true,
      showInFab: true,
    );
  }

  return null;
}

bool shouldShowPaywallForFab() {
  final msg = buildPaywallMessage(forFab: true);
  if (msg == null) return false;
  if (!msg.showInFab) return false;
  return true;
}

Future<void> showFabPaywallDialog(BuildContext context) async {
  final msg = buildPaywallMessage(forFab: true);
  if (msg == null) return;

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
                _buildFeaturesList(),
              ],
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لاحقاً'),
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
              child: const Text('حسناً'),
            ),
        ],
      ),
    ),
  );

  // ✅ Fix: kein BuildContext nach async-gap ohne mounted-check
  if (!context.mounted) return;

  if (result == true && isPayment) {
    context.push('/payment', extra: {
      'plan': 'premium_monthly',
      'returnUrl': '/home',
    });
  }
}


Widget _buildFeaturesList() {
  const items = <(IconData, String)>[
    (Icons.visibility_rounded, 'إظهار الأسعار والمقاسات والخيارات'),
    (Icons.image_rounded, 'إظهار صور المنتجات'),
    (Icons.edit_rounded, 'إضافة وتعديل المنتجات'),
    (Icons.support_agent_rounded, 'دعم أسرع عند الحاجة'),
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Align(
        alignment: Alignment.centerRight,
        child: Text(
          'بالتفعيل ستحصل على:',
          style: TextStyle(fontWeight: FontWeight.w800),
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

  final nowUtc = _serverNowUtc();
  final left = _trialDaysRemaining(nowUtc);
  final hint = (left == null)
      ? ''
      : (left <= 0 ? 'اليوم آخر يوم في التجربة.' : 'متبقي ${_arabicDays(left)} في التجربة.');

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        icon: const Icon(Icons.celebration_rounded, size: 44, color: Color(0xFFFFD700)),
        title: const Text('مرحباً بك في التجربة 🎉', textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'يمكنك الآن تجربة جميع المزايا:\n'
                  '• إضافة المنتجات\n'
                  '• مشاركة رابط متجرك\n'
                  '• عرض المتجر للزبائن',
              textAlign: TextAlign.right,
            ),
            if (hint.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('⏳ $hint', textAlign: TextAlign.right),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
            ),
            child: const Text('تمام'),
          ),
        ],
      ),
    ),
  );

  await TrialWelcomeManager.markAsShown();
}
