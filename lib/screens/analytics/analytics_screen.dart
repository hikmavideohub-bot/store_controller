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

  // wir laden genug Daten für 12 Monate (~400 Tage)
  static const int _cacheDays = 400;

  late int _selYear;
  late int _selMonth; // 1..12

  RangeValues _range = const RangeValues(0, 0);
  bool _rangeInitialized = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selYear = now.year;
    _selMonth = now.month;
  }

  Future<List<AnalyticsDaily>> _loadAll() => _repo.fetchLastDays(days: _cacheDays);

  List<_MonthOption> _last12Months(AppLocalizations s) {
    final now = DateTime.now();
    final out = <_MonthOption>[];
    for (int i = 0; i < 12; i++) {
      final d = DateTime(now.year, now.month - i, 1);
      out.add(_MonthOption(year: d.year, month: d.month));
    }
    return out;
  }
  String _dayLabel(int day) {
    final dd = day.toString().padLeft(2, '0');
    final monthName = _monthName(AppLocalizations.of(context)!, _selMonth);
    return '$dd. $monthName'; // z.B. 05. März:
  }

  String _monthName(AppLocalizations s, int m) {
    switch (m) {
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

  int _daysInMonth(int year, int month) {
    // Tag 0 vom nächsten Monat = letzter Tag des Monats
    return DateTime(year, month + 1, 0).day;
  }

  String _dayKey(int year, int month, int day) {
    String p2(int v) => v.toString().padLeft(2, '0');
    return '${year.toString().padLeft(4, '0')}-${p2(month)}-${p2(day)}';
  }

  void _resetRangeForMonth(int daysInMonth) {
    _rangeInitialized = true;
    _range = RangeValues(0, (daysInMonth - 1).toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.analyticsTitle),
        actions: [
          IconButton(
            tooltip: s.refreshButton,
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<AnalyticsDaily>>(
        future: _loadAll(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(snap.error.toString(), style: TextStyle(color: colors.error)),
              ),
            );
          }

          final all = snap.data ?? [];

          // Map dayKey -> doc (schnell)
          final map = <String, AnalyticsDaily>{
            for (final e in all) e.dayKey: e,
          };

          final dim = _daysInMonth(_selYear, _selMonth);

          // Monat vollständig 1..dim füllen (auch wenn keine Daten existieren)
          final monthDays = List<AnalyticsDaily>.generate(dim, (i) {
            final day = i + 1;
            final key = _dayKey(_selYear, _selMonth, day);
            return map[key] ??
                AnalyticsDaily(
                  dayKey: key,
                  pageView: 0,
                  productView: 0,
                  addToCart: 0,
                  checkoutIntent: 0,
                  whatsappClick: 0,
                );
          });

          // Range init / clamp (num->double safe)
          final maxIdx = (monthDays.length - 1).toDouble();
          if (!_rangeInitialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() => _resetRangeForMonth(dim));
            });
          } else {
            final start = _range.start.clamp(0.0, maxIdx).toDouble();
            final end = _range.end.clamp(0.0, maxIdx).toDouble();
            if (start != _range.start || end != _range.end) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                setState(() => _range = RangeValues(start, end));
              });
            }
          }

          final from = min(_range.start.round(), _range.end.round()).clamp(0, dim - 1);
          final to = max(_range.start.round(), _range.end.round()).clamp(0, dim - 1);
          final visible = monthDays.sublist(from, to + 1);

          int sum(int Function(AnalyticsDaily e) f) => visible.fold(0, (a, b) => a + f(b));

          final totalVisits = sum((e) => e.pageView);
          final totalWhatsApp = sum((e) => e.whatsappClick);
          final totalProductViews = sum((e) => e.productView);
          final totalAddToCart = sum((e) => e.addToCart);
          final totalCheckout = sum((e) => e.checkoutIntent);

          final pvSeries = visible.map((e) => e.pageView.toDouble()).toList();
          final waSeries = visible.map((e) => e.whatsappClick.toDouble()).toList();

          // X labels: 1..dim (sichtbarer Ausschnitt)
          final xLabels = List<String>.generate(visible.length, (i) => (from + i + 1).toString());

          final peakVisits = _peakOf(visible, (e) => e.pageView);
          final peakWhats = _peakOf(visible, (e) => e.whatsappClick);

          final monthOptions = _last12Months(s);
          final selectedLabel = '${_monthName(s, _selMonth)} ${_selYear}';

          final bottomPad = MediaQuery.of(context).padding.bottom;

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPad + 18),
              children: [
                // Filter Card: Month dropdown + range slider
                _CollapsibleFilter(
                  title: s.analyticsFilterTitle,
                  subtitle: '${_monthName(s, _selMonth)} $_selYear • ${_dayLabel(from + 1)} → ${_dayLabel(to + 1)}',
                  initiallyExpanded: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Month Dropdown
                      Row(
                        children: [
                          Icon(Icons.calendar_month_rounded, size: 18, color: colors.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Text(
                            s.analyticsMonthLabel,
                            style: TextStyle(color: colors.onSurfaceVariant, fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<_MonthOption>(
                              value: _MonthOption(year: _selYear, month: _selMonth),
                              items: monthOptions
                                  .map((m) => DropdownMenuItem<_MonthOption>(
                                value: m,
                                child: Text('${_monthName(s, m.month)} ${m.year}'),
                              ))
                                  .toList(),
                              onChanged: (v) {
                                if (v == null) return;
                                setState(() {
                                  _selYear = v.year;
                                  _selMonth = v.month;
                                  _rangeInitialized = false;
                                  _range = const RangeValues(0, 0);
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Icon(Icons.filter_alt_rounded, size: 18, color: colors.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${s.analyticsFilterFrom} ${_dayLabel(from + 1)}  •  ${s.analyticsFilterTo} ${_dayLabel(to + 1)}',
                              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      RangeSlider(
                        values: RangeValues(from.toDouble(), to.toDouble()),
                        min: 0,
                        max: maxIdx,
                        divisions: max(1, dim - 1),
                        labels: RangeLabels(_dayLabel(from + 1), _dayLabel(to + 1)),
                        onChanged: (v) => setState(() => _range = RangeValues(v.start, v.end)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                _SummaryGrid(
                  items: [
                    _SummaryItem(icon: Icons.visibility_rounded, title: s.analyticsCardVisits, value: totalVisits),
                    _SummaryItem(icon: Icons.wechat, title: s.analyticsCardWhatsapp, value: totalWhatsApp),
                    _SummaryItem(icon: Icons.shopping_bag_rounded, title: s.analyticsCardProductViews, value: totalProductViews),
                    _SummaryItem(icon: Icons.add_shopping_cart_rounded, title: s.analyticsCardAddToCart, value: totalAddToCart),
                    _SummaryItem(icon: Icons.payments_rounded, title: s.analyticsCardCheckout, value: totalCheckout),
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
                        dayLabel: _dayLabel(from + 1 + peakVisits.index),
                        value: peakVisits.value,
                      ),
                      const SizedBox(height: 8),
                      _PeakRow(
                        icon: Icons.wechat,
                        title: s.analyticsCardWhatsapp,
                        dayLabel: _dayLabel(from + 1 + peakWhats.index),
                        value: peakWhats.value,
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
                  count: visible.length,
                  child: Column(
                    children: visible.reversed.map((e) {
                      // Tag-Nummer aus dayKey (YYYY-MM-DD)
                      final dayNum = int.tryParse(e.dayKey.substring(8, 10)) ?? 0;
                      return _DayRow(
                        dayKey: '${e.dayKey}  (${dayNum})',
                        pageViews: e.pageView,
                        whatsappClicks: e.whatsappClick,
                        productViews: e.productView,
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
}

class _MonthOption {
  final int year;
  final int month;
  const _MonthOption({required this.year, required this.month});

  @override
  bool operator ==(Object other) =>
      other is _MonthOption && other.year == year && other.month == month;

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
  const _Card({required this.title, required this.leading, required this.child});

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
                  style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface),
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
  _SummaryItem({required this.icon, required this.title, required this.value});
}

class _SummaryGrid extends StatelessWidget {
  final List<_SummaryItem> items;
  const _SummaryGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final w = MediaQuery.of(context).size.width;
    final cols = w >= 900 ? 3 : 2;
    const spacing = 12.0;
    final cardW = (w - 16 * 2 - spacing * (cols - 1)) / cols;

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
                    Text(it.title, style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12)),
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
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _ChartCard({required this.title, required this.icon, required this.child});

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
                child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface)),
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
  final int value;

  const _PeakRow({
    required this.icon,
    required this.title,
    required this.dayLabel,
    required this.value,
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
            child: Text(title, style: TextStyle(color: colors.onSurface, fontWeight: FontWeight.w600)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: colors.primary.withValues(alpha: 0.5)),
            ),
            child: Text(
              '${dayLabel} • $value',
              style: TextStyle(color: colors.onPrimaryContainer, fontWeight: FontWeight.w700, fontSize: 12),
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

  const _DaysExpansion({required this.title, required this.count, required this.child});

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
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface)),
        subtitle: Text('$count', style: TextStyle(color: colors.onSurfaceVariant)),
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

  const _DayRow({
    required this.dayKey,
    required this.pageViews,
    required this.whatsappClicks,
    required this.productViews,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(dayKey, style: TextStyle(color: colors.onSurface))),
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
        Text(value.toString(), style: TextStyle(color: colors.onSurface, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

/// Chart mit Achsen + vertikalem Y Label
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
    final c = Theme.of(context).colorScheme;
    return CustomPaint(
      painter: _AxisLineChartPainter(
        values: values,
        xLabels: xLabels,
        color: c.primary,
        grid: c.outlineVariant.withValues(alpha: 0.55),
        text: c.onSurfaceVariant,
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

    const leftPad = 54.0; // mehr Platz wegen vertikalem Y Label
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

    // y grid lines + y ticks
    for (int i = 0; i <= 4; i++) {
      final t = i / 4;
      final y = topPad + h * (1 - t);
      canvas.drawLine(Offset(leftPad, y), Offset(leftPad + w, y), gridPaint);

      final val = (safeMax * t).round();
      _drawText(canvas, val.toString(), Offset(8, y - 7), 11, text);
    }

    // x baseline
    canvas.drawLine(Offset(leftPad, topPad + h), Offset(leftPad + w, topPad + h), gridPaint);

    // x labels: start/mid/end
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

    // X axis label (center bottom)
    _drawText(canvas, axisLabelX, Offset(leftPad + w / 2 - 20, size.height - 18), 11, text);

    // Y axis label (VERTIKAL links)
    canvas.save();
    canvas.translate(14, topPad + h / 2 + 18);
    canvas.rotate(-pi / 2);
    _drawText(canvas, axisLabelY, const Offset(0, 0), 11, text);
    canvas.restore();

    // Line
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

    // Highlight dot
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
        style: TextStyle(fontSize: fontSize, color: color, fontWeight: FontWeight.w600),
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
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface)),
        subtitle: Text(subtitle, style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12)),
        children: [child],
      ),
    );
  }
}