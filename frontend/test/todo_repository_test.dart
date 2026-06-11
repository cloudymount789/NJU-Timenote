import 'package:flutter_test/flutter_test.dart';
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

  test('auto-completes expired duration todos on query', () async {
    final now = DateTime.now();
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
    final now = DateTime.now();
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
