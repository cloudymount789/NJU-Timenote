import '../models/settings.dart';

abstract class SettingsRepository {
  Future<SemesterSettings> getSemesterSettings();
  Future<SemesterTimetable> addSemesterTimetable({
    DateTime? startDate,
    int weekCount = 16,
    String? schoolYear,
    SemesterTermType? termType,
  });
  Future<SemesterTimetable> saveSemesterTimetable(SemesterTimetable semester);
  Future<void> updateSemesterTimetable(SemesterTimetable semester);
  Future<void> deleteSemesterTimetable(String semesterId);
  Future<void> setLastSelectedSemesterId(String semesterId);
}
