import 'package:flutter_test/flutter_test.dart';
import 'package:nju_timenote/core/time/app_clock.dart';
import 'package:nju_timenote/data/models/todo.dart';
import 'package:nju_timenote/data/sources/local/local_tag_source.dart';
import 'package:nju_timenote/data/sources/local/local_todo_source.dart';
import 'package:nju_timenote/features/todo/todo_list_page.dart';

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

  test('expired deadline todos stay open', () async {
    final now = DateTime(2026, 6, 12, 12);
    todos = LocalTodoSource(tags, clock: FixedAppClock(now));
    final todo = await todos.createTodo(
      TodoDraft(
        title: '过期 DDL',
        kind: TodoKind.deadline,
        deadlineAt: now.subtract(const Duration(hours: 1)),
      ),
    );

    final refreshed = await todos.getTodoById(todo.id);

    expect(refreshed?.status, TodoStatus.open);
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
    'smart sort uses urgency before priority and overwrites manual order',
    () async {
      final base = DateTime(2026, 6, 12, 9);
      final urgentLow = await todos.createTodo(
        TodoDraft(
          title: '紧急低优先级',
          kind: TodoKind.deadline,
          deadlineAt: base,
          priority: 1,
        ),
      );
      final laterHigh = await todos.createTodo(
        TodoDraft(
          title: '较晚高优先级',
          kind: TodoKind.deadline,
          deadlineAt: base.add(const Duration(days: 3)),
          priority: 5,
        ),
      );

      await todos.reorderTodos([laterHigh.id, urgentLow.id]);
      await todos.smartSortTodos();

      final result = await todos.getTodos();
      expect(result.map((todo) => todo.id).take(2), [
        urgentLow.id,
        laterHigh.id,
      ]);
    },
  );

  test('creating a todo reruns smart sort while keeping it enabled', () async {
    final base = DateTime(2026, 6, 12, 9);
    final later = await todos.createTodo(
      TodoDraft(
        title: '较晚',
        kind: TodoKind.deadline,
        deadlineAt: base.add(const Duration(days: 3)),
        priority: 5,
      ),
    );
    await todos.smartSortTodos();

    final urgent = await todos.createTodo(
      TodoDraft(
        title: '新增紧急',
        kind: TodoKind.deadline,
        deadlineAt: base,
        priority: 1,
      ),
    );

    expect(await todos.isSmartSortEnabled(), isTrue);
    expect((await todos.getTodos()).map((todo) => todo.id), [
      urgent.id,
      later.id,
    ]);
  });

  test('manual reorder after smart sort disables smart sort', () async {
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
    final middle = await todos.createTodo(
      TodoDraft(
        title: '中优先级',
        kind: TodoKind.deadline,
        deadlineAt: base.add(const Duration(days: 1)),
        priority: 3,
      ),
    );

    await todos.smartSortTodos();
    expect((await todos.getTodos()).map((todo) => todo.id), [
      low.id,
      middle.id,
      high.id,
    ]);
    expect(await todos.isSmartSortEnabled(), isTrue);

    await todos.reorderTodos([low.id, high.id, middle.id]);

    expect(await todos.isSmartSortEnabled(), isFalse);
    expect((await todos.getTodos()).map((todo) => todo.id), [
      low.id,
      high.id,
      middle.id,
    ]);
  });

  test(
    'recurring todos project once daily weekly and biweekly schedules',
    () async {
      final clock = MutableAppClock(DateTime(2026, 6, 17, 9));
      todos = LocalTodoSource(tags, clock: clock);
      final once = await todos.createTodo(
        TodoDraft(
          title: '仅一次 DDL',
          kind: TodoKind.deadline,
          deadlineAt: DateTime(2026, 6, 18, 18, 30),
        ),
      );
      final daily = await todos.createTodo(
        TodoDraft(
          title: '每天 DDL',
          kind: TodoKind.deadline,
          deadlineAt: DateTime(2026, 6, 1, 18, 30),
          repeatRule: RepeatRule.daily,
        ),
      );
      final weekly = await todos.createTodo(
        TodoDraft(
          title: '每周 DDL',
          kind: TodoKind.deadline,
          deadlineAt: DateTime(2026, 6, 3, 18, 30),
          repeatRule: RepeatRule.weekly,
        ),
      );
      final biweekly = await todos.createTodo(
        TodoDraft(
          title: '双周 DDL',
          kind: TodoKind.deadline,
          deadlineAt: DateTime(2026, 6, 3, 18, 30),
          repeatRule: RepeatRule.biweekly,
        ),
      );

      final result = await todos.getTodos();
      final byId = {for (final todo in result) todo.id: todo};

      expect(byId[once.id]?.deadlineAt, DateTime(2026, 6, 18, 18, 30));
      expect(byId[daily.id]?.deadlineAt, DateTime(2026, 6, 17, 18, 30));
      expect(byId[weekly.id]?.deadlineAt, DateTime(2026, 6, 17, 18, 30));
      expect(byId[biweekly.id]?.deadlineAt, DateTime(2026, 6, 17, 18, 30));
    },
  );

  test(
    'recurring deadline completion only completes the current cycle',
    () async {
      final clock = MutableAppClock(DateTime(2026, 6, 17, 9));
      todos = LocalTodoSource(tags, clock: clock);
      final todo = await todos.createTodo(
        TodoDraft(
          title: '每周 DDL',
          kind: TodoKind.deadline,
          deadlineAt: DateTime(2026, 6, 3, 18, 30),
          repeatRule: RepeatRule.weekly,
        ),
      );

      await todos.completeTodo(todo.id);

      expect(await todos.getTodos(), hasLength(1));
      expect((await todos.getTodoById(todo.id))?.status, TodoStatus.done);

      clock.fixedNow = DateTime(2026, 6, 24, 9);
      final nextCycle = await todos.getTodoById(todo.id);

      expect(nextCycle?.deadlineAt, DateTime(2026, 6, 24, 18, 30));
      expect(nextCycle?.status, TodoStatus.open);
    },
  );

  test('overdue recurring deadline continues into the next cycle', () async {
    final clock = MutableAppClock(DateTime(2026, 6, 18, 9));
    todos = LocalTodoSource(tags, clock: clock);
    final todo = await todos.createTodo(
      TodoDraft(
        title: '过期每周 DDL',
        kind: TodoKind.deadline,
        deadlineAt: DateTime(2026, 6, 3, 18, 30),
        repeatRule: RepeatRule.weekly,
      ),
    );

    final current = await todos.getTodoById(todo.id);

    expect(current?.deadlineAt, DateTime(2026, 6, 17, 18, 30));
    expect(current?.status, TodoStatus.open);
  });

  test('deleting a recurring todo deletes the whole rule', () async {
    final clock = MutableAppClock(DateTime(2026, 6, 17, 9));
    todos = LocalTodoSource(tags, clock: clock);
    final todo = await todos.createTodo(
      TodoDraft(
        title: '每天 DDL',
        kind: TodoKind.deadline,
        deadlineAt: DateTime(2026, 6, 17, 18, 30),
        repeatRule: RepeatRule.daily,
      ),
    );
    await todos.completeTodo(todo.id);

    await todos.deleteTodo(todo.id);

    expect(await todos.getTodos(), isEmpty);
  });

  test('completed recurring records are cleaned after seven days', () async {
    final clock = MutableAppClock(DateTime(2026, 6, 12, 9));
    todos = LocalTodoSource(tags, clock: clock);
    final todo = await todos.createTodo(
      TodoDraft(
        title: '每天 DDL',
        kind: TodoKind.deadline,
        deadlineAt: DateTime(2026, 6, 12, 18, 30),
        repeatRule: RepeatRule.daily,
      ),
    );
    await todos.completeTodo(todo.id);

    clock.fixedNow = DateTime(2026, 6, 20, 9);
    final oldCycle = await todos.getTodos(
      TodoFilter(date: DateTime(2026, 6, 12)),
    );

    expect(oldCycle.single.status, TodoStatus.open);
  });

  test('todo list meta text formats recurring todos', () {
    TodoItem recurring({
      required TodoKind kind,
      required RepeatRule repeatRule,
      DateTime? startAt,
      DateTime? endAt,
      DateTime? deadlineAt,
    }) {
      return TodoItem(
        id: 'todo',
        title: '标题',
        content: '',
        location: '',
        kind: kind,
        startAt: startAt,
        endAt: endAt,
        deadlineAt: deadlineAt,
        priority: 0,
        tags: const [],
        repeatRule: repeatRule,
        status: TodoStatus.open,
        createdAt: DateTime(2026, 6, 12),
        updatedAt: DateTime(2026, 6, 12),
      );
    }

    expect(
      todoListMetaText(
        recurring(
          kind: TodoKind.deadline,
          repeatRule: RepeatRule.weekly,
          deadlineAt: DateTime(2026, 6, 17, 18, 30),
        ),
      ),
      '重复 DDL：每周 周三 18:30',
    );
    expect(
      todoListMetaText(
        recurring(
          kind: TodoKind.deadline,
          repeatRule: RepeatRule.biweekly,
          deadlineAt: DateTime(2026, 6, 17, 18, 30),
        ),
      ),
      '重复 DDL：每两周 周三 18:30',
    );
    expect(
      todoListMetaText(
        recurring(
          kind: TodoKind.deadline,
          repeatRule: RepeatRule.daily,
          deadlineAt: DateTime(2026, 6, 17, 18, 30),
        ),
      ),
      '重复 DDL：每天 18:30',
    );
    expect(
      todoListMetaText(
        recurring(
          kind: TodoKind.duration,
          repeatRule: RepeatRule.weekly,
          startAt: DateTime(2026, 6, 19, 15, 30),
          endAt: DateTime(2026, 6, 19, 16, 30),
        ),
      ),
      '重复 每周五 15:30 - 16:30',
    );
    expect(
      todoListMetaText(
        recurring(
          kind: TodoKind.duration,
          repeatRule: RepeatRule.biweekly,
          startAt: DateTime(2026, 6, 19, 15, 30),
          endAt: DateTime(2026, 6, 19, 16, 30),
        ),
      ),
      '重复 每两周 周五 15:30 - 16:30',
    );
    expect(
      todoListMetaText(
        recurring(
          kind: TodoKind.duration,
          repeatRule: RepeatRule.daily,
          startAt: DateTime(2026, 6, 19, 15, 30),
          endAt: DateTime(2026, 6, 19, 16, 30),
        ),
      ),
      '重复 每天 15:30 - 16:30',
    );
    expect(
      todoListMetaText(
        recurring(kind: TodoKind.normal, repeatRule: RepeatRule.daily),
      ),
      '重复 普通待办',
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

  test('deleting a tag removes it from existing todos', () async {
    final todo = await todos.createTodo(
      const TodoDraft(title: '带 tag', tags: ['复习', '作业']),
    );

    await tags.deleteTag('复习');
    await todos.removeTagFromTodos('复习');

    expect(await tags.getTags(), isNot(contains('复习')));
    expect((await todos.getTodoById(todo.id))?.tags, ['作业']);
  });

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

class MutableAppClock extends AppClock {
  MutableAppClock(this.fixedNow);

  DateTime fixedNow;

  @override
  DateTime now() => fixedNow;
}
