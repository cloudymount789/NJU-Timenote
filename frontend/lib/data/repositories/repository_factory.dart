import '../sources/local/local_course_source.dart';
import '../sources/local/local_goal_split_source.dart';
import '../sources/local/local_json_store.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

class RepositoryFactory {
  const RepositoryFactory._();

  static AppRepositories local([AppClock clock = const AppClock()]) {
    return _build(clock: clock);
  }

  static Future<AppRepositories> persistent([
    AppClock clock = const AppClock(),
  ]) async {
    final preferences = await SharedPreferences.getInstance();
    return _build(clock: clock, store: LocalJsonStore(preferences));
  }

  static AppRepositories _build({
    required AppClock clock,
    LocalJsonStore? store,
  }) {
    final tagSource = LocalTagSource(store: store);
    final todoSource = LocalTodoSource(tagSource, clock: clock, store: store);
    final settingsSource = LocalSettingsSource(clock: clock, store: store);
    final changes = DataRefreshNotifier();
    return AppRepositories(
      courses: LocalCourseRepository(
        LocalCourseSource(
          clock: clock,
          store: store,
          settingsSource: settingsSource,
        ),
        changes,
      ),
      todos: LocalTodoRepository(todoSource, changes),
      tags: LocalTagRepository(tagSource, todoSource, changes),
      settings: LocalSettingsRepository(settingsSource, changes),
      recommendations: LocalRecommendationRepository(
        LocalRecommendationSource(todoSource),
      ),
      goalSplits: LocalGoalSplitRepository(
        LocalGoalSplitSource(todoSource),
        changes,
      ),
      quickTodos: LocalQuickTodoRepository(todoSource, changes),
      changes: changes,
    );
  }
}

class LocalCourseRepository implements CourseRepository {
  const LocalCourseRepository(this._source, this._changes);

  final LocalCourseSource _source;
  final DataRefreshNotifier _changes;

  @override
  Future<List<Course>> getCoursesForWeek(int week, {String? semesterId}) {
    return _source.getCoursesForWeek(week, semesterId: semesterId);
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
  Future<Course> createCourse(CourseDraft draft) async {
    final course = await _source.createCourse(draft);
    _changes.markChanged();
    return course;
  }

  @override
  Future<Course> updateCourse(String courseId, CourseDraft draft) async {
    final course = await _source.updateCourse(courseId, draft);
    _changes.markChanged();
    return course;
  }

  @override
  Future<Course> cancelCourseForWeek(String courseId, int week) async {
    final course = await _source.cancelCourseForWeek(courseId, week);
    _changes.markChanged();
    return course;
  }

  @override
  Future<void> deleteCourse(String courseId) async {
    await _source.deleteCourse(courseId);
    _changes.markChanged();
  }

  @override
  String colorKeyForCourseName(String name) {
    return _source.colorKeyForCourseName(name);
  }
}

class LocalTodoRepository implements TodoRepository {
  const LocalTodoRepository(this._source, this._changes);

  final LocalTodoSource _source;
  final DataRefreshNotifier _changes;

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
  Future<bool> isSmartSortEnabled() {
    return _source.isSmartSortEnabled();
  }

  @override
  Future<TodoItem> createTodo(TodoDraft draft) async {
    final todo = await _source.createTodo(draft);
    _changes.markChanged();
    return todo;
  }

  @override
  Future<TodoItem> updateTodo(String todoId, TodoPatch patch) async {
    final todo = await _source.updateTodo(todoId, patch);
    _changes.markChanged();
    return todo;
  }

  @override
  Future<void> deleteTodo(String todoId) async {
    await _source.deleteTodo(todoId);
    _changes.markChanged();
  }

  @override
  Future<TodoItem> completeTodo(String todoId) async {
    final todo = await _source.completeTodo(todoId);
    _changes.markChanged();
    return todo;
  }

  @override
  Future<TodoItem> reopenTodo(String todoId) async {
    final todo = await _source.reopenTodo(todoId);
    _changes.markChanged();
    return todo;
  }

