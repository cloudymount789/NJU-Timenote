enum WeekRule { all, odd, even }

enum CourseSource { manual, screenshot, sample }

class Course {
  const Course({
    required this.id,
    required this.name,
    required this.teacher,
    required this.location,
    required this.note,
    required this.dayOfWeek,
    required this.startPeriod,
    required this.endPeriod,
    required this.weekRule,
    required this.startWeek,
    required this.endWeek,
    this.semesterId = 'semester-2026-03-02',
    this.canceledWeeks = const [],
    required this.colorKey,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String teacher;
  final String location;
  final String note;
  final int dayOfWeek;
  final int startPeriod;
  final int endPeriod;
  final WeekRule weekRule;
  final int startWeek;
  final int endWeek;
  final String semesterId;
  final List<int> canceledWeeks;
  final String colorKey;
  final CourseSource source;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'teacher': teacher,
      'location': location,
      'note': note,
      'dayOfWeek': dayOfWeek,
      'startPeriod': startPeriod,
      'endPeriod': endPeriod,
      'weekRule': weekRule.name,
      'startWeek': startWeek,
      'endWeek': endWeek,
      'semesterId': semesterId,
      'canceledWeeks': canceledWeeks,
      'colorKey': colorKey,
      'source': source.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Course.fromJson(Map<String, Object?> json) {
    return Course(
      id: json['id'] as String,
      name: json['name'] as String,
      teacher: json['teacher'] as String? ?? '',
      location: json['location'] as String,
      note: json['note'] as String? ?? '',
      dayOfWeek: json['dayOfWeek'] as int,
      startPeriod: json['startPeriod'] as int,
      endPeriod: json['endPeriod'] as int,
      weekRule: WeekRule.values.byName(json['weekRule'] as String),
      startWeek: json['startWeek'] as int,
      endWeek: json['endWeek'] as int,
      semesterId: json['semesterId'] as String? ?? 'semester-2026-03-02',
      canceledWeeks: (json['canceledWeeks'] as List? ?? const [])
          .map((week) => week as int)
          .toList(),
      colorKey: json['colorKey'] as String,
      source: CourseSource.values.byName(json['source'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Course copyWith({
    String? id,
    String? name,
    String? teacher,
    String? location,
    String? note,
    int? dayOfWeek,
    int? startPeriod,
    int? endPeriod,
    WeekRule? weekRule,
    int? startWeek,
    int? endWeek,
    String? semesterId,
    List<int>? canceledWeeks,
    String? colorKey,
    CourseSource? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      teacher: teacher ?? this.teacher,
      location: location ?? this.location,
      note: note ?? this.note,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startPeriod: startPeriod ?? this.startPeriod,
      endPeriod: endPeriod ?? this.endPeriod,
      weekRule: weekRule ?? this.weekRule,
      startWeek: startWeek ?? this.startWeek,
      endWeek: endWeek ?? this.endWeek,
      semesterId: semesterId ?? this.semesterId,
      canceledWeeks: canceledWeeks ?? this.canceledWeeks,
      colorKey: colorKey ?? this.colorKey,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool occursInWeek(int week) {
    if (canceledWeeks.contains(week)) {
      return false;
    }
    if (week < startWeek || week > endWeek) {
      return false;
    }
    return switch (weekRule) {
      WeekRule.all => true,
      WeekRule.odd => week.isOdd,
      WeekRule.even => week.isEven,
    };
  }
}

class CourseDraft {
  const CourseDraft({
    required this.name,
    required this.teacher,
    required this.location,
    required this.note,
    required this.dayOfWeek,
    required this.startPeriod,
    required this.endPeriod,
    required this.weekRule,
    required this.startWeek,
    required this.endWeek,
    this.semesterId,
    this.source = CourseSource.manual,
  });

  final String name;
  final String teacher;
  final String location;
  final String note;
  final int dayOfWeek;
  final int startPeriod;
  final int endPeriod;
  final WeekRule weekRule;
  final int startWeek;
  final int endWeek;
  final String? semesterId;
  final CourseSource source;
}
