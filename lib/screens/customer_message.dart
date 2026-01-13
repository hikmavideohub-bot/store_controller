import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import '../widgets/premium_app_bar.dart';

class CustomerMessageScreen extends StatefulWidget {
  const CustomerMessageScreen({super.key});

  @override
  State<CustomerMessageScreen> createState() => _CustomerMessageScreenState();
}

class _CustomerMessageScreenState extends State<CustomerMessageScreen> {
  // Konstanten
  static const Color _primaryGold = Color(0xFFFFD700);
  static const Color _darkGold = Color(0xFF4A453E);
  static const Color _successColor = Color(0xFF00FF88);
  static const Duration _animationDuration = Duration(milliseconds: 400);
  static const double _borderRadius = 16.0;
  static const int _maxLen = 300;

  final _ctrl = TextEditingController();
  bool _loading = true;
  bool _editMode = false;
  bool _busy = false;
  String _lastSavedText = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _load();

    // Autosave nach 5 Sekunden Inaktivität
    _ctrl.addListener(() {
      _debounceTimer?.cancel();
      if (_editMode && _ctrl.text.isNotEmpty && _ctrl.text != _lastSavedText) {
        _debounceTimer = Timer(const Duration(seconds: 5), () {
          if (_editMode && mounted) {
            _save();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _load({bool force = false}) async {
    if (mounted) {
      setState(() => _loading = true);
    }

    try {
      final msg = await ApiService.getCustomerMessage(forceRefresh: force);
      if (!mounted) return;

      _ctrl.text = msg ?? '';
      _lastSavedText = _ctrl.text;
    } catch (e) {
      if (mounted) {
        _toast('فشل تحميل الرسالة', isError: true);
      }
      debugPrint('Error loading message: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _save() async {
    final msg = _ctrl.text.trim();
    if (msg.isEmpty) {
      _toast('الرسالة فارغة', isError: true);
      return;
    }

    setState(() => _busy = true);

    try {
      final ok = await ApiService.setCustomerMessage(msg);
      if (!mounted) return;

      setState(() {
        _busy = false;
        if (ok) {
          _editMode = false;
          _lastSavedText = msg;
        }
      });

      _toast(
        ok ? 'تم حفظ الرسالة ✅' : 'فشل الحفظ ❌',
        isError: !ok,
        isSuccess: ok,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _toast('خطأ في الاتصال بالخادم', isError: true);
      debugPrint('Error saving message: $e');
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('حذف الرسالة؟', textAlign: TextAlign.right),
        content: const Text(
          'سيتم حذف الرسالة من الموقع مباشرة ولن يراها العملاء.',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف الآن'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _busy = true);

    try {
      final ok = await ApiService.clearCustomerMessage();
      if (!mounted) return;

      setState(() {
        _busy = false;
        if (ok) {
          _ctrl.clear();
          _editMode = false;
          _lastSavedText = '';
        }
      });

      _toast(
        ok ? 'تم حذف الرسالة 🗑' : 'فشل الحذف ❌',
        isError: !ok,
        isSuccess: ok,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _toast('خطأ في الاتصال بالخادم', isError: true);
      debugPrint('Error deleting message: $e');
    }
  }

  void _toast(String msg, {bool isError = false, bool isSuccess = false}) {
    final icon = isSuccess
        ? Icons.check_circle_outline
        : isError
        ? Icons.error_outline
        : Icons.info_outline;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isSuccess
            ? Colors.green[800]
            : isError
            ? Colors.redAccent
            : Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
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
          : RefreshIndicator(
        onRefresh: () => _load(force: true),
        color: _primaryGold,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildHeaderInfo(isDark),
            const SizedBox(height: 20),
            AnimatedContainer(
              duration: _animationDuration,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: _editMode
                      ? _primaryGold.withValues(alpha:0.5)
                      : Colors.black.withValues(alpha:0.05),
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
      ),
    );
  }

  Widget _buildHeaderInfo(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _primaryGold.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _primaryGold.withValues(alpha:0.2)),
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
        ),
      ],
    );
  }

  Widget _buildTextField(bool isDark) {
    final textLength = _ctrl.text.length;
    final nearLimit = textLength > _maxLen * 0.8;
    final overLimit = textLength > _maxLen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: _ctrl,
          enabled: _editMode && !_busy,
          maxLines: 5,
          maxLength: _maxLen,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            fontWeight: FontWeight.w500,
            color: overLimit ? Colors.red : null,
          ),
          decoration: InputDecoration(
            hintText: 'اكتب رسالتك هنا (مثلاً: خصومات بمناسبة العيد...)',
            filled: true,
            fillColor: _editMode ? Colors.transparent : Colors.grey.withValues(alpha:0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha:0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
              borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$textLength/$_maxLen',
          style: TextStyle(
            fontSize: 12,
            color: overLimit
                ? Colors.red
                : nearLimit
                ? Colors.orange
                : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (!_editMode) {
      return Column(
        children: [
          _customButton(
            icon: Icons.edit_note_rounded,
            label: 'تعديل الرسالة',
            color: _darkGold,
            onTap: () => setState(() => _editMode = true),
          ),
          const SizedBox(height: 12),
          _customButton(
            icon: Icons.refresh_rounded,
            label: 'تحديث من السيرفر',
            color: Colors.blueGrey,
            isOutlined: true,
            onTap: () => _load(force: true),
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
          icon: Icons.check_circle_rounded,
          label: _busy ? 'جارٍ الحفظ...' : 'حفظ ونشر الآن',
          color: _successColor,
          onTap: _busy ? null : _save,
          isLoading: _busy,
        ),
        const SizedBox(height: 12),
        _customButton(
          icon: Icons.delete_forever_rounded,
          label: 'حذف الرسالة',
          color: Colors.redAccent,
          isOutlined: true,
          onTap: _busy ? null : _delete,
          isLoading: false,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _busy ? null : () {
            setState(() => _editMode = false);
            _ctrl.text = _lastSavedText;
          },
          child: const Text(
            'إلغاء التغييرات',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
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
    bool isLoading = false,
  }) {
    final bool isDisabled = onTap == null || isLoading;

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: isOutlined
            ? OutlinedButton.icon(
          onPressed: isDisabled ? null : onTap,
          icon: isLoading
              ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          )
              : Icon(icon, size: 20),
          label: Text(
            isLoading ? 'جاري...' : label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
          ),
        )
            : ElevatedButton.icon(
          onPressed: isDisabled ? null : onTap,
          icon: isLoading
              ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
              ),
            ),
          )
              : Icon(icon, size: 20),
          label: Text(
            isLoading ? 'جاري...' : label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
          ),
        ),
      ),
    );
  }
}