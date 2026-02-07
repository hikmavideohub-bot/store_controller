import 'package:flutter/material.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import '../settings_viewmodel.dart';
import '../../../utils/working_hours.dart';

class WorkingHoursCard extends StatelessWidget {
  final SettingsViewModel vm;

  const WorkingHoursCard({super.key, required this.vm});

  // Die Reihenfolge der Keys
  static const List<String> _weekKeys = [
    'mon',
    'tue',
    'wed',
    'thu',
    'fri',
    'sat',
    'sun',
  ];

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          s.workingHoursTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: const Icon(Icons.access_time),
        childrenPadding: const EdgeInsets.all(16),
        children: _weekKeys
            .map((dayKey) => _buildDayRow(context, dayKey))
            .toList(),
      ),
    );
  }

  Widget _buildDayRow(BuildContext context, String dayKey) {
    // Hier wird der Typ 'WorkingHours' oder die Liste explizit deklariert
    final List<Map<String, dynamic>> periods = vm.workingHours[dayKey] ?? [];
    final isClosed = periods.isEmpty || periods.any((p) => p['closed'] == true);

    return Column(
      children: [
        Row(
          children: [
            // Tag Name
            SizedBox(
              width: 80,
              child: Text(
                _getLocalizedDayName(context, dayKey),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            // Toggle (Geöffnet/Geschlossen)
            Switch(
              value: !isClosed,
              onChanged: (isOpen) {
                final WorkingHours newHours =
                    Map<String, List<Map<String, dynamic>>>.from(
                      vm.workingHours,
                    );

                if (isOpen) {
                  newHours[dayKey] = [
                    {'start': '09:00', 'end': '18:00'},
                  ];
                } else {
                  newHours[dayKey] = [];
                }
                vm.updateWorkingHours(newHours);
              },
            ),
            const Spacer(),
            if (!isClosed)
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  final newHours = Map<String, List<Map<String, dynamic>>>.from(
                    vm.workingHours,
                  );
                  newHours[dayKey] = [
                    ...periods,
                    {'start': '09:00', 'end': '18:00'},
                  ];
                  vm.updateWorkingHours(newHours);
                },
              ),
          ],
        ),

        // Die Zeit-Perioden Liste
        if (!isClosed)
          ...periods.asMap().entries.map((entry) {
            final index = entry.key;
            final period = entry.value;
            final start = period['start'] ?? '09:00';
            final end = period['end'] ?? '18:00';

            return Padding(
              padding: const EdgeInsets.only(bottom: 8, right: 20), // Einrücken
              child: Row(
                children: [
                  _TimeButton(
                    time: start,
                    onTap: () async {
                      final t = await _pickTime(context, start);
                      if (t != null) _updateTime(dayKey, index, 'start', t);
                    },
                  ),
                  const Text(' - '),
                  _TimeButton(
                    time: end,
                    onTap: () async {
                      final t = await _pickTime(context, end);
                      if (t != null) _updateTime(dayKey, index, 'end', t);
                    },
                  ),
                  const Spacer(),
                  // Löschen Button für Periode
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: () {
                      final newHours =
                          Map<String, List<Map<String, dynamic>>>.from(
                            vm.workingHours,
                          );
                      final currentList = List<Map<String, dynamic>>.from(
                        newHours[dayKey]!,
                      );
                      currentList.removeAt(index);
                      newHours[dayKey] = currentList;
                      vm.updateWorkingHours(newHours);
                    },
                  ),
                ],
              ),
            );
          }),
        const Divider(),
      ],
    );
  }

  String _getLocalizedDayName(BuildContext context, String key) {
    final s = AppLocalizations.of(context)!;
    switch (key) {
      case 'mon':
        return s.monday;
      case 'tue':
        return s.tuesday;
      case 'wed':
        return s.wednesday;
      case 'thu':
        return s.thursday;
      case 'fri':
        return s.friday;
      case 'sat':
        return s.saturday;
      case 'sun':
        return s.sunday;
      default:
        return key;
    }
  }

  void _updateTime(String day, int index, String field, String value) {
    final newHours = Map<String, List<Map<String, dynamic>>>.from(
      vm.workingHours,
    );
    final list = List<Map<String, dynamic>>.from(newHours[day]!);
    list[index] = Map.from(list[index])..[field] = value;
    newHours[day] = list;
    vm.updateWorkingHours(newHours);
  }

  Future<String?> _pickTime(BuildContext context, String current) async {
    final parts = current.split(':');
    final initial = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked == null) return null;

    return '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
  }
}

class _TimeButton extends StatelessWidget {
  final String time;
  final VoidCallback onTap;
  const _TimeButton({required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final parts = time.split(':');
    final tod = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
    final formattedTime = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(tod, alwaysUse24HourFormat: false);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          formattedTime,
          textDirection: TextDirection.ltr, // Zeiten immer LTR
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
