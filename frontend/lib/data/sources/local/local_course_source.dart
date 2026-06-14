import '../../../core/time/app_clock.dart';
import '../../models/course.dart';
import '../../models/settings.dart';
import 'local_json_store.dart';
import 'local_settings_source.dart';

class LocalCourseSource {
  LocalCourseSource({
    this.clock = const AppClock(),
    this.store,
    this.settingsSource,
  }) {
    _restore();
  }

  final AppClock clock;
  final LocalJsonStore? store;
  final LocalSettingsSource? settingsSource;
  final List<Course> _courses = <Course>[];
  final Map<String, String> _colorByName = <String, String>{};

  Future<List<Course>> getCoursesForWeek(int week, {String? semesterId}) async {
    final semester = await _semesterForQuery(semesterId);
    if (semester == null || !semester.containsWeek(week)) {
      return const [];
    }
    return _courses
        .where(
          (course) =>
              course.semesterId == semester.id && course.occursInWeek(week),
        )
        .toList()
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
    final now = clock.now();
    final semester = await _currentSemester(now);
    if (semester == null) {
      return null;
    }
    final currentWeek = semester.weekForDate(now);
    if (!semester.containsWeek(currentWeek)) {
      return null;
    }
    final upcoming =
        _courses
            .where(
              (course) =>
                  course.semesterId == semester.id &&
                  course.occursInWeek(currentWeek),
            )
            .map(
              (course) =>
                  (course: course, startsAt: _nextStartFor(course, now)),
            )
            .toList()
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return upcoming.firstOrNull?.course;
  }

  Future<Course> createCourse(CourseDraft draft) async {
    final now = clock.now();
    final semesterId = await _semesterIdForDraft(draft);
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
      semesterId: semesterId,
      colorKey: colorKeyForCourseName(draft.name),
      source: draft.source,
      createdAt: now,
      updatedAt: now,
    );
    _courses.add(course);
    await _persist();
    return course;
  }

  Future<Course> updateCourse(String courseId, CourseDraft draft) async {
    final index = _courses.indexWhere((course) => course.id == courseId);
    if (index == -1) {
      throw StateError('课程不存在');
    }
    final old = _courses[index];
    final semesterId = await _semesterIdForDraft(draft);
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
      semesterId: semesterId,
      colorKey: colorKeyForCourseName(draft.name),
      source: draft.source,
      updatedAt: clock.now(),
    );
    _courses[index] = updated;
    await _persist();
    return updated;
  }

  Future<void> deleteCourse(String courseId) async {
    _courses.removeWhere((course) => course.id == courseId);
    await _persist();
  }

  Future<Course> cancelCourseForWeek(String courseId, int week) async {
    final index = _courses.indexWhere((course) => course.id == courseId);
    if (index == -1) {
      throw StateError('课程不存在');
    }
    final old = _courses[index];
    final canceledWeeks = {...old.canceledWeeks, week}.toList()..sort();
    final updated = old.copyWith(
      canceledWeeks: canceledWeeks,
      updatedAt: clock.now(),
    );
    _courses[index] = updated;
    await _persist();
    return updated;
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

  void _restore() {
    final data = store?.readMap(LocalStoreKeys.courses);
    if (data == null || data.isEmpty) {
      return;
    }
    final courses = data['courses'] as List? ?? const [];
    _courses
      ..clear()
      ..addAll(
        courses.map((course) => Course.fromJson((course as Map).cast())),
      );
    final colorByName = data['colorByName'] as Map? ?? const {};
    _colorByName
      ..clear()
      ..addAll(colorByName.cast<String, String>());
  }

  Future<void> _persist() async {
    final localStore = store;
    if (localStore == null) {
      return;
    }
    await localStore.writeMap(LocalStoreKeys.courses, {
      'courses': _courses.map((course) => course.toJson()).toList(),
      'colorByName': _colorByName,
    });
  }

  Future<String> _semesterIdForDraft(CourseDraft draft) async {
    if (draft.semesterId != null) {
      return draft.semesterId!;
    }
    final settings = await settingsSource?.getSemesterSettings();
    return settings?.activeSemester.id ?? defaultSemesterTimetable.id;
  }

  Future<SemesterTimetable?> _semesterForQuery(String? semesterId) async {
    final settings = await settingsSource?.getSemesterSettings();
    if (settings == null) {
      return defaultSemesterTimetable;
    }
    if (semesterId != null) {
      return settings.semesterById(semesterId);
    }
    return settings.activeSemester;
  }

  Future<SemesterTimetable?> _currentSemester(DateTime now) async {
    final settings = await settingsSource?.getSemesterSettings();
    final semesters = settings?.semesters ?? [defaultSemesterTimetable];
    if (semesters.isEmpty) {
      return null;
    }
    final inRange =
        semesters.where((semester) {
            final week = semester.weekForDate(now);
            return semester.containsWeek(week);
          }).toList()
          ..sort((a, b) => b.semesterStartDate.compareTo(a.semesterStartDate));
    return inRange.firstOrNull ?? settings?.activeSemester ?? semesters.last;
  }
}

DateTime _nextStartFor(Course course, DateTime now) {
  final period = defaultPeriodTimes
      .where((period) => period.period == course.startPeriod)
      .firstOrNull;
  final parts = (period?.start ?? '00:00').split(':').map(int.parse).toList();
  var daysAhead = course.dayOfWeek - now.weekday;
  if (daysAhead < 0) {
    daysAhead += 7;
  }
  var date = DateTime(
    now.year,
    now.month,
    now.day,
  ).add(Duration(days: daysAhead));
  var startsAt = DateTime(date.year, date.month, date.day, parts[0], parts[1]);
  if (startsAt.isBefore(now)) {
    date = date.add(const Duration(days: 7));
    startsAt = DateTime(date.year, date.month, date.day, parts[0], parts[1]);
  }
  return startsAt;
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
