import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import '../services/api_service.dart';
import '../widgets/premium_app_bar.dart';
import 'package:store_controller/widgets/responsive_center.dart';

class CustomerMessageScreen extends StatefulWidget {
  const CustomerMessageScreen({super.key});

  @override
  State<CustomerMessageScreen> createState() => _CustomerMessageScreenState();
}

class _CustomerMessageScreenState extends State<CustomerMessageScreen> {
  final _ctrlAr = TextEditingController();
  final _ctrlDe = TextEditingController();
  final _ctrlEn = TextEditingController();
  final _ctrlTr = TextEditingController();

  TextEditingController _ctrlFor(String lang) => switch (lang) {
    'ar' => _ctrlAr,
    'de' => _ctrlDe,
    'en' => _ctrlEn,
    'tr' => _ctrlTr,
    _ => _ctrlDe,
  };

  String _selectedLang = 'de';
  Map<String, String> _lastSavedTexts = {'ar': '', 'de': '', 'en': '', 'tr': ''};

  bool _loading = true;
  bool _busy = false;
  String? _publicUrl;
  final int _maxLen = 250;

  int _selectedDays = 0; // 0 = Immer

  // Liste für die eigenen lokalen Vorlagen
  List<Map<String, String>> _customTemplates = [];

  // --- NEU: Getter prüft jederzeit, ob es ungespeicherte Änderungen gibt ---
  bool get _hasChanged {
    return _ctrlAr.text.trim() != _lastSavedTexts['ar'] ||
        _ctrlDe.text.trim() != _lastSavedTexts['de'] ||
        _ctrlEn.text.trim() != _lastSavedTexts['en'] ||
        _ctrlTr.text.trim() != _lastSavedTexts['tr'];
  }

  @override
  void initState() {
    super.initState();
    _load();
    _loadCustomTemplates();
  }

  @override
  void dispose() {
    _ctrlAr.dispose();
    _ctrlDe.dispose();
    _ctrlEn.dispose();
    _ctrlTr.dispose();
    super.dispose();
  }

