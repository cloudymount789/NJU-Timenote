import 'package:flutter/material.dart';

import '../data/models/recommendation.dart';
import '../features/goal_split/goal_split_page.dart';
import '../features/home/home_page.dart';
import '../features/recommendation/next_thing_page.dart';
import '../features/schedule/add_schedule_page.dart';
import '../features/schedule/manual_course_page.dart';
import '../features/schedule/schedule_page.dart';
import '../features/schedule/screenshot_course_page.dart';
import '../features/settings/semester_pages.dart';
import '../features/settings/settings_page.dart';
import '../features/todo/todo_detail_page.dart';
import '../features/todo/todo_list_page.dart';
import '../features/todo/todo_search_page.dart';
import '../features/todo/todo_tag_page.dart';

class AppRoutes {
  const AppRoutes._();

  static const home = '/';
  static const settings = '/settings';
  static const semesters = '/settings/semesters';
  static const semesterDetail = '/settings/semesters/detail';
  static const schedule = '/schedule';
  static const scheduleAdd = '/schedule/add';
  static const scheduleAddManual = '/schedule/add/manual';
  static const scheduleAddScreenshot = '/schedule/add/screenshot';
  static const todos = '/todos';
  static const todoDetail = '/todos/detail';
  static const todoTags = '/todos/tags';
  static const todoSearch = '/todos/search';
  static const nextThing = '/todos/next';
  static const nextThingRecommend = '/todos/next/recommend';
  static const goalSplit = '/todos/goal-split';
}

class CourseDetailRouteArgs {
  const CourseDetailRouteArgs({this.courseId});

  final String? courseId;
}

class SemesterDetailRouteArgs {
  const SemesterDetailRouteArgs({this.semesterId});

  final String? semesterId;
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

class RecommendationRouteArgs {
  const RecommendationRouteArgs({required this.input});

  final RecommendationInput input;
}

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case AppRoutes.home:
        page = const HomePage();
      case AppRoutes.settings:
        page = const SettingsPage();
      case AppRoutes.semesters:
        page = const SemesterListPage();
      case AppRoutes.semesterDetail:
        final args = settings.arguments;
        page = SemesterDetailPage(
          semesterId: args is SemesterDetailRouteArgs ? args.semesterId : null,
        );
      case AppRoutes.schedule:
        page = const SchedulePage();
      case AppRoutes.scheduleAdd:
        page = const AddSchedulePage();
      case AppRoutes.scheduleAddManual:
        final args = settings.arguments;
        page = ManualCoursePage(
          courseId: args is CourseDetailRouteArgs ? args.courseId : null,
        );
      case AppRoutes.scheduleAddScreenshot:
        page = const ScreenshotCoursePage();
      case AppRoutes.todos:
        page = const TodoListPage();
      case AppRoutes.todoDetail:
        final args = settings.arguments;
        page = TodoDetailPage(
          isCreate: args is TodoDetailRouteArgs && args.isCreate,
          todoId: args is TodoDetailRouteArgs ? args.todoId : null,
        );
      case AppRoutes.todoTags:
        final args = settings.arguments;
        page = TodoTagPage(
          initialTags: args is TodoTagRouteArgs ? args.initialTags : const [],
        );
      case AppRoutes.todoSearch:
        page = const TodoSearchPage();
      case AppRoutes.nextThing:
        page = const NextThingPage();
      case AppRoutes.nextThingRecommend:
        final args = settings.arguments;
        page = NextThingRecommendPage(
          input: args is RecommendationRouteArgs
              ? args.input
              : const RecommendationInput(
                  mood: 52,
                  willingness: 68,
                  anxiety: 35,
                ),
        );
      case AppRoutes.goalSplit:
        final args = settings.arguments;
        page = GoalSplitPage(
          initialTitle: args is GoalSplitRouteArgs ? args.initialTitle : null,
        );
      default:
        page = const HomePage();
    }

    return MaterialPageRoute<dynamic>(builder: (_) => page, settings: settings);
  }
}
