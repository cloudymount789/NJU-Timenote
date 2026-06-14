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
  int _currentWeekMax = defaultSemesterTimetable.weekCount;
  String? _selectedSemesterId;
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

  Future<void> _refreshSchedule() async {
    setState(_loadCourses);
    await _scheduleFuture;
  }

  Future<_ScheduleLoad> _loadSchedule() async {
    final repos = AppScope.repositoriesOf(context);
    final now = AppScope.clockOf(context).now();
    final settings = await repos.settings.getSemesterSettings();
    var semester = _selectedSemesterId == null
        ? settings.activeSemester
        : settings.semesterById(_selectedSemesterId!) ??
              settings.activeSemester;
    _selectedSemesterId = semester.id;
    _currentWeekMax = semester.weekCount;
    if (!_didSetInitialWeek) {
      final initialWeek = _boundedWeekForDate(semester, now);
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
    final queryWeek = _currentWeek.clamp(1, semester.weekCount).toInt();
    if (queryWeek != _currentWeek) {
      _currentWeek = queryWeek;
    }
    final courses = await repos.courses.getCoursesForWeek(
      queryWeek,
      semesterId: semester.id,
    );
    return _ScheduleLoad(
      semester: semester,
      semesters: settings.semesters,
      courses: courses,
    );
  }

  Future<void> _changeSemester(SemesterTimetable semester) async {
    await AppScope.repositoriesOf(
      context,
    ).settings.setLastSelectedSemesterId(semester.id);
    if (!mounted) {
      return;
    }
    final now = AppScope.clockOf(context).now();
    setState(() {
      _selectedSemesterId = semester.id;
      _currentWeekMax = semester.weekCount;
      _currentWeek = _boundedWeekForDate(semester, now);
      _didSetInitialWeek = true;
      _loadCourses();
    });
  }

  void _changeWeek(int delta) {
    final next = (_currentWeek + delta).clamp(1, _currentWeekMax).toInt();
    if (next == _currentWeek) {
      return;
    }
    setState(() {
      _currentWeek = next;
      _loadCourses();
    });
  }

  Future<void> _deleteCourse(Course course) async {
    final scope = await _pickDeleteScope();
    if (scope == null || !mounted) {
      return;
    }
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: scope == _CourseDeleteScope.once ? '删除这一次课？' : '删除所有课程？',
      message: scope == _CourseDeleteScope.once
          ? '只会隐藏第 $_currentWeek 周的这一次课，其他周不受影响。'
          : '删除后这门课的所有周都不再显示。',
      confirmText: '删除',
    );
    if (confirmed != true || !mounted) {
      return;
    }
    final repository = AppScope.repositoriesOf(context).courses;
    if (scope == _CourseDeleteScope.once) {
      await repository.cancelCourseForWeek(course.id, _currentWeek);
    } else {
      await repository.deleteCourse(course.id);
    }
    if (!mounted) {
      return;
    }
    setState(_loadCourses);
  }

  Future<_CourseDeleteScope?> _pickDeleteScope() {
    return showModalBottomSheet<_CourseDeleteScope>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.event_busy_outlined),
                title: const Text('仅删除这一次课'),
                subtitle: Text('第 $_currentWeek 周不再显示'),
                onTap: () => Navigator.of(context).pop(_CourseDeleteScope.once),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('删除所有课程'),
                subtitle: const Text('删除整门课的课程规则'),
                onTap: () => Navigator.of(context).pop(_CourseDeleteScope.all),
              ),
            ],
          ),
        );
      },
    );
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
                await Navigator.of(context).pushNamed(
                  AppRoutes.scheduleAdd,
                  arguments: CourseDetailRouteArgs(
                    semesterId: _selectedSemesterId,
                  ),
                );
                if (mounted) {
                  setState(_loadCourses);
                }
              },
            ),
            const SizedBox(height: 4),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshSchedule,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      child: FutureBuilder<_ScheduleLoad>(
                        future: _scheduleFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
                            return const AppCard(child: LoadingState());
                          }
                          if (snapshot.hasError) {
                            return const AppCard(
                              child: ErrorState(message: '无法读取课表。'),
                            );
                          }
                          final data = snapshot.data;
                          final courses = data?.courses ?? const <Course>[];
                          final semester =
                              data?.semester ?? defaultSemesterTimetable;
                          final todayWeek = semester.weekForDate(now);
                          return Column(
                            children: [
                              _ScheduleControls(
                                semesters:
                                    data?.semesters ??
                                    [defaultSemesterTimetable],
                                selectedSemester: semester,
                                currentWeek: _currentWeek,
                                onSemesterChanged: _changeSemester,
                                onPreviousWeek: _currentWeek <= 1
                                    ? null
                                    : () => _changeWeek(-1),
                                onNextWeek: _currentWeek >= semester.weekCount
                                    ? null
                                    : () => _changeWeek(1),
                              ),
                              const SizedBox(height: 4),
                              Expanded(
                                child: TimetableView(
                                  courses: courses,
                                  week: _currentWeek,
                                  currentDate: now,
                                  semesterStartDate: semester.semesterStartDate,
                                  todayWeekday:
                                      semester.containsWeek(todayWeek) &&
                                          _currentWeek == todayWeek
                                      ? now.weekday
                                      : null,
                                  onDeleteCourse: _deleteCourse,
                                  onOpenCourse: (course) async {
                                    await Navigator.of(context).pushNamed(
                                      AppRoutes.scheduleAddManual,
                                      arguments: CourseDetailRouteArgs(
                                        courseId: course.id,
                                      ),
                                    );
                                    if (mounted) {
                                      setState(_loadCourses);
                                    }
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleLoad {
  const _ScheduleLoad({
    required this.semester,
    required this.semesters,
    required this.courses,
  });

  final SemesterTimetable semester;
  final List<SemesterTimetable> semesters;
  final List<Course> courses;
}

enum _CourseDeleteScope { once, all }

int _boundedWeekForDate(SemesterTimetable semester, DateTime date) {
  return semester.weekForDate(date).clamp(1, semester.weekCount).toInt();
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

class _ScheduleControls extends StatelessWidget {
  const _ScheduleControls({
    required this.semesters,
    required this.selectedSemester,
    required this.currentWeek,
    required this.onSemesterChanged,
    required this.onPreviousWeek,
    required this.onNextWeek,
  });

  final List<SemesterTimetable> semesters;
  final SemesterTimetable selectedSemester;
  final int currentWeek;
  final ValueChanged<SemesterTimetable> onSemesterChanged;
  final VoidCallback? onPreviousWeek;
  final VoidCallback? onNextWeek;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SemesterSwitcher(
            semesters: semesters,
            selectedSemester: selectedSemester,
            onChanged: onSemesterChanged,
          ),
        ),
        const SizedBox(width: 8),
        _WeekSwitcher(
          currentWeek: currentWeek,
          onPrevious: onPreviousWeek,
          onNext: onNextWeek,
        ),
      ],
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
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: '上一周',
                onPressed: onPrevious,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints.tightFor(
                  width: 32,
                  height: 32,
                ),
                icon: const Icon(Icons.chevron_left, size: 24),
              ),
              Text(
                '第 $currentWeek 周',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                tooltip: '下一周',
                onPressed: onNext,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints.tightFor(
                  width: 32,
                  height: 32,
                ),
                icon: const Icon(Icons.chevron_right, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SemesterSwitcher extends StatelessWidget {
  const _SemesterSwitcher({
    required this.semesters,
    required this.selectedSemester,
    required this.onChanged,
  });

  final List<SemesterTimetable> semesters;
  final SemesterTimetable selectedSemester;
  final ValueChanged<SemesterTimetable> onChanged;

  @override
  Widget build(BuildContext context) {
    if (semesters.isEmpty) {
      return const SizedBox.shrink();
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedSemester.id,
            isDense: true,
            isExpanded: true,
            borderRadius: BorderRadius.circular(12),
            items: [
              for (final semester in semesters)
                DropdownMenuItem(
                  value: semester.id,
                  child: Text(
                    semester.displayName,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (value) {
              final semester = semesters
                  .where((item) => item.id == value)
                  .firstOrNull;
              if (semester != null && semester.id != selectedSemester.id) {
                onChanged(semester);
              }
            },
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
      segments.addAll(_segmentsForCourse(course));
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

  List<_CourseSegment> _segmentsForCourse(Course course) {
    const segmentEnds = [4, 8, 12];
    final segments = <_CourseSegment>[];
    var start = course.startPeriod;
    for (final boundary in segmentEnds) {
      if (start > course.endPeriod) {
        break;
      }
      if (start <= boundary) {
        final end = math.min(course.endPeriod, boundary);
        segments.add(_CourseSegment(course, start, end));
        start = end + 1;
      }
    }
    return segments;
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
