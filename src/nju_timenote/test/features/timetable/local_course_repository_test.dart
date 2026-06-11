import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nju_timenote/core/database/app_database.dart';
import 'package:nju_timenote/features/timetable/data/local_course_repository.dart';
import 'package:nju_timenote/features/timetable/models/course.dart';

void main() {
  group('LocalCourseRepository', () {
    late AppDatabase db;
    late LocalCourseRepository repo;

    setUp(() {
      db = AppDatabase(executor: NativeDatabase.memory(), seedData: false);
      repo = LocalCourseRepository(db);
    });

    tearDown(() => db.close());

    test('adds and fetches courses filtered by week and weekRule', () async {
      // odd-week course
      await repo.addCourse(const CourseDraft(
        name: '奇数周课程',
        teacher: '',
        location: '教室A',
        note: '',
        dayOfWeek: 1,
        startPeriod: 1,
        endPeriod: 2,
        weekRule: WeekRule.odd,
        startWeek: 1,
        endWeek: 16,
      ));
      // even-week course
      await repo.addCourse(const CourseDraft(
        name: '偶数周课程',
        teacher: '',
        location: '教室B',
        note: '',
        dayOfWeek: 2,
        startPeriod: 3,
        endPeriod: 4,
        weekRule: WeekRule.even,
        startWeek: 1,
        endWeek: 16,
      ));

      final week5 = await repo.fetchCourses(week: 5);
      expect(week5.map((c) => c.name), ['奇数周课程']);

      final week6 = await repo.fetchCourses(week: 6);
      expect(week6.map((c) => c.name), ['偶数周课程']);
    });

    test('rejects invalid course', () async {
      expect(
        () => repo.addCourse(const CourseDraft(
          name: '',
          teacher: '',
          location: '教室',
          note: '',
          dayOfWeek: 1,
          startPeriod: 4,
          endPeriod: 2,
          weekRule: WeekRule.all,
          startWeek: 1,
          endWeek: 16,
        )),
        throwsArgumentError,
      );
    });

    test('uses UUID-format IDs', () async {
      final course = await repo.addCourse(const CourseDraft(
        name: '测试',
        teacher: '',
        location: '教室',
        note: '',
        dayOfWeek: 1,
        startPeriod: 1,
        endPeriod: 1,
        weekRule: WeekRule.all,
        startWeek: 1,
        endWeek: 16,
      ));
      expect(course.id, startsWith('course-'));
      expect(course.id.length, greaterThan(10));
    });

    test('deleting unsynced course removes it physically', () async {
      final course = await repo.addCourse(const CourseDraft(
        name: '待删除',
        teacher: '',
        location: '教室',
        note: '',
        dayOfWeek: 3,
        startPeriod: 1,
        endPeriod: 1,
        weekRule: WeekRule.all,
        startWeek: 1,
        endWeek: 16,
      ));

      await repo.deleteCourse(course.id);

      final after = await repo.fetchCourses(week: 3);
      expect(after.where((c) => c.id == course.id), isEmpty);

      final rows = await db.select(db.courseRows).get();
      expect(rows.where((r) => r.id == course.id), isEmpty);
    });

    test('sample courses are seeded on first creation', () async {
      final seededDb = AppDatabase(
        executor: NativeDatabase.memory(),
        seedData: true,
      );
      addTearDown(seededDb.close);
      final seededRepo = LocalCourseRepository(seededDb);

      final courses = await seededRepo.fetchCourses(week: 6);
      expect(courses.length, greaterThanOrEqualTo(10));
    });
  });
}
