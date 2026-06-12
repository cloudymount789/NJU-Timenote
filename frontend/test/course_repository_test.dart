import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nju_timenote/core/time/app_clock.dart';
import 'package:nju_timenote/data/models/course.dart';
import 'package:nju_timenote/data/sources/local/local_course_source.dart';
import 'package:nju_timenote/features/schedule/schedule_page.dart';

void main() {
  test('Course serializes and deserializes with contract field names', () {
    final now = DateTime.parse('2026-06-12T08:00:00+08:00');
    final course = Course(
      id: 'course-1',
      name: '课程',
      teacher: '老师',
      location: '教室',
      note: '备注',
      dayOfWeek: 1,
      startPeriod: 1,
      endPeriod: 2,
      weekRule: WeekRule.all,
      startWeek: 1,
      endWeek: 16,
      colorKey: 'blue',
      source: CourseSource.manual,
      createdAt: now,
      updatedAt: now,
    );

    final json = course.toJson();
    expect(json['weekRule'], 'all');
    expect(json['source'], 'manual');
    expect(Course.fromJson(json).name, '课程');
  });

  test('local source filters by week rule and keeps stable colors', () async {
    final source = LocalCourseSource();
    final first = await source.createCourse(
      const CourseDraft(
        name: '高等数学',
        teacher: '',
        location: '仙 I-101',
        note: '',
        dayOfWeek: 1,
        startPeriod: 1,
        endPeriod: 2,
        weekRule: WeekRule.odd,
        startWeek: 1,
        endWeek: 5,
      ),
    );
    final second = await source.createCourse(
      const CourseDraft(
        name: '高等数学',
        teacher: '另一位老师',
        location: '仙 I-102',
        note: '',
        dayOfWeek: 3,
        startPeriod: 3,
        endPeriod: 4,
        weekRule: WeekRule.all,
        startWeek: 1,
        endWeek: 25,
      ),
    );

    expect(first.colorKey, second.colorKey);
    expect(await source.getCoursesForWeek(1), hasLength(2));
    expect(await source.getCoursesForWeek(2), hasLength(1));
  });

  test('local course source uses injected clock for timestamps', () async {
    final fixedNow = DateTime(2026, 6, 12, 9, 41);
    final source = LocalCourseSource(clock: FixedAppClock(fixedNow));

    final course = await source.createCourse(
      const CourseDraft(
        name: '课程',
        teacher: '',
        location: '教室',
        note: '',
        dayOfWeek: 5,
        startPeriod: 1,
        endPeriod: 2,
        weekRule: WeekRule.all,
        startWeek: 1,
        endWeek: 16,
      ),
    );

    expect(course.createdAt, fixedNow);
    expect(course.updatedAt, fixedNow);
  });

  test('local course source updates existing course', () async {
    final source = LocalCourseSource();
    final course = await source.createCourse(
      const CourseDraft(
        name: '课程',
        teacher: '',
        location: '教室',
        note: '',
        dayOfWeek: 1,
        startPeriod: 1,
        endPeriod: 2,
        weekRule: WeekRule.all,
        startWeek: 1,
        endWeek: 16,
      ),
    );

    final updated = await source.updateCourse(
      course.id,
      const CourseDraft(
        name: '新课程',
        teacher: '老师',
        location: '新教室',
        note: '备注',
        dayOfWeek: 5,
        startPeriod: 3,
        endPeriod: 4,
        weekRule: WeekRule.even,
        startWeek: 2,
        endWeek: 20,
      ),
    );

    expect(updated.name, '新课程');
    expect((await source.getCourseById(course.id))?.location, '新教室');
    expect(await source.getCoursesForWeek(1), isEmpty);
    expect(await source.getCoursesForWeek(2), hasLength(1));
  });

  test('local course source picks upcoming course by current time', () async {
    final source = LocalCourseSource(
      clock: FixedAppClock(DateTime(2026, 6, 12, 9)),
    );
    await source.createCourse(
      const CourseDraft(
        name: '晚课',
        teacher: '',
        location: 'B',
        note: '',
        dayOfWeek: 5,
        startPeriod: 9,
        endPeriod: 10,
        weekRule: WeekRule.all,
        startWeek: 1,
        endWeek: 16,
      ),
    );
    await source.createCourse(
      const CourseDraft(
        name: '上午课',
        teacher: '',
        location: 'A',
        note: '',
        dayOfWeek: 5,
        startPeriod: 3,
        endPeriod: 4,
        weekRule: WeekRule.all,
        startWeek: 1,
        endWeek: 16,
      ),
    );

    expect((await source.getNextCourse())?.name, '上午课');
  });

  testWidgets('timetable renders spanning and conflicting courses', (
    tester,
  ) async {
    final now = DateTime.now();
    final courses = [
      Course(
        id: 'course-1',
        name: '跨节课程',
        teacher: '',
        location: 'A',
        note: '',
        dayOfWeek: 1,
        startPeriod: 3,
        endPeriod: 6,
        weekRule: WeekRule.all,
        startWeek: 1,
        endWeek: 16,
        colorKey: 'blue',
        source: CourseSource.manual,
        createdAt: now,
        updatedAt: now,
      ),
      Course(
        id: 'course-2',
        name: '冲突课程',
        teacher: '',
        location: 'B',
        note: '',
        dayOfWeek: 1,
        startPeriod: 4,
        endPeriod: 4,
        weekRule: WeekRule.all,
        startWeek: 1,
        endWeek: 16,
        colorKey: 'pink',
        source: CourseSource.manual,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 390,
            height: 700,
            child: TimetableView(
              courses: courses,
              currentDate: DateTime(2026, 6, 12),
              onDeleteCourse: (_) {},
              onOpenCourse: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('跨节课程'), findsWidgets);
    expect(find.text('冲突课程'), findsOneWidget);
  });

  testWidgets('timetable shows period times and highlights today', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 390,
            height: 760,
            child: TimetableView(
              courses: const [],
              currentDate: DateTime(2026, 6, 12),
              todayWeekday: 4,
              onDeleteCourse: (_) {},
              onOpenCourse: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('08:00'), findsOneWidget);
    expect(find.text('08:50'), findsOneWidget);
    final thursday = tester.widget<Text>(find.text('周四'));
    expect(thursday.style?.color, const Color(0xFF0062FF));
  });
}
