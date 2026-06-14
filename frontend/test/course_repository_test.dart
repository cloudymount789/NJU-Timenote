import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nju_timenote/core/time/app_clock.dart';
import 'package:nju_timenote/data/models/course.dart';
import 'package:nju_timenote/data/models/settings.dart';
import 'package:nju_timenote/data/sources/local/local_course_source.dart';
import 'package:nju_timenote/data/sources/local/local_settings_source.dart';
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
    expect(json['semesterId'], 'semester-2026-03-02');
    expect(Course.fromJson(json).name, '课程');
  });

  test('default semester starts on 2026-03-02 and lasts 16 weeks', () async {
    final settings = await LocalSettingsSource().getSemesterSettings();

    expect(settings.semesters, hasLength(1));
    expect(settings.activeSemester.semesterStartDate, DateTime(2026, 3, 2));
    expect(settings.activeSemester.weekCount, 16);
    expect(settings.activeSemester.name, '2025-2026学年第二学期');
  });

  test('semester calculates current week from start date', () {
    expect(defaultSemesterTimetable.weekForDate(DateTime(2026, 3, 2)), 1);
    expect(defaultSemesterTimetable.weekForDate(DateTime(2026, 3, 8)), 1);
    expect(defaultSemesterTimetable.weekForDate(DateTime(2026, 3, 9)), 2);
  });

  test('semester name suggestion follows academic year term rules', () {
    expect(
      suggestedSemesterName('2025-2026', SemesterTermType.autumn),
      '2025-2026学年第一学期',
    );
    expect(
      suggestedSemesterName('2025-2026', SemesterTermType.spring),
      '2025-2026学年第二学期',
    );
  });

  test('local settings source creates updates deletes semesters', () async {
    final source = LocalSettingsSource(
      clock: FixedAppClock(DateTime(2026, 7, 1, 9)),
    );

    final added = await source.addSemesterTimetable(
      startDate: DateTime(2026, 9, 7),
      weekCount: 20,
      schoolYear: '2026-2027',
      termType: SemesterTermType.autumn,
    );
    expect((await source.getSemesterSettings()).semesters, hasLength(2));
    expect(added.displayName, '2026-2027学年第一学期');

    await source.updateSemesterTimetable(
      added.copyWith(weekCount: 18, termType: SemesterTermType.spring),
    );
    var settings = await source.getSemesterSettings();
    expect(settings.semesterById(added.id)?.weekCount, 18);
    expect(settings.semesterById(added.id)?.displayName, '2026-2027学年第二学期');

    await source.deleteSemesterTimetable(added.id);
    settings = await source.getSemesterSettings();
    expect(settings.semesterById(added.id), isNull);
    expect(settings.semesters, hasLength(1));
  });

  test('local settings source rejects overlapping semester ranges', () async {
    final source = LocalSettingsSource();

    expect(
      () => source.addSemesterTimetable(
        startDate: DateTime(2026, 3, 9),
        weekCount: 16,
      ),
      throwsA(isA<StateError>()),
    );
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

  test('course source hides courses outside semester week count', () async {
    final settingsSource = LocalSettingsSource();
    final source = LocalCourseSource(settingsSource: settingsSource);

    await source.createCourse(
      const CourseDraft(
        name: '超长课程',
        teacher: '',
        location: 'A',
        note: '',
        dayOfWeek: 1,
        startPeriod: 1,
        endPeriod: 2,
        weekRule: WeekRule.all,
        startWeek: 1,
        endWeek: 25,
      ),
    );

    expect(await source.getCoursesForWeek(16), hasLength(1));
    expect(await source.getCoursesForWeek(17), isEmpty);
  });

  test('course source filters by semester and canceled weeks', () async {
    final settingsSource = LocalSettingsSource(
      clock: FixedAppClock(DateTime(2026, 7, 1, 9)),
    );
    final source = LocalCourseSource(settingsSource: settingsSource);
    final autumn = await settingsSource.addSemesterTimetable(
      startDate: DateTime(2026, 9, 7),
      weekCount: 16,
      schoolYear: '2026-2027',
      termType: SemesterTermType.autumn,
    );

    final springCourse = await source.createCourse(
      const CourseDraft(
        name: '春季课程',
        teacher: '',
        location: 'A',
        note: '',
        dayOfWeek: 1,
        startPeriod: 1,
        endPeriod: 2,
        weekRule: WeekRule.all,
        startWeek: 1,
        endWeek: 16,
        semesterId: 'semester-2026-03-02',
      ),
    );
    await source.createCourse(
      CourseDraft(
        name: '秋季课程',
        teacher: '',
        location: 'B',
        note: '',
        dayOfWeek: 1,
        startPeriod: 1,
        endPeriod: 2,
        weekRule: WeekRule.all,
        startWeek: 1,
        endWeek: 16,
        semesterId: autumn.id,
      ),
    );

    expect(
      (await source.getCoursesForWeek(1, semesterId: autumn.id)).single.name,
      '秋季课程',
    );
    expect(
      (await source.getCoursesForWeek(
        1,
        semesterId: 'semester-2026-03-02',
      )).single.name,
      '春季课程',
    );

    await source.cancelCourseForWeek(springCourse.id, 1);
    expect(
      await source.getCoursesForWeek(1, semesterId: 'semester-2026-03-02'),
      isEmpty,
    );
    expect(
      await source.getCoursesForWeek(2, semesterId: 'semester-2026-03-02'),
      hasLength(1),
    );
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

  testWidgets('timetable splits courses across evening boundary', (
    tester,
  ) async {
    final now = DateTime.now();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 390,
            height: 760,
            child: TimetableView(
              courses: [
                Course(
                  id: 'course-evening',
                  name: '晚间跨段',
                  teacher: '',
                  location: 'A',
                  note: '',
                  dayOfWeek: 2,
                  startPeriod: 7,
                  endPeriod: 9,
                  weekRule: WeekRule.all,
                  startWeek: 1,
                  endWeek: 16,
                  colorKey: 'purple',
                  source: CourseSource.manual,
                  createdAt: now,
                  updatedAt: now,
                ),
              ],
              currentDate: DateTime(2026, 6, 12),
              onDeleteCourse: (_) {},
              onOpenCourse: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('晚间跨段'), findsNWidgets(2));
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
