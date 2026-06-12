import 'package:flutter/foundation.dart';

import 'course_repository.dart';
import 'goal_split_repository.dart';
import 'quick_todo_repository.dart';
import 'recommendation_repository.dart';
import 'settings_repository.dart';
import 'tag_repository.dart';
import 'todo_repository.dart';

class AppRepositories {
  AppRepositories({
    required this.courses,
    required this.todos,
    required this.tags,
    required this.settings,
    required this.recommendations,
    required this.goalSplits,
    required this.quickTodos,
    DataRefreshNotifier? changes,
  }) : changes = changes ?? DataRefreshNotifier();

  final CourseRepository courses;
  final TodoRepository todos;
  final TagRepository tags;
  final SettingsRepository settings;
  final RecommendationRepository recommendations;
  final GoalSplitRepository goalSplits;
  final QuickTodoRepository quickTodos;
  final DataRefreshNotifier changes;
}

class DataRefreshNotifier extends ChangeNotifier {
  int _version = 0;

  int get version => _version;

  void markChanged() {
    _version += 1;
    notifyListeners();
  }
}
