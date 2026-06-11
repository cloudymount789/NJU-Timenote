import '../models/settings.dart';

abstract class SettingsRepository {
  Future<SemesterSettings> fetchSemesterSettings();
  Future<void> updatePeriodTimes(List<PeriodTime> periods);
  Future<void> updateSemesterStartDate(DateTime date);
  Future<String> backup();
  Future<void> exportData();
}

class MockSettingsRepository implements SettingsRepository {
  @override
  Future<SemesterSettings> fetchSemesterSettings() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return SemesterSettings(
      semesterStartDate: DateTime(2026, 9, 1),
      periods: const [
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
      ],
    );
  }

  @override
  Future<void> updatePeriodTimes(List<PeriodTime> periods) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
  }

  @override
  Future<void> updateSemesterStartDate(DateTime date) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
  }

  @override
  Future<String> backup() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return '/mock/backup/path';
  }

  @override
  Future<void> exportData() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
  }
}
