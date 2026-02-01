import 'dart:convert';

typedef WorkingHours = Map<String, List<Map<String, dynamic>>>;
// Beispiel: {"mon":[{"start":"09:00","end":"18:00"}], "sun":[{"closed":true}], ...}

WorkingHours workingHoursFromJson(String? raw) {
  if (raw == null) return _emptyWeek();
  final t = raw.trim();
  if (t.isEmpty) return _emptyWeek();

  try {
    final obj = jsonDecode(t);
    if (obj is! Map) return _emptyWeek();

    final out = _emptyWeek();
    for (final k in out.keys) {
      final v = obj[k];
      if (v is List) {
        out[k] = v
            .whereType<Map>()
            .map((m) => Map<String, dynamic>.from(m))
            .toList();
      }
    }
    return out;
  } catch (_) {
    return _emptyWeek();
  }
}

String workingHoursToJson(WorkingHours wh) {
  // فقط نضمن ترتيب مفاتيح الأسبوع
  final out = <String, dynamic>{};
  for (final k in _weekKeys) {
    out[k] = wh[k] ?? [];
  }
  return jsonEncode(out);
}

WorkingHours _emptyWeek() => {
  for (final k in _weekKeys) k: <Map<String, dynamic>>[],
};

const List<String> _weekKeys = [
  'mon',
  'tue',
  'wed',
  'thu',
  'fri',
  'sat',
  'sun',
];

bool isValidHHmm(String s) => RegExp(r'^\d{2}:\d{2}$').hasMatch(s);

int hhmmToMinutes(String hhmm) {
  final parts = hhmm.split(':');
  final h = int.parse(parts[0]);
  final m = int.parse(parts[1]);
  return h * 60 + m;
}
