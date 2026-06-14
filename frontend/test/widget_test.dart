import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nju_timenote/app/app.dart';
import 'package:nju_timenote/app/router.dart';
import 'package:nju_timenote/core/time/app_clock.dart';
import 'package:nju_timenote/data/models/course.dart';
import 'package:nju_timenote/data/models/recommendation.dart';
import 'package:nju_timenote/data/models/settings.dart';
import 'package:nju_timenote/data/models/todo.dart';
import 'package:nju_timenote/data/repositories/app_repositories.dart';
import 'package:nju_timenote/data/repositories/repository_factory.dart';
import 'package:nju_timenote/features/home/home_page.dart';
import 'package:nju_timenote/features/recommendation/next_thing_page.dart';
import 'package:nju_timenote/features/schedule/manual_course_page.dart';
import 'package:nju_timenote/features/schedule/schedule_page.dart';
import 'package:nju_timenote/features/settings/semester_pages.dart';
import 'package:nju_timenote/features/todo/todo_detail_page.dart';
import 'package:nju_timenote/features/todo/todo_list_page.dart';

void main() {
  testWidgets('starts on home and opens settings', (tester) async {
    await tester.pumpWidget(
      TimenoteApp(repositories: RepositoryFactory.local()),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('今天也要加油啊'), findsOneWidget);
    expect(find.text('下一节课'), findsOneWidget);
    expect(find.text('下一件事'), findsOneWidget);
    expect(find.text('DDL 提醒'), findsOneWidget);

    await tester.tap(find.byTooltip('设置'));
    await tester.pumpAndSettle();

    expect(find.text('设置'), findsOneWidget);
    expect(find.text('课表与作息'), findsOneWidget);
    expect(find.text('数据与分享'), findsOneWidget);
  });

  testWidgets('home can open create todo sheet', (tester) async {
    await tester.pumpWidget(
      TimenoteApp(repositories: RepositoryFactory.local()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('智能一句话添加待办...'));
    await tester.pumpAndSettle();

    expect(find.text('创建待办'), findsOneWidget);
    expect(find.text('手动创建待办'), findsOneWidget);
  });

  testWidgets('deadline card opens the default todo list', (tester) async {
    await tester.pumpWidget(
      TimenoteApp(repositories: RepositoryFactory.local()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('DDL 提醒'));
    await tester.pumpAndSettle();

    expect(find.text('待办'), findsOneWidget);
    expect(find.text('暂无待办'), findsOneWidget);
  });

  testWidgets('creating a todo from list detail refreshes visible list', (
    tester,
  ) async {
    final repositories = RepositoryFactory.local();
    await tester.pumpWidget(
      _ScopedTestApp(repositories: repositories, home: const TodoListPage()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('添加待办'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '标题'), '新待办');
    await tester.ensureVisible(find.text('保存'));
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('新待办'), findsOneWidget);
  });

  testWidgets(
    'batch cancel selected clears current selection without select all',
    (tester) async {
      final repositories = RepositoryFactory.local();
      await repositories.todos.createTodo(const TodoDraft(title: '第一件事'));
      await repositories.todos.createTodo(const TodoDraft(title: '第二件事'));

      await tester.pumpWidget(
        _ScopedTestApp(repositories: repositories, home: const TodoListPage()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('批量操作'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('第一件事'));
      await tester.pumpAndSettle();

      expect(find.text('取消选中'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      await tester.tap(find.text('取消选中'));
      await tester.pumpAndSettle();

      expect(find.text('全选'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing);

      await tester.tap(find.text('全选'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsNWidgets(2));
    },
  );

  testWidgets('todo detail tag row opens tag selection with or without tags', (
    tester,
  ) async {
    final repositories = RepositoryFactory.local();
    await tester.pumpWidget(
      _ScopedTestApp(
        repositories: repositories,
        home: const TodoDetailPage(isCreate: true),
      ),
    );
    await tester.pumpAndSettle();

    final tagPicker = find.byKey(const ValueKey('todo-tag-picker'));
    await tester.ensureVisible(tagPicker);
    await tester.tap(tagPicker);
    await tester.pumpAndSettle();

    expect(find.text('选择 Tag'), findsOneWidget);
    await tester.tap(find.text('完成'));
    await tester.pumpAndSettle();

    final created = await repositories.todos.createTodo(
      const TodoDraft(title: '带 tag', tags: ['作业']),
    );
    await tester.pumpWidget(
      _ScopedTestApp(
        repositories: repositories,
        home: TodoDetailPage(isCreate: false, todoId: created.id),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(tagPicker);
    await tester.tap(tagPicker);
    await tester.pumpAndSettle();

    expect(find.text('选择 Tag'), findsOneWidget);
  });

  testWidgets('home renders real next course todo and deadline data', (
    tester,
  ) async {
    final fixedNow = DateTime(2026, 6, 12, 9);
    final repositories = RepositoryFactory.local(FixedAppClock(fixedNow));
    await repositories.courses.createCourse(
      const CourseDraft(
        name: '数据结构',
        teacher: '王老师',
        location: '仙 I-101',
        note: '',
        dayOfWeek: 5,
        startPeriod: 5,
        endPeriod: 6,
        weekRule: WeekRule.all,
        startWeek: 1,
        endWeek: 16,
      ),
    );
    await repositories.todos.createTodo(
      TodoDraft(
        title: '预习课程',
        kind: TodoKind.duration,
        startAt: DateTime(2026, 6, 12, 10),
        endAt: DateTime(2026, 6, 12, 11),
      ),
    );
    await repositories.todos.createTodo(
      TodoDraft(
        title: '提交实验报告',
        kind: TodoKind.deadline,
        deadlineAt: DateTime(2026, 6, 13, 23, 59),
      ),
    );

    await tester.pumpWidget(
      _ScopedTestApp(
        repositories: repositories,
        clock: FixedAppClock(fixedNow),
        home: const HomePage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('数据结构'), findsOneWidget);
    expect(find.text('预习课程'), findsOneWidget);
    expect(find.text('提交实验报告'), findsOneWidget);
  });

  testWidgets('schedule opens on computed semester week', (tester) async {
    final fixedNow = DateTime(2026, 3, 10, 9);
    final repositories = RepositoryFactory.local(FixedAppClock(fixedNow));
    await repositories.courses.createCourse(
      const CourseDraft(
        name: '第二周课程',
        teacher: '',
        location: '仙 I-101',
        note: '',
        dayOfWeek: 2,
        startPeriod: 3,
        endPeriod: 4,
        weekRule: WeekRule.all,
        startWeek: 2,
        endWeek: 2,
      ),
    );

    await tester.pumpWidget(
      _ScopedTestApp(
        repositories: repositories,
        clock: FixedAppClock(fixedNow),
        home: const SchedulePage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('第 2 周'), findsOneWidget);
    expect(find.text('第二周课程'), findsOneWidget);
  });

  testWidgets('manual course week picker follows semester week count', (
    tester,
  ) async {
    final repositories = RepositoryFactory.local();

    await tester.pumpWidget(
      _ScopedTestApp(
        repositories: repositories,
        home: const ManualCoursePage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1-16周 全部'), findsOneWidget);

    await tester.tap(find.text('1-16周 全部'));
    await tester.pumpAndSettle();

    expect(find.text('选择上课周次'), findsOneWidget);
    expect(find.text('16'), findsOneWidget);
    expect(find.text('25'), findsNothing);
  });

  testWidgets('semester detail uses generated name as card title', (
    tester,
  ) async {
    await tester.pumpWidget(
      _ScopedTestApp(
        repositories: RepositoryFactory.local(),
        home: const SemesterDetailPage(semesterId: 'semester-2026-03-02'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('我的2025-2026学年第二学期课表'), findsOneWidget);
    expect(find.text('课表名称'), findsNothing);
  });

  testWidgets(
    'manual course semester picker handles long names on narrow width',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 780));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final repositories = RepositoryFactory.local();

      await tester.pumpWidget(
        _ScopedTestApp(
          repositories: repositories,
          home: const ManualCoursePage(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('添加至'));
      await tester.pumpAndSettle();

      expect(find.text('添加至学期'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('schedule pull refresh reloads course data', (tester) async {
    final fixedNow = DateTime(2026, 3, 10, 9);
    final repositories = RepositoryFactory.local(FixedAppClock(fixedNow));

    await tester.pumpWidget(
      _ScopedTestApp(
        repositories: repositories,
        clock: FixedAppClock(fixedNow),
        home: const SchedulePage(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('刷新后课程'), findsNothing);

    await repositories.courses.createCourse(
      const CourseDraft(
        name: '刷新后课程',
        teacher: '',
        location: '仙 I-101',
        note: '',
        dayOfWeek: 2,
        startPeriod: 3,
        endPeriod: 4,
        weekRule: WeekRule.all,
        startWeek: 2,
        endWeek: 2,
      ),
    );

    await tester.drag(find.byType(CustomScrollView), const Offset(0, 320));
    await tester.pumpAndSettle();

    expect(find.text('刷新后课程'), findsOneWidget);
  });

  testWidgets('schedule switches semesters and refreshes courses', (
    tester,
  ) async {
    final fixedNow = DateTime(2026, 3, 10, 9);
    final repositories = RepositoryFactory.local(FixedAppClock(fixedNow));
    final autumn = await repositories.settings.addSemesterTimetable(
      startDate: DateTime(2026, 9, 7),
      weekCount: 16,
      schoolYear: '2026-2027',
      termType: SemesterTermType.autumn,
    );
    await repositories.settings.setLastSelectedSemesterId(
      'semester-2026-03-02',
    );
    await repositories.courses.createCourse(
      const CourseDraft(
        name: '春季课程',
        teacher: '',
        location: '仙 I-101',
        note: '',
        dayOfWeek: 2,
        startPeriod: 3,
        endPeriod: 4,
        weekRule: WeekRule.all,
        startWeek: 2,
        endWeek: 2,
        semesterId: 'semester-2026-03-02',
      ),
    );
    await repositories.courses.createCourse(
      CourseDraft(
        name: '秋季课程',
        teacher: '',
        location: '仙 I-102',
        note: '',
        dayOfWeek: 1,
        startPeriod: 1,
        endPeriod: 2,
        weekRule: WeekRule.all,
        startWeek: 1,
        endWeek: 1,
        semesterId: autumn.id,
      ),
    );

    await tester.pumpWidget(
      _ScopedTestApp(
        repositories: repositories,
        clock: FixedAppClock(fixedNow),
        home: const SchedulePage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('春季课程'), findsOneWidget);
    expect(find.text('秋季课程'), findsNothing);

    await tester.tap(find.text('我的2025-2026学年第二学期课表'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('我的2026-2027学年第一学期课表').last);
    await tester.pumpAndSettle();

    expect(find.text('第 1 周'), findsOneWidget);
    expect(find.text('秋季课程'), findsOneWidget);
    expect(find.text('春季课程'), findsNothing);
  });

  testWidgets('schedule scoped delete hides one week or all weeks', (
    tester,
  ) async {
    final fixedNow = DateTime(2026, 3, 3, 9);
    final repositories = RepositoryFactory.local(FixedAppClock(fixedNow));
    await repositories.courses.createCourse(
      const CourseDraft(
        name: '可删除课程',
        teacher: '',
        location: '仙 I-101',
        note: '',
        dayOfWeek: 2,
        startPeriod: 3,
        endPeriod: 4,
        weekRule: WeekRule.all,
        startWeek: 1,
        endWeek: 2,
      ),
    );

    await tester.pumpWidget(
      _ScopedTestApp(
        repositories: repositories,
        clock: FixedAppClock(fixedNow),
        home: const SchedulePage(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.text('可删除课程'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('仅删除这一次课'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除').last);
    await tester.pumpAndSettle();

    expect(find.text('可删除课程'), findsNothing);
    expect(await repositories.courses.getCoursesForWeek(2), hasLength(1));

    await tester.tap(find.byTooltip('下一周'));
    await tester.pumpAndSettle();
    expect(find.text('可删除课程'), findsOneWidget);

    await tester.longPress(find.text('可删除课程'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除所有课程'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除').last);
    await tester.pumpAndSettle();

    expect(await repositories.courses.getCoursesForWeek(2), isEmpty);
  });

  testWidgets('next thing add button creates todo and shows refreshed state', (
    tester,
  ) async {
    final repositories = RepositoryFactory.local();
    await tester.pumpWidget(
      _ScopedTestApp(
        repositories: repositories,
        home: const NextThingRecommendPage(
          input: RecommendationInput(mood: 50, willingness: 20, anxiety: 30),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('添加到待办'));
    await tester.pumpAndSettle();

    expect(await repositories.todos.getTodos(), hasLength(1));
    expect(find.text('已添加到待办'), findsOneWidget);
    expect(find.text('取消添加'), findsOneWidget);
  });
}

class _ScopedTestApp extends StatelessWidget {
  const _ScopedTestApp({
    required this.repositories,
    required this.home,
    this.clock = const AppClock(),
  });

  final AppRepositories repositories;
  final Widget home;
  final AppClock clock;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      repositories: repositories,
      clock: clock,
      child: MaterialApp(
        home: home,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
