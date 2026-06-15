import '../models/todo.dart';

abstract class TodoRepository {
  Future<List<TodoItem>> getTodos([TodoFilter filter = const TodoFilter()]);
  Future<TodoItem?> getTodoById(String todoId);
  Future<List<TodoItem>> searchTodos(String query);
  Future<TodoItem?> getNextTodo();
  Future<bool> isSmartSortEnabled();
  Future<TodoItem> createTodo(TodoDraft draft);
  Future<TodoItem> updateTodo(String todoId, TodoPatch patch);
  Future<void> deleteTodo(String todoId);
  Future<TodoItem> completeTodo(String todoId);
  Future<TodoItem> reopenTodo(String todoId);
  Future<TodoItem> toggleTodoCompletion(String todoId);
  Future<void> reorderTodos(List<String> orderedTodoIds);
  Future<void> smartSortTodos();
  Future<void> batchDelete(List<String> todoIds);
  Future<List<TodoItem>> batchComplete(List<String> todoIds);
}
