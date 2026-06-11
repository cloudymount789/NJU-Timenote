import 'package:flutter/material.dart';

import '../features/goal_split/goal_split_placeholder_page.dart';
import '../features/home/home_page.dart';
import '../features/recommendation/next_thing_page.dart';
import '../features/schedule/add_schedule_page.dart';
import '../features/schedule/manual_course_page.dart';
import '../features/schedule/schedule_page.dart';
import '../features/schedule/screenshot_course_page.dart';
import '../features/settings/settings_page.dart';
import '../features/todo/todo_detail_placeholder_page.dart';
import '../features/todo/todo_list_placeholder_page.dart';
import '../features/todo/todo_search_placeholder_page.dart';

class AppRoutes {
  const AppRoutes._();

  static const home = '/';
  static const settings = '/settings';
  static const schedule = '/schedule';
  static const scheduleAdd = '/schedule/add';
  static const scheduleAddManual = '/schedule/add/manual';
  static const scheduleAddScreenshot = '/schedule/add/screenshot';
  static const todos = '/todos';
  static const todoDetail = '/todos/detail';
  static const todoSearch = '/todos/search';
  static const nextThing = '/todos/next';
  static const goalSplit = '/todos/goal-split';
}

class TodoListRouteArgs {
  const TodoListRouteArgs({this.onlyDeadline = false});

  final bool onlyDeadline;
}

class TodoDetailRouteArgs {
  const TodoDetailRouteArgs({this.isCreate = false, this.todoId});

  final bool isCreate;
  final String? todoId;
}

class GoalSplitRouteArgs {
  const GoalSplitRouteArgs({this.initialTitle});

  final String? initialTitle;
}

class AppRouter {
  const AppRouter._();

  static Route<void> onGenerateRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case AppRoutes.home:
        page = const HomePage();
      case AppRoutes.settings:
        page = const SettingsPage();
      case AppRoutes.schedule:
        page = const SchedulePage();
      case AppRoutes.scheduleAdd:
        page = const AddSchedulePage();
      case AppRoutes.scheduleAddManual:
        page = const ManualCoursePage();
      case AppRoutes.scheduleAddScreenshot:
        page = const ScreenshotCoursePage();
      case AppRoutes.todos:
        final args = settings.arguments;
        page = TodoListPlaceholderPage(
          onlyDeadline: args is TodoListRouteArgs && args.onlyDeadline,
        );
      case AppRoutes.todoDetail:
        final args = settings.arguments;
        page = TodoDetailPlaceholderPage(
          isCreate: args is TodoDetailRouteArgs && args.isCreate,
        );
      case AppRoutes.todoSearch:
        page = const TodoSearchPlaceholderPage();
      case AppRoutes.nextThing:
        page = const NextThingPage();
      case AppRoutes.goalSplit:
        final args = settings.arguments;
        page = GoalSplitPlaceholderPage(
          initialTitle: args is GoalSplitRouteArgs ? args.initialTitle : null,
        );
      default:
        page = const HomePage();
    }

    return MaterialPageRoute<void>(builder: (_) => page, settings: settings);
  }
}
