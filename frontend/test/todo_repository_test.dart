import 'package:flutter_test/flutter_test.dart';
import 'package:nju_timenote/core/time/app_clock.dart';
import 'package:nju_timenote/data/models/todo.dart';
import 'package:nju_timenote/data/sources/local/local_tag_source.dart';
import 'package:nju_timenote/data/sources/local/local_todo_source.dart';

void main() {
  late LocalTagSource tags;
  late LocalTodoSource todos;

  setUp(() {
    tags = LocalTagSource();
    todos = LocalTodoSource(tags);
  });

  test('default todo filter includes open and done statuses', () {
    const filter = TodoFilter();

    expect(filter.statuses, containsAll([TodoStatus.open, TodoStatus.done]));
    expect(
      filter.kinds,
      containsAll([TodoKind.duration, TodoKind.deadline, TodoKind.normal]),
    );
  });

  test(
    'sorts open before done, timed before untimed, by time ascending',
    () async {
      final base = DateTime(2026, 6, 12, 9);
      final normal = await todos.createTodo(const TodoDraft(title: '普通'));
      final later = await todos.createTodo(
        TodoDraft(
          title: '较晚 DDL',
          kind: TodoKind.deadline,
          deadlineAt: base.add(const Duration(days: 2)),
        ),
      );
      final earlier = await todos.createTodo(
        TodoDraft(
          title: '较早 DDL',
          kind: TodoKind.deadline,
          deadlineAt: base.add(const Duration(days: 1)),
        ),
      );
      await todos.completeTodo(normal.id);
      final result = await todos.getTodos();

      expect(result.map((todo) => todo.id), [earlier.id, later.id, normal.id]);
    },
  );

  test('filters by date, kind, status and tags', () async {
    final date = DateTime(2026, 6, 19, 23, 59);
    await todos.createTodo(
      TodoDraft(
        title: 'DDL',
        kind: TodoKind.deadline,
        deadlineAt: date,
        tags: const ['作业'],
      ),
    );
    await todos.createTodo(const TodoDraft(title: '普通', tags: ['生活']));

    final result = await todos.getTodos(
      TodoFilter(
        date: DateTime(2026, 6, 19),
        kinds: const [TodoKind.deadline],
        statuses: const [TodoStatus.open],
        tags: const ['作业'],
      ),
    );

    expect(result, hasLength(1));
    expect(result.single.title, 'DDL');
  });

  test('empty status filter returns no todos', () async {
    await todos.createTodo(const TodoDraft(title: '普通'));

    final result = await todos.getTodos(const TodoFilter(statuses: []));

    expect(result, isEmpty);
  });

  test('auto-completes expired duration todos on query', () async {
    final now = DateTime(2026, 6, 12, 12);
    todos = LocalTodoSource(tags, clock: FixedAppClock(now));
    final todo = await todos.createTodo(
      TodoDraft(
        title: '已结束持续事项',
        kind: TodoKind.duration,
        startAt: now.subtract(const Duration(hours: 2)),
        endAt: now.subtract(const Duration(hours: 1)),
      ),
    );

    final refreshed = await todos.getTodoById(todo.id);

    expect(refreshed?.status, TodoStatus.done);
  });

  test('batch complete skips duration todos', () async {
    final now = DateTime(2026, 6, 12, 12);
    todos = LocalTodoSource(tags, clock: FixedAppClock(now));
    final normal = await todos.createTodo(const TodoDraft(title: '普通'));
    final duration = await todos.createTodo(
      TodoDraft(
        title: '未结束持续事项',
        kind: TodoKind.duration,
        startAt: now,
        endAt: now.add(const Duration(hours: 1)),
      ),
    );

    await todos.batchComplete([normal.id, duration.id]);

    expect((await todos.getTodoById(normal.id))?.status, TodoStatus.done);
    expect((await todos.getTodoById(duration.id))?.status, TodoStatus.open);
  });

  test('normal and deadline todos can be completed and reopened', () async {
    final normal = await todos.createTodo(const TodoDraft(title: '普通'));
    final completed = await todos.toggleTodoCompletion(normal.id);
    final reopened = await todos.toggleTodoCompletion(normal.id);

    expect(completed.status, TodoStatus.done);
    expect(reopened.status, TodoStatus.open);
  });

  test('duration manual completion restriction remains intact', () async {
    final now = DateTime(2026, 6, 12, 12);
    todos = LocalTodoSource(tags, clock: FixedAppClock(now));
    final duration = await todos.createTodo(
      TodoDraft(
        title: '未结束持续事项',
        kind: TodoKind.duration,
        startAt: now,
        endAt: now.add(const Duration(hours: 1)),
      ),
    );

    expect(todos.toggleTodoCompletion(duration.id), throwsStateError);
    expect((await todos.getTodoById(duration.id))?.status, TodoStatus.open);
  });

  test('fixed clock is used for created and updated timestamps', () async {
    final fixedNow = DateTime(2026, 6, 12, 9, 41);
    todos = LocalTodoSource(tags, clock: FixedAppClock(fixedNow));

    final todo = await todos.createTodo(const TodoDraft(title: '固定时间'));

    expect(todo.createdAt, fixedNow);
    expect(todo.updatedAt, fixedNow);
  });

  test('manual reorder changes visible todo order', () async {
    final first = await todos.createTodo(const TodoDraft(title: '第一'));
    final second = await todos.createTodo(const TodoDraft(title: '第二'));
    final third = await todos.createTodo(const TodoDraft(title: '第三'));

    await todos.reorderTodos([third.id, first.id, second.id]);

    final result = await todos.getTodos();
    expect(result.map((todo) => todo.id), [third.id, first.id, second.id]);
  });

  test(
    'smart sort uses priority before urgency and overwrites manual order',
    () async {
      final base = DateTime(2026, 6, 12, 9);
      final low = await todos.createTodo(
        TodoDraft(
          title: '低优先级',
          kind: TodoKind.deadline,
          deadlineAt: base,
          priority: 1,
        ),
      );
      final high = await todos.createTodo(
        TodoDraft(
          title: '高优先级',
          kind: TodoKind.deadline,
          deadlineAt: base.add(const Duration(days: 3)),
          priority: 5,
        ),
      );

      await todos.reorderTodos([low.id, high.id]);
      await todos.smartSortTodos();

      final result = await todos.getTodos();
      expect(result.map((todo) => todo.id).take(2), [high.id, low.id]);
    },
  );

  test('biweekly repeat creates next instance when completed', () async {
    final fixedNow = DateTime(2026, 6, 12, 9, 41);
    todos = LocalTodoSource(tags, clock: FixedAppClock(fixedNow));
    final todo = await todos.createTodo(
      TodoDraft(
        title: '双周 DDL',
        kind: TodoKind.deadline,
        deadlineAt: DateTime(2026, 6, 13, 15, 30),
        repeatRule: RepeatRule.biweekly,
      ),
    );

    await todos.completeTodo(todo.id);
    final result = await todos.getTodos();

    expect(result, hasLength(2));
    expect(
      result.where((item) => item.status == TodoStatus.open).single.deadlineAt,
      DateTime(2026, 6, 27, 15, 30),
    );
  });

  test(
    'new tags are added to local tag source when creating or updating',
    () async {
      final todo = await todos.createTodo(
        const TodoDraft(title: '带新 tag', tags: ['复习']),
      );
      await todos.updateTodo(
        todo.id,
        const TodoPatch(tags: PatchField.value(['复习', '实验'])),
      );

      expect(await tags.getTags(), containsAll(['复习', '实验']));
    },
  );

  test('kind update cleans incompatible time fields', () async {
    final todo = await todos.createTodo(
      TodoDraft(
        title: 'DDL',
        kind: TodoKind.deadline,
        deadlineAt: DateTime(2026, 6, 19, 23, 59),
      ),
    );

    final updated = await todos.updateTodo(
      todo.id,
      const TodoPatch(kind: PatchField.value(TodoKind.normal)),
    );

    expect(updated.kind, TodoKind.normal);
    expect(updated.startAt, isNull);
    expect(updated.endAt, isNull);
    expect(updated.deadlineAt, isNull);
  });
}
