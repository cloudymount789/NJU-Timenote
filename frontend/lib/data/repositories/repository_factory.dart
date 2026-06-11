import '../sources/local/local_course_source.dart';
import '../sources/local/local_goal_split_source.dart';
import '../sources/local/local_recommendation_source.dart';
import '../sources/local/local_settings_source.dart';
import '../sources/local/local_tag_source.dart';
import '../sources/local/local_todo_source.dart';
import 'app_repositories.dart';
import 'course_repository.dart';
import 'goal_split_repository.dart';
import 'recommendation_repository.dart';
import 'settings_repository.dart';
import 'tag_repository.dart';
import 'todo_repository.dart';
import '../models/course.dart';
import '../models/goal_split.dart';
import '../models/recommendation.dart';
import '../models/settings.dart';
import '../models/todo.dart';

class RepositoryFactory {
  const RepositoryFactory._();

  static AppRepositories local() {
    final tagSource = LocalTagSource();
    return AppRepositories(
      courses: LocalCourseRepository(LocalCourseSource()),
      todos: LocalTodoRepository(LocalTodoSource(tagSource)),
      tags: LocalTagRepository(tagSource),
      settings: LocalSettingsRepository(LocalSettingsSource()),
      recommendations: LocalRecommendationRepository(
        LocalRecommendationSource(),
      ),
      goalSplits: LocalGoalSplitRepository(LocalGoalSplitSource()),
    );
  }
}

class LocalCourseRepository implements CourseRepository {
  const LocalCourseRepository(this._source);

  final LocalCourseSource _source;

  @override
  Future<List<Course>> getCoursesForWeek(int week) {
    return _source.getCoursesForWeek(week);
  }

  @override
  Future<Course?> getNextCourse() {
    return _source.getNextCourse();
  }

  @override
  Future<Course> createCourse(CourseDraft draft) {
    return _source.createCourse(draft);
  }

  @override
  Future<void> deleteCourse(String courseId) {
    return _source.deleteCourse(courseId);
  }

  @override
  String colorKeyForCourseName(String name) {
    return _source.colorKeyForCourseName(name);
  }
}

class LocalTodoRepository implements TodoRepository {
  const LocalTodoRepository(this._source);

  final LocalTodoSource _source;

  @override
  Future<List<TodoItem>> getTodos([TodoFilter filter = const TodoFilter()]) {
    return _source.getTodos(filter);
  }

  @override
  Future<TodoItem?> getTodoById(String todoId) {
    return _source.getTodoById(todoId);
  }

  @override
  Future<TodoItem?> getNextTodo() {
    return _source.getNextTodo();
  }

  @override
  Future<List<TodoItem>> searchTodos(String query) {
    return _source.searchTodos(query);
  }

  @override
  Future<TodoItem> createTodo(TodoDraft draft) {
    return _source.createTodo(draft);
  }

  @override
  Future<TodoItem> updateTodo(String todoId, TodoPatch patch) {
    return _source.updateTodo(todoId, patch);
  }

  @override
  Future<void> deleteTodo(String todoId) {
    return _source.deleteTodo(todoId);
  }

  @override
  Future<TodoItem> completeTodo(String todoId) {
    return _source.completeTodo(todoId);
  }

  @override
  Future<void> batchDelete(List<String> todoIds) {
    return _source.batchDelete(todoIds);
  }

  @override
  Future<List<TodoItem>> batchComplete(List<String> todoIds) {
    return _source.batchComplete(todoIds);
  }
}

class LocalTagRepository implements TagRepository {
  const LocalTagRepository(this._source);

  final LocalTagSource _source;

  @override
  Future<List<String>> getTags() {
    return _source.getTags();
  }

  @override
  Future<String> addTag(String name) {
    return _source.addTag(name);
  }
}

class LocalSettingsRepository implements SettingsRepository {
  const LocalSettingsRepository(this._source);

  final LocalSettingsSource _source;

  @override
  Future<SemesterSettings> getSemesterSettings() {
    return _source.getSemesterSettings();
  }
}

class LocalRecommendationRepository implements RecommendationRepository {
  const LocalRecommendationRepository(this._source);

  final LocalRecommendationSource _source;

  @override
  Future<List<TodoRecommendation>> getRecommendations(
    RecommendationInput input,
  ) {
    return _source.getRecommendations(input);
  }
}

class LocalGoalSplitRepository implements GoalSplitRepository {
  const LocalGoalSplitRepository(this._source);

  final LocalGoalSplitSource _source;

  @override
  Future<void> createFromGoalSplit(GoalSplitDraft draft) {
    return _source.createFromGoalSplit(draft);
  }
}
