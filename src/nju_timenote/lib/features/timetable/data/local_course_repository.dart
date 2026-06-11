import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../models/course.dart';
import '../repositories/course_repository.dart';

class LocalCourseRepository implements CourseRepository {
  LocalCourseRepository(this._db, [this._uuid = const Uuid()]);

  final AppDatabase _db;
  final Uuid _uuid;

  @override
  Future<List<Course>> fetchCourses({required int week}) async {
    if (week < 1 || week > 25) {
      throw ArgumentError.value(week, 'week', 'must be between 1 and 25');
    }

    final query = _db.select(_db.courseRows)
      ..where(
        (row) =>
            row.deletedAt.isNull() &
            row.startWeek.isSmallerOrEqualValue(week) &
            row.endWeek.isBiggerOrEqualValue(week) &
            (row.weekRule.equals('all') |
                row.weekRule.equals(week.isOdd ? 'odd' : 'even')),
      )
      ..orderBy([
        (row) => OrderingTerm(expression: row.dayOfWeek),
        (row) => OrderingTerm(expression: row.startPeriod),
        (row) => OrderingTerm(expression: row.endPeriod),
        (row) => OrderingTerm(expression: row.name),
      ]);

    return (await query.get()).map(_toModel).toList();
  }

  @override
  Future<Course> addCourse(CourseDraft draft) {
    _validateDraft(draft);
    return _insert(draft);
  }

  @override
  Future<Course> updateCourse(String courseId, CourseDraft draft) async {
    _validateDraft(draft);
    final row = await (_db.select(_db.courseRows)
      ..where((r) => r.id.equals(courseId))).getSingleOrNull();
    if (row == null) throw StateError('Course not found: $courseId');

    final now = DateTime.now().toUtc();
    await (_db.update(_db.courseRows)..where((r) => r.id.equals(courseId)))
        .write(
      CourseRowsCompanion(
        name: Value(draft.name.trim()),
        teacher: Value(draft.teacher.trim()),
        location: Value(draft.location.trim()),
        note: Value(draft.note.trim()),
        dayOfWeek: Value(draft.dayOfWeek),
        startPeriod: Value(draft.startPeriod),
        endPeriod: Value(draft.endPeriod),
        weekRule: Value(draft.weekRule.name),
        startWeek: Value(draft.startWeek),
        endWeek: Value(draft.endWeek),
        colorKey: Value(_colorKey(draft.name)),
        updatedAt: Value(now),
        localRevision: Value(row.localRevision + 1),
      ),
    );

    return Course(
      id: row.id,
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
      colorKey: _colorKey(draft.name),
      source: CourseSource.values.byName(row.source),
      createdAt: row.createdAt,
      updatedAt: now,
    );
  }

  @override
  Future<void> deleteCourse(String courseId) async {
    final row = await (_db.select(_db.courseRows)
      ..where((r) => r.id.equals(courseId))).getSingleOrNull();

    if (row == null) return;

    // Physical delete for never-synced records; tombstone for synced ones
    if (row.serverRevision == null) {
      await (_db.delete(_db.courseRows)
        ..where((r) => r.id.equals(courseId))).go();
    } else {
      final now = DateTime.now().toUtc();
      await (_db.update(_db.courseRows)
        ..where((r) => r.id.equals(courseId))).write(
        CourseRowsCompanion(
          updatedAt: Value(now),
          deletedAt: Value(now),
          syncStatus: const Value('pendingDelete'),
          localRevision: Value(row.localRevision + 1),
        ),
      );
    }
  }

  @override
  Future<List<Course>> importCoursesFromScreenshot() {
    return _db.transaction(() async {
      final results = <Course>[];
      for (final draft in _screenshotPlaceholders) {
        results.add(await _insert(draft));
      }
      return results;
    });
  }

  // ── helpers ─────────────────────────────────────────────────────

  Future<Course> _insert(CourseDraft draft) async {
    final now = DateTime.now().toUtc();
    final course = Course(
      id: 'course-${_uuid.v4()}',
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
      colorKey: _colorKey(draft.name),
      source: draft.source,
      createdAt: now,
      updatedAt: now,
    );
    await _db.into(_db.courseRows).insert(_toCompanion(course));
    return course;
  }

  void _validateDraft(CourseDraft d) {
    if (d.name.trim().isEmpty) {
      throw ArgumentError.value(d.name, 'name', 'must not be empty');
    }
    if (d.location.trim().isEmpty) {
      throw ArgumentError.value(d.location, 'location', 'must not be empty');
    }
    if (d.dayOfWeek < 1 || d.dayOfWeek > 7) {
      throw ArgumentError.value(d.dayOfWeek, 'dayOfWeek', 'must be 1-7');
    }
    if (d.startPeriod < 1 ||
        d.endPeriod > 12 ||
        d.startPeriod > d.endPeriod) {
      throw ArgumentError('period range must be 1-12 and start ≤ end');
    }
    if (d.startWeek < 1 || d.endWeek > 25 || d.startWeek > d.endWeek) {
      throw ArgumentError('week range must be 1-25 and start ≤ end');
    }
  }

  Course _toModel(CourseRow r) => Course(
    id: r.id,
    name: r.name,
    teacher: r.teacher,
    location: r.location,
    note: r.note,
    dayOfWeek: r.dayOfWeek,
    startPeriod: r.startPeriod,
    endPeriod: r.endPeriod,
    weekRule: WeekRule.values.byName(r.weekRule),
    startWeek: r.startWeek,
    endWeek: r.endWeek,
    colorKey: r.colorKey,
    source: CourseSource.values.byName(r.source),
    createdAt: r.createdAt,
    updatedAt: r.updatedAt,
  );

  CourseRowsCompanion _toCompanion(Course c) => CourseRowsCompanion.insert(
    id: c.id,
    name: c.name,
    teacher: c.teacher,
    location: c.location,
    note: c.note,
    dayOfWeek: c.dayOfWeek,
    startPeriod: c.startPeriod,
    endPeriod: c.endPeriod,
    weekRule: c.weekRule.name,
    startWeek: c.startWeek,
    endWeek: c.endWeek,
    colorKey: c.colorKey,
    source: c.source.name,
    createdAt: c.createdAt,
    updatedAt: c.updatedAt,
  );

  static String _colorKey(String name) {
    const keys = ['blue', 'purple', 'pink', 'indigo'];
    return keys[name.runes.fold(0, (s, r) => s + r) % keys.length];
  }
}

const _screenshotPlaceholders = [
  CourseDraft(
    name: '软件工程',
    teacher: '陈老师',
    location: '仙林 B406',
    note: '由课表截图识别',
    dayOfWeek: 5,
    startPeriod: 3,
    endPeriod: 4,
    weekRule: WeekRule.all,
    startWeek: 1,
    endWeek: 16,
    source: CourseSource.screenshot,
  ),
  CourseDraft(
    name: '人工智能导论',
    teacher: '李老师',
    location: '鼓楼 逸夫楼',
    note: '由课表截图识别',
    dayOfWeek: 2,
    startPeriod: 9,
    endPeriod: 10,
    weekRule: WeekRule.all,
    startWeek: 1,
    endWeek: 16,
    source: CourseSource.screenshot,
  ),
];
