class SemesterSettings {
  const SemesterSettings({
    required this.semesters,
    required this.periods,
    this.lastSelectedSemesterId,
  });

  final List<SemesterTimetable> semesters;
  final List<PeriodTime> periods;
  final String? lastSelectedSemesterId;

  DateTime get semesterStartDate => activeSemester.semesterStartDate;

  SemesterTimetable get activeSemester {
    if (lastSelectedSemesterId != null) {
      final selected = semesterById(lastSelectedSemesterId!);
      if (selected != null) {
        return selected;
      }
    }
    return latestSemester ?? defaultSemesterTimetable;
  }

  SemesterTimetable? get latestSemester {
    if (semesters.isEmpty) {
      return null;
    }
    final sorted = [...semesters]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.first;
  }

  SemesterTimetable? semesterById(String id) {
    return semesters.where((semester) => semester.id == id).firstOrNull;
  }

  Map<String, Object?> toJson() {
    return {
      'semesterStartDate': _dateOnly(semesterStartDate),
      'semesters': semesters.map((semester) => semester.toJson()).toList(),
      'periods': periods.map((period) => period.toJson()).toList(),
      'lastSelectedSemesterId': lastSelectedSemesterId,
    };
  }

  factory SemesterSettings.fromJson(Map<String, Object?> json) {
    final semesters = (json['semesters'] as List? ?? const [])
        .map((semester) => SemesterTimetable.fromJson((semester as Map).cast()))
        .toList();
    if (semesters.isEmpty && json['semesterStartDate'] is String) {
      final startDate = DateTime.parse(json['semesterStartDate']! as String);
      semesters.add(
        defaultSemesterTimetable.copyWith(
          id: _semesterIdForDate(startDate),
          name: _semesterNameForDate(startDate),
          semesterStartDate: startDate,
        ),
      );
    }
    return SemesterSettings(
      semesters: semesters,
      periods: (json['periods'] as List? ?? const [])
          .map((period) => PeriodTime.fromJson((period as Map).cast()))
          .toList(),
      lastSelectedSemesterId: json['lastSelectedSemesterId'] as String?,
    );
  }

  SemesterSettings copyWith({
    List<SemesterTimetable>? semesters,
    List<PeriodTime>? periods,
    String? lastSelectedSemesterId,
  }) {
    return SemesterSettings(
      semesters: semesters ?? this.semesters,
      periods: periods ?? this.periods,
      lastSelectedSemesterId:
          lastSelectedSemesterId ?? this.lastSelectedSemesterId,
    );
  }
}

class SemesterTimetable {
  const SemesterTimetable({
    required this.id,
    required this.name,
    required this.semesterStartDate,
    required this.weekCount,
    required this.createdAt,
  });

  final String id;
  final String name;
  final DateTime semesterStartDate;
  final int weekCount;
  final DateTime createdAt;

  DateTime get semesterEndDate {
    return semesterStartDate.add(Duration(days: weekCount * 7 - 1));
  }

  int weekForDate(DateTime date) {
    final start = DateTime(
      semesterStartDate.year,
      semesterStartDate.month,
      semesterStartDate.day,
    );
    final target = DateTime(date.year, date.month, date.day);
    return target.difference(start).inDays ~/ 7 + 1;
  }

  bool containsWeek(int week) {
    return week >= 1 && week <= weekCount;
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'semesterStartDate': _dateOnly(semesterStartDate),
      'weekCount': weekCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SemesterTimetable.fromJson(Map<String, Object?> json) {
    final startDate = DateTime.parse(json['semesterStartDate']! as String);
    return SemesterTimetable(
      id: json['id'] as String? ?? _semesterIdForDate(startDate),
      name: json['name'] as String? ?? _semesterNameForDate(startDate),
      semesterStartDate: startDate,
      weekCount: json['weekCount'] as int? ?? 16,
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt']! as String)
          : startDate,
    );
  }

  SemesterTimetable copyWith({
    String? id,
    String? name,
    DateTime? semesterStartDate,
    int? weekCount,
    DateTime? createdAt,
  }) {
    return SemesterTimetable(
      id: id ?? this.id,
      name: name ?? this.name,
      semesterStartDate: semesterStartDate ?? this.semesterStartDate,
      weekCount: weekCount ?? this.weekCount,
      createdAt: createdAt ?? this.createdAt,
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

final defaultSemesterTimetable = SemesterTimetable(
  id: 'semester-2026-03-02',
  name: '2026 春季学期',
  semesterStartDate: _defaultSemesterStartDate,
  weekCount: 16,
  createdAt: _defaultSemesterStartDate,
);

final _defaultSemesterStartDate = DateTime(2026, 3, 2);

String _semesterIdForDate(DateTime date) {
  return 'semester-${_dateOnly(date)}';
}

String _semesterNameForDate(DateTime date) {
  final season = date.month <= 7 ? '春季学期' : '秋季学期';
  return '${date.year} $season';
}
