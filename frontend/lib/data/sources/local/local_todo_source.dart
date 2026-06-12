import '../../../core/time/app_clock.dart';
import '../../models/todo.dart';
import 'local_tag_source.dart';

class LocalTodoSource {
  LocalTodoSource(
    this._tagSource, {
    this.clock = const AppClock(),
    List<TodoItem>? initial,
  }) : _items = [...?initial];

  final LocalTagSource _tagSource;
  final AppClock clock;
  final List<TodoItem> _items;
  final List<String> _manualOrder = <String>[];
  bool _usesManualOrder = false;
  int _counter = 0;

  Future<List<TodoItem>> getTodos([
    TodoFilter filter = const TodoFilter(),
  ]) async {
    _autoCompleteExpiredDurations();
    final todos = _items.where(filter.matches).toList()..sort(_compareTodos);
    return List.unmodifiable(todos);
  }

  Future<TodoItem?> getTodoById(String todoId) async {
    _autoCompleteExpiredDurations();
    return _items.where((item) => item.id == todoId).firstOrNull;
  }

  Future<List<TodoItem>> searchTodos(String query) async {
    _autoCompleteExpiredDurations();
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return const [];
    }
    final todos = _items.where((item) {
      final haystack = [
        item.title,
        item.content,
        item.location,
        ...item.tags,
      ].join(' ').toLowerCase();
      return haystack.contains(normalized);
    }).toList()..sort(_compareTodos);
    return List.unmodifiable(todos);
  }

  Future<TodoItem?> getNextTodo() async {
    final todos = await getTodos(const TodoFilter(statuses: [TodoStatus.open]));
    return todos.firstOrNull;
  }

  Future<TodoItem> createTodo(TodoDraft draft) async {
    _validateDraft(draft);
    await _tagSource.addTags(draft.tags);
    final now = clock.now();
    final todo = TodoItem(
      id: 'todo-${now.microsecondsSinceEpoch}-${++_counter}',
      title: draft.title.trim(),
      content: draft.content.trim(),
      location: draft.location.trim(),
      kind: draft.kind,
      startAt: draft.kind == TodoKind.duration ? draft.startAt : null,
      endAt: draft.kind == TodoKind.duration ? draft.endAt : null,
      deadlineAt: draft.kind == TodoKind.deadline ? draft.deadlineAt : null,
      priority: draft.priority.clamp(0, 5).toDouble(),
      tags: List.unmodifiable(_normalizeTags(draft.tags)),
      repeatRule: draft.repeatRule,
      status: TodoStatus.open,
      createdAt: now,
      updatedAt: now,
    );
    _items.add(todo);
    if (_usesManualOrder) {
      _manualOrder.add(todo.id);
    }
    return todo.withAutoCompletion(now);
  }

  Future<TodoItem> updateTodo(String todoId, TodoPatch patch) async {
    final index = _indexOf(todoId);
    final old = _items[index];
    final nextKind = patch.kind.isSet ? patch.kind.value! : old.kind;
    final now = clock.now();
    final nextTags = patch.tags.isSet
        ? _normalizeTags(patch.tags.value ?? const [])
        : old.tags;
    await _tagSource.addTags(nextTags);

    final updated = old.copyWith(
      title: patch.title.isSet ? patch.title.value?.trim() : null,
      content: patch.content.isSet ? patch.content.value?.trim() : null,
      location: patch.location.isSet ? patch.location.value?.trim() : null,
      kind: nextKind,
      startAt: _timeFieldForKind(
        kind: nextKind,
        field: patch.startAt,
        oldValue: old.startAt,
        keepsFor: TodoKind.duration,
      ),
      endAt: _timeFieldForKind(
        kind: nextKind,
        field: patch.endAt,
        oldValue: old.endAt,
        keepsFor: TodoKind.duration,
      ),
      deadlineAt: _timeFieldForKind(
        kind: nextKind,
        field: patch.deadlineAt,
        oldValue: old.deadlineAt,
        keepsFor: TodoKind.deadline,
      ),
      priority: patch.priority.isSet
          ? (patch.priority.value ?? 0).clamp(0, 5).toDouble()
          : null,
      tags: nextTags,
      repeatRule: patch.repeatRule.isSet ? patch.repeatRule.value : null,
      status: patch.status.isSet ? patch.status.value : null,
      updatedAt: now,
    );
    _validateItem(updated);
    final result = updated.withAutoCompletion(now);
    _items[index] = result;
    if (old.status != TodoStatus.done &&
        result.status == TodoStatus.done &&
        result.repeatRule != RepeatRule.once) {
      await _createNextRepeat(result, now);
    }
    return result;
  }

  Future<void> deleteTodo(String todoId) async {
    _items.removeAt(_indexOf(todoId));
    _manualOrder.remove(todoId);
  }

  Future<TodoItem> completeTodo(String todoId) async {
    final item = await getTodoById(todoId);
    if (item == null) {
      throw StateError('待办不存在');
    }
    if (item.kind == TodoKind.duration) {
      throw StateError('持续时间待办不可提前手动完成');
    }
    return updateTodo(
      todoId,
      const TodoPatch(status: PatchField.value(TodoStatus.done)),
    );
  }

  Future<TodoItem> reopenTodo(String todoId) async {
    final item = await getTodoById(todoId);
    if (item == null) {
      throw StateError('待办不存在');
    }
    if (item.kind == TodoKind.duration) {
      throw StateError('持续时间待办暂不支持手动取消完成');
    }
    return updateTodo(
      todoId,
      const TodoPatch(status: PatchField.value(TodoStatus.open)),
    );
  }

  Future<TodoItem> toggleTodoCompletion(String todoId) async {
    final item = await getTodoById(todoId);
    if (item == null) {
      throw StateError('待办不存在');
    }
    return item.status == TodoStatus.done
        ? reopenTodo(todoId)
        : completeTodo(todoId);
  }

  Future<void> batchDelete(List<String> todoIds) async {
    final ids = todoIds.toSet();
    _items.removeWhere((item) => ids.contains(item.id));
  }

  Future<List<TodoItem>> batchComplete(List<String> todoIds) async {
    final completed = <TodoItem>[];
    for (final id in todoIds) {
      final item = await getTodoById(id);
      if (item == null || item.kind == TodoKind.duration) {
        continue;
      }
      completed.add(await completeTodo(id));
    }
    return completed;
  }

  Future<void> reorderTodos(List<String> orderedTodoIds) async {
    _usesManualOrder = true;
    final visible = orderedTodoIds.toSet();
    _manualOrder
      ..removeWhere(visible.contains)
      ..insertAll(0, orderedTodoIds);
  }

  Future<void> smartSortTodos() async {
    _autoCompleteExpiredDurations();
    final sorted = [..._items]..sort(compareTodosByPriority);
    _usesManualOrder = true;
    _manualOrder
      ..clear()
      ..addAll(sorted.map((todo) => todo.id));
  }

  int _compareTodos(TodoItem a, TodoItem b) {
    if (!_usesManualOrder || _manualOrder.isEmpty) {
      return compareTodos(a, b);
    }
    final aIndex = _manualOrder.indexOf(a.id);
    final bIndex = _manualOrder.indexOf(b.id);
    if (aIndex != -1 && bIndex != -1) {
      return aIndex.compareTo(bIndex);
    }
    if (aIndex != -1) {
      return -1;
    }
    if (bIndex != -1) {
      return 1;
    }
    return compareTodos(a, b);
  }

  Future<void> _createNextRepeat(TodoItem completed, DateTime now) async {
    final delta = switch (completed.repeatRule) {
      RepeatRule.daily => const Duration(days: 1),
      RepeatRule.weekly => const Duration(days: 7),
      RepeatRule.biweekly => const Duration(days: 14),
      RepeatRule.once => Duration.zero,
    };
    if (delta == Duration.zero) {
      return;
    }
    final next = completed.copyWith(
      id: 'todo-${now.microsecondsSinceEpoch}-${++_counter}',
      startAt: PatchField.value(completed.startAt?.add(delta)),
      endAt: PatchField.value(completed.endAt?.add(delta)),
      deadlineAt: PatchField.value(completed.deadlineAt?.add(delta)),
      status: TodoStatus.open,
      createdAt: now,
      updatedAt: now,
    );
    _items.add(next);
    final currentIndex = _manualOrder.indexOf(completed.id);
    if (_usesManualOrder) {
      _manualOrder.insert(
        currentIndex == -1 ? _manualOrder.length : currentIndex + 1,
        next.id,
      );
    }
  }

  void _autoCompleteExpiredDurations() {
    final now = clock.now();
    for (var index = 0; index < _items.length; index += 1) {
      _items[index] = _items[index].withAutoCompletion(now);
    }
  }

  int _indexOf(String todoId) {
    final index = _items.indexWhere((item) => item.id == todoId);
    if (index == -1) {
      throw StateError('待办不存在');
    }
    return index;
  }
}

