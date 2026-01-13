import 'package:flutter/material.dart';
import '../data/logo_emoji_catalog.dart';
import '../data/all_emoji_catalog.dart';

class EmojiPickerSheet extends StatefulWidget {
  final String selected;
  final ScrollController scrollController;

  const EmojiPickerSheet({
    super.key,
    required this.selected,
    required this.scrollController,
  });


  @override
  State<EmojiPickerSheet> createState() => _EmojiPickerSheetState();
}

class _EmojiPickerSheetState extends State<EmojiPickerSheet> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _search = TextEditingController();
  String _q = '';

  @override
  void initState() {
    super.initState();

    final tabsCount = LogoEmojiCatalog.categories.length + 1; // + All tab
    _tab = TabController(length: tabsCount, vsync: this);

    _search.addListener(() {
      setState(() => _q = _search.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final logoKeys = LogoEmojiCatalog.categories.keys.toList();
    final allTabIndex = logoKeys.length;

    final searching = _q.isNotEmpty;
    final isAllTab = _tab.index == allTabIndex;

    // list per tab
    List<String> list;
    if (searching) {
      // search across BOTH sets
      final a = LogoEmojiCatalog.all();
      final b = AllEmojiCatalog.all;

      // Simple search: match by category keywords (AR/EN/DE-ish)
      // If query matches a category name, show that category (logos).
      // Otherwise show all emojis (still useful).
      final matchedLogoCats = logoKeys.where((k) => k.toLowerCase().contains(_q)).toList();
      if (matchedLogoCats.isNotEmpty) {
        final out = <String>[];
        for (final k in matchedLogoCats) {
          out.addAll(LogoEmojiCatalog.categories[k] ?? const []);
        }
        list = _unique(out);
      } else {
        // fallback: show union (logos + all)
        list = _unique([...a, ...b]);
      }
    } else {
      if (isAllTab) {
        list = AllEmojiCatalog.all;
      } else {
        list = LogoEmojiCatalog.categories[logoKeys[_tab.index]] ?? const [];
      }
    }

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'اختر أيقونة المتجر',
              textDirection: TextDirection.rtl,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),

            // Search
            TextField(
              controller: _search,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search (مثلاً: متاجر / مطاعم / تقنية / all)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // Tabs
            IgnorePointer(
              ignoring: searching,
              child: Opacity(
                opacity: searching ? 0.5 : 1,
                child: TabBar(
                  controller: _tab,
                  isScrollable: true,
                  tabs: [
                    for (final k in logoKeys) Tab(text: k),
                    const Tab(text: '✨ جميع الإيموجي'),
                  ],
                  onTap: (_) => setState(() {}),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: GridView.builder(
                controller: widget.scrollController, // ✅ WICHTIG
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, // ✅ UX
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final e = list[i];
                  final selected = e == widget.selected;

                  return InkWell(
                    onTap: () => Navigator.pop(context, e),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        e,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  );
                },
              ),
            ),

            if (!searching && isAllTab)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '⚠️ هذه قائمة كبيرة. بعض الإيموجي قد لا تظهر على كل الأجهزة.',
                  textDirection: TextDirection.rtl,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),

            if (searching)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'امسح البحث للعودة للتصنيفات.',
                  textDirection: TextDirection.rtl,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<String> _unique(List<String> input) {
    final seen = <String>{};
    final out = <String>[];
    for (final e in input) {
      final t = e.trim();
      if (t.isEmpty) continue;
      if (seen.add(t)) out.add(t);
    }
    return out;
  }
}