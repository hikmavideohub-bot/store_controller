import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import '../widgets/premium_app_bar.dart';
import '../theme.dart';

class CustomerMessageScreen extends StatefulWidget {
  const CustomerMessageScreen({super.key});


  @override
  State<CustomerMessageScreen> createState() => _CustomerMessageScreenState();
}

class _CustomerMessageScreenState extends State<CustomerMessageScreen> {
  static const Color _darkGold = Color(0xFF4A453E);
  final _ctrl = TextEditingController();
  bool _loading = true;
  bool _editMode = false;
  bool _busy = false;
  static const int _maxLen = 300;


  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _load({bool force = false}) async {
    setState(() => _loading = true);
    final msg = await ApiService.getCustomerMessage(forceRefresh: force);
    if (!mounted) return;
    _ctrl.text = msg ?? '';
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final msg = _ctrl.text.trim();
    if (msg.isEmpty) {
      _toast('الرسالة فارغة', isError: true);
      return;
    }
    setState(() => _busy = true);
    final ok = await ApiService.setCustomerMessage(msg);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (ok) _editMode = false;
    });
    _toast(ok ? 'تم حفظ الرسالة ✅' : 'فشل الحفظ ❌', isError: !ok);
  }

  Future<void> _delete() async {
    final confirm = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (ctx, a1, a2) => Container(),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (ctx, a1, a2, child) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('حذف الرسالة؟', textAlign: TextAlign.right),
              content: const Text('سيتم حذف الرسالة من الموقع مباشرة ولن يراها العملاء.', textAlign: TextAlign.right),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('حذف الآن'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm != true) return;

    setState(() => _busy = true);
    final ok = await ApiService.clearCustomerMessage();
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (ok) {
        _ctrl.clear();
        _editMode = false;
      }
    });
    _toast(ok ? 'تم حذف الرسالة 🗑' : 'فشل الحذف ❌', isError: !ok);
  }

  void _toast(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.redAccent : Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: PremiumAnimatedAppBar(
        title: 'رسالة العملاء',
        showBackButton: true,
        showSettings: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Info Header Card
          _buildHeaderInfo(isDark),
          const SizedBox(height: 20),

          // Main Editor Container
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: _editMode ? const Color(0xFFFFD700).withValues(alpha: 0.5) : Colors.black.withValues(alpha:0.05),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:isDark ? 0.3 : 0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildTextField(isDark),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700).withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha:0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFFFFD700), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'هذه الرسالة تظهر في واجهة المتجر الرئيسية لجميع الزوار.',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(bool isDark) {
    return TextField(
      controller: _ctrl,
      enabled: _editMode && !_busy,
      maxLines: 5,
      maxLength: _maxLen,
      textDirection: TextDirection.rtl,
      style: const TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: 'اكتب رسالتك هنا (مثلاً: خصومات بمناسبة العيد...)',
        filled: true,
        fillColor: _editMode ? Colors.transparent : Colors.grey.withValues(alpha:0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha:0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (!_editMode) {
      return Column(
        children: [
          _customButton(
            icon: Icons.edit_note_rounded,
            label: 'تعديل الرسالة',
            color: const Color(0xFF4A453E), // Hier die neue Farbe
            onTap: () => setState(() => _editMode = true),
          ),
          const SizedBox(height: 12),
          _customButton(
            icon: Icons.arrow_back_ios_new_rounded,
            label: 'رجوع',
            color: Colors.grey.shade400,
            isOutlined: true,
            onTap: () => context.pop(),
          ),
        ],
      );
    }

    return Column(
      children: [
        _customButton(
          icon: _busy ? Icons.hourglass_top_rounded : Icons.check_circle_rounded,
          label: _busy ? 'جارٍ الحفظ...' : 'حفظ ونشر الآن',
          color: const Color(0xFF00FF88),
          onTap: _busy ? null : _save,
        ),
        const SizedBox(height: 12),
        _customButton(
          icon: Icons.delete_forever_rounded,
          label: 'حذف الرسالة',
          color: Colors.redAccent,
          isOutlined: true,
          onTap: _busy ? null : _delete,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _busy ? null : () {
            setState(() => _editMode = false);
            _load();
          },
          child: const Text('إلغاء التغييرات', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _customButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
    bool isOutlined = false,
  }) {
    final bool isDisabled = onTap == null;
    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: isOutlined
            ? OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 20),
          label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        )
            : ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 20),
          label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }
}