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
  final String colorKey;
  final CourseSource source;
  final DateTime createdAt;
  final DateTime updatedAt;
}
