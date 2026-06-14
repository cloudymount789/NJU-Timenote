import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../core/widgets/gradient_page_scaffold.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/course.dart';
import '../../data/models/settings.dart';
import '../../data/sources/local/local_course_source.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  int _currentWeek = 1;
  late Future<_ScheduleLoad> _scheduleFuture;
  var _didSetInitialWeek = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCourses();
  }

  void _loadCourses() {
    _scheduleFuture = _loadSchedule();
  }

  Future<_ScheduleLoad> _loadSchedule() async {
    final repos = AppScope.repositoriesOf(context);
    final now = AppScope.clockOf(context).now();
    final settings = await repos.settings.getSemesterSettings();
    final semester = settings.activeSemester;
    if (!_didSetInitialWeek) {
      final computedWeek = semester.weekForDate(now);
      final initialWeek = computedWeek.clamp(0, 25).toInt();
      if (mounted) {
        setState(() {
          _currentWeek = initialWeek;
          _didSetInitialWeek = true;
        });
      } else {
        _currentWeek = initialWeek;
        _didSetInitialWeek = true;
      }
    }
    final courses = await repos.courses.getCoursesForWeek(
      _currentWeek,
      semesterId: semester.id,
    );
    return _ScheduleLoad(semester: semester, courses: courses);
  }

  void _changeWeek(int delta) {
    final next = (_currentWeek + delta).clamp(0, 25).toInt();
    if (next == _currentWeek) {
      return;
    }
    setState(() {
      _currentWeek = next;
      _loadCourses();
    });
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
    final now = AppScope.clockOf(context).now();
    return GradientPageScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
        child: Column(
          children: [
            _ScheduleHeader(
              onBack: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              onAdd: () async {
                await Navigator.of(context).pushNamed(AppRoutes.scheduleAdd);
                if (mounted) {
                  setState(_loadCourses);
                }
              },
            ),
            const SizedBox(height: 2),
            _WeekSwitcher(
              currentWeek: _currentWeek,
              onPrevious: _currentWeek == 0 ? null : () => _changeWeek(-1),
              onNext: _currentWeek == 25 ? null : () => _changeWeek(1),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: FutureBuilder<_ScheduleLoad>(
                future: _scheduleFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const AppCard(child: LoadingState());
                  }
                  if (snapshot.hasError) {
                    return const AppCard(child: ErrorState(message: '无法读取课表。'));
                  }
                  final data = snapshot.data;
                  final courses = data?.courses ?? const <Course>[];
                  final semester = data?.semester ?? defaultSemesterTimetable;
                  final todayWeek = semester.weekForDate(now);
                  return TimetableView(
                    courses: courses,
                    week: _currentWeek,
                    currentDate: now,
                    semesterStartDate: semester.semesterStartDate,
                    todayWeekday: _currentWeek == todayWeek
                        ? now.weekday
                        : null,
                    onDeleteCourse: _deleteCourse,
                    onOpenCourse: (course) async {
                      await Navigator.of(context).pushNamed(
                        AppRoutes.scheduleAddManual,
                        arguments: CourseDetailRouteArgs(courseId: course.id),
                      );
                      if (mounted) {
                        setState(_loadCourses);
                      }
                    },
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

class _ScheduleLoad {
  const _ScheduleLoad({required this.semester, required this.courses});

  final SemesterTimetable semester;
  final List<Course> courses;
}

class _ScheduleHeader extends StatelessWidget {
  const _ScheduleHeader({required this.onBack, required this.onAdd});

  final VoidCallback onBack;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Row(
        children: [
          AppIconButton(
            icon: Icons.chevron_left,
            tooltip: '返回',
            onPressed: onBack,
            size: 34,
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              '课表',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 30,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
          ),
          AppIconButton(
            icon: Icons.add,
            tooltip: '添加课表',
            onPressed: onAdd,
            size: 34,
          ),
        ],
      ),
    );
  }
}

class _WeekSwitcher extends StatelessWidget {
  const _WeekSwitcher({
    required this.currentWeek,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentWeek;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.54),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: '上一周',
                onPressed: onPrevious,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.chevron_left, size: 24),
              ),
              Text(
                '第 $currentWeek 周',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                tooltip: '下一周',
                onPressed: onNext,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.chevron_right, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimetableView extends StatelessWidget {
  const TimetableView({
    required this.courses,
    required this.onDeleteCourse,
    required this.onOpenCourse,
    this.week = 1,
    this.currentDate,
    this.semesterStartDate,
    this.todayWeekday,
    super.key,
  });

  static const rowHeight = 55.0;
  static const headerHeight = 42.0;
  static const periodWidth = 38.0;
  static const weekdays = <String>['一', '二', '三', '四', '五', '六', '日'];

  final List<Course> courses;
  final ValueChanged<Course> onDeleteCourse;
  final ValueChanged<Course> onOpenCourse;
  final int week;
  final DateTime? currentDate;
  final DateTime? semesterStartDate;
  final int? todayWeekday;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      radius: 12,
      shadowPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dayWidth = math.max(
            45.0,
            (constraints.maxWidth - periodWidth) / 7,
          );
          final tableWidth = periodWidth + dayWidth * 7;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Column(
                children: [
                  _WeekHeader(
                    dayWidth: dayWidth,
                    todayWeekday: todayWeekday,
                    dates: _weekDates(
                      currentDate ?? DateTime(2026, 6, 12),
                      semesterStartDate,
                      week,
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
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
                        if (courses.isEmpty)
                          const Center(
                            child: EmptyState(
                              title: '暂无课程',
                              message: '点击右上角加号添加第一门课。',
                              icon: Icons.calendar_month_outlined,
                            ),
                          ),
                      ],
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
      final blockWidth = (dayWidth - 1) / conflictCount;
      return Positioned(
        left:
            (segment.course.dayOfWeek - 1) * dayWidth +
            0.5 +
            math.max(0, conflictIndex) * blockWidth,
        top: (segment.start - 1) * rowHeight + 1,
        width: blockWidth - 1,
        height: (segment.end - segment.start + 1) * rowHeight - 2,
        child: _CourseBlock(
          segment: segment,
          onTap: () => onOpenCourse(segment.course),
          onLongPress: () => onDeleteCourse(segment.course),
        ),
      );
    }).toList();
  }

  List<DateTime> _weekDates(DateTime now, DateTime? semesterStart, int week) {
    final anchor = semesterStart ?? now;
    final monday = DateTime(
      anchor.year,
      anchor.month,
      anchor.day,
    ).subtract(Duration(days: anchor.weekday - 1));
    final targetMonday = monday.add(Duration(days: (week - 1) * 7));
    return [
      for (var index = 0; index < 7; index += 1)
        targetMonday.add(Duration(days: index)),
    ];
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({
    required this.dayWidth,
    required this.todayWeekday,
    required this.dates,
  });

  final double dayWidth;
  final int? todayWeekday;
  final List<DateTime> dates;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: TimetableView.headerHeight,
      child: Row(
        children: [
          const SizedBox(width: TimetableView.periodWidth),
          for (var index = 0; index < TimetableView.weekdays.length; index += 1)
            SizedBox(
              width: dayWidth,
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: todayWeekday == index + 1
                        ? const Color(0xFFE8F0FF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: todayWeekday == index + 1
                        ? Border.all(color: AppColors.primary)
                        : null,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '周${TimetableView.weekdays[index]}',
                          style: TextStyle(
                            color: todayWeekday == index + 1
                                ? AppColors.primary
                                : AppColors.muted,
                            fontSize: 12,
                            fontWeight: todayWeekday == index + 1
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                        Text(
                          _dateText(dates[index]),
                          style: TextStyle(
                            color: todayWeekday == index + 1
                                ? AppColors.primary
                                : AppColors.subtle,
                            fontSize: 9,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
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
                child: _PeriodLabel(periodTime: defaultPeriodTimes[period - 1]),
              ),
            ),
        ],
      ),
    );
  }
}

class _PeriodLabel extends StatelessWidget {
  const _PeriodLabel({required this.periodTime});

  final PeriodTimeConfig periodTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${periodTime.period}',
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 0.95,
          ),
        ),
        Text(
          periodTime.start,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 8,
            height: 0.95,
          ),
        ),
        Text(
          periodTime.end,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 8,
            height: 0.95,
          ),
        ),
      ],
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
  const _CourseBlock({
    required this.segment,
    required this.onTap,
    required this.onLongPress,
  });

  final _CourseSegment segment;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final course = segment.course;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _courseColor(course.colorKey),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 34;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: narrow ? 1 : 2,
                    child: Text(
                      course.name,
                      maxLines: narrow ? 2 : 4,
                      overflow: TextOverflow.fade,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                  ),
                  if (!narrow) ...[
                    const SizedBox(height: 3),
                    Flexible(
                      child: Text(
                        course.location,
                        maxLines: 3,
                        overflow: TextOverflow.fade,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 9,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
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

String _dateText(DateTime date) {
  return '${date.month.toString().padLeft(2, '0')}/'
      '${date.day.toString().padLeft(2, '0')}';
}
