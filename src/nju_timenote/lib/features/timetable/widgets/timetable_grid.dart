import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../settings/models/settings.dart';
import '../models/course.dart';

class TimetableGrid extends StatelessWidget {
  const TimetableGrid({
    required this.courses,
    required this.periods,
    required this.onCourseLongPress,
    super.key,
  });

  final List<Course> courses;
  final List<PeriodTime> periods;
  final ValueChanged<Course> onCourseLongPress;

  static const _timeColumnWidth = 46.0;
  static const _headerHeight = 58.0;
  static const _periodHeight = 58.0;

  @override
  Widget build(BuildContext context) {
    final shownPeriods = periods.take(12).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final gridWidth = constraints.maxWidth;
        final dayWidth = (gridWidth - _timeColumnWidth) / 7;
        final height = _headerHeight + shownPeriods.length * _periodHeight;
        final placements = _placements(dayWidth);

        return SizedBox(
          width: gridWidth,
          height: height,
          child: Stack(
            children: [
              _GridBackground(periods: shownPeriods),
              Positioned.fill(
                top: _headerHeight,
                left: _timeColumnWidth,
                child: CustomPaint(
                  painter: _GridLinePainter(periodCount: shownPeriods.length),
                ),
              ),
              ...placements.map(
                (placement) => Positioned(
                  left:
                      _timeColumnWidth +
                      (placement.course.dayOfWeek - 1) * dayWidth +
                      2 +
                      placement.laneOffset,
                  top:
                      _headerHeight +
                      (placement.course.startPeriod - 1) * _periodHeight +
                      3,
                  width: dayWidth / placement.laneCount - 4,
                  height:
                      (placement.course.endPeriod -
                              placement.course.startPeriod +
                              1) *
                          _periodHeight -
                      6,
                  child: _CourseBlock(
                    course: placement.course,
                    onLongPress: () => onCourseLongPress(placement.course),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<_CoursePlacement> _placements(double dayWidth) {
    final placements = <_CoursePlacement>[];
    for (var day = 1; day <= 7; day++) {
      final dayCourses =
          courses.where((course) => course.dayOfWeek == day).toList()
            ..sort((a, b) => a.startPeriod.compareTo(b.startPeriod));
      for (final course in dayCourses) {
        final conflicts = dayCourses.where((other) {
          return other.startPeriod <= course.endPeriod &&
              other.endPeriod >= course.startPeriod;
        }).toList();
        final laneIndex = conflicts.indexWhere(
          (other) => other.id == course.id,
        );
        final laneCount = conflicts.length;
        placements.add(
          _CoursePlacement(
            course: course,
            laneCount: laneCount,
            laneOffset: (dayWidth / laneCount) * laneIndex,
          ),
        );
      }
    }
    return placements;
  }
}

Color _courseColor(String colorKey) {
  return switch (colorKey) {
    'blue' => const Color(0xFFDCEBFF),
    'purple' => const Color(0xFFE9E1FF),
    'pink' => const Color(0xFFFCE5F0),
    'indigo' => const Color(0xFFE0E7FF),
    _ => const Color(0xFFE5F0FF),
  };
}

class _CoursePlacement {
  const _CoursePlacement({
    required this.course,
    required this.laneCount,
    required this.laneOffset,
  });

  final Course course;
  final int laneCount;
  final double laneOffset;
}

class _GridBackground extends StatelessWidget {
  const _GridBackground({required this.periods});

  final List<PeriodTime> periods;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: TimetableGrid._headerHeight,
          child: Row(
            children: [
              const SizedBox(
                width: TimetableGrid._timeColumnWidth,
                child: Padding(
                  padding: EdgeInsets.only(left: 4, top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '4月',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '第6周',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              for (final day in const [
                ('周一', '04/06'),
                ('周二', '04/07'),
                ('周三', '04/08'),
                ('周四', '04/09'),
                ('周五', '04/10'),
                ('周六', '04/11'),
                ('周日', '04/12'),
              ])
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 1,
                      vertical: 5,
                    ),
                    decoration: day.$2 == '04/09'
                        ? BoxDecoration(
                            border: Border.all(
                              color: AppColors.accent,
                              width: 1.4,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          )
                        : null,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            day.$1,
                            style: const TextStyle(
                              fontSize: 10,
                              height: 1.05,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            day.$2,
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.05,
                              fontWeight: FontWeight.w700,
                              color: day.$2 == '04/09'
                                  ? AppColors.accent
                                  : AppColors.textPrimary,
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
        for (final period in periods)
          SizedBox(
            height: TimetableGrid._periodHeight,
            child: Row(
              children: [
                SizedBox(
                  width: TimetableGrid._timeColumnWidth,
                  child: FittedBox(
                    alignment: Alignment.topLeft,
                    fit: BoxFit.scaleDown,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${period.period}',
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.05,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          period.start,
                          style: const TextStyle(
                            fontSize: 8,
                            height: 1.05,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          period.end,
                          style: const TextStyle(
                            fontSize: 8,
                            height: 1.05,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
      ],
    );
  }
}

class _GridLinePainter extends CustomPainter {
  const _GridLinePainter({required this.periodCount});

  final int periodCount;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 0.7;
    final dayWidth = size.width / 7;
    for (var i = 0; i <= 7; i++) {
      final x = i * dayWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var i = 0; i <= periodCount; i++) {
      final y = i * TimetableGrid._periodHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridLinePainter oldDelegate) {
    return oldDelegate.periodCount != periodCount;
  }
}

class _CourseBlock extends StatelessWidget {
  const _CourseBlock({required this.course, required this.onLongPress});

  final Course course;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _courseColor(course.colorKey),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onLongPress: onLongPress,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 12) {
              return const SizedBox.expand();
            }
            return Padding(
              padding: const EdgeInsets.all(5),
              child: ClipRect(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        course.name,
                        maxLines: constraints.maxHeight > 50 ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          height: 1.05,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (constraints.maxHeight > 38) ...[
                      const SizedBox(height: 2),
                      Text(
                        course.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9,
                          height: 1.05,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
