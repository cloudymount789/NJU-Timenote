import '../../models/course.dart';

class LocalCourseSource {
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

  Future<Course?> getNextCourse() async {
    final courses = await getCoursesForWeek(1);
    return courses.isEmpty ? null : courses.first;
  }

  Future<Course> createCourse(CourseDraft draft) async {
    final now = DateTime.now();
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
