import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../domain/todo.dart';
import '../domain/todo_repository.dart';

class LocalTodoRepository implements TodoRepository {
  LocalTodoRepository(this._db, [this._uuid = const Uuid()]);

  final AppDatabase _db;
  final Uuid _uuid;

  // ── fetch ─────────────────────────────────────────────────────────

  @override
  Future<List<TodoItem>> fetchTodos({
    TodoFilter filter = const TodoFilter(),
  }) async {
    var query = _db.select(_db.todoRows)
      ..where((r) => r.deletedAt.isNull());

    if (filter.onlyDeadline) {
      query = _db.select(_db.todoRows)
        ..where(
          (r) =>
              r.deletedAt.isNull() &
              r.deadlineAt.isNotNull() &
              r.kind.equals('deadline'),
        );
    }

    if (filter.date != null) {
      final d = filter.date!;
      final start = DateTime.utc(d.year, d.month, d.day);
      final end = start.add(const Duration(days: 1));
      query = _db.select(_db.todoRows)
        ..where(
          (r) =>
              r.deletedAt.isNull() &
              (r.deadlineAt.isBetweenValues(start, end) |
                  r.startAt.isBetweenValues(start, end)),
        );
    }

    if (filter.kinds.isNotEmpty) {
      final kindValues = filter.kinds.map((k) => k.name).toList();
      query = _db.select(_db.todoRows)
        ..where(
          (r) =>
              r.deletedAt.isNull() &
              r.kind.isIn(kindValues),
        );
    }

    if (filter.statuses.isNotEmpty) {
      final statusValues = filter.statuses.map((s) => s.name).toList();
      query = _db.select(_db.todoRows)
        ..where(
          (r) =>
              r.deletedAt.isNull() &
              r.status.isIn(statusValues),
        );
    }

    final rows = await query.get();

    // tag filter — done in Dart because it's a join
    List<TodoRow> filtered = rows;
    if (filter.tags.isNotEmpty) {
      final tagRows = await (_db.select(_db.todoTagRows)
        ..where((r) => r.tagName.isIn(filter.tags.toList()))).get();
      final matchingIds = tagRows.map((r) => r.todoId).toSet();
      filtered = rows.where((r) => matchingIds.contains(r.id)).toList();
    }

    final todos = await Future.wait(filtered.map((r) => _toModel(r)));
    return _sort(todos);
  }

  @override
  Future<List<TodoItem>> searchTodos(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    final rows = await (_db.select(_db.todoRows)
      ..where((r) => r.deletedAt.isNull())).get();

    final todos = await Future.wait(rows.map((r) => _toModel(r)));

    final matching = todos.where((t) {
      return t.title.toLowerCase().contains(q) ||
          t.content.toLowerCase().contains(q) ||
          t.location.toLowerCase().contains(q) ||
          t.tags.any((tag) => tag.toLowerCase().contains(q));
    }).toList();

    return _sort(matching);
  }

  // ── create ────────────────────────────────────────────────────────

  @override
  Future<TodoItem> createTodo(TodoDraft draft) async {
    final now = DateTime.now().toUtc();
    final todo = TodoItem(
      id: 'todo-${_uuid.v4()}',
      title: draft.title.trim().isEmpty ? '未命名待办' : draft.title.trim(),
      content: draft.content,
      location: draft.location,
      kind: draft.kind,
      startAt: draft.startAt,
      endAt: draft.endAt,
      deadlineAt: draft.deadlineAt,
      priority: draft.priority.clamp(0.0, 5.0),
      tags: List<String>.from(draft.tags),
      repeatRule: draft.repeatRule,
      status: TodoStatus.open,
      createdAt: now,
      updatedAt: now,
    );

    await _db.transaction(() async {
      await _db.into(_db.todoRows).insert(_todoToCompanion(todo));
      await _setTags(todo.id, todo.tags);
      await _ensureTagsExist(todo.tags);
    });

    return todo;
  }

  // ── update ────────────────────────────────────────────────────────

