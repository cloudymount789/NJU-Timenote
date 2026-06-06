import '../models/todo_item.dart';

abstract class TodoRepository {
  Future<List<TodoItem>> fetchTodos({bool? hasDeadline, String? query});
}

class MockTodoRepository implements TodoRepository {
  MockTodoRepository() : _todos = _seedTodos();

  final List<TodoItem> _todos;

  @override
  Future<List<TodoItem>> fetchTodos({bool? hasDeadline, String? query}) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    Iterable<TodoItem> result = _todos;
    if (hasDeadline != null) {
      result = result.where((todo) => todo.hasDeadline == hasDeadline);
    }
    if (query != null && query.trim().isNotEmpty) {
      final keyword = query.trim();
      result = result.where(
        (todo) => todo.title.contains(keyword) || todo.note.contains(keyword),
      );
    }
    return result.toList();
  }

  static List<TodoItem> _seedTodos() {
    final now = DateTime(2026, 4, 9, 9, 41);
    return [
      TodoItem(
        id: 'todo-1',
        title: '数据结构实验报告',
        note: '实验三',
        dueAt: DateTime(2026, 4, 9, 23, 59),
        status: TodoStatus.open,
        createdAt: now,
        updatedAt: now,
      ),
      TodoItem(
        id: 'todo-2',
        title: '高等数学作业 (第4章)',
        note: '习题 4.1',
        dueAt: DateTime(2026, 4, 10, 18),
        status: TodoStatus.open,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
