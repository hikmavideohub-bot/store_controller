import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../services/store_config_service.dart';
import '../widgets/premium_app_bar.dart';
import '../theme.dart';

class PaymentScreen extends StatefulWidget {
  final String plan;
  final String returnUrl;

  const PaymentScreen({
    super.key,
    required this.plan,
    required this.returnUrl,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _loading = false;
  String? _paymentUrl;
  String? _error;

  // Währungs- und Angebots-Konfiguration (nur hier ändern)
  static const String _currency = 'يورو'; // Euro auf Arabisch
  static const String _currencyCode = 'EUR'; // Für API/Backend
  static const double _yearlyPrice = 15.00; // Startangebot: 15€ jährlich
  static const String _yearlyPriceFormatted = '15.00'; // Formatierte Version

  // Pläne mit Preisen und Features - NUR JÄHRLICH
  static final Map<String, Map<String, dynamic>> _plans = {
    'premium_yearly': {
      'name': 'بريميوم سنوي',
      'price': _yearlyPriceFormatted,
      'currency': _currency,
      'period': 'سنة',
      'features': [
        'منتجات غير محدودة',
        'فئات متعددة',
        'استخدام كامل بدون قيود',
        'تحديثات مستمرة',
        'أولوية في الدعم الفني',
      ],

      'highlight': false,
    },
  };

  @override
  void initState() {
    super.initState();
    _loadPaymentInfo();
  }

  Future<void> _loadPaymentInfo() async {
    final storeId = ApiService.storeId;
    if (storeId == null || storeId.isEmpty) {
      setState(() => _error = 'لم يتم العثور على معرف المتجر');
      return;
    }

    setState(() => _loading = true);

    try {
      // Hier würdest du normalerweise die Payment-URL von deinem Backend holen
      // Fürs Beispiel erstellen wir eine Dummy-URL

      // Simulieren einer API-Anfrage
      await Future.delayed(const Duration(milliseconds: 800));

      // Beispiel-URL (in der Realität von deinem Payment-Provider)
      final baseUrl = 'https://your-payment-provider.com/pay';
      final params = {
        'store_id': storeId,
        'plan': widget.plan,
        'amount': _yearlyPriceFormatted,
        'currency': _currencyCode,
        'return_url': 'https://your-app.com/payment-success',
        'cancel_url': 'https://your-app.com/payment-cancel',
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: params);
      setState(() {
        _paymentUrl = uri.toString();
        _loading = false;
      });

    } catch (e) {
      setState(() {
        _error = 'حدث خطأ أثناء تحضير عملية الدفع';
        _loading = false;
      });
    }
  }

  Future<void> _openPayment() async {
    if (_paymentUrl == null) return;

    final uri = Uri.parse(_paymentUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      // Optional: Nach Zahlung zurückkehren und Status prüfen
      await _checkPaymentStatus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر فتح صفحة الدفع'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _checkPaymentStatus() async {
    // Hier könntest du den Payment-Status vom Backend prüfen
    // Beispiel: Polling oder Webhook-Response
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.check_circle, size: 60, color: Colors.green),
        title: const Text('تم الدفع بنجاح! 🎉'),
        content: const Text(
          'تم تفعيل اشتراكك بنجاح.\n'
              'يمكنك الآن الاستمتاع بجميع مميزات البريميوم لمدة سنة كاملة.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
              context.go(widget.returnUrl);
            },
            child: const Text('الذهاب للمتجر'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentPlan = _plans['premium_yearly']!;

    return Scaffold(
      appBar: PremiumAnimatedAppBar(
        title: 'تفعيل المتجر لمدة سنة',
        showBackButton: true,
        showSettings: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Card mit besonderem Angebot
          _buildSpecialOfferCard(isDark),
          const SizedBox(height: 24),

          // Current Plan
          _buildPlanCard(currentPlan, isDark, true),
          const SizedBox(height: 32),

          // Payment Button
          if (_paymentUrl != null)
            _buildPaymentButton(currentPlan),

          if (_error != null)
            _buildErrorCard(),

          const SizedBox(height: 20),

          // Features List
          _buildFeaturesList(currentPlan['features'] as List<String>),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSpecialOfferCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFFD700).withValues(alpha:0.2),
              const Color(0xFF00C853).withValues(alpha:0.1),
            ]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha:0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'سعر الإطلاق',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'اشتراك سنوي بسعر مبدائي مميز!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'استمتع بجميع الميزات المتقدمة لمدة سنة كاملة بسعر رمزي. '
                'دفعة واحدة سنوية ,والتجديد اختياري.',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan, bool isDark, bool isCurrent, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isCurrent
              ? const Color(0xFFFFD700).withValues(alpha:0.1)
              : isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFFD700),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:isDark ? 0.2 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'الخطة الوحيدة',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Text(
                  plan['name'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFD700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  plan['price'] as String,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  plan['currency'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '/${plan['period']}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'ينتهي بعد سنة – تجديد اختياري',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton(Map<String, dynamic> plan) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: _openPayment,
        icon: const Icon(Icons.payment_rounded),
        label: Text(
          ' فعل متجرك - دفع ${plan['price']} ${plan['currency']}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00C853),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha:0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textDirection: TextDirection.rtl,
            ),
          ),
          TextButton(
            onPressed: _loadPaymentInfo,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(List<String> features) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'المميزات المتضمنة في الاشتراك السنوي:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 12),
        ...features.map((feature) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  feature,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
