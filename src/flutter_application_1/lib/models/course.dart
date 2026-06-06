import 'package:flutter/material.dart';

enum WeekRule { all, odd, even }

enum CourseSource { manual, screenshot, sample }

class PeriodRange {
  const PeriodRange({
    required this.dayOfWeek,
    required this.startPeriod,
    required this.endPeriod,
  });

  final int dayOfWeek;
  final int startPeriod;
  final int endPeriod;

  String get label =>
      '${weekdayLabels[dayOfWeek - 1]} 第 $startPeriod-$endPeriod 节';

  static const weekdayLabels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
}

class Course {
  const Course({
    required this.id,
    required this.name,
    required this.teacher,
    required this.location,
    required this.note,
    required this.dayOfWeek,
    required this.startPeriod,
    required this.endPeriod,
    required this.weekRule,
    required this.startWeek,
    required this.endWeek,
    required this.colorKey,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String teacher;
  final String location;
  final String note;
  final int dayOfWeek;
  final int startPeriod;
  final int endPeriod;
  final WeekRule weekRule;
  final int startWeek;
  final int endWeek;
  final String colorKey;
  final CourseSource source;
  final DateTime createdAt;
  final DateTime updatedAt;

  PeriodRange get periodRange => PeriodRange(
    dayOfWeek: dayOfWeek,
    startPeriod: startPeriod,
    endPeriod: endPeriod,
  );

  bool occursInWeek(int week) {
    if (week < startWeek || week > endWeek) {
      return false;
    }
    return switch (weekRule) {
      WeekRule.all => true,
      WeekRule.odd => week.isOdd,
      WeekRule.even => week.isEven,
    };
  }

  Course copyWith({
    String? id,
    String? name,
    String? teacher,
    String? location,
    String? note,
    int? dayOfWeek,
    int? startPeriod,
    int? endPeriod,
    WeekRule? weekRule,
    int? startWeek,
    int? endWeek,
    String? colorKey,
    CourseSource? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      teacher: teacher ?? this.teacher,
      location: location ?? this.location,
      note: note ?? this.note,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startPeriod: startPeriod ?? this.startPeriod,
      endPeriod: endPeriod ?? this.endPeriod,
      weekRule: weekRule ?? this.weekRule,
      startWeek: startWeek ?? this.startWeek,
      endWeek: endWeek ?? this.endWeek,
      colorKey: colorKey ?? this.colorKey,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CourseDraft {
  const CourseDraft({
    required this.name,
    required this.teacher,
    required this.location,
    required this.note,
    required this.dayOfWeek,
    required this.startPeriod,
    required this.endPeriod,
    required this.weekRule,
    required this.startWeek,
    required this.endWeek,
    this.source = CourseSource.manual,
  });

  final String name;
  final String teacher;
  final String location;
  final String note;
  final int dayOfWeek;
  final int startPeriod;
  final int endPeriod;
  final WeekRule weekRule;
  final int startWeek;
  final int endWeek;
  final CourseSource source;
}

String weekRuleLabel(WeekRule rule) {
  return switch (rule) {
    WeekRule.all => '全部',
    WeekRule.odd => '单周',
    WeekRule.even => '双周',
  };
}

Color courseColor(String colorKey) {
  return switch (colorKey) {
    'blue' => const Color(0xFFDCEBFF),
    'purple' => const Color(0xFFE9E1FF),
    'pink' => const Color(0xFFFCE5F0),
    'indigo' => const Color(0xFFE0E7FF),
    _ => const Color(0xFFE5F0FF),
  };
}
