import '../models/todo.dart';

abstract class TodoRepository {
  Future<List<TodoItem>> getTodos([TodoFilter filter = const TodoFilter()]);
  Future<List<TodoItem>> searchTodos(String query);
  Future<TodoItem?> getNextTodo();
}
