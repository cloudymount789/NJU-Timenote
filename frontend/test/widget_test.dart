import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nju_timenote/app/app.dart';
import 'package:nju_timenote/app/router.dart';
import 'package:nju_timenote/core/time/app_clock.dart';
import 'package:nju_timenote/core/widgets/app_card.dart';
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
  test('duration time helpers default to one hour and handle next day', () {
    final start = DateTime(2026, 6, 12, 23, 30);

    expect(defaultDurationEndForStart(start), DateTime(2026, 6, 13, 0, 30));
    expect(
      durationEndOnOrAfterStart(start, const TimeOfDay(hour: 0, minute: 15)),
      DateTime(2026, 6, 13, 0, 15),
    );
    expect(
      durationEndOnOrAfterStart(start, const TimeOfDay(hour: 23, minute: 45)),
      DateTime(2026, 6, 12, 23, 45),
    );
  });

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

  testWidgets('todo detail top back prompts for unsaved edits and can save', (
    tester,
  ) async {
    final repositories = RepositoryFactory.local();
    final todo = await repositories.todos.createTodo(
      const TodoDraft(title: '原标题'),
    );

    await tester.pumpWidget(
      _ScopedTestApp(repositories: repositories, home: const TodoListPage()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('原标题'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '标题'), '新标题');
    await tester.tap(find.byTooltip('返回'));
    await tester.pumpAndSettle();

    expect(find.text('有未保存的修改'), findsOneWidget);
    await tester.tap(find.text('保存后返回'));
    await tester.pumpAndSettle();

    expect(find.text('待办'), findsOneWidget);
    expect((await repositories.todos.getTodoById(todo.id))?.title, '新标题');
  });

  testWidgets('todo detail system back prompts for unsaved edits', (
    tester,
  ) async {
    final repositories = RepositoryFactory.local();
    await repositories.todos.createTodo(const TodoDraft(title: '系统返回待办'));

    await tester.pumpWidget(
      _ScopedTestApp(repositories: repositories, home: const TodoListPage()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('系统返回待办'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '内容'), '修改内容');

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('有未保存的修改'), findsOneWidget);
  });

  testWidgets('todo detail discard and cancel choices keep expected state', (
    tester,
  ) async {
    final repositories = RepositoryFactory.local();
    final todo = await repositories.todos.createTodo(
      const TodoDraft(title: '保留原值'),
    );

    await tester.pumpWidget(
      _ScopedTestApp(repositories: repositories, home: const TodoListPage()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('保留原值'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '标题'), '取消修改');
    await tester.tap(find.byTooltip('返回'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    expect(find.text('待办详情'), findsOneWidget);

    await tester.tap(find.byTooltip('返回'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('不保存'));
    await tester.pumpAndSettle();

    expect(find.text('待办'), findsOneWidget);
    expect((await repositories.todos.getTodoById(todo.id))?.title, '保留原值');
  });

  testWidgets('todo detail without edits returns without unsaved prompt', (
    tester,
  ) async {
    final repositories = RepositoryFactory.local();
    await repositories.todos.createTodo(const TodoDraft(title: '无需提示'));

    await tester.pumpWidget(
      _ScopedTestApp(repositories: repositories, home: const TodoListPage()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('无需提示'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('返回'));
    await tester.pumpAndSettle();

    expect(find.text('有未保存的修改'), findsNothing);
    expect(find.text('无需提示'), findsOneWidget);
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

  testWidgets('todo list smart sort state can be restored and toggled off', (
    tester,
  ) async {
    final repositories = RepositoryFactory.local();
    await repositories.todos.createTodo(const TodoDraft(title: '普通'));
    await repositories.todos.smartSortTodos();

    await tester.pumpWidget(
      _ScopedTestApp(repositories: repositories, home: const TodoListPage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('智能排序已开启'), findsOneWidget);

    await tester.pumpWidget(
      _ScopedTestApp(repositories: repositories, home: const TodoListPage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('智能排序已开启'), findsOneWidget);

    await tester.tap(find.text('智能排序已开启'));
    await tester.pumpAndSettle();

    expect(await repositories.todos.isSmartSortEnabled(), isFalse);
    expect(find.text('开启智能排序'), findsOneWidget);
  });

  testWidgets('manual reorder in smart sort mode asks before switching modes', (
    tester,
  ) async {
    final repositories = RepositoryFactory.local();
    final first = await repositories.todos.createTodo(
      TodoDraft(
        title: '紧急',
        kind: TodoKind.deadline,
        deadlineAt: DateTime(2026, 6, 12, 9),
      ),
    );
    final second = await repositories.todos.createTodo(
      TodoDraft(
        title: '稍后',
        kind: TodoKind.deadline,
        deadlineAt: DateTime(2026, 6, 13, 9),
      ),
    );
    await repositories.todos.smartSortTodos();

    await tester.pumpWidget(
      _ScopedTestApp(repositories: repositories, home: const TodoListPage()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('批量操作'));
    await tester.pumpAndSettle();

    final reorderable = tester.widget<ReorderableListView>(
      find.byType(ReorderableListView),
    );
    reorderable.onReorderItem!(0, 2);
    await tester.pumpAndSettle();

    expect(find.text('关闭智能排序？'), findsOneWidget);
    expect(find.text('当前处于智能排序模式，手动调整位置将会自动关闭智能排序。'), findsOneWidget);

    await tester.tap(find.text('关闭并排序'));
    await tester.pumpAndSettle();

    expect(await repositories.todos.isSmartSortEnabled(), isFalse);
    expect((await repositories.todos.getTodos()).map((todo) => todo.id), [
      second.id,
      first.id,
    ]);
  });

  testWidgets('canceling smart sort reorder keeps smart mode and order', (
    tester,
  ) async {
    final repositories = RepositoryFactory.local();
    final first = await repositories.todos.createTodo(
      TodoDraft(
        title: '紧急保留',
        kind: TodoKind.deadline,
        deadlineAt: DateTime(2026, 6, 12, 9),
      ),
    );
    final second = await repositories.todos.createTodo(
      TodoDraft(
        title: '稍后保留',
        kind: TodoKind.deadline,
        deadlineAt: DateTime(2026, 6, 13, 9),
      ),
    );
    await repositories.todos.smartSortTodos();

    await tester.pumpWidget(
      _ScopedTestApp(repositories: repositories, home: const TodoListPage()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('批量操作'));
    await tester.pumpAndSettle();

    final reorderable = tester.widget<ReorderableListView>(
      find.byType(ReorderableListView),
    );
    reorderable.onReorderItem!(0, 2);
    await tester.pumpAndSettle();
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    expect(await repositories.todos.isSmartSortEnabled(), isTrue);
    expect((await repositories.todos.getTodos()).map((todo) => todo.id), [
      first.id,
      second.id,
    ]);
  });

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

  testWidgets('tag picker adds and deletes tags with confirmation', (
    tester,
  ) async {
    final repositories = RepositoryFactory.local();
    final todo = await repositories.todos.createTodo(
      const TodoDraft(title: '带 tag', tags: ['复习', '作业']),
    );

    await tester.pumpWidget(
      _ScopedTestApp(
        repositories: repositories,
        home: TodoDetailPage(isCreate: false, todoId: todo.id),
      ),
    );
    await tester.pumpAndSettle();

    final tagPicker = find.byKey(const ValueKey('todo-tag-picker'));
    await tester.ensureVisible(tagPicker);
    await tester.tap(tagPicker);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('新增 tag'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '请输入 tag 名称'), '实验');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, '确定'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('新增 Tag'), findsNothing);
    expect(find.text('实验'), findsOneWidget);

    await tester.longPress(find.widgetWithText(FilterChip, '复习'));
    await tester.pumpAndSettle();
    expect(find.text('删除 Tag'), findsOneWidget);

    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();

    expect(find.text('复习'), findsNothing);
    expect((await repositories.todos.getTodoById(todo.id))?.tags, ['作业']);
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
    await repositories.todos.createTodo(
      TodoDraft(
        title: '缴费确认',
        kind: TodoKind.deadline,
        deadlineAt: DateTime(2026, 6, 14, 12),
      ),
    );
    await repositories.todos.createTodo(
      TodoDraft(
        title: '下周申请',
        kind: TodoKind.deadline,
        deadlineAt: DateTime(2026, 6, 20, 12),
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
    expect(find.text('缴费确认'), findsOneWidget);
    expect(find.text('下周申请'), findsNothing);
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

  testWidgets('semester list empty state card fills available width', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 780));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repositories = RepositoryFactory.local();
    await repositories.settings.deleteSemesterTimetable('semester-2026-03-02');

    await tester.pumpWidget(
      _ScopedTestApp(
        repositories: repositories,
        home: const SemesterListPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('暂无学期课表'), findsOneWidget);
    final cardRect = tester.getRect(find.byType(AppCard));
    expect(cardRect.width, greaterThan(330));
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
