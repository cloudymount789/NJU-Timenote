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
  final Map<String, _RepeatCompletion> _repeatCompletions = {};
  _TodoSortMode _sortMode = _TodoSortMode.defaultOrder;
  int _counter = 0;

  Future<List<TodoItem>> getTodos([
    TodoFilter filter = const TodoFilter(),
  ]) async {
    final reference = filter.date ?? clock.now();
    _refreshCompletionState(reference);
    final todos =
        _items
            .map((item) => _projectForReference(item, reference))
            .where(filter.matches)
            .toList()
          ..sort(_compareTodos);
    return List.unmodifiable(todos);
  }

  Future<TodoItem?> getTodoById(String todoId) async {
    final now = clock.now();
    _refreshCompletionState(now);
    final item = _items.where((item) => item.id == todoId).firstOrNull;
    return item == null ? null : _projectForReference(item, now);
  }

  Future<List<TodoItem>> searchTodos(String query) async {
    final now = clock.now();
    _refreshCompletionState(now);
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return const [];
    }
    final todos = _items.map((item) => _projectForReference(item, now)).where((
      item,
    ) {
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
    if (_sortMode != _TodoSortMode.defaultOrder) {
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
      status: old.isRecurring
          ? TodoStatus.open
          : patch.status.isSet
          ? patch.status.value
          : null,
      updatedAt: now,
    );
    _validateItem(updated);
    final result = updated.isRecurring
        ? updated
        : updated.withAutoCompletion(now);
    _items[index] = result;
    if (result.isRecurring && patch.status.isSet) {
      _setRepeatCompletion(result, now, patch.status.value == TodoStatus.done);
    }
    return _projectForReference(result, now);
  }

  Future<void> deleteTodo(String todoId) async {
    _items.removeAt(_indexOf(todoId));
    _manualOrder.remove(todoId);
    _repeatCompletions.removeWhere((key, _) => key.split('|').first == todoId);
  }

  Future<TodoItem> completeTodo(String todoId) async {
    final item = await getTodoById(todoId);
    if (item == null) {
      throw StateError('待办不存在');
    }
    if (item.kind == TodoKind.duration) {
      throw StateError('持续时间待办不可提前手动完成');
    }
    if (item.isRecurring) {
      final template = _items[_indexOf(todoId)];
      final now = clock.now();
      _setRepeatCompletion(template, now, true);
      return _projectForReference(template, now);
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
    if (item.isRecurring) {
      final template = _items[_indexOf(todoId)];
      final now = clock.now();
      _setRepeatCompletion(template, now, false);
      return _projectForReference(template, now);
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
    _manualOrder.removeWhere(ids.contains);
    _repeatCompletions.removeWhere(
      (key, _) => ids.contains(key.split('|').first),
    );
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
    _sortMode = _TodoSortMode.manual;
    final visible = orderedTodoIds.toSet();
    _manualOrder
      ..removeWhere(visible.contains)
      ..insertAll(0, orderedTodoIds);
  }

  Future<void> smartSortTodos() async {
    _refreshCompletionState(clock.now());
    final sorted = [..._items]..sort(compareTodosByPriority);
    _sortMode = _TodoSortMode.smart;
    _manualOrder
      ..clear()
      ..addAll(sorted.map((todo) => todo.id));
  }

  int _compareTodos(TodoItem a, TodoItem b) {
    if (_sortMode == _TodoSortMode.defaultOrder || _manualOrder.isEmpty) {
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

  void _refreshCompletionState(DateTime reference) {
    final now = clock.now();
    _repeatCompletions.removeWhere(
      (_, completion) => completion.completedAt.isBefore(
        now.subtract(const Duration(days: 7)),
      ),
    );
    for (var index = 0; index < _items.length; index += 1) {
      final item = _items[index];
      if (item.isRecurring) {
        final projected = _projectForReference(item, reference);
        if (projected.kind == TodoKind.duration &&
            projected.endAt != null &&
            !projected.endAt!.isAfter(now)) {
          _setRepeatCompletion(item, reference, true);
        }
      } else {
        _items[index] = item.withAutoCompletion(now);
      }
    }
  }

  TodoItem _projectForReference(TodoItem item, DateTime reference) {
    if (!item.isRecurring) {
      return item;
    }
    final occurrenceDate = _occurrenceDate(item, reference);
    final projected = item.copyWith(
      startAt: PatchField.value(
        item.kind == TodoKind.duration
            ? _withDate(occurrenceDate, item.startAt)
            : null,
      ),
      endAt: PatchField.value(
        item.kind == TodoKind.duration
            ? _withDate(occurrenceDate, item.endAt)
            : null,
      ),
      deadlineAt: PatchField.value(
        item.kind == TodoKind.deadline
            ? _withDate(occurrenceDate, item.deadlineAt)
            : null,
      ),
      status: _isRepeatCompleted(item, occurrenceDate)
          ? TodoStatus.done
          : TodoStatus.open,
    );
    return projected;
  }

  DateTime _occurrenceDate(TodoItem item, DateTime reference) {
    final timeSource = item.deadlineAt ?? item.startAt ?? item.createdAt;
    return switch (item.repeatRule) {
      RepeatRule.once => DateTime(
        reference.year,
        reference.month,
        reference.day,
      ),
      RepeatRule.daily => DateTime(
        reference.year,
        reference.month,
        reference.day,
      ),
      RepeatRule.weekly => _startOfWeek(
        reference,
      ).add(Duration(days: timeSource.weekday - 1)),
      RepeatRule.biweekly => _biweeklyCycleStart(
        timeSource,
        reference,
      ).add(Duration(days: timeSource.weekday - 1)),
    };
  }

  DateTime _biweeklyCycleStart(DateTime anchor, DateTime reference) {
    final anchorWeek = _startOfWeek(anchor);
    final referenceWeek = _startOfWeek(reference);
    final days = referenceWeek.difference(anchorWeek).inDays;
    final cycles = days < 0 ? 0 : days ~/ 14;
    return anchorWeek.add(Duration(days: cycles * 14));
  }

  bool _isRepeatCompleted(TodoItem item, DateTime occurrenceDate) {
    return _repeatCompletions.containsKey(_repeatKey(item.id, occurrenceDate));
  }

  void _setRepeatCompletion(TodoItem item, DateTime reference, bool done) {
    final occurrenceDate = _occurrenceDate(item, reference);
    final key = _repeatKey(item.id, occurrenceDate);
    if (done) {
      _repeatCompletions[key] = _RepeatCompletion(clock.now());
    } else {
      _repeatCompletions.remove(key);
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

enum _TodoSortMode { defaultOrder, manual, smart }

class _RepeatCompletion {
  const _RepeatCompletion(this.completedAt);

  final DateTime completedAt;
}

DateTime _startOfWeek(DateTime value) {
  final date = DateTime(value.year, value.month, value.day);
  return date.subtract(Duration(days: value.weekday - 1));
}

DateTime? _withDate(DateTime date, DateTime? timeSource) {
  if (timeSource == null) {
    return null;
  }
  return DateTime(
    date.year,
    date.month,
    date.day,
    timeSource.hour,
    timeSource.minute,
  );
}

String _repeatKey(String todoId, DateTime occurrenceDate) {
  final date = DateTime(
    occurrenceDate.year,
    occurrenceDate.month,
    occurrenceDate.day,
  );
  return '$todoId|${date.toIso8601String()}';
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
