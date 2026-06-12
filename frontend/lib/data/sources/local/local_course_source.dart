import '../../../core/time/app_clock.dart';
import '../../models/course.dart';

class LocalCourseSource {
  LocalCourseSource({this.clock = const AppClock()});

  final AppClock clock;
  final List<Course> _courses = <Course>[];
  final Map<String, String> _colorByName = <String, String>{};

  Future<List<Course>> getCoursesForWeek(int week) async {
    return _courses.where((course) => course.occursInWeek(week)).toList()
      ..sort((a, b) {
        final dayCompare = a.dayOfWeek.compareTo(b.dayOfWeek);
        if (dayCompare != 0) {
          return dayCompare;
        }
        return a.startPeriod.compareTo(b.startPeriod);
      });
  }

  Future<Course?> getCourseById(String courseId) async {
    return _courses.where((course) => course.id == courseId).firstOrNull;
  }

  Future<Course?> getNextCourse() async {
    final courses = await getCoursesForWeek(1);
    final now = clock.now();
    final today = now.weekday;
    final upcoming = courses.where((course) {
      if (course.dayOfWeek > today) {
        return true;
      }
      if (course.dayOfWeek < today) {
        return false;
      }
      final start = defaultPeriodTimes
          .where((period) => period.period == course.startPeriod)
          .firstOrNull;
      if (start == null) {
        return true;
      }
      final parts = start.start.split(':').map(int.parse).toList();
      final startTime = DateTime(
        now.year,
        now.month,
        now.day,
        parts[0],
        parts[1],
      );
      return !startTime.isBefore(now);
    }).toList();
    return upcoming.isEmpty ? null : upcoming.first;
  }

  Future<Course> createCourse(CourseDraft draft) async {
    final now = clock.now();
    final course = Course(
      id: 'course-${now.microsecondsSinceEpoch}',
      name: draft.name.trim(),
      teacher: draft.teacher.trim(),
      location: draft.location.trim(),
      note: draft.note.trim(),
      dayOfWeek: draft.dayOfWeek,
      startPeriod: draft.startPeriod,
      endPeriod: draft.endPeriod,
      weekRule: draft.weekRule,
      startWeek: draft.startWeek,
      endWeek: draft.endWeek,
      colorKey: colorKeyForCourseName(draft.name),
      source: draft.source,
      createdAt: now,
      updatedAt: now,
    );
    _courses.add(course);
    return course;
  }

  Future<Course> updateCourse(String courseId, CourseDraft draft) async {
    final index = _courses.indexWhere((course) => course.id == courseId);
    if (index == -1) {
      throw StateError('课程不存在');
    }
    final old = _courses[index];
    final updated = old.copyWith(
      name: draft.name.trim(),
      teacher: draft.teacher.trim(),
      location: draft.location.trim(),
      note: draft.note.trim(),
      dayOfWeek: draft.dayOfWeek,
      startPeriod: draft.startPeriod,
      endPeriod: draft.endPeriod,
      weekRule: draft.weekRule,
      startWeek: draft.startWeek,
      endWeek: draft.endWeek,
      colorKey: colorKeyForCourseName(draft.name),
      source: draft.source,
      updatedAt: clock.now(),
    );
    _courses[index] = updated;
    return updated;
  }

  Future<void> deleteCourse(String courseId) async {
    _courses.removeWhere((course) => course.id == courseId);
  }

  String colorKeyForCourseName(String name) {
    final normalized = name.trim();
    if (normalized.isEmpty) {
      return 'blue';
    }
    return _colorByName.putIfAbsent(normalized, () {
      const colorKeys = <String>['blue', 'purple', 'pink'];
      final hash = normalized.codeUnits.fold<int>(
        0,
        (value, unit) => value + unit,
      );
      return colorKeys[hash % colorKeys.length];
    });
  }
}

const defaultPeriodTimes = <PeriodTimeConfig>[
  PeriodTimeConfig(period: 1, start: '08:00', end: '08:50'),
  PeriodTimeConfig(period: 2, start: '09:00', end: '09:50'),
  PeriodTimeConfig(period: 3, start: '10:10', end: '11:00'),
  PeriodTimeConfig(period: 4, start: '11:10', end: '12:00'),
  PeriodTimeConfig(period: 5, start: '14:00', end: '14:50'),
  PeriodTimeConfig(period: 6, start: '15:00', end: '15:50'),
  PeriodTimeConfig(period: 7, start: '16:10', end: '17:00'),
  PeriodTimeConfig(period: 8, start: '17:10', end: '18:00'),
  PeriodTimeConfig(period: 9, start: '18:30', end: '19:20'),
  PeriodTimeConfig(period: 10, start: '19:30', end: '20:20'),
  PeriodTimeConfig(period: 11, start: '20:30', end: '21:20'),
  PeriodTimeConfig(period: 12, start: '21:30', end: '22:20'),
];

class PeriodTimeConfig {
  const PeriodTimeConfig({
    required this.period,
    required this.start,
    required this.end,
  });

  final int period;
  final String start;
  final String end;
}
