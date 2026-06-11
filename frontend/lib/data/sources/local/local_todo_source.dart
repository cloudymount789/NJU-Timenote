import '../../models/todo.dart';

class LocalTodoSource {
  Future<List<TodoItem>> getTodos([
    TodoFilter filter = const TodoFilter(),
  ]) async {
    return const [];
  }

  Future<List<TodoItem>> searchTodos(String query) async {
    return const [];
  }

  Future<TodoItem?> getNextTodo() async {
    return null;
  }
}