  @override
  Future<TodoItem> updateTodo(String todoId, TodoPatch patch) async {
    final existingRow = await _requireRow(todoId);
    final existing = await _toModel(existingRow);
    final now = DateTime.now().toUtc();

    final title = patch.title ?? existing.title;
    final content = patch.content ?? existing.content;
    final location = patch.location ?? existing.location;
    final kind = patch.kind ?? existing.kind;
    final priority = patch.priority ?? existing.priority;
    final tags = patch.tags ?? existing.tags;
    final repeatRule = patch.repeatRule ?? existing.repeatRule;
    final status = patch.status ?? existing.status;

    DateTime? startAt, endAt, deadlineAt;

    if (patch.clearDuration) {
      startAt = null;
      endAt = null;
      if (patch.deadlineAt != null) {
        deadlineAt = patch.deadlineAt;
      } else {
        deadlineAt = existing.deadlineAt;
      }
    } else if (patch.clearDeadline) {
      deadlineAt = null;
      if (patch.startAt != null || patch.endAt != null) {
        startAt = patch.startAt;
        endAt = patch.endAt;
      } else {
        startAt = existing.startAt;
        endAt = existing.endAt;
      }
    } else {
      startAt = patch.startAt ?? existing.startAt;
      endAt = patch.endAt ?? existing.endAt;
      deadlineAt = patch.deadlineAt ?? existing.deadlineAt;
    }

    await _db.transaction(() async {
      await (_db.update(_db.todoRows)..where((r) => r.id.equals(todoId)))
          .write(
        TodoRowsCompanion(
          title: Value(title),
          content: Value(content),
          location: Value(location),
          kind: Value(kind.name),
          startAt: Value(startAt),
          endAt: Value(endAt),
          deadlineAt: Value(deadlineAt),
          priority: Value(priority),
          repeatRule: Value(repeatRule.name),
          status: Value(status.name),
          updatedAt: Value(now),
          localRevision: Value(existingRow.localRevision + 1),
        ),
      );
      await _setTags(todoId, tags);
      await _ensureTagsExist(tags);
    });

    return TodoItem(
      id: existingRow.id,
      title: title,
      content: content,
      location: location,
      kind: kind,
      startAt: startAt,
      endAt: endAt,
      deadlineAt: deadlineAt,
      priority: priority,
      tags: tags,
      repeatRule: repeatRule,
      status: status,
      createdAt: existingRow.createdAt,
      updatedAt: now,
    );
  }

  // ── delete / complete ─────────────────────────────────────────────

  @override
  Future<void> deleteTodo(String todoId) async {
    final row = await (_db.select(_db.todoRows)
      ..where((r) => r.id.equals(todoId))).getSingleOrNull();
    if (row == null) return;

    if (row.serverRevision == null) {
      await (_db.delete(_db.todoRows)
        ..where((r) => r.id.equals(todoId))).go();
      await (_db.delete(_db.todoTagRows)
        ..where((r) => r.todoId.equals(todoId))).go();
    } else {
      final now = DateTime.now().toUtc();
      await (_db.update(_db.todoRows)..where((r) => r.id.equals(todoId)))
          .write(
        TodoRowsCompanion(
          updatedAt: Value(now),
          deletedAt: Value(now),
          syncStatus: const Value('pendingDelete'),
          localRevision: Value(row.localRevision + 1),
        ),
      );
    }
  }

  @override
  Future<void> completeTodo(String todoId) async {
    final now = DateTime.now().toUtc();
    final row = await _requireRow(todoId);
    await (_db.update(_db.todoRows)..where((r) => r.id.equals(todoId))).write(
      TodoRowsCompanion(
        status: const Value('done'),
        updatedAt: Value(now),
        localRevision: Value(row.localRevision + 1),
      ),
    );
  }

  // ── batch ─────────────────────────────────────────────────────────

  @override
  Future<void> batchDelete(Set<String> todoIds) async {
    for (final id in todoIds) {
      await deleteTodo(id);
    }
  }

  @override
  Future<void> batchComplete(Set<String> todoIds) async {
    final rows = await (_db.select(_db.todoRows)
      ..where((r) => r.id.isIn(todoIds.toList()) & r.deletedAt.isNull()))
        .get();

    final toComplete = rows.where((r) => r.kind != 'duration');
    final now = DateTime.now().toUtc();

    for (final row in toComplete) {
      await (_db.update(_db.todoRows)..where((r) => r.id.equals(row.id)))
          .write(
        TodoRowsCompanion(
          status: const Value('done'),
          updatedAt: Value(now),
          localRevision: Value(row.localRevision + 1),
        ),
      );
    }
  }

  // ── tags ──────────────────────────────────────────────────────────

  @override
  Future<List<String>> fetchTags() async {
    final rows = await _db.select(_db.tagRows).get();
    return rows.map((r) => r.name).toList();
  }

  @override
  Future<String> addTag(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError('tag name is required');

    await _db.into(_db.tagRows).insertOnConflictUpdate(
      TagRowsCompanion.insert(name: trimmed, createdAt: DateTime.now().toUtc()),
    );
    return trimmed;
  }

  // ── recommend ─────────────────────────────────────────────────────

