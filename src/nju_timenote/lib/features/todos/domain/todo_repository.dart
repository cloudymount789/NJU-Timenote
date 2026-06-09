import 'todo.dart';

abstract class TodoRepository {
  Future<List<TodoItem>> fetchTodos({TodoFilter filter = const TodoFilter()});
  Future<List<TodoItem>> searchTodos(String query);
  Future<TodoItem> createTodo(TodoDraft draft);
  Future<TodoItem> updateTodo(String todoId, TodoPatch patch);
  Future<void> deleteTodo(String todoId);
  Future<void> completeTodo(String todoId);
  Future<void> batchDelete(Set<String> todoIds);
  Future<void> batchComplete(Set<String> todoIds);
  Future<List<String>> fetchTags();
  Future<String> addTag(String name);
  Future<List<TodoRecommendation>> recommendTodos(RecommendationInput input);
  Future<List<TodoItem>> createGoalSplitTodos(GoalSplitDraft draft);
}
