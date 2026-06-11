import '../../models/settings.dart';

class LocalSettingsSource {
  Future<SemesterSettings> getSemesterSettings() async {
    return SemesterSettings(
      semesterStartDate: DateTime(2026, 9),
      periods: const [],
    );
  }
}
