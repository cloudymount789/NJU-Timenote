class SemesterSettings {
  const SemesterSettings({
    required this.semesterStartDate,
    required this.periods,
  });

  final DateTime semesterStartDate;
  final List<PeriodTime> periods;

  Map<String, Object?> toJson() {
    return {
      'semesterStartDate': _dateOnly(semesterStartDate),
      'periods': periods.map((period) => period.toJson()).toList(),
    };
  }

  factory SemesterSettings.fromJson(Map<String, Object?> json) {
    return SemesterSettings(
      semesterStartDate: DateTime.parse(json['semesterStartDate']! as String),
      periods: (json['periods'] as List? ?? const [])
          .map((period) => PeriodTime.fromJson((period as Map).cast()))
          .toList(),
    );
  }
}

class PeriodTime {
  const PeriodTime({
    required this.period,
    required this.start,
    required this.end,
  });

  final int period;
  final String start;
  final String end;

  Map<String, Object?> toJson() {
    return {'period': period, 'start': start, 'end': end};
  }

  factory PeriodTime.fromJson(Map<String, Object?> json) {
    return PeriodTime(
      period: json['period']! as int,
      start: json['start']! as String,
      end: json['end']! as String,
    );
  }
}

String _dateOnly(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
