import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/app_database.dart';
import '../features/settings/data/local_settings_repository.dart';
import '../features/settings/models/settings.dart';
import '../features/settings/repositories/settings_repository.dart';
import '../features/timetable/data/local_course_repository.dart';
import '../features/timetable/models/course.dart';
import '../features/timetable/repositories/course_repository.dart';
import '../features/todos/data/local_todo_repository.dart';
import '../features/todos/domain/todo.dart';
import '../features/todos/domain/todo_repository.dart';

final selectedWeekProvider = Provider<int>((ref) => 6);

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final courseRepositoryProvider = Provider<CourseRepository>(
  (ref) => LocalCourseRepository(ref.watch(databaseProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => LocalSettingsRepository(ref.watch(databaseProvider)),
);

final todoRepositoryProvider = Provider<TodoRepository>(
  (ref) => LocalTodoRepository(ref.watch(databaseProvider)),
);

final coursesControllerProvider =
    AsyncNotifierProvider<CoursesController, List<Course>>(
      CoursesController.new,
    );

class CoursesController extends AsyncNotifier<List<Course>> {
  @override
  Future<List<Course>> build() {
    final week = ref.watch(selectedWeekProvider);
    return ref.watch(courseRepositoryProvider).fetchCourses(week: week);
  }

  Future<Course> addCourse(CourseDraft draft) async {
    final repository = ref.read(courseRepositoryProvider);
    final course = await repository.addCourse(draft);
    ref.invalidateSelf();
    await future;
    return course;
  }

  Future<Course> updateCourse(String courseId, CourseDraft draft) async {
    final repository = ref.read(courseRepositoryProvider);
    final course = await repository.updateCourse(courseId, draft);
    ref.invalidateSelf();
    await future;
    return course;
  }

  Future<void> deleteCourse(String courseId) async {
    await ref.read(courseRepositoryProvider).deleteCourse(courseId);
    ref.invalidateSelf();
    await future;
  }

  Future<List<Course>> importCoursesFromScreenshot() async {
    final courses = await ref
        .read(courseRepositoryProvider)
        .importCoursesFromScreenshot();
    ref.invalidateSelf();
    await future;
    return courses;
  }
}

final semesterSettingsProvider = FutureProvider<SemesterSettings>((ref) {
  return ref.watch(settingsRepositoryProvider).fetchSemesterSettings();
});

final todosControllerProvider =
    AsyncNotifierProvider<TodosController, TodosState>(TodosController.new);

class TodosController extends AsyncNotifier<TodosState> {
  @override
  Future<TodosState> build() async {
    final repository = ref.watch(todoRepositoryProvider);
    final todos = await repository.fetchTodos();
    final tags = await repository.fetchTags();
    final history = await repository.fetchSearchHistory();
    return TodosState(todos: todos, tags: tags, searchHistory: history);
  }

  TodoRepository get _repository => ref.read(todoRepositoryProvider);

  Future<void> setFilter(TodoFilter filter) async {
    final current = await future;
    final todos = await _repository.fetchTodos(filter: filter);
    state = AsyncData(current.copyWith(todos: todos, filter: filter));
  }

  Future<void> clearFilter() => setFilter(const TodoFilter());

  Future<TodoItem> create(TodoDraft draft) async {
    final created = await _repository.createTodo(draft);
    await _refreshKeepingFilter();
    return created;
  }

  Future<TodoItem> updateTodo(String todoId, TodoPatch patch) async {
    final updated = await _repository.updateTodo(todoId, patch);
    await _refreshKeepingFilter();
    return updated;
  }

  Future<void> delete(String todoId) async {
    await _repository.deleteTodo(todoId);
    await _refreshKeepingFilter();
  }

  Future<void> complete(String todoId) async {
    await _repository.completeTodo(todoId);
    await _refreshKeepingFilter();
  }

  Future<void> batchDelete(Set<String> todoIds) async {
    await _repository.batchDelete(todoIds);
    await _refreshKeepingFilter();
  }

  Future<void> batchComplete(Set<String> todoIds) async {
    await _repository.batchComplete(todoIds);
    await _refreshKeepingFilter();
  }

  Future<String> addTag(String name) async {
    final tag = await _repository.addTag(name);
    final current = await future;
    state = AsyncData(current.copyWith(tags: await _repository.fetchTags()));
    return tag;
  }

  Future<List<TodoItem>> search(String query) async {
    final results = await _repository.searchTodos(query);
    if (query.trim().isNotEmpty) {
      final current = await future;
      final history = [
        query.trim(),
        ...current.searchHistory.where((item) => item != query.trim()),
      ].take(8).toList();
      state = AsyncData(current.copyWith(searchHistory: history));
    }
    return results;
  }

  Future<void> clearSearchHistory() async {
    await _repository.clearSearchHistory();
    final current = await future;
    state = AsyncData(current.copyWith(searchHistory: const []));
  }

  Future<List<TodoRecommendation>> recommend(RecommendationInput input) async {
    return _repository.recommendTodos(input);
  }

  Future<List<TodoItem>> createGoalSplit(GoalSplitDraft draft) async {
    final created = await _repository.createGoalSplitTodos(draft);
    await _refreshKeepingFilter();
    return created;
  }

  TodoItem? todoById(String id) {
    return state.value?.todos.where((todo) => todo.id == id).firstOrNull;
  }

  Future<void> _refreshKeepingFilter() async {
    final current = await future;
    final todos = await _repository.fetchTodos(filter: current.filter);
    final tags = await _repository.fetchTags();
    state = AsyncData(current.copyWith(todos: todos, tags: tags));
  }
}

class TodosState {
  const TodosState({
    required this.todos,
    required this.tags,
    this.filter = const TodoFilter(),
    this.searchHistory = const [],
  });

  final List<TodoItem> todos;
  final List<String> tags;
  final TodoFilter filter;
  final List<String> searchHistory;

  List<TodoItem> get deadlineTodos =>
      todos.where((todo) => todo.hasDeadline && !todo.isDone).toList();

  TodosState copyWith({
    List<TodoItem>? todos,
    List<String>? tags,
    TodoFilter? filter,
    List<String>? searchHistory,
  }) {
    return TodosState(
      todos: todos ?? this.todos,
      tags: tags ?? this.tags,
      filter: filter ?? this.filter,
      searchHistory: searchHistory ?? this.searchHistory,
    );
  }
}