int compareTodos(TodoItem a, TodoItem b) {
  final statusCompare = a.status.index.compareTo(b.status.index);
  if (statusCompare != 0) {
    return statusCompare;
  }
  final aTime = a.sortAt;
  final bTime = b.sortAt;
  if (aTime != null && bTime != null) {
    final timeCompare = aTime.compareTo(bTime);
    if (timeCompare != 0) {
      return timeCompare;
    }
  } else if (aTime != null) {
    return -1;
  } else if (bTime != null) {
    return 1;
  }
  return a.createdAt.compareTo(b.createdAt);
}

int compareTodosByPriority(TodoItem a, TodoItem b) {
  final statusCompare = a.status.index.compareTo(b.status.index);
  if (statusCompare != 0) {
    return statusCompare;
  }
  final priorityCompare = b.priority.compareTo(a.priority);
  if (priorityCompare != 0) {
    return priorityCompare;
  }
  return compareTodos(a, b);
}

PatchField<DateTime> _timeFieldForKind({
  required TodoKind kind,
  required PatchField<DateTime> field,
  required DateTime? oldValue,
  required TodoKind keepsFor,
}) {
  if (kind != keepsFor) {
    return const PatchField.value(null);
  }
  if (field.isSet) {
    return PatchField.value(field.value);
  }
  return PatchField.value(oldValue);
}

