import 'dart:math';
import 'package:flutter/material.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import '../../repositories/analytics_repository.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _repo = AnalyticsRepository();

  static const int _cacheDays = 400;

  late int _selYear;
  late int _selMonth;

  RangeValues _range = const RangeValues(0, 0);
  RangeValues? _draggingRange;
  bool _rangeInitialized = false;

  // NEU: Speichert das Future, damit es den Filter beim Neuladen nicht zerstört!
  late Future<List<AnalyticsDaily>> _dataFuture;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selYear = now.year;
    _selMonth = now.month;
    _dataFuture = _loadAll(); // Einmaliges Laden beim Start
  }

  Future<List<AnalyticsDaily>> _loadAll() => _repo.fetchLastDays(days: _cacheDays);

  List<_MonthOption> _last12Months() {
    final now = DateTime.now();
    return List<_MonthOption>.generate(12, (i) {
      final d = DateTime(now.year, now.month - i, 1);
      return _MonthOption(year: d.year, month: d.month);
    });
  }

  String _monthName(AppLocalizations s, int month) {
    switch (month) {
      case 1:
        return s.month01;
      case 2:
        return s.month02;
      case 3:
        return s.month03;
      case 4:
        return s.month04;
      case 5:
        return s.month05;
      case 6:
        return s.month06;
      case 7:
        return s.month07;
      case 8:
        return s.month08;
      case 9:
        return s.month09;
      case 10:
        return s.month10;
      case 11:
        return s.month11;
      case 12:
        return s.month12;
      default:
        return '';
    }
  }

  int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  String _dayKey(int year, int month, int day) {
    String p2(int v) => v.toString().padLeft(2, '0');
    return '${year.toString().padLeft(4, '0')}-${p2(month)}-${p2(day)}';
  }

  String _dayLabel(AppLocalizations s, int year, int month, int day) {
    final dd = day.toString().padLeft(2, '0');
    return '$dd. ${_monthName(s, month)}';
  }

  String _dateLabel(AppLocalizations s, DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    return '$dd. ${_monthName(s, date.month)} ${date.year}';
  }

  AnalyticsDaily _emptyDailyForDate(DateTime date) {
    return AnalyticsDaily(
      dayKey: _dayKey(date.year, date.month, date.day),
      pageView: 0,
      productView: 0,
      addToCart: 0,
      checkoutIntent: 0,
      whatsappClick: 0,
    );
  }

  AnalyticsDaily _dailyForDate(Map<String, AnalyticsDaily> map, DateTime date) {
    final key = _dayKey(date.year, date.month, date.day);
    return map[key] ?? _emptyDailyForDate(date);
  }

  void _resetRangeForMonth(int maxDays) {
    final full = RangeValues(0, (maxDays - 1).toDouble());
    _rangeInitialized = true;
    _range = full;
    _draggingRange = null;
  }

  RangeValues _clampRange(RangeValues input, int maxDays) {
    final maxIdx = (maxDays - 1).toDouble();
    final start = input.start.clamp(0.0, maxIdx).toDouble();
    final end = input.end.clamp(0.0, maxIdx).toDouble();
    return RangeValues(start, end);
  }

  bool _sameRange(RangeValues a, RangeValues b) {
    return a.start == b.start && a.end == b.end;
  }

  RangeValues _lastNDaysRange(int maxDays, int count) {
    final end = maxDays - 1;
    final start = max(0, maxDays - count);
    return RangeValues(start.toDouble(), end.toDouble());
  }

  _Peak _peakOf(List<AnalyticsDaily> list, int Function(AnalyticsDaily e) f) {
    var bestIdx = 0;
    var bestVal = -1;

    for (int i = 0; i < list.length; i++) {
      final v = f(list[i]);
      if (v > bestVal) {
        bestVal = v;
        bestIdx = i;
      }
    }

    return _Peak(index: bestIdx, value: bestVal);
  }

  int _averageBefore(
      Map<String, AnalyticsDaily> map,
      DateTime anchorExclusive,
      int days,
      int Function(AnalyticsDaily e) pick,
      ) {
    if (days <= 0) return 0;
    var sum = 0;
    for (int i = 1; i <= days; i++) {
      sum += pick(_dailyForDate(map, anchorExclusive.subtract(Duration(days: i))));
    }
    return (sum / days).round();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final material = MaterialLocalizations.of(context);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(s.analyticsTitle),
        actions: [
          IconButton(
            tooltip: s.refreshButton,
            // Button zwingt die App jetzt, wirklich neu aus der Datenbank zu laden
            onPressed: () => setState(() => _dataFuture = _loadAll()),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<AnalyticsDaily>>(
        future: _dataFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  snap.error.toString(),
                  style: TextStyle(color: colors.error),
                ),
              ),
            );
          }

          final all = snap.data ?? <AnalyticsDaily>[];
          final byDay = <String, AnalyticsDaily>{
            for (final e in all) e.dayKey: e,
          };

          final dim = _daysInMonth(_selYear, _selMonth);
          final maxDays = (_selYear == now.year && _selMonth == now.month)
              ? now.day
              : dim;

          final monthDays = List<AnalyticsDaily>.generate(maxDays, (i) {
            final day = i + 1;
            final key = _dayKey(_selYear, _selMonth, day);
            return byDay[key] ??
                AnalyticsDaily(
                  dayKey: key,
                  pageView: 0,
                  productView: 0,
                  addToCart: 0,
                  checkoutIntent: 0,
                  whatsappClick: 0,
                );
          });

          if (!_rangeInitialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() => _resetRangeForMonth(maxDays));
            });
          }

          final fullRange = RangeValues(0, (maxDays - 1).toDouble());
          final appliedRange = _rangeInitialized ? _clampRange(_range, maxDays) : fullRange;

          if (_rangeInitialized && !_sameRange(appliedRange, _range)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() {
                _range = appliedRange;
              });
            });
          }

          final from = min(appliedRange.start.round(), appliedRange.end.round()).clamp(0, maxDays - 1);
          final to = max(appliedRange.start.round(), appliedRange.end.round()).clamp(0, maxDays - 1);

          // Slider UI-Feedback (nur für die Anzeige beim Ziehen, löst kein Neuladen der Diagramme aus)
          final activeStart = _draggingRange?.start ?? appliedRange.start;
          final activeEnd = _draggingRange?.end ?? appliedRange.end;
          final draftFrom = min(activeStart.round(), activeEnd.round()).clamp(0, maxDays - 1);
          final draftTo = max(activeStart.round(), activeEnd.round()).clamp(0, maxDays - 1);

          final visible = monthDays.sublist(from, to + 1);
          final reversedVisible = visible.reversed.toList();

          int sumVisible(int Function(AnalyticsDaily e) pick) {
            return visible.fold(0, (a, b) => a + pick(b));
          }

          final totalVisits = sumVisible((e) => e.pageView);
          final totalWhatsApp = sumVisible((e) => e.whatsappClick);
          final totalProductViews = sumVisible((e) => e.productView);
          final totalAddToCart = sumVisible((e) => e.addToCart);
          final totalCheckout = sumVisible((e) => e.checkoutIntent);

          final today = _dailyForDate(byDay, now);
          final yesterday = _dailyForDate(byDay, now.subtract(const Duration(days: 1)));

          final avg7Visits = _averageBefore(byDay, now, 7, (e) => e.pageView);
          final avg7WhatsApp = _averageBefore(byDay, now, 7, (e) => e.whatsappClick);
          final avg7ProductViews = _averageBefore(byDay, now, 7, (e) => e.productView);
          final avg7AddToCart = _averageBefore(byDay, now, 7, (e) => e.addToCart);
          final avg7Checkout = _averageBefore(byDay, now, 7, (e) => e.checkoutIntent);

          final pvSeries = visible.map((e) => e.pageView.toDouble()).toList();
          final waSeries = visible.map((e) => e.whatsappClick.toDouble()).toList();
          final xLabels = List<String>.generate(visible.length, (i) => (from + i + 1).toString());

          final peakVisits = _peakOf(visible, (e) => e.pageView);
          final peakWhats = _peakOf(visible, (e) => e.whatsappClick);

          final monthOptions = _last12Months();
          final bottomPad = MediaQuery.of(context).padding.bottom;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _dataFuture = _loadAll());
              await _dataFuture;
            },
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 20 + bottomPad + 18),
              children: [
                _TodayHeroCard(
                  title: material.currentDateLabel,
                  subtitle: _dateLabel(s, now),
                  items: [
                    _HeroStatItem(
                      icon: Icons.visibility_rounded,
                      label: s.analyticsCardVisitsToday, // NEU: Key für Heute
                      value: today.pageView,
                      delta: today.pageView - yesterday.pageView,
                      avg: avg7Visits,
                    ),
                    _HeroStatItem(
                      icon: Icons.shopping_bag_rounded,
                      label: s.analyticsCardProductViews,
                      value: today.productView,
                      delta: today.productView - yesterday.productView,
                      avg: avg7ProductViews,
                    ),
                    _HeroStatItem(
                      icon: Icons.add_shopping_cart_rounded,
                      label: s.analyticsCardAddToCart,
                      value: today.addToCart,
                      delta: today.addToCart - yesterday.addToCart,
                      avg: avg7AddToCart,
                    ),
                    _HeroStatItem(
                      icon: Icons.payments_rounded,
                      label: s.analyticsCardCheckout,
                      value: today.checkoutIntent,
                      delta: today.checkoutIntent - yesterday.checkoutIntent,
                      avg: avg7Checkout,
                    ),
                    _HeroStatItem(
                      icon: Icons.wechat,
                      label: s.analyticsCardWhatsapp,
                      value: today.whatsappClick,
                      delta: today.whatsappClick - yesterday.whatsappClick,
                      avg: avg7WhatsApp,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _CollapsibleFilter(
                  title: s.analyticsFilterTitle,
                  subtitle:
                  '${_monthName(s, _selMonth)} $_selYear • ${_dayLabel(s, _selYear, _selMonth, from + 1)} → ${_dayLabel(s, _selYear, _selMonth, to + 1)}',
                  initiallyExpanded: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            size: 18,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            s.analyticsMonthLabel,
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<_MonthOption>(
                              value: _MonthOption(year: _selYear, month: _selMonth),
                              items: monthOptions
                                  .map(
                                    (m) => DropdownMenuItem<_MonthOption>(
                                  value: m,
                                  child: Text('${_monthName(s, m.month)} ${m.year}'),
                                ),
                              )
                                  .toList(),
                              onChanged: (v) {
                                if (v == null) return;
                                setState(() {
                                  _selYear = v.year;
                                  _selMonth = v.month;
                                  _rangeInitialized = false;
                                  _range = const RangeValues(0, 0);
                                  _draggingRange = null; // <-- Hier war der Fehler!
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _PresetChip(
                            label: _monthName(s, _selMonth),
                            selected: from == 0 && to == maxDays - 1,
                            onTap: () {
                              final full = RangeValues(0, (maxDays - 1).toDouble());
                              setState(() {
                                _draggingRange = null;
                                _range = full;
                              });
                            },
                          ),
                          _PresetChip(
                            label: '7 ${s.analyticsAxisDays}',
                            selected: from == max(0, maxDays - 7) && to == maxDays - 1,
                            onTap: () {
                              final r = _lastNDaysRange(maxDays, 7);
                              setState(() {
                                _draggingRange = null;
                                _range = r;
                              });
                            },
                          ),
                          _PresetChip(
                            label: '14 ${s.analyticsAxisDays}',
                            selected: from == max(0, maxDays - 14) && to == maxDays - 1,
                            onTap: () {
                              final r = _lastNDaysRange(maxDays, 14);
                              setState(() {
                                _draggingRange = null;
                                _range = r;
                              });
                            },
                          ),
                          if (_selYear == now.year && _selMonth == now.month)
                            _PresetChip(
                              label: material.currentDateLabel,
                              selected: from == now.day - 1 && to == now.day - 1,
                              onTap: () {
                                final r = RangeValues((now.day - 1).toDouble(), (now.day - 1).toDouble());
                                setState(() {
                                  _draggingRange = null;
                                  _range = r;
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.filter_alt_rounded,
                            size: 18,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${s.analyticsFilterFrom} ${_dayLabel(s, _selYear, _selMonth, draftFrom + 1)}  •  ${s.analyticsFilterTo} ${_dayLabel(s, _selYear, _selMonth, draftTo + 1)}',
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (maxDays > 1)
                        RangeSlider(
                          values: RangeValues(activeStart, activeEnd),
                          min: 0,
                          max: (maxDays - 1).toDouble(),
                          divisions: max(1, maxDays - 1),
                          labels: RangeLabels(
                            _dayLabel(s, _selYear, _selMonth, draftFrom + 1),
                            _dayLabel(s, _selYear, _selMonth, draftTo + 1),
                          ),
                          // onChanged updatet NUR das UI (den Text drüber), NICHT die eigentlichen Daten!
                          onChanged: (v) {
                            setState(() {
                              _draggingRange = v;
                            });
                          },
                          // onChangeEnd feuert, wenn du loslässt -> Jetzt erst Daten updaten!
                          onChangeEnd: (v) {
                            setState(() {
                              _range = _clampRange(v, maxDays);
                              _draggingRange = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _SummaryGrid(
                  items: [
                    _SummaryItem(
                      icon: Icons.visibility_rounded,
                      title: s.analyticsCardVisitsRange, // NEU: Key für Bereich
                      value: totalVisits,
                    ),
                    _SummaryItem(
                      icon: Icons.wechat,
                      title: s.analyticsCardWhatsapp,
                      value: totalWhatsApp,
                    ),
                    _SummaryItem(
                      icon: Icons.shopping_bag_rounded,
                      title: s.analyticsCardProductViews,
                      value: totalProductViews,
                    ),
                    _SummaryItem(
                      icon: Icons.add_shopping_cart_rounded,
                      title: s.analyticsCardAddToCart,
                      value: totalAddToCart,
                    ),
                    _SummaryItem(
                      icon: Icons.payments_rounded,
                      title: s.analyticsCardCheckout,
                      value: totalCheckout,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _Card(
                  title: s.analyticsPeakTitle,
                  leading: Icons.emoji_events_rounded,
                  child: Column(
                    children: [
                      _PeakRow(
                        icon: Icons.visibility_rounded,
                        title: s.analyticsCardVisits,
                        dayLabel: _dayLabel(s, _selYear, _selMonth, from + 1 + peakVisits.index),
                        valueText: s.analyticsPeakVisits(peakVisits.value),
                      ),
                      const SizedBox(height: 8),
                      _PeakRow(
                        icon: Icons.wechat,
                        title: s.analyticsCardWhatsapp,
                        dayLabel: _dayLabel(s, _selYear, _selMonth, from + 1 + peakWhats.index),
                        valueText: s.analyticsPeakWhatsapp(peakWhats.value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _ChartCard(
                  title: s.analyticsChartVisits,
                  icon: Icons.show_chart_rounded,
                  child: AxisLineChart(
                    values: pvSeries,
                    xLabels: xLabels,
                    yAxisLabel: s.analyticsAxisCount,
                    xAxisLabel: s.analyticsAxisDays,
                    highlightIndex: peakVisits.index,
                  ),
                ),
                const SizedBox(height: 12),
                _ChartCard(
                  title: s.analyticsChartWhatsapp,
                  icon: Icons.trending_up_rounded,
                  child: AxisLineChart(
                    values: waSeries,
                    xLabels: xLabels,
                    yAxisLabel: s.analyticsAxisCount,
                    xAxisLabel: s.analyticsAxisDays,
                    highlightIndex: peakWhats.index,
                  ),
                ),
                const SizedBox(height: 12),
                _DaysExpansion(
                  title: s.analyticsTableTitle,
                  count: reversedVisible.length,
                  child: Column(
                    children: reversedVisible.map((e) {
                      final dayNum = int.tryParse(e.dayKey.substring(8, 10)) ?? 0;
                      final isToday =
                          _selYear == now.year && _selMonth == now.month && dayNum == now.day;

                      return _DayRow(
                        dayKey: e.dayKey,
                        pageViews: e.pageView,
                        whatsappClicks: e.whatsappClick,
                        productViews: e.productView,
                        isToday: isToday,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MonthOption {
  final int year;
  final int month;

  const _MonthOption({required this.year, required this.month});

  @override
  bool operator ==(Object other) {
    return other is _MonthOption && other.year == year && other.month == month;
  }

  @override
  int get hashCode => Object.hash(year, month);
}

class _Peak {
  final int index;
  final int value;

  const _Peak({required this.index, required this.value});
}

class _Card extends StatelessWidget {
  final String title;
  final IconData leading;
  final Widget child;

  const _Card({
    required this.title,
    required this.leading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(leading, size: 18, color: colors.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SummaryItem {
  final IconData icon;
  final String title;
  final int value;

  _SummaryItem({
    required this.icon,
    required this.title,
    required this.value,
  });
}

class _SummaryGrid extends StatelessWidget {
  final List<_SummaryItem> items;

  const _SummaryGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final cols = maxWidth >= 900 ? 3 : 2;
        const spacing = 12.0;
        final cardW = (maxWidth - spacing * (cols - 1)) / cols;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items.map((it) {
            return Container(
              width: cardW,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(it.icon, color: colors.onPrimaryContainer),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          it.title,
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          it.value.toString(),
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _HeroStatItem {
  final IconData icon;
  final String label;
  final int value;
  final int delta;
  final int avg;

  const _HeroStatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.delta,
    required this.avg,
  });
}

class _TodayHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<_HeroStatItem> items;

  const _TodayHeroCard({
    required this.title,
    required this.subtitle,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primaryContainer.withValues(alpha: 0.9),
            colors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final columns = maxWidth >= 980 ? 5 : maxWidth >= 760 ? 3 : 2;
          const spacing = 10.0;
          final tileWidth = (maxWidth - spacing * (columns - 1)) / columns;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colors.surface.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.today_rounded, color: colors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: items.map((item) {
                  return Container(
                    width: tileWidth,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surface.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colors.outlineVariant.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(item.icon, size: 18, color: colors.primary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.label,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.value.toString(),
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _TinyPill(
                              icon: item.delta >= 0
                                  ? Icons.north_rounded
                                  : Icons.south_rounded,
                              text: item.delta == 0
                                  ? s.analyticsVsYesterdayValue('0')
                                  : item.delta > 0
                                  ? s.analyticsVsYesterdayValue('+${item.delta}')
                                  : s.analyticsVsYesterdayValue('${item.delta}'),
                            ),
                            _TinyPill(
                              icon: Icons.timeline_rounded,
                              text: s.analyticsAvg7DaysValue('${item.avg}'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TinyPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TinyPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.onPrimaryContainer),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: colors.onPrimaryContainer,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? colors.primaryContainer.withValues(alpha: 0.85)
              : colors.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? colors.primary.withValues(alpha: 0.4)
                : colors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? colors.onPrimaryContainer : colors.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colors.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(height: 220, child: child),
        ],
      ),
    );
  }
}

class _PeakRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String dayLabel;
  final String valueText;

  const _PeakRow({
    required this.icon,
    required this.title,
    required this.dayLabel,
    required this.valueText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: colors.primary.withValues(alpha: 0.5)),
            ),
            child: Text(
              '$dayLabel • $valueText',
              style: TextStyle(
                color: colors.onPrimaryContainer,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _DaysExpansion extends StatelessWidget {
  final String title;
  final int count;
  final Widget child;

  const _DaysExpansion({
    required this.title,
    required this.count,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        leading: Icon(Icons.list_alt_rounded, color: colors.onSurfaceVariant),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        subtitle: Text(
          '$count',
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
        children: [child],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  final String dayKey;
  final int pageViews;
  final int whatsappClicks;
  final int productViews;
  final bool isToday;

  const _DayRow({
    required this.dayKey,
    required this.pageViews,
    required this.whatsappClicks,
    required this.productViews,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isToday
            ? colors.primaryContainer.withValues(alpha: 0.25)
            : colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isToday
              ? colors.primary.withValues(alpha: 0.5)
              : colors.outlineVariant.withValues(alpha: 0.5),
          width: isToday ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 128,
            child: Row(
              children: [
                if (isToday) ...[
                  Icon(Icons.today_rounded, size: 16, color: colors.primary),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    dayKey,
                    style: TextStyle(
                      color: isToday ? colors.primary : colors.onSurface,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _MiniStat(icon: Icons.visibility_rounded, value: pageViews),
          const SizedBox(width: 10),
          _MiniStat(icon: Icons.wechat, value: whatsappClicks),
          const SizedBox(width: 10),
          _MiniStat(icon: Icons.shopping_bag_rounded, value: productViews),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final int value;

  const _MiniStat({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: colors.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          value.toString(),
          style: TextStyle(
            color: colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class AxisLineChart extends StatelessWidget {
  final List<double> values;
  final List<String> xLabels;
  final String yAxisLabel;
  final String xAxisLabel;
  final int? highlightIndex;

  const AxisLineChart({
    super.key,
    required this.values,
    required this.xLabels,
    required this.yAxisLabel,
    required this.xAxisLabel,
    this.highlightIndex,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return CustomPaint(
      painter: _AxisLineChartPainter(
        values: values,
        xLabels: xLabels,
        color: colors.primary,
        grid: colors.outlineVariant.withValues(alpha: 0.55),
        text: colors.onSurfaceVariant,
        highlightIndex: highlightIndex,
        axisLabelX: xAxisLabel,
        axisLabelY: yAxisLabel,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _AxisLineChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> xLabels;
  final Color color;
  final Color grid;
  final Color text;
  final int? highlightIndex;
  final String axisLabelX;
  final String axisLabelY;

  _AxisLineChartPainter({
    required this.values,
    required this.xLabels,
    required this.color,
    required this.grid,
    required this.text,
    required this.highlightIndex,
    required this.axisLabelX,
    required this.axisLabelY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const leftPad = 54.0;
    const rightPad = 10.0;
    const topPad = 10.0;
    const bottomPad = 34.0;

    final w = size.width - leftPad - rightPad;
    final h = size.height - topPad - bottomPad;

    final maxV = values.reduce((a, b) => a > b ? a : b);
    final safeMax = maxV <= 0 ? 1.0 : maxV;

    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final t = i / 4;
      final y = topPad + h * (1 - t);
      canvas.drawLine(Offset(leftPad, y), Offset(leftPad + w, y), gridPaint);

      final val = (safeMax * t).round();
      _drawText(canvas, val.toString(), Offset(8, y - 7), 11, text);
    }

    canvas.drawLine(
      Offset(leftPad, topPad + h),
      Offset(leftPad + w, topPad + h),
      gridPaint,
    );

    void drawX(int idx, Alignment align) {
      if (idx < 0 || idx >= xLabels.length) return;
      final x = leftPad + (values.length == 1 ? 0 : (w * idx / (values.length - 1)));
      final y = topPad + h + 6;
      final tp = _textPainter(xLabels[idx], 11, text);

      final dx = align == Alignment.centerLeft
          ? x
          : align == Alignment.centerRight
          ? x - tp.width
          : x - tp.width / 2;

      tp.paint(canvas, Offset(dx, y));
    }

    drawX(0, Alignment.centerLeft);
    drawX((values.length - 1) ~/ 2, Alignment.center);
    drawX(values.length - 1, Alignment.centerRight);

    _drawText(canvas, axisLabelX, Offset(leftPad + w / 2 - 20, size.height - 18), 11, text);

    canvas.save();
    canvas.translate(14, topPad + h / 2 + 18);
    canvas.rotate(-pi / 2);
    _drawText(canvas, axisLabelY, const Offset(0, 0), 11, text);
    canvas.restore();

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = leftPad + (values.length == 1 ? 0 : (w * i / (values.length - 1)));
      final y = topPad + h - (h * (values[i] / safeMax));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);

    final hi = highlightIndex;
    if (hi != null && hi >= 0 && hi < values.length) {
      final x = leftPad + (values.length == 1 ? 0 : (w * hi / (values.length - 1)));
      final y = topPad + h - (h * (values[hi] / safeMax));

      final dotFill = Paint()..color = color;
      final dotRing = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(Offset(x, y), 4.6, dotFill);
      canvas.drawCircle(Offset(x, y), 6.6, dotRing);
    }
  }

  TextPainter _textPainter(String textStr, double fontSize, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: textStr,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    );
    tp.layout();
    return tp;
  }

  void _drawText(Canvas canvas, String textStr, Offset offset, double fontSize, Color color) {
    final tp = _textPainter(textStr, fontSize, color);
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _AxisLineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.xLabels != xLabels ||
        oldDelegate.color != color ||
        oldDelegate.grid != grid ||
        oldDelegate.text != text ||
        oldDelegate.highlightIndex != highlightIndex ||
        oldDelegate.axisLabelX != axisLabelX ||
        oldDelegate.axisLabelY != axisLabelY;
  }
}

class _CollapsibleFilter extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool initiallyExpanded;
  final Widget child;

  const _CollapsibleFilter({
    required this.title,
    required this.subtitle,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        leading: Icon(Icons.tune_rounded, color: colors.onSurfaceVariant),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        children: [child],
      ),
    );
  }
}