  @override
  Future<List<TodoRecommendation>> recommendTodos(
    RecommendationInput input,
  ) async {
    final all = await fetchTodos();
    final open = all.where((t) => !t.isDone).toList();

    final urgent = open.where((t) => t.hasDeadline).toList()
      ..sort((a, b) {
        final la = a.deadlineAt ?? DateTime(2099);
        final lb = b.deadlineAt ?? DateTime(2099);
        return la.compareTo(lb);
      });

    final normals = open.where((t) => t.kind == TodoKind.normal);

    return [
      if (urgent.isNotEmpty)
        TodoRecommendation(
          section: '不得不做的事',
          title: urgent.first.title,
          todoId: urgent.first.id,
          reason:
              '虽然你现在可能不是很想做事情，但是ddl马上要到啦，不妨试着从简单的一步先开始吧？',
        )
      else
        const TodoRecommendation(
          section: '不得不做的事',
          title: '暂无待办，先去添加一条吧',
          reason: '还没有待办时，可以先从一件很小的事开始，比如整理桌面或喝一杯水。',
        ),
      if (normals.isNotEmpty)
        TodoRecommendation(
          section: '适合现在状态的事',
          title: normals.first.title,
          todoId: normals.first.id,
          reason: input.mood < 45
              ? '心情不好的话，先好好哄一下自己吧？磨刀不误砍柴工嘛~'
              : '现在的启动意愿还不错，可以挑一件普通待办保持节奏。',
        )
      else
        const TodoRecommendation(
          section: '适合现在状态的事',
          title: '深呼吸 5 分钟',
          reason: '心情偏低时，先照顾好自己的状态，比硬撑更有效。',
        ),
      const TodoRecommendation(
        section: '其他可以做的事',
        title: '今天早点睡',
        reason: '实在不想动的话，今天早点睡，把事情交给明天状态更好的自己吧？',
        canAdd: true,
      ),
    ];
  }

  // ── goal split ────────────────────────────────────────────────────

  @override
  Future<List<TodoItem>> createGoalSplitTodos(GoalSplitDraft draft) async {
    return _db.transaction(() async {
      final created = <TodoItem>[];
      for (final sub in draft.subtasks) {
        final date = sub.plannedDate;
        created.add(
          await createTodo(
            TodoDraft(
              title: sub.title,
              content: draft.note,
              kind: TodoKind.deadline,
              deadlineAt: DateTime(date.year, date.month, date.day, 23, 59),
              priority: 4,
              tags: const ['学习'],
            ),
          ),
        );
      }
      return created;
    });
  }

  // ── search history ────────────────────────────────────────────────

  @override
  Future<List<String>> fetchSearchHistory() async {
    final rows = await (_db.select(_db.searchHistoryRows)
      ..orderBy([(r) => OrderingTerm(expression: r.searchedAt, mode: OrderingMode.desc)])
      ..limit(8)).get();
    return rows.map((r) => r.query).toList();
  }

  @override
  Future<void> clearSearchHistory() async {
    await _db.delete(_db.searchHistoryRows).go();
  }

  // ── helpers ───────────────────────────────────────────────────────

  Future<TodoItem> _toModel(TodoRow r) async {
    final tagRows = await (_db.select(_db.todoTagRows)
      ..where((t) => t.todoId.equals(r.id))).get();
    final tags = tagRows.map((t) => t.tagName).toList();

    return TodoItem(
      id: r.id,
      title: r.title,
      content: r.content,
      location: r.location,
      kind: TodoKind.values.byName(r.kind),
      startAt: r.startAt,
      endAt: r.endAt,
      deadlineAt: r.deadlineAt,
      priority: r.priority,
      tags: tags,
      repeatRule: RepeatRule.values.byName(r.repeatRule),
      status: TodoStatus.values.byName(r.status),
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );
  }

  TodoRowsCompanion _todoToCompanion(TodoItem t) => TodoRowsCompanion.insert(
    id: t.id,
    title: t.title,
    content: Value(t.content),
    location: Value(t.location),
    kind: t.kind.name,
    startAt: Value(t.startAt),
    endAt: Value(t.endAt),
    deadlineAt: Value(t.deadlineAt),
    priority: t.priority,
    repeatRule: Value(t.repeatRule.name),
    status: Value(t.status.name),
    createdAt: t.createdAt,
    updatedAt: t.updatedAt,
  );

  Future<void> _setTags(String todoId, List<String> tags) async {
    await (_db.delete(_db.todoTagRows)
      ..where((r) => r.todoId.equals(todoId))).go();
    for (final tag in tags) {
      if (tag.trim().isNotEmpty) {
        await _db.into(_db.todoTagRows).insert(
          TodoTagRowsCompanion.insert(todoId: todoId, tagName: tag.trim()),
        );
      }
    }
  }

  Future<void> _ensureTagsExist(List<String> tags) async {
    for (final tag in tags) {
      if (tag.trim().isNotEmpty) {
        await addTag(tag.trim());
      }
    }
  }

  Future<TodoRow> _requireRow(String id) async {
    final row = await (_db.select(_db.todoRows)
      ..where((r) => r.id.equals(id))).getSingleOrNull();
    if (row == null) throw StateError('Todo not found: $id');
    return row;
  }

  Future<TodoItem> _requireTodo(String id) async {
    return _toModel(await _requireRow(id));
  }

  List<TodoItem> _sort(List<TodoItem> todos) {
    final open = todos.where((t) => !t.isDone).toList();
    final done = todos.where((t) => t.isDone).toList();

    int cmp(TodoItem a, TodoItem b) {
      final la = a.deadlineAt ?? a.startAt;
      final lb = b.deadlineAt ?? b.startAt;
      if (la == null && lb == null) return 0;
      if (la == null) return 1;
      if (lb == null) return -1;
      return la.compareTo(lb);
    }

    open.sort(cmp);
    done.sort(cmp);
    return [...open, ...done];
  }
}
