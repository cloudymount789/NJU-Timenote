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
    required this.schoolYear,
    required this.termType,
    required this.semesterStartDate,
    required this.weekCount,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String schoolYear;
  final SemesterTermType termType;
  final DateTime semesterStartDate;
  final int weekCount;
  final DateTime createdAt;

  String get displayName => '$schoolYear ${termType.label}';

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
      'schoolYear': schoolYear,
      'termType': termType.name,
      'semesterStartDate': _dateOnly(semesterStartDate),
      'weekCount': weekCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SemesterTimetable.fromJson(Map<String, Object?> json) {
    final startDate = DateTime.parse(json['semesterStartDate']! as String);
    final termType = json['termType'] is String
        ? SemesterTermType.values.byName(json['termType']! as String)
        : _termTypeForDate(startDate);
    final schoolYear =
        json['schoolYear'] as String? ?? _schoolYearForDate(startDate);
    return SemesterTimetable(
      id: json['id'] as String? ?? _semesterIdForDate(startDate),
      name: json['name'] as String? ?? _semesterNameFor(schoolYear, termType),
      schoolYear: schoolYear,
      termType: termType,
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
    String? schoolYear,
    SemesterTermType? termType,
    DateTime? semesterStartDate,
    int? weekCount,
    DateTime? createdAt,
  }) {
    final nextSchoolYear = schoolYear ?? this.schoolYear;
    final nextTermType = termType ?? this.termType;
    return SemesterTimetable(
      id: id ?? this.id,
      name: name ?? _semesterNameFor(nextSchoolYear, nextTermType),
      schoolYear: nextSchoolYear,
      termType: nextTermType,
      semesterStartDate: semesterStartDate ?? this.semesterStartDate,
      weekCount: weekCount ?? this.weekCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum SemesterTermType {
  spring('春季学期'),
  autumn('秋季学期');

  const SemesterTermType(this.label);

  final String label;
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
  schoolYear: '2025-2026',
  termType: SemesterTermType.spring,
  semesterStartDate: _defaultSemesterStartDate,
  weekCount: 16,
  createdAt: _defaultSemesterStartDate,
);

final _defaultSemesterStartDate = DateTime(2026, 3, 2);

String _semesterIdForDate(DateTime date) {
  return 'semester-${_dateOnly(date)}';
}

String _semesterNameForDate(DateTime date) {
  return _semesterNameFor(_schoolYearForDate(date), _termTypeForDate(date));
}

String _semesterNameFor(String schoolYear, SemesterTermType termType) {
  return '$schoolYear ${termType.label}';
}

String _schoolYearForDate(DateTime date) {
  if (date.month >= 8) {
    return '${date.year}-${date.year + 1}';
  }
  return '${date.year - 1}-${date.year}';
}

SemesterTermType _termTypeForDate(DateTime date) {
  return date.month <= 7 ? SemesterTermType.spring : SemesterTermType.autumn;
}