  Future<void> _loadCustomTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('custom_message_templates');
    if (str != null) {
      final List<dynamic> decoded = jsonDecode(str);
      setState(() {
        _customTemplates = decoded.map((e) => Map<String, String>.from(e)).toList();
      });
    }
  }

  Future<void> _saveCustomTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_message_templates', jsonEncode(_customTemplates));
  }

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
      final results = await Future.wait([
        ApiService.getCustomerMessage(),
        ApiService.getPublicStoreUrl(),
      ]);

      if (!mounted) return;

      final messageData = results[0];

      if (messageData is Map) {
        _ctrlAr.text = (messageData['ar'] ?? '').toString();
        _ctrlDe.text = (messageData['de'] ?? '').toString();
        _ctrlEn.text = (messageData['en'] ?? '').toString();
        _ctrlTr.text = (messageData['tr'] ?? '').toString();
      } else {
        final legacyMsg = (messageData ?? '').toString();
        _ctrlAr.text = legacyMsg;
        _ctrlDe.text = legacyMsg;
        _ctrlEn.text = legacyMsg;
        _ctrlTr.text = legacyMsg;
      }

      _lastSavedTexts = {
        'ar': _ctrlAr.text,
        'de': _ctrlDe.text,
        'en': _ctrlEn.text,
        'tr': _ctrlTr.text,
      };

      _publicUrl = results[1] as String?;
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
    setState(() => _busy = true);

    DateTime? expiry;
    if (_selectedDays > 0) {
      expiry = DateTime.now().add(Duration(days: _selectedDays));
    }

    final msgMap = {
      'ar': _ctrlAr.text.trim(),
      'de': _ctrlDe.text.trim(),
      'en': _ctrlEn.text.trim(),
      'tr': _ctrlTr.text.trim(),
    };

    try {
      final ok = await ApiService.setCustomerMessage(msgMap, expiryDate: expiry);
      if (!mounted) return;

      if (ok) {
        _lastSavedTexts = Map.from(msgMap);
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

      _ctrlAr.clear(); _ctrlDe.clear(); _ctrlEn.clear(); _ctrlTr.clear();
      _lastSavedTexts = {'ar': '', 'de': '', 'en': '', 'tr': ''};
      _selectedDays = 0;

      setState(() => _busy = false);
      _toast(s.messageDeleted);
    }
  }

  // --- NEU: Dialog für ungespeicherte Änderungen ---
  Future<bool> _showUnsavedDialog() async {
    final s = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(s.unsavedChangesTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(s.unsavedChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), // Bleiben
            child: Text(s.stayButton, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true), // Verwerfen / Rausgehen
            child: Text(s.discardButton),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _showAddEditCustomTemplateDialog(StateSetter setModalState, {int? index}) async {
    final s = AppLocalizations.of(context)!;
    final titleCtrl = TextEditingController(text: index != null ? _customTemplates[index]['title'] : '');
    final textCtrl = TextEditingController(text: index != null ? _customTemplates[index]['text'] : '');

    await showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(index == null ? s.customTemplateNewTitle : s.customTemplateEditTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: s.customTemplateTitleHint,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: s.customTemplateMessageHint,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(s.cancel)
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty || textCtrl.text.trim().isEmpty) return;

              setModalState(() {
                if (index == null) {
                  _customTemplates.add({'title': titleCtrl.text.trim(), 'text': textCtrl.text.trim()});
                } else {
                  _customTemplates[index] = {'title': titleCtrl.text.trim(), 'text': textCtrl.text.trim()};
                }
              });

              _saveCustomTemplates();
              Navigator.pop(dialogCtx);
            },
            child: Text(s.save),
          ),
        ],
      ),
    );
  }

  void _showTemplates() {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appLang = AppLocalizations.of(context)!;

    final templateLang = lookupAppLocalizations(Locale(_selectedLang));
    final defaultTemplates = _getTemplates(templateLang);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      appLang.chooseTemplateTitle,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8, top: 8),
                            child: Text(appLang.customTemplateDefaultTab, style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                          ...List.generate(defaultTemplates.length, (index) {
                            final t = defaultTemplates[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: Icon(Icons.description_outlined, color: colors.primary),
                                title: Text(t['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(t['text']!, maxLines: 2, overflow: TextOverflow.ellipsis),
                                onTap: () {
                                  setState(() {
                                    for (final lang in ['ar', 'de', 'en', 'tr']) {
                                      final loc = lookupAppLocalizations(Locale(lang));
                                      final textsInThisLang = _getTemplates(loc);
                                      _ctrlFor(lang).text = textsInThisLang[index]['text']!;
                                    }
                                  });
                                  Navigator.pop(ctx);
                                },
                              ),
                            );
                          }),

                          const Divider(height: 32),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(appLang.customTemplateMyTab, style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                              TextButton.icon(
                                onPressed: () => _showAddEditCustomTemplateDialog(setModalState),
                                icon: const Icon(Icons.add, size: 18),
                                label: Text(appLang.customTemplateCreateNew),
                              ),
                            ],
                          ),

                          if (_customTemplates.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  appLang.customTemplateEmpty,
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                                ),
                              ),
                            ),

                          ...List.generate(_customTemplates.length, (index) {
                            final t = _customTemplates[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey.shade900 : Colors.white,
                                border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(t['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(t['text']!, maxLines: 2, overflow: TextOverflow.ellipsis),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 20),
                                      color: Colors.blueGrey,
                                      onPressed: () => _showAddEditCustomTemplateDialog(setModalState, index: index),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 20),
                                      color: Colors.redAccent,
                                      onPressed: () {
                                        setModalState(() => _customTemplates.removeAt(index));
                                        _saveCustomTemplates();
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  setState(() => _ctrlFor(_selectedLang).text = t['text']!);
                                  Navigator.pop(ctx);
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
      ),
    );
  }

  void _toast(String msg, {bool isError = false, bool isSuccess = false}) {
    final colors = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isSuccess ? Colors.green : (isError ? colors.error : colors.primary),
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
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final s = AppLocalizations.of(context)!;

    // --- NEU: PopScope blockiert das Verlassen, wenn es Änderungen gab ---
    return PopScope(
      canPop: !_hasChanged, // True = er darf sofort raus, False = er wird blockiert
      onPopInvoked: (didPop) async {
        if (didPop) return; // Wenn er schon draußen ist, nichts tun

        // Wenn blockiert wurde, zeigen wir den Dialog
        final shouldPop = await _showUnsavedDialog();
        if (shouldPop && context.mounted) {
          context.pop(); // Wenn "Verwerfen" geklickt wurde, lassen wir ihn raus
        }
      },
      child: Scaffold(
        appBar: PremiumAnimatedAppBar(
          title: s.customerMessageTitle,
          showBackButton: true,
          showSettings: false,
        ),
        body: ResponsiveCenter(
          maxWidth: 900,
          child: _loading
              ? Center(child: CircularProgressIndicator(color: colors.primary))
              : SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 20,
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
                      icon: Icon(Icons.auto_awesome, size: 16, color: colors.primary),
                      label: Text(s.templatesButton, style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                _buildEditCard(isDark, s),

                const SizedBox(height: 24),
                _buildSectionHeader(s.displayDurationTitle),
                const SizedBox(height: 12),
                _buildExpiryOptions(s),

                const SizedBox(height: 32),
                _buildActionButtons(_hasChanged, s),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
    );
  }

  Widget _buildLivePreview(bool isDark, AppLocalizations s) {
    final colors = Theme.of(context).colorScheme;
    final currentCtrl = _ctrlFor(_selectedLang);

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
              Text(_publicUrl ?? 'your-store.web.app', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            ],
          ),
          const Divider(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              currentCtrl.text.isEmpty ? s.previewPlaceholder : currentCtrl.text,
              textAlign: TextAlign.center,
              textDirection: _selectedLang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              3, (i) => Expanded(
              child: Container(
                height: 40, margin: const EdgeInsets.symmetric(horizontal: 4),
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
    final labels = {
      'ar': s.descLangAr,
      'de': s.descLangDe,
      'en': s.descLangEn,
      'tr': s.descLangTr,
    };
    final currentCtrl = _ctrlFor(_selectedLang);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: labels.entries
                    .map((e) => ButtonSegment(value: e.key, label: Text(e.value)))
                    .toList(),
                selected: {_selectedLang},
                onSelectionChanged: (sel) => setState(() => _selectedLang = sel.first),
                showSelectedIcon: false,
              ),
            ),
          ),
          TextField(
            controller: currentCtrl,
            maxLines: 4,
            maxLength: _maxLen,
            textDirection: _selectedLang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: s.messageHint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
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
                  '${currentCtrl.text.length} / $_maxLen',
                  style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold,
                    color: currentCtrl.text.length > (_maxLen * 0.9) ? Colors.red : Colors.grey,
                  ),
                ),
                Text(s.engageTextHint, style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
              onSelected: (val) => setState(() => _selectedDays = opt['days'] as int),
              selectedColor: colors.primary,
              labelStyle: TextStyle(
                color: isSelected ? colors.onPrimary : colors.primary, fontWeight: FontWeight.bold,
              ),
              backgroundColor: colors.primary.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide.none),
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
          width: double.infinity, height: 55,
          child: ElevatedButton.icon(
            onPressed: (_busy || !hasChanged) ? null : _save,
            icon: _busy
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: colors.onPrimary))
                : const Icon(Icons.send_rounded),
            label: Text(s.saveAndPublishButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary, foregroundColor: colors.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0,
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
                  foregroundColor: Colors.redAccent, side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                // --- NEU: Abbrechen-Button nutzt jetzt auch die Dialog-Prüfung ---
                onPressed: () async {
                  if (_hasChanged) {
                    final discard = await _showUnsavedDialog();
                    if (discard && context.mounted) {
                      context.pop();
                    }
                  } else {
                    context.pop();
                  }
                },
                icon: const Icon(Icons.close_rounded),
                label: Text(s.cancel),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey, side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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