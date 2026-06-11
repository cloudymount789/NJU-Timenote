import '../domain/todo.dart';
import '../domain/todo_repository.dart';

class MockTodoRepository implements TodoRepository {
  MockTodoRepository()
    : _todos = _seedTodos(),
      _tags = ['考试', '作业', '讲座', '会议', '生活', '学习'],
      _searchHistory = ['dlco', '作业', '考试', '数据结构', '会议'];

  final List<TodoItem> _todos;
  final List<String> _tags;
  final List<String> _searchHistory;
  int _nextId = 100;

  @override
  Future<List<TodoItem>> fetchTodos({
    TodoFilter filter = const TodoFilter(),
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 90));
    return _applyFilter(_todos, filter);
  }

  @override
  Future<List<TodoItem>> searchTodos(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 90));
    final keyword = query.trim().toLowerCase();
    if (keyword.isEmpty) {
      return [];
    }
    return _ordered(
      _todos.where((todo) {
        return todo.title.toLowerCase().contains(keyword) ||
            todo.content.toLowerCase().contains(keyword) ||
            todo.location.toLowerCase().contains(keyword) ||
            todo.tags.any((tag) => tag.toLowerCase().contains(keyword));
      }).toList(),
    );
  }

  @override
  Future<TodoItem> createTodo(TodoDraft draft) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final now = DateTime.now();
    final todo = TodoItem(
      id: 'todo-${_nextId++}',
      title: draft.title.trim().isEmpty ? '未命名待办' : draft.title.trim(),
      content: draft.content,
      location: draft.location,
      kind: draft.kind,
      startAt: draft.startAt,
      endAt: draft.endAt,
      deadlineAt: draft.deadlineAt,
      priority: draft.priority.clamp(0, 5),
      tags: List<String>.from(draft.tags),
      repeatRule: draft.repeatRule,
      status: TodoStatus.open,
      createdAt: now,
      updatedAt: now,
    );
    _todos.add(todo);
    _addMissingTags(todo.tags);
    return todo;
  }

  @override
  Future<TodoItem> updateTodo(String todoId, TodoPatch patch) async {
    await Future<void>.delayed(const Duration(milliseconds: 90));
    final index = _todos.indexWhere((todo) => todo.id == todoId);
    if (index < 0) {
      throw StateError('Todo not found: $todoId');
    }
    final existing = _todos[index];
    final updated = existing.copyWith(
      title: patch.title,
      content: patch.content,
      location: patch.location,
      kind: patch.kind,
      startAt: patch.startAt,
      endAt: patch.endAt,
      deadlineAt: patch.deadlineAt,
      priority: patch.priority,
      tags: patch.tags,
      repeatRule: patch.repeatRule,
      status: patch.status,
      clearDuration: patch.clearDuration,
      clearDeadline: patch.clearDeadline,
      updatedAt: DateTime.now(),
    );
    _todos[index] = updated;
    _addMissingTags(updated.tags);
    return updated;
  }

  @override
  Future<void> deleteTodo(String todoId) async {
    await Future<void>.delayed(const Duration(milliseconds: 90));
    _todos.removeWhere((todo) => todo.id == todoId);
  }

  @override
  Future<void> completeTodo(String todoId) async {
    await updateTodo(todoId, const TodoPatch(status: TodoStatus.done));
  }

  @override
  Future<void> batchDelete(Set<String> todoIds) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _todos.removeWhere((todo) => todoIds.contains(todo.id));
  }

  @override
  Future<void> batchComplete(Set<String> todoIds) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    for (var i = 0; i < _todos.length; i++) {
      final todo = _todos[i];
      if (todoIds.contains(todo.id) && todo.kind != TodoKind.duration) {
        _todos[i] = todo.copyWith(
          status: TodoStatus.done,
          updatedAt: DateTime.now(),
        );
      }
    }
  }

  @override
  Future<List<String>> fetchTags() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return List<String>.unmodifiable(_tags);
  }

  @override
  Future<String> addTag(String name) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('tag name is required');
    }
    if (!_tags.contains(trimmed)) {
      _tags.add(trimmed);
    }
    return trimmed;
  }

  @override
  Future<List<TodoRecommendation>> recommendTodos(
    RecommendationInput input,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final openTodos = _todos.where((todo) => !todo.isDone).toList();
    final urgent = openTodos.where((todo) => todo.hasDeadline).toList()
      ..sort((a, b) {
        final left = a.deadlineAt ?? DateTime(2099);
        final right = b.deadlineAt ?? DateTime(2099);
        return left.compareTo(right);
      });
    final normal = openTodos.where((todo) => todo.kind == TodoKind.normal);

    return [
      if (urgent.isNotEmpty)
        TodoRecommendation(
          section: '不得不做的事',
          title: urgent.first.title,
          todoId: urgent.first.id,
          reason: '虽然你现在可能不是很想做事情，但是ddl马上要到啦，不妨试着从简单的一步先开始吧？',
        )
      else
        const TodoRecommendation(
          section: '不得不做的事',
          title: '暂无待办，先去添加一条吧',
          reason: '还没有待办时，可以先从一件很小的事开始，比如整理桌面或喝一杯水。',
        ),
      if (normal.isNotEmpty)
        TodoRecommendation(
          section: '适合现在状态的事',
          title: normal.first.title,
          todoId: normal.first.id,
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

  @override
  Future<List<TodoItem>> createGoalSplitTodos(GoalSplitDraft draft) async {
    final created = <TodoItem>[];
    for (final subtask in draft.subtasks) {
      final date = subtask.plannedDate;
      created.add(
        await createTodo(
          TodoDraft(
            title: subtask.title,
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
  }

  @override
  Future<List<String>> fetchSearchHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 30));
    return List<String>.unmodifiable(_searchHistory);
  }

  @override
  Future<void> clearSearchHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 30));
    _searchHistory.clear();
  }

  List<TodoItem> _applyFilter(List<TodoItem> todos, TodoFilter filter) {
    Iterable<TodoItem> result = todos;
    if (filter.onlyDeadline) {
      result = result.where((todo) => todo.hasDeadline);
    }
    if (filter.date != null) {
      final target = filter.date!;
      result = result.where((todo) {
        final date = todo.deadlineAt ?? todo.startAt;
        return date != null &&
            date.year == target.year &&
            date.month == target.month &&
            date.day == target.day;
      });
    }
    if (filter.kinds.isNotEmpty) {
      result = result.where((todo) => filter.kinds.contains(todo.kind));
    }
    if (filter.statuses.isNotEmpty) {
      result = result.where((todo) => filter.statuses.contains(todo.status));
    }
    if (filter.tags.isNotEmpty) {
      result = result.where(
        (todo) => todo.tags.any((tag) => filter.tags.contains(tag)),
      );
    }
    return _ordered(result.toList());
  }

  List<TodoItem> _ordered(List<TodoItem> todos) {
    final open = todos.where((todo) => !todo.isDone).toList();
    final done = todos.where((todo) => todo.isDone).toList();
    int compareTime(TodoItem a, TodoItem b) {
      final left = a.deadlineAt ?? a.startAt ?? DateTime(2099);
      final right = b.deadlineAt ?? b.startAt ?? DateTime(2099);
      return left.compareTo(right);
    }

    open.sort(compareTime);
    done.sort(compareTime);
    return [...open, ...done];
  }

  void _addMissingTags(List<String> tags) {
    for (final tag in tags) {
      if (tag.trim().isNotEmpty && !_tags.contains(tag)) {
        _tags.add(tag);
      }
    }
  }

  static List<TodoItem> _seedTodos() {
    final now = DateTime(2026, 6, 19, 9, 41);
    return [
      TodoItem(
        id: 'todo-1',
        title: '高等数学习题课',
        content: '完成第5-8章习题',
        location: '教学楼 A302',
        kind: TodoKind.duration,
        startAt: DateTime(2026, 6, 19, 18),
        endAt: DateTime(2026, 6, 19, 19, 30),
        deadlineAt: null,
        priority: 4,
        tags: const ['学习'],
        repeatRule: RepeatRule.once,
        status: TodoStatus.open,
        createdAt: now,
        updatedAt: now,
      ),
      TodoItem(
        id: 'todo-2',
        title: '数据结构实验报告',
        content: '完成实验三并提交到教学网',
        location: '线上提交',
        kind: TodoKind.deadline,
        startAt: null,
        endAt: null,
        deadlineAt: DateTime(2026, 6, 19, 23, 59),
        priority: 4.5,
        tags: const ['作业', '考试'],
        repeatRule: RepeatRule.once,
        status: TodoStatus.open,
        createdAt: now,
        updatedAt: now,
      ),
      TodoItem(
        id: 'todo-3',
        title: '整理课堂笔记',
        content: '把今天三节课的重点整理成思维导图',
        location: '图书馆',
        kind: TodoKind.normal,
        startAt: null,
        endAt: null,
        deadlineAt: null,
        priority: 3.5,
        tags: const ['学习', '作业'],
        repeatRule: RepeatRule.once,
        status: TodoStatus.open,
        createdAt: now,
        updatedAt: now,
      ),
      TodoItem(
        id: 'todo-4',
        title: '回复导师邮件',
        content: '确认组会时间',
        location: '',
        kind: TodoKind.normal,
        startAt: null,
        endAt: null,
        deadlineAt: null,
        priority: 2,
        tags: const ['会议'],
        repeatRule: RepeatRule.once,
        status: TodoStatus.done,
        createdAt: now,
        updatedAt: now,
      ),
      TodoItem(
        id: 'todo-5',
        title: '数据结构期中复习',
        content: '复习树、图和排序',
        location: '图书馆',
        kind: TodoKind.deadline,
        startAt: null,
        endAt: null,
        deadlineAt: DateTime(2026, 6, 20, 23, 59),
        priority: 4,
        tags: const ['考试'],
        repeatRule: RepeatRule.once,
        status: TodoStatus.open,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