List<String> _normalizeTags(List<String> tags) {
  return tags
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toSet()
      .toList()
    ..sort();
}

void _validateDraft(TodoDraft draft) {
  if (draft.title.trim().isEmpty) {
    throw ArgumentError.value(draft.title, 'title', '标题不能为空');
  }
  _validateTimeFields(
    kind: draft.kind,
    startAt: draft.startAt,
    endAt: draft.endAt,
    deadlineAt: draft.deadlineAt,
  );
}

void _validateItem(TodoItem item) {
  if (item.title.trim().isEmpty) {
    throw ArgumentError.value(item.title, 'title', '标题不能为空');
  }
  _validateTimeFields(
    kind: item.kind,
    startAt: item.startAt,
    endAt: item.endAt,
    deadlineAt: item.deadlineAt,
  );
}

void _validateTimeFields({
  required TodoKind kind,
  required DateTime? startAt,
  required DateTime? endAt,
  required DateTime? deadlineAt,
}) {
  switch (kind) {
    case TodoKind.duration:
      if (startAt == null || endAt == null || !startAt.isBefore(endAt)) {
        throw ArgumentError('持续时间待办需要有效的起止时间');
      }
    case TodoKind.deadline:
      if (deadlineAt == null) {
        throw ArgumentError('DDL 待办需要截止时间');
      }
    case TodoKind.normal:
      break;
  }
}