  @override
  Future<TodoItem> toggleTodoCompletion(String todoId) async {
    final todo = await _source.toggleTodoCompletion(todoId);
    _changes.markChanged();
    return todo;
  }

  @override
  Future<void> reorderTodos(List<String> orderedTodoIds) async {
    await _source.reorderTodos(orderedTodoIds);
    _changes.markChanged();
  }

  @override
  Future<void> smartSortTodos() async {
    await _source.smartSortTodos();
    _changes.markChanged();
  }

  @override
  Future<void> disableSmartSort() async {
    await _source.disableSmartSort();
    _changes.markChanged();
  }

  @override
  Future<void> batchDelete(List<String> todoIds) async {
    await _source.batchDelete(todoIds);
    _changes.markChanged();
  }

  @override
  Future<List<TodoItem>> batchComplete(List<String> todoIds) async {
    final todos = await _source.batchComplete(todoIds);
    if (todos.isNotEmpty) {
      _changes.markChanged();
    }
    return todos;
  }
}

class LocalTagRepository implements TagRepository {
  const LocalTagRepository(this._source, this._todos, this._changes);

  final LocalTagSource _source;
  final LocalTodoSource _todos;
  final DataRefreshNotifier _changes;

  @override
  Future<List<String>> getTags() {
    return _source.getTags();
  }

  @override
  Future<String> addTag(String name) {
    return _source.addTag(name);
  }

  @override
  Future<void> deleteTag(String name) async {
    final removedTag = await _source.deleteTag(name);
    final changedTodos = await _todos.removeTagFromTodos(name);
    if (removedTag || changedTodos) {
      _changes.markChanged();
    }
  }
}

class LocalQuickTodoRepository implements QuickTodoRepository {
  const LocalQuickTodoRepository(this._source, this._changes);

  final LocalTodoSource _source;
  final DataRefreshNotifier _changes;

  @override
  Future<TodoItem> createFromSentence(String sentence) async {
    final title = sentence.trim();
    if (title.isEmpty) {
      throw ArgumentError.value(sentence, 'sentence', '内容不能为空');
    }
    final todo = await _source.createTodo(TodoDraft(title: title));
    _changes.markChanged();
    return todo;
  }
}

class LocalSettingsRepository implements SettingsRepository {
  const LocalSettingsRepository(this._source, this._changes);

  final LocalSettingsSource _source;
  final DataRefreshNotifier _changes;

  @override
  Future<SemesterSettings> getSemesterSettings() {
    return _source.getSemesterSettings();
  }

  @override
  Future<SemesterTimetable> addSemesterTimetable({
    DateTime? startDate,
    int weekCount = 16,
    String owner = '我',
    String? schoolYear,
    SemesterTermType? termType,
  }) async {
    final semester = await _source.addSemesterTimetable(
      startDate: startDate,
      weekCount: weekCount,
      owner: owner,
      schoolYear: schoolYear,
      termType: termType,
    );
    _changes.markChanged();
    return semester;
  }

  @override
  Future<SemesterTimetable> saveSemesterTimetable(
    SemesterTimetable semester,
  ) async {
    final saved = await _source.saveSemesterTimetable(semester);
    _changes.markChanged();
    return saved;
  }

  @override
  Future<void> updateSemesterTimetable(SemesterTimetable semester) async {
    await _source.updateSemesterTimetable(semester);
    _changes.markChanged();
  }

  @override
  Future<void> deleteSemesterTimetable(String semesterId) async {
    await _source.deleteSemesterTimetable(semesterId);
    _changes.markChanged();
  }

  @override
  Future<void> setLastSelectedSemesterId(String semesterId) async {
    await _source.setLastSelectedSemesterId(semesterId);
    _changes.markChanged();
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
  const LocalGoalSplitRepository(this._source, this._changes);

  final LocalGoalSplitSource _source;
  final DataRefreshNotifier _changes;

  @override
  Future<void> createFromGoalSplit(GoalSplitDraft draft) async {
    await _source.createFromGoalSplit(draft);
    _changes.markChanged();
  }
}
