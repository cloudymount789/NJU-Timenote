import '../models/settings.dart';

abstract class SettingsRepository {
  Future<SemesterSettings> getSemesterSettings();
  Future<SemesterTimetable> addSemesterTimetable({
    DateTime? startDate,
    int weekCount = 16,
  });
  Future<void> updateSemesterTimetable(SemesterTimetable semester);
  Future<void> setLastSelectedSemesterId(String semesterId);
}
