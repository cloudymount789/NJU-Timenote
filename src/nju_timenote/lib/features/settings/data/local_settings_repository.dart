import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/database/app_database.dart';
import '../models/settings.dart';
import '../repositories/settings_repository.dart';

class LocalSettingsRepository implements SettingsRepository {
  LocalSettingsRepository(this._db);

  final AppDatabase _db;

  @override
  Future<SemesterSettings> fetchSemesterSettings() async {
    final settingRow = await (_db.select(_db.semesterSettingsRows)
      ..where((r) => r.id.equals(1))).getSingleOrNull();

    final periodRows = await _db.select(_db.periodTimeRows).get();

    final periods = periodRows.isNotEmpty
        ? periodRows
            .map(
              (r) => PeriodTime(period: r.period, start: r.start, end: r.end),
            )
            .toList()
        : _defaultPeriods;

    return SemesterSettings(
      semesterStartDate:
          settingRow?.semesterStartDate ?? DateTime.utc(2026, 9, 1),
      periods: periods,
    );
  }

  @override
  Future<void> updatePeriodTimes(List<PeriodTime> periods) async {
    await _db.transaction(() async {
      await _db.delete(_db.periodTimeRows).go();
      for (final p in periods) {
        await _db.into(_db.periodTimeRows).insert(
          PeriodTimeRowsCompanion.insert(
            period: Value(p.period),
            start: p.start,
            end: p.end,
          ),
        );
      }
    });
  }

  @override
  Future<void> updateSemesterStartDate(DateTime date) async {
    await _db.into(_db.semesterSettingsRows).insertOnConflictUpdate(
      SemesterSettingsRowsCompanion.insert(
        id: const Value(1),
        semesterStartDate: date,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }

  @override
  Future<String> backup() async {
    final dir = await getApplicationDocumentsDirectory();
    final src = File('$dir${Platform.pathSeparator}nju_timenote.sqlite');
    if (!await src.exists()) {
      throw StateError('数据库文件不存在');
    }
    final downloads = Platform.isWindows
        ? '${Platform.environment['USERPROFILE']}\\Downloads'
        : dir.path;
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '')
        .replaceAll('-', '')
        .substring(0, 15);
    final dst = File(
      '$downloads${Platform.pathSeparator}nju_timenote_backup_$timestamp.sqlite',
    );
    await src.copy(dst.path);
    return dst.path;
  }

  @override
  Future<void> exportData() async {
    // TODO: export data for sharing
  }
}

const _defaultPeriods = [
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
