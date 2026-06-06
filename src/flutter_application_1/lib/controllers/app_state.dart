import 'package:flutter/widgets.dart';

import '../models/course.dart';
import '../models/settings.dart';
import '../models/todo_item.dart';
import '../repositories/course_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/todo_repository.dart';

class TimenoteState extends ChangeNotifier {
  TimenoteState({
    required this.courseRepository,
    required this.todoRepository,
    required this.settingsRepository,
  });

  final CourseRepository courseRepository;
  final TodoRepository todoRepository;
  final SettingsRepository settingsRepository;

  int selectedWeek = 6;
  List<Course> courses = [];
  List<TodoItem> todos = [];
  SemesterSettings? settings;
  bool isLoading = false;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    final loaded = await Future.wait([
      courseRepository.fetchCourses(week: selectedWeek),
      todoRepository.fetchTodos(),
      settingsRepository.fetchSemesterSettings(),
    ]);
    courses = loaded[0] as List<Course>;
    todos = loaded[1] as List<TodoItem>;
    settings = loaded[2] as SemesterSettings;
    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshCourses() async {
    courses = await courseRepository.fetchCourses(week: selectedWeek);
    notifyListeners();
  }

  Future<Course> addCourse(CourseDraft draft) async {
    final course = await courseRepository.addCourse(draft);
    await refreshCourses();
    return course;
  }

  Future<void> deleteCourse(String courseId) async {
    await courseRepository.deleteCourse(courseId);
    await refreshCourses();
  }

  Future<List<Course>> importCoursesFromScreenshot() async {
    final imported = await courseRepository.importCoursesFromScreenshot();
    await refreshCourses();
    return imported;
  }

  List<Course> coursesForDay(int dayOfWeek) {
    return courses.where((course) => course.dayOfWeek == dayOfWeek).toList();
  }

  List<TodoItem> get deadlineTodos =>
      todos.where((todo) => todo.hasDeadline).toList();
}

class TimenoteScope extends InheritedNotifier<TimenoteState> {
  const TimenoteScope({
    required TimenoteState state,
    required super.child,
    super.key,
  }) : super(notifier: state);

  static TimenoteState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TimenoteScope>();
    assert(scope != null, 'TimenoteScope not found in context');
    return scope!.notifier!;
  }
}
