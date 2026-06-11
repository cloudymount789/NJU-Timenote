import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

part 'app_database.g.dart';

// ── Sync metadata mixin ────────────────────────────────────────────

mixin SyncableFields on Table {
  TextColumn get syncStatus =>
      text().withDefault(const Constant('localOnly'))();
  IntColumn get localRevision => integer().withDefault(const Constant(1))();
  IntColumn get serverRevision => integer().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

// ── Tables ──────────────────────────────────────────────────────────

@DataClassName('CourseRow')
class CourseRows extends Table with SyncableFields {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get teacher => text()();
  TextColumn get location => text()();
  TextColumn get note => text()();
  IntColumn get dayOfWeek => integer()();
  IntColumn get startPeriod => integer()();
  IntColumn get endPeriod => integer()();
  TextColumn get weekRule => text()();
  IntColumn get startWeek => integer()();
  IntColumn get endWeek => integer()();
  TextColumn get colorKey => text()();
  TextColumn get source => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TodoRow')
class TodoRows extends Table with SyncableFields {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get content => text().withDefault(const Constant(''))();
  TextColumn get location => text().withDefault(const Constant(''))();
  TextColumn get kind => text()();
  DateTimeColumn get startAt => dateTime().nullable()();
  DateTimeColumn get endAt => dateTime().nullable()();
  DateTimeColumn get deadlineAt => dateTime().nullable()();
  RealColumn get priority => real()();
  TextColumn get repeatRule => text().withDefault(const Constant('once'))();
  TextColumn get status => text().withDefault(const Constant('open'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TagRow')
class TagRows extends Table {
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {name};
}

@DataClassName('TodoTagRow')
class TodoTagRows extends Table {
  TextColumn get todoId => text()();
  TextColumn get tagName => text()();

  @override
  Set<Column> get primaryKey => {todoId, tagName};
}

@DataClassName('SemesterSettingsRow')
class SemesterSettingsRows extends Table {
  IntColumn get id => integer()();
  DateTimeColumn get semesterStartDate => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PeriodTimeRow')
class PeriodTimeRows extends Table {
  IntColumn get period => integer()();
  TextColumn get start => text()();
  TextColumn get end => text()();

  @override
  Set<Column> get primaryKey => {period};
}

@DataClassName('SearchHistoryRow')
class SearchHistoryRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get query => text()();
  DateTimeColumn get searchedAt => dateTime()();
}

// ── Database ────────────────────────────────────────────────────────

@DriftDatabase(
  tables: [
    CourseRows,
    TodoRows,
    TagRows,
    TodoTagRows,
    SemesterSettingsRows,
    PeriodTimeRows,
    SearchHistoryRows,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor, this.seedData = false})
    : super(executor ?? _openDatabase());

  final bool seedData;

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      if (seedData) {
        await _seed(migrator);
      }
    },
  );

  static QueryExecutor _openDatabase() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      return NativeDatabase(
        File('${dir.path}${Platform.pathSeparator}nju_timenote.sqlite'),
      );
    });
  }

  Future<void> _seed(Migrator m) async {
    final now = DateTime.now().toUtc();
    final sampleTimestamp = DateTime.utc(2026, 4);

    await batch((b) {
      b.insertAll(courseRows, _sampleCourses(sampleTimestamp));
      b.insertAll(tagRows, _defaultTags(now));
      b.insertAll(periodTimeRows, _defaultPeriodTimes());
      b.insert(
        semesterSettingsRows,
        SemesterSettingsRowsCompanion.insert(
          id: const Value(1),
          semesterStartDate: DateTime.utc(2026, 9, 1),
          updatedAt: now,
        ),
      );
    });

    // Seed sample todos (must be after batch — batch doesn't handle cross-table refs well)
    await _seedTodos(now);
  }

  Future<void> _seedTodos(DateTime now) async {
    final uuid = const Uuid();
    final todos = [
      _todoSeed('课程', 'todo-${uuid.v4()}', '高等数学习题课', '完成第5-8章习题',
          '教学楼 A302', 'duration', now, 4, ['学习'],
          startAt: DateTime(now.year, now.month, now.day + 0, 18),
          endAt: DateTime(now.year, now.month, now.day + 0, 19, 30)),
      _todoSeed('待办', 'todo-${uuid.v4()}', '数据结构实验报告', '完成实验三并提交到教学网',
          '线上提交', 'deadline', now, 4.5, ['作业', '考试'],
          deadlineAt: DateTime(now.year, now.month, now.day + 0, 23, 59)),
      _todoSeed('待办', 'todo-${uuid.v4()}', '整理课堂笔记', '把今天三节课的重点整理成思维导图',
          '图书馆', 'normal', now, 3.5, ['学习', '作业']),
      _todoSeed('待办', 'todo-${uuid.v4()}', '数据结构期中复习', '复习树、图和排序',
          '图书馆', 'deadline', now, 4, ['考试'],
          deadlineAt: DateTime(now.year, now.month, now.day + 1, 23, 59)),
      _todoSeed('邮件', 'todo-${uuid.v4()}', '回复导师邮件', '确认组会时间',
          '', 'normal', now, 2, ['会议'], status: 'done'),
    ];

    for (final (id, todo, tags) in todos) {
      await into(todoRows).insert(todo);
      for (final tag in tags) {
        await into(todoTagRows).insert(
          TodoTagRowsCompanion.insert(todoId: id, tagName: tag),
        );
      }
    }
  }

  (String, TodoRowsCompanion, List<String>) _todoSeed(
    String searchTerm,
    String id,
    String title,
    String content,
    String location,
    String kind,
    DateTime now,
    double priority,
    List<String> tags, {
    DateTime? startAt,
    DateTime? endAt,
    DateTime? deadlineAt,
    String status = 'open',
  }) {
    return (
      id,
      TodoRowsCompanion.insert(
        id: id,
        title: title,
        content: Value(content),
        location: Value(location),
        kind: kind,
        startAt: Value(startAt),
        endAt: Value(endAt),
        deadlineAt: Value(deadlineAt),
        priority: priority,
        repeatRule: const Value('once'),
        status: Value(status),
        createdAt: now,
        updatedAt: now,
      ),
      tags,
    );
  }
}

