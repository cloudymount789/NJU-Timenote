import 'package:flutter/material.dart';

import '../app.dart';
import '../controllers/app_state.dart';
import '../models/course.dart';
import '../models/settings.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/timetable_grid.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = TimenoteScope.of(context);
    final periods = state.settings?.periods ?? _fallbackPeriods;

    return AppGradientScaffold(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            child: Column(
              children: [
                const StatusHeader(),
                PageTitleBar(
                  title: '我的课表',
                  trailing: IconButton.filled(
                    key: const Key('timetable-add-button'),
                    tooltip: '添加课表',
                    onPressed: () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.addCourseEntry),
                    icon: const Icon(Icons.add, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 370,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: TimetableGrid(
                        courses: state.courses,
                        periods: periods,
                        onCourseLongPress: (course) =>
                            _confirmDelete(context, course),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Course course) async {
    final state = TimenoteScope.of(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text('是否确定删除课程？'),
        content: const Text('删除后无法恢复'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const Key('confirm-delete-course'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (shouldDelete == true && context.mounted) {
      await state.deleteCourse(course.id);
    }
  }
}

const _fallbackPeriods = [
  PeriodTime(period: 1, start: '08:00', end: '08:50'),
  PeriodTime(period: 2, start: '09:00', end: '09:50'),
  PeriodTime(period: 3, start: '10:10', end: '11:00'),
  PeriodTime(period: 4, start: '11:10', end: '12:00'),
  PeriodTime(period: 5, start: '14:00', end: '14:50'),
  PeriodTime(period: 6, start: '15:00', end: '15:50'),
  PeriodTime(period: 7, start: '16:10', end: '17:00'),
  PeriodTime(period: 8, start: '17:10', end: '18:00'),
  PeriodTime(period: 9, start: '18:30', end: '19:20'),
  PeriodTime(period: 10, start: '19:30', end: '20:20'),
  PeriodTime(period: 11, start: '20:30', end: '21:20'),
  PeriodTime(period: 12, start: '21:30', end: '22:20'),
];
