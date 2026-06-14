class PeriodTime {
  const PeriodTime({
    required this.period,
    required this.start,
    required this.end,
  });

  final int period;
  final String start;
  final String end;
}

class SemesterSettings {
  const SemesterSettings({
    required this.semesterStartDate,
    required this.periods,
  });

  final DateTime semesterStartDate;
  final List<PeriodTime> periods;
}
