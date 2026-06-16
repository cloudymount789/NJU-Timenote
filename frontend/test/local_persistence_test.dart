import 'package:flutter_test/flutter_test.dart';
import 'package:nju_timenote/core/time/app_clock.dart';
import 'package:nju_timenote/data/models/course.dart';
import 'package:nju_timenote/data/models/todo.dart';
import 'package:nju_timenote/data/repositories/repository_factory.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'courses survive repository recreation after create update and delete',
    () async {
      final clock = MutableAppClock(DateTime(2026, 6, 12, 9));
      var repos = await RepositoryFactory.persistent(clock);
      final created = await repos.courses.createCourse(
        const CourseDraft(
          name: '数据结构',
          teacher: '王老师',
          location: '仙 I-101',
          note: '',
          dayOfWeek: 5,
          startPeriod: 3,
          endPeriod: 4,
          weekRule: WeekRule.all,
          startWeek: 1,
          endWeek: 16,
        ),
      );
      await repos.courses.updateCourse(
        created.id,
        const CourseDraft(
          name: '数据结构',
          teacher: '李老师',
          location: '仙 I-202',
          note: '更新后',
          dayOfWeek: 5,
          startPeriod: 5,
          endPeriod: 6,
          weekRule: WeekRule.even,
          startWeek: 2,
          endWeek: 18,
        ),
      );

      repos = await RepositoryFactory.persistent(clock);
      expect(await repos.courses.getCoursesForWeek(1), isEmpty);
      final week2 = await repos.courses.getCoursesForWeek(2);
      expect(week2.single.location, '仙 I-202');

      await repos.courses.deleteCourse(created.id);
      repos = await RepositoryFactory.persistent(clock);
      expect(await repos.courses.getCourseById(created.id), isNull);
    },
  );

  test('semester settings survive repository recreation after edits', () async {
    final clock = MutableAppClock(DateTime(2026, 6, 12, 9));
    var repos = await RepositoryFactory.persistent(clock);
    var settings = await repos.settings.getSemesterSettings();
    final defaultSemester = settings.activeSemester;

    await repos.settings.updateSemesterTimetable(
      defaultSemester.copyWith(
        semesterStartDate: DateTime(2026, 2, 23),
        weekCount: 18,
      ),
    );
    final added = await repos.settings.addSemesterTimetable(
      startDate: DateTime(2026, 9, 7),
      weekCount: 20,
    );
    await repos.settings.setLastSelectedSemesterId(added.id);

    repos = await RepositoryFactory.persistent(clock);
    settings = await repos.settings.getSemesterSettings();

    expect(settings.semesters, hasLength(2));
    expect(settings.semesters.first.semesterStartDate, DateTime(2026, 2, 23));
    expect(settings.semesters.first.weekCount, 18);
    expect(settings.activeSemester.id, added.id);
    expect(settings.activeSemester.weekCount, 20);

    await repos.settings.deleteSemesterTimetable(added.id);
    repos = await RepositoryFactory.persistent(clock);
    settings = await repos.settings.getSemesterSettings();
    expect(settings.semesterById(added.id), isNull);
    expect(settings.semesters, hasLength(1));
  });

  test(
    'deleting all semester settings survives repository recreation',
    () async {
      final clock = MutableAppClock(DateTime(2026, 6, 12, 9));
      var repos = await RepositoryFactory.persistent(clock);
      var settings = await repos.settings.getSemesterSettings();

      for (final semester in settings.semesters) {
        await repos.settings.deleteSemesterTimetable(semester.id);
      }

      repos = await RepositoryFactory.persistent(clock);
      settings = await repos.settings.getSemesterSettings();

      expect(settings.semesters, isEmpty);
    },
  );

  test(
    'todos tags filters and repeat state survive repository recreation',
    () async {
      final clock = MutableAppClock(DateTime(2026, 6, 12, 9));
      var repos = await RepositoryFactory.persistent(clock);
      final normal = await repos.todos.createTodo(
        const TodoDraft(title: '普通任务', tags: ['复习']),
      );
      final deadline = await repos.todos.createTodo(
        TodoDraft(
          title: 'DDL',
          kind: TodoKind.deadline,
          deadlineAt: DateTime(2026, 6, 13, 23, 59),
          tags: const ['作业'],
        ),
      );
      final recurring = await repos.todos.createTodo(
        TodoDraft(
          title: '每周复盘',
          kind: TodoKind.deadline,
          deadlineAt: DateTime(2026, 6, 12, 18),
          repeatRule: RepeatRule.weekly,
        ),
      );
      await repos.todos.updateTodo(
        normal.id,
        const TodoPatch(priority: PatchField.value(4.5)),
      );
      await repos.todos.completeTodo(recurring.id);
      await repos.todos.reorderTodos([deadline.id, normal.id, recurring.id]);

      repos = await RepositoryFactory.persistent(clock);
      final filtered = await repos.todos.getTodos(
        TodoFilter(
          date: DateTime(2026, 6, 13),
          kinds: const [TodoKind.deadline],
          statuses: const [TodoStatus.open],
          tags: const ['作业'],
        ),
      );
      expect(filtered.single.id, deadline.id);
      expect((await repos.todos.getTodoById(normal.id))?.priority, 4.5);
      expect(
        (await repos.todos.getTodoById(recurring.id))?.status,
        TodoStatus.done,
      );
      expect(await repos.tags.getTags(), containsAll(['考试', '作业', '复习']));

      await repos.todos.deleteTodo(deadline.id);
      repos = await RepositoryFactory.persistent(clock);
      expect(await repos.todos.getTodoById(deadline.id), isNull);
    },
  );

  test('smart sort mode survives repository recreation', () async {
    final clock = MutableAppClock(DateTime(2026, 6, 12, 9));
    var repos = await RepositoryFactory.persistent(clock);
    final later = await repos.todos.createTodo(
      TodoDraft(
        title: '较晚',
        kind: TodoKind.deadline,
        deadlineAt: DateTime(2026, 6, 15, 9),
        priority: 5,
      ),
    );
    await repos.todos.smartSortTodos();

    repos = await RepositoryFactory.persistent(clock);
    expect(await repos.todos.isSmartSortEnabled(), isTrue);

    final urgent = await repos.todos.createTodo(
      TodoDraft(
        title: '新增紧急',
        kind: TodoKind.deadline,
        deadlineAt: DateTime(2026, 6, 12, 10),
        priority: 1,
      ),
    );

    expect((await repos.todos.getTodos()).map((todo) => todo.id), [
      urgent.id,
      later.id,
    ]);
  });

  test(
    'manual reorder after smart sort survives repository recreation',
    () async {
      final clock = MutableAppClock(DateTime(2026, 6, 12, 9));
      var repos = await RepositoryFactory.persistent(clock);
      final urgent = await repos.todos.createTodo(
        TodoDraft(
          title: '紧急',
          kind: TodoKind.deadline,
          deadlineAt: DateTime(2026, 6, 12, 10),
        ),
      );
      final later = await repos.todos.createTodo(
        TodoDraft(
          title: '稍后',
          kind: TodoKind.deadline,
          deadlineAt: DateTime(2026, 6, 15, 9),
          priority: 5,
        ),
      );
      await repos.todos.smartSortTodos();
      await repos.todos.reorderTodos([later.id, urgent.id]);

      repos = await RepositoryFactory.persistent(clock);

      expect(await repos.todos.isSmartSortEnabled(), isFalse);
      expect((await repos.todos.getTodos()).map((todo) => todo.id), [
        later.id,
        urgent.id,
      ]);
    },
  );
}

class MutableAppClock extends AppClock {
  MutableAppClock(this.fixedNow);

  DateTime fixedNow;

  @override
  DateTime now() => fixedNow;
}
