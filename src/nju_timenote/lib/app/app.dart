import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../features/home/home_screen.dart';
import '../features/settings/screens/period_editor_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/timetable/screens/add_course_entry_screen.dart';
import '../features/timetable/screens/manual_course_screen.dart';
import '../features/timetable/screens/screenshot_course_screen.dart';
import '../features/timetable/screens/timetable_screen.dart';
import '../features/todos/presentation/screens/batch_todos_screen.dart';
import '../features/todos/presentation/screens/goal_split_screen.dart';
import '../features/todos/presentation/screens/next_action_screen.dart';
import '../features/todos/presentation/screens/todo_detail_screen.dart';
import '../features/todos/presentation/screens/todo_search_screen.dart';
import '../features/todos/presentation/screens/todos_screen.dart';
import 'routes.dart';

class TimenoteApp extends ConsumerWidget {
  const TimenoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'NJU Timenote',
      debugShowCheckedModeBanner: false,
      theme: buildTimenoteTheme(),
      routes: {
        AppRoutes.periodEditor: (_) => const PeriodEditorScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
        AppRoutes.timetable: (_) => const TimetableScreen(),
        AppRoutes.addCourseEntry: (_) => const AddCourseEntryScreen(),
        AppRoutes.manualCourse: (_) => const ManualCourseScreen(),
        AppRoutes.screenshotCourse: (_) => const ScreenshotCourseScreen(),
        AppRoutes.todos: (_) => const TodosScreen(),
        AppRoutes.todoSearch: (_) => const TodoSearchScreen(),
        AppRoutes.todoDetail: (_) => const TodoDetailScreen(),
        AppRoutes.nextAction: (_) => const NextActionScreen(),
        AppRoutes.nextRecommendations: (_) => const NextRecommendationsScreen(),
        AppRoutes.batchTodos: (_) => const BatchTodosScreen(),
        AppRoutes.goalSplitSetup: (_) => const GoalSplitSetupScreen(),
        AppRoutes.goalSplitBreakdown: (_) => const GoalSplitBreakdownScreen(),
        AppRoutes.goalSplitReview: (_) => const GoalSplitReviewScreen(),
      },
    );
  }
}
