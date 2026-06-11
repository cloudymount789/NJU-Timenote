import '../models/settings.dart';

abstract class SettingsRepository {
  Future<SemesterSettings> getSemesterSettings();
}
