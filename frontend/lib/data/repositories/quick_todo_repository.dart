import '../models/todo.dart';

abstract class QuickTodoRepository {
  Future<TodoItem> createFromSentence(String sentence);
}
