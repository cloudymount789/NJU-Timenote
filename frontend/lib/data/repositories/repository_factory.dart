import '../sources/local/local_course_source.dart';
import '../sources/local/local_goal_split_source.dart';
import '../sources/local/local_recommendation_source.dart';
import '../sources/local/local_settings_source.dart';
import '../sources/local/local_tag_source.dart';
import '../sources/local/local_todo_source.dart';
import 'app_repositories.dart';
import 'course_repository.dart';
import 'goal_split_repository.dart';
import 'quick_todo_repository.dart';
import 'recommendation_repository.dart';
import 'settings_repository.dart';
import 'tag_repository.dart';
import 'todo_repository.dart';
import '../../core/time/app_clock.dart';
import '../models/course.dart';
import '../models/goal_split.dart';
import '../models/recommendation.dart';
import '../models/settings.dart';
import '../models/todo.dart';

class RepositoryFactory {
  const RepositoryFactory._();

  static AppRepositories local([AppClock clock = const AppClock()]) {
    final tagSource = LocalTagSource();
    final todoSource = LocalTodoSource(tagSource, clock: clock);
    return AppRepositories(
      courses: LocalCourseRepository(LocalCourseSource(clock: clock)),
      todos: LocalTodoRepository(todoSource),
      tags: LocalTagRepository(tagSource),
      settings: LocalSettingsRepository(LocalSettingsSource()),
      recommendations: LocalRecommendationRepository(
        LocalRecommendationSource(todoSource),
      ),
      goalSplits: LocalGoalSplitRepository(LocalGoalSplitSource(todoSource)),
      quickTodos: LocalQuickTodoRepository(todoSource),
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
  Future<Course?> getCourseById(String courseId) {
    return _source.getCourseById(courseId);
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
  Future<Course> updateCourse(String courseId, CourseDraft draft) {
    return _source.updateCourse(courseId, draft);
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
  Future<TodoItem> reopenTodo(String todoId) {
    return _source.reopenTodo(todoId);
  }

  @override
  Future<TodoItem> toggleTodoCompletion(String todoId) {
    return _source.toggleTodoCompletion(todoId);
  }

  @override
  Future<void> reorderTodos(List<String> orderedTodoIds) {
    return _source.reorderTodos(orderedTodoIds);
  }

  @override
  Future<void> smartSortTodos() {
    return _source.smartSortTodos();
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

class LocalQuickTodoRepository implements QuickTodoRepository {
  const LocalQuickTodoRepository(this._source);

  final LocalTodoSource _source;

  @override
  Future<TodoItem> createFromSentence(String sentence) {
    final title = sentence.trim();
    if (title.isEmpty) {
      throw ArgumentError.value(sentence, 'sentence', '内容不能为空');
    }
    return _source.createTodo(TodoDraft(title: title));
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
