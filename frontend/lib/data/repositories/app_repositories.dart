import 'course_repository.dart';
import 'goal_split_repository.dart';
import 'quick_todo_repository.dart';
import 'recommendation_repository.dart';
import 'settings_repository.dart';
import 'tag_repository.dart';
import 'todo_repository.dart';

class AppRepositories {
  const AppRepositories({
    required this.courses,
    required this.todos,
    required this.tags,
    required this.settings,
    required this.recommendations,
    required this.goalSplits,
    required this.quickTodos,
  });

  final CourseRepository courses;
  final TodoRepository todos;
  final TagRepository tags;
  final SettingsRepository settings;
  final RecommendationRepository recommendations;
  final GoalSplitRepository goalSplits;
  final QuickTodoRepository quickTodos;
}
