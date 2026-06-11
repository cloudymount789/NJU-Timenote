import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/app_shell.dart';
import '../../settings/models/settings.dart';
import '../models/course.dart';
import '../widgets/timetable_grid.dart';

class TimetableScreen extends ConsumerWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(coursesControllerProvider).value ?? [];
    final settings = ref.watch(semesterSettingsProvider).value;
    final periods = settings?.periods ?? _fallbackPeriods;

    return AppGradientScaffold(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            child: Column(
              children: [
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
                borderRadius: BorderRadius.circular(AppRadii.card),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 370,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: TimetableGrid(
                        courses: courses,
                        periods: periods,
                        onCourseLongPress: (course) =>
                            _confirmDelete(context, ref, course),
                        onCourseTap: (course) =>
                            _showCourseDetail(context, ref, course),
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

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Course course,
  ) async {
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
      await ref
          .read(coursesControllerProvider.notifier)
          .deleteCourse(course.id);
    }
  }

  void _showCourseDetail(
    BuildContext context,
    WidgetRef ref,
    Course course,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.sheet)),
      ),
      builder: (ctx) => _CourseDetailSheet(course: course),
    );
  }
}

class _CourseDetailSheet extends StatelessWidget {
  const _CourseDetailSheet({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(course.name, style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              IconButton(
                tooltip: '编辑课程',
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(
                    AppRoutes.manualCourse,
                    arguments: course,
                  );
                },
                icon: const Icon(Icons.edit_outlined, color: AppColors.accent),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (course.teacher.isNotEmpty) ...[
            _DetailRow(icon: Icons.person_outline, label: '教师', value: course.teacher),
            const Divider(height: 1),
          ],
          _DetailRow(icon: Icons.location_on_outlined, label: '地点', value: course.location),
          if (course.note.isNotEmpty) ...[
            const Divider(height: 1),
            _DetailRow(icon: Icons.note_alt_outlined, label: '备注', value: course.note),
          ],
          const Divider(height: 1),
          _DetailRow(
            icon: Icons.access_time,
            label: '时间',
            value: '${PeriodRange.weekdayLabels[course.dayOfWeek - 1]} 第 ${course.startPeriod}-${course.endPeriod} 节',
          ),
          const Divider(height: 1),
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            label: '周次',
            value: '${course.startWeek}-${course.endWeek}周 ${weekRuleLabel(course.weekRule)}',
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
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
