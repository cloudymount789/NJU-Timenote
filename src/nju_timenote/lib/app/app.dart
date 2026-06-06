import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/home/home_screen.dart';
import '../features/settings/repositories/settings_repository.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/timetable/repositories/course_repository.dart';
import '../features/timetable/screens/add_course_entry_screen.dart';
import '../features/timetable/screens/manual_course_screen.dart';
import '../features/timetable/screens/screenshot_course_screen.dart';
import '../features/timetable/screens/timetable_screen.dart';
import '../features/todos/repositories/todo_repository.dart';
import '../features/todos/screens/placeholder_screen.dart';
import '../state/timenote_state.dart';
import 'routes.dart';

class TimenoteApp extends StatefulWidget {
  const TimenoteApp({super.key});

  @override
  State<TimenoteApp> createState() => _TimenoteAppState();
}

class _TimenoteAppState extends State<TimenoteApp> {
  late final TimenoteState _state;

  @override
  void initState() {
    super.initState();
    _state = TimenoteState(
      courseRepository: MockCourseRepository(),
      todoRepository: MockTodoRepository(),
      settingsRepository: MockSettingsRepository(),
    );
    _state.load();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TimenoteScope(
      state: _state,
      child: MaterialApp(
        title: 'NJU Timenote',
        debugShowCheckedModeBanner: false,
        theme: buildTimenoteTheme(),
        routes: {
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.settings: (_) => const SettingsScreen(),
          AppRoutes.timetable: (_) => const TimetableScreen(),
          AppRoutes.addCourseEntry: (_) => const AddCourseEntryScreen(),
          AppRoutes.manualCourse: (_) => const ManualCourseScreen(),
          AppRoutes.screenshotCourse: (_) => const ScreenshotCourseScreen(),
          AppRoutes.todos: (_) => const PlaceholderScreen(
            title: '待办',
            subtitle: '待办列表将在后续版本接入完整界面。',
          ),
          AppRoutes.todoSearch: (_) => const PlaceholderScreen(
            title: '待办搜索',
            subtitle: '搜索待办、课程关联事项和 DDL。',
          ),
          AppRoutes.nextAction: (_) => const PlaceholderScreen(
            title: '下一件事',
            subtitle: '这里会展示智能挑选出的下一步行动。',
          ),
          AppRoutes.batchTodos: (_) =>
              const PlaceholderScreen(title: '批量操作', subtitle: '批量完成、移动或归档待办。'),
        },
      ),
    );
  }
}
