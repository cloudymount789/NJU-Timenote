import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../core/widgets/gradient_page_scaffold.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/course.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  static const _currentWeek = 1;
  late Future<List<Course>> _coursesFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCourses();
  }

  void _loadCourses() {
    _coursesFuture = AppScope.repositoriesOf(
      context,
    ).courses.getCoursesForWeek(_currentWeek);
  }

  Future<void> _deleteCourse(Course course) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: '删除课程？',
      message: '删除后无法恢复。',
      confirmText: '删除',
    );
    if (confirmed != true || !mounted) {
      return;
    }
    await AppScope.repositoriesOf(context).courses.deleteCourse(course.id);
    if (!mounted) {
      return;
    }
    setState(_loadCourses);
  }

  @override
  Widget build(BuildContext context) {
    return GradientPageScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 20, 12, 20),
        child: Column(
          children: [
            AppHeader(
              title: '课表',
              subtitle: '第 $_currentWeek 周',
              onBack: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              trailing: AppIconButton(
                icon: Icons.add,
                tooltip: '添加课表',
                onPressed: () async {
                  await Navigator.of(context).pushNamed(AppRoutes.scheduleAdd);
                  if (mounted) {
                    setState(_loadCourses);
                  }
                },
                size: 36,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<Course>>(
                future: _coursesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const AppCard(child: LoadingState());
                  }
                  if (snapshot.hasError) {
                    return const AppCard(child: ErrorState(message: '无法读取课表。'));
                  }
                  final courses = snapshot.data ?? const <Course>[];
                  if (courses.isEmpty) {
                    return const AppCard(
                      child: Center(
                        child: EmptyState(
                          title: '暂无课程',
                          message: '点击右上角加号添加第一门课。',
                          icon: Icons.calendar_month_outlined,
                        ),
                      ),
                    );
                  }
                  return TimetableView(
                    courses: courses,
                    onDeleteCourse: _deleteCourse,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimetableView extends StatelessWidget {
  const TimetableView({
    required this.courses,
    required this.onDeleteCourse,
    super.key,
  });

  static const rowHeight = 58.0;
  static const headerHeight = 38.0;
  static const periodWidth = 34.0;
  static const weekdays = <String>['一', '二', '三', '四', '五', '六', '日'];

  final List<Course> courses;
  final ValueChanged<Course> onDeleteCourse;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      radius: 12,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dayWidth = math.max(
            46.0,
            (constraints.maxWidth - periodWidth) / 7,
          );
          final tableWidth = periodWidth + dayWidth * 7;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Column(
                children: [
                  _WeekHeader(dayWidth: dayWidth),
                  Expanded(
                    child: SingleChildScrollView(
                      child: SizedBox(
                        height: rowHeight * 12,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _PeriodColumn(),
                            SizedBox(
                              width: dayWidth * 7,
                              height: rowHeight * 12,
                              child: Stack(
                                children: [
                                  _GridLines(dayWidth: dayWidth),
                                  ..._buildCourseBlocks(dayWidth),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildCourseBlocks(double dayWidth) {
    final segments = <_CourseSegment>[];
    for (final course in courses) {
      if (course.startPeriod <= 4 && course.endPeriod >= 5) {
        segments.add(_CourseSegment(course, course.startPeriod, 4));
        segments.add(_CourseSegment(course, 5, course.endPeriod));
      } else {
        segments.add(
          _CourseSegment(course, course.startPeriod, course.endPeriod),
        );
      }
    }

    return segments.map((segment) {
      final sameDay =
          segments.where((other) {
            return other.course.dayOfWeek == segment.course.dayOfWeek &&
                other.overlaps(segment);
          }).toList()..sort((a, b) {
            final startCompare = a.start.compareTo(b.start);
            if (startCompare != 0) {
              return startCompare;
            }
            return a.course.id.compareTo(b.course.id);
          });
      final conflictCount = math.max(1, sameDay.length);
      final conflictIndex = sameDay.indexWhere(
        (item) =>
            item.course.id == segment.course.id &&
            item.start == segment.start &&
            item.end == segment.end,
      );
      final blockWidth = (dayWidth - 4) / conflictCount;
      return Positioned(
        left:
            (segment.course.dayOfWeek - 1) * dayWidth +
            2 +
            math.max(0, conflictIndex) * blockWidth,
        top: (segment.start - 1) * rowHeight + 3,
        width: blockWidth - 2,
        height: (segment.end - segment.start + 1) * rowHeight - 6,
        child: _CourseBlock(
          segment: segment,
          onLongPress: () => onDeleteCourse(segment.course),
        ),
      );
    }).toList();
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({required this.dayWidth});

  final double dayWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: TimetableView.headerHeight,
      child: Row(
        children: [
          const SizedBox(width: TimetableView.periodWidth),
          for (final day in TimetableView.weekdays)
            SizedBox(
              width: dayWidth,
              child: Center(
                child: Text(
                  '周$day',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PeriodColumn extends StatelessWidget {
  const _PeriodColumn();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: TimetableView.periodWidth,
      child: Column(
        children: [
          for (var period = 1; period <= 12; period++)
            SizedBox(
              height: TimetableView.rowHeight,
              child: Center(
                child: Text(
                  '$period',
                  style: const TextStyle(color: AppColors.subtle, fontSize: 11),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GridLines extends StatelessWidget {
  const _GridLines({required this.dayWidth});

  final double dayWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(dayWidth * 7, TimetableView.rowHeight * 12),
      painter: _GridPainter(dayWidth: dayWidth),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter({required this.dayWidth});

  final double dayWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.line
      ..strokeWidth = 0.7;
    for (var day = 0; day <= 7; day++) {
      final x = day * dayWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var row = 0; row <= 12; row++) {
      final y = row * TimetableView.rowHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) {
    return dayWidth != oldDelegate.dayWidth;
  }
}

class _CourseSegment {
  const _CourseSegment(this.course, this.start, this.end);

  final Course course;
  final int start;
  final int end;

  bool overlaps(_CourseSegment other) {
    return start <= other.end && end >= other.start;
  }
}

class _CourseBlock extends StatelessWidget {
  const _CourseBlock({required this.segment, required this.onLongPress});

  final _CourseSegment segment;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final course = segment.course;
    return GestureDetector(
      onLongPress: onLongPress,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _courseColor(course.colorKey),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                course.location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted, fontSize: 9),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _courseColor(String colorKey) {
    return switch (colorKey) {
      'purple' => AppColors.coursePurple,
      'pink' => AppColors.coursePink,
      _ => AppColors.courseBlue,
    };
  }
}