// ── Seed data ──────────────────────────────────────────────────────

List<CourseRowsCompanion> _sampleCourses(DateTime ts) {
  CourseRowsCompanion c(
    String name,
    String loc,
    int day,
    int sp,
    int ep,
    String color,
  ) {
    return CourseRowsCompanion.insert(
      id: 'course-${const Uuid().v4()}',
      name: name,
      teacher: '',
      location: loc,
      note: '',
      dayOfWeek: day,
      startPeriod: sp,
      endPeriod: ep,
      weekRule: 'all',
      startWeek: 1,
      endWeek: 16,
      colorKey: color,
      source: 'sample',
      createdAt: ts,
      updatedAt: ts,
    );
  }

  return [
    c('微积分 II', '馆1-105', 1, 1, 2, 'purple'),
    c('离散数学', '馆2-302', 1, 3, 4, 'purple'),
    c('编译原理', '馆1-210', 1, 7, 8, 'purple'),
    c('数字逻辑', 'B503', 2, 3, 4, 'blue'),
    c('数据结构', '机房A', 3, 5, 6, 'pink'),
    c('高级编程', '教学楼③', 3, 3, 4, 'pink'),
    c('数据库', '教学楼②', 3, 7, 8, 'pink'),
    c('思修', '大教202', 4, 10, 11, 'pink'),
    c('线性代数', '逸C-101', 4, 3, 4, 'blue'),
    c('操作系统', '计科楼', 4, 5, 6, 'purple'),
    c('大学英语', '外院201', 5, 1, 2, 'pink'),
    c('计算机网络', 'B202', 5, 5, 7, 'blue'),
  ];
}

List<TagRowsCompanion> _defaultTags(DateTime now) {
  return ['考试', '作业', '讲座', '会议', '生活', '学习'].map(
    (name) => TagRowsCompanion.insert(name: name, createdAt: now),
  ).toList();
}

List<PeriodTimeRowsCompanion> _defaultPeriodTimes() {
  const periods = [
    (1, '08:00', '08:50'),
    (2, '09:00', '09:50'),
    (3, '10:10', '11:00'),
    (4, '11:10', '12:00'),
    (5, '14:00', '14:50'),
    (6, '15:00', '15:50'),
    (7, '16:10', '17:00'),
    (8, '17:10', '18:00'),
    (9, '18:30', '19:20'),
    (10, '19:30', '20:20'),
    (11, '20:30', '21:20'),
    (12, '21:30', '22:20'),
  ];
  return periods.map(
    (p) => PeriodTimeRowsCompanion.insert(
      period: Value(p.$1),
      start: p.$2,
      end: p.$3,
    ),
  ).toList();
}
