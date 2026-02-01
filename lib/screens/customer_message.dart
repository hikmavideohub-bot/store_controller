import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import '../services/api_service.dart';
import '../widgets/premium_app_bar.dart';

class CustomerMessageScreen extends StatefulWidget {
  const CustomerMessageScreen({super.key});

  @override
  State<CustomerMessageScreen> createState() => _CustomerMessageScreenState();
}

class _CustomerMessageScreenState extends State<CustomerMessageScreen> {
  final _ctrl = TextEditingController();
  bool _loading = true;
  bool _busy = false;
  String _lastSavedText = '';
  String? _publicUrl;
  final int _maxLen = 250;

  int _selectedDays = 0; // 0 = Immer

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

  // Templates dynamisch abrufen für Lokalisierung
  List<Map<String, String>> _getTemplates(AppLocalizations s) {
    return [
      {'title': s.templateDiscountTitle, 'text': s.templateDiscountText},
      {'title': s.templateWelcomeTitle, 'text': s.templateWelcomeText},
      {'title': s.templateNewTitle, 'text': s.templateNewText},
      {'title': s.templateDeliveryTitle, 'text': s.templateDeliveryText},
      {'title': s.templateOccasionTitle, 'text': s.templateOccasionText},
    ];
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait<String?>([
        ApiService.getCustomerMessage(),
        ApiService.getPublicStoreUrl(),
      ]);

      if (!mounted) return;

      _ctrl.text = results[0] ?? '';
      _lastSavedText = _ctrl.text;
      _publicUrl = results[1];

      // Falls URL mit https:// beginnt, kürzen wir sie für die Vorschau
      if (_publicUrl != null) {
        _publicUrl = _publicUrl!
            .replaceFirst('https://', '')
            .replaceFirst('http://', '');
      }
    } catch (e) {
      if (!mounted) return;
      final s = AppLocalizations.of(context)!;
      _toast(s.loadDataError, isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final s = AppLocalizations.of(context)!;
    final msg = _ctrl.text.trim();
    setState(() => _busy = true);

    DateTime? expiry;
    if (_selectedDays > 0) {
      expiry = DateTime.now().add(Duration(days: _selectedDays));
    }

    try {
      final ok = await ApiService.setCustomerMessage(msg, expiryDate: expiry);
      if (!mounted) return;

      if (ok) {
        _lastSavedText = msg;
        _toast(s.messagePublishedSuccess, isSuccess: true);
        FocusScope.of(context).unfocus();
      } else {
        _toast(s.saveFailed, isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      _toast(s.connectionError, isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final s = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteMessageTitle),
        content: Text(s.deleteMessageConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (ok == true) {
      setState(() => _busy = true);
      await ApiService.clearCustomerMessage();
      if (!mounted) return;

      _ctrl.clear();
      _lastSavedText = '';
      _selectedDays = 0;
      setState(() => _busy = false);
      _toast(s.messageDeleted);
    }
  }

  void _showTemplates() {
    final colors = Theme.of(context).colorScheme;
    final s = AppLocalizations.of(context)!;
    final templates = _getTemplates(s);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(ctx).viewPadding.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              s.chooseTemplateTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: templates
                    .map(
                      (t) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(
                            alpha: 0.05,
                          ), // Primary statt Gold
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.description_outlined,
                            color: colors.primary,
                          ),
                          title: Text(
                            t['title']!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            t['text']!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            setState(() => _ctrl.text = t['text']!);
                            Navigator.pop(ctx);
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toast(String msg, {bool isError = false, bool isSuccess = false}) {
    final colors = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        // Success: Grün, Error: Rot, Sonst: Primary (Teal)
        backgroundColor: isSuccess
            ? Colors.green
            : (isError ? colors.error : colors.primary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final hasChanged = _ctrl.text.trim() != _lastSavedText;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: PremiumAnimatedAppBar(
        title: s.customerMessageTitle,
        showBackButton: true,
        showSettings: false,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: colors.primary))
          : SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 40 + bottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(s.previewTitle),
                  const SizedBox(height: 12),
                  _buildLivePreview(isDark, s),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionHeader(s.editMessageTitle),
                      TextButton.icon(
                        onPressed: _showTemplates,
                        icon: Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: colors.primary,
                        ),
                        label: Text(
                          s.templatesButton,
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  _buildEditCard(isDark, s),

                  const SizedBox(height: 24),
                  _buildSectionHeader(s.displayDurationTitle),
                  const SizedBox(height: 12),
                  _buildExpiryOptions(s),

                  const SizedBox(height: 32),
                  _buildActionButtons(hasChanged, s),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    // Primary Color statt Gold für die Section Headers
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildLivePreview(bool isDark, AppLocalizations s) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.language, size: 14, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                _publicUrl ?? 'your-store.web.app',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ],
          ),
          const Divider(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              // Vorschau nutzt Primary (Teal) als Hintergrund
              color: colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _ctrl.text.isEmpty ? s.previewPlaceholder : _ctrl.text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              3,
              (i) => Expanded(
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditCard(bool isDark, AppLocalizations s) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _ctrl,
            maxLines: 4,
            maxLength: _maxLen,
            onChanged: (_) => setState(() {}),
            // textAlign: TextAlign.right, // Entfernt: TextDirection wird automatisch gesteuert durch App Direction
            decoration: InputDecoration(
              hintText: s.messageHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(20),
              counterText: "",
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_ctrl.text.length} / $_maxLen',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _ctrl.text.length > (_maxLen * 0.9)
                        ? Colors.red
                        : Colors.grey,
                  ),
                ),
                Text(
                  s.engageTextHint,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryOptions(AppLocalizations s) {
    final colors = Theme.of(context).colorScheme;

    final options = [
      {'label': s.durationAlways, 'days': 0},
      {'label': s.durationDay, 'days': 1},
      {'label': s.duration3Days, 'days': 3},
      {'label': s.durationWeek, 'days': 7},
      {'label': s.durationMonth, 'days': 30},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((opt) {
          final isSelected = _selectedDays == opt['days'];
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ChoiceChip(
              label: Text(opt['label'] as String),
              selected: isSelected,
              onSelected: (val) =>
                  setState(() => _selectedDays = opt['days'] as int),
              selectedColor: colors.primary, // Teal
              labelStyle: TextStyle(
                color: isSelected ? colors.onPrimary : colors.primary,
                fontWeight: FontWeight.bold,
              ),
              backgroundColor: colors.primary.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide.none,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButtons(bool hasChanged, AppLocalizations s) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: (_busy || !hasChanged) ? null : _save,
            icon: _busy
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.onPrimary,
                    ),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(
              s.saveAndPublishButton,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary, // Teal
              foregroundColor: colors.onPrimary, // White
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _busy ? null : _delete,
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text(s.deleteMessageTitle),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close_rounded),
                label: Text(s.cancel),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey,
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
